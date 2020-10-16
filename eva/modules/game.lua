--- Eva game module
-- Contains basic game functions
-- Like exit, reboot, open url etc
-- time_policy:
-- 	- local - just socket.gettime
-- 	- local_uptime - try to protect time with uptime
-- 	- server - use server time
-- @submodule eva


local log = require("eva.log")
local app = require("eva.app")
local const = require("eva.const")
local gui_extra_functions = require "gui_extra_functions.gui_extra_functions"
local time_string = require("eva.libs.time_string")

local proto = require("eva.modules.proto")
local sound = require("eva.modules.sound")
local saver = require("eva.modules.saver")
local events = require("eva.modules.events")
local device = require("eva.modules.device")

local logger = log.get_logger("eva.game")

local M = {}


-- How to update the game time. See module description
local TIME_LOCAL = "local"
local TIME_LOCAL_UPTIME = "local_uptime"
local TIME_SERVER = "server"


local function sync_time()
	local settings = app.settings.game
	local game_save = app[const.EVA.GAME]

	if settings.time_policy == TIME_LOCAL_UPTIME then
		local current_uptime = socket.gettime()
		if uptime then
			current_uptime = uptime.get()
		end

		if current_uptime < game_save.last_uptime or game_save.last_uptime == 0 then
			game_save.last_diff_time = socket.gettime() - current_uptime

			local prev_uptime = game_save.last_uptime
			game_save.last_uptime = current_uptime

			logger:debug("Sync time with uptime", {
				time = game_save.last_uptime,
				diff = game_save.last_diff_time,
				prev_time = prev_uptime
			})
		end

		app.game_data.current_time = current_uptime + game_save.last_diff_time
	end
end


local function select_url(url_ios, url_android)
	local android_id = sys.get_config("android.package") or ""
	local ios_id = sys.get_config("ios.id") or ""

	local is_ios = device.is_ios()
	local url_source = "game"
	local market_url = is_ios and url_ios or url_android

	return string.format(market_url, is_ios and ios_id or android_id, url_source)
end


local function check_session()
	local game = app[const.EVA.GAME]
	local current_time = M.get_time()

	if current_time - game.last_play_timepoint >= app.settings.game.session_time then
		game.session_start_time = current_time
		events.event(const.EVENT.NEW_SESSION)
	end

	local current_date = M.get_current_date_code()
	if game.last_play_date ~= current_date then
		game.last_play_date = current_date
		events.event(const.EVENT.NEW_DAY)
	end
end


local function on_window_event(self, event, data)
	events.event(const.EVENT.WINDOW_EVENT, { event = event, data = data })
	if event == window.WINDOW_EVENT_FOCUS_GAINED then
		sync_time()
		check_session()
		events.event(const.EVENT.GAME_FOCUS)
	end
end


--- Open store page in store application
-- @function eva.game.open_store_page
function M.open_store_page()
	local market_url = select_url(const.STORE_URL.IOS_MARKET, const.STORE_URL.ANDROID_MARKET)
	local success = sys.open_url(market_url)
		if not success then
		local direct_url = select_url(const.STORE_URL.IOS_MARKET, const.STORE_URL.ANDROID_URL)
		sys.open_url(direct_url)
	end
end


--- Reboot the game
-- @function eva.game.reboot
-- @tparam number delay Delay before reboot, in seconds
function M.reboot(delay, arg1, arg2)
	delay = delay or 0

	sound.stop_all()
	timer.delay(delay, false, function()
		msg.post("@system:", "reboot", { arg1 = arg1, arg2 = arg2 })
	end)
end


--- Exit from the game
-- @function eva.game.exit
-- @tparam int code The exit code
function M.exit(code)
	code = code or 0
	msg.post("@system:", "exit", { code = code })
end


--- Check game on debug mode
-- @function eva.game.is_debug
function M.is_debug()
	if app.game_data then
		return app.game_data.is_debug
	end

	return sys.get_engine_info().is_debug
end


--- Get game time
-- @function eva.game.get_time
-- @treturn number Return game time in seconds
function M.get_time()
	local settings = app.settings.game

	if settings.time_policy == TIME_LOCAL then
		return socket.gettime()
	end

	if settings.time_policy == TIME_LOCAL_UPTIME then
		return app.game_data.current_time
	end

	logger:error("Unknown game time_policy type", { policy = settings.time_policy })
	return socket.gettime()
end


--- Return unique id for local session
-- @function eva.game.get_session_uid
-- @treturn number Unique id in this game session
function M.get_session_uid()
	app.game_data.last_uid = app.game_data.last_uid + 1
	return app.game_data.last_uid
end


--- Return unique id for player profile
-- @function eva.game.get_uid
-- @treturn number Unique id in player profile
function M.get_uid()
	app[const.EVA.GAME].game_uid = app[const.EVA.GAME].game_uid + 1
	return app[const.EVA.GAME].game_uid
end


--- Get current time in string format
-- @function eva.game.get_current_time_string
-- @treturn string Time format in iso e.g. "2019-09-25T01:48:19Z"
function M.get_current_time_string(time)
	return time_string.get_ISO(time or M.get_time())
end


--- Get current date in format: YYYYMMDD
-- @function ev.game.get_current_day_string
-- @treturn number Current day in format YYYYMMDD
function M.get_current_date_code(date)
	date = date or os.date("*t", M.get_time())
	return date.year * 10000 + date.month * 100 + date.day
end


--- Get days since first game launch
-- @function eva.game.get_days_played
-- @treturn number Days since first game launch
function M.get_days_played()
	local first_time = app[const.EVA.GAME].first_start_time
	local play_time = M.get_time() - first_time

	return math.floor(play_time / (60 * 60 * 24))
end


--- Return true, if game launched first time
-- @function eva.game.is_first_launch
-- @treturn bool True, if game first time launch
function M.is_first_launch()
	return app[const.EVA.GAME].game_start_count == 1
end


function M.on_eva_init()
	math.randomseed(os.time())
	math.random()

	app.game_data = {
		last_uid = 0,
		current_time = 0,
		is_debug = sys.get_engine_info().is_debug
	}

	if device.is_mobile() then
		-- TODO: Make custom Dimming timing for specific time?
		window.set_dim_mode(window.DIMMING_OFF)
	end

	gui_extra_functions.init()

	app[const.EVA.GAME] = proto.get(const.EVA.GAME)
	saver.add_save_part(const.EVA.GAME, app[const.EVA.GAME])
	sync_time()
end


function M.after_eva_init()
	local settings = app.settings.game
	local game = app[const.EVA.GAME]
	game.game_start_count = game.game_start_count + 1

	table.insert(game.game_start_dates, M.get_current_time_string())
	while #game.game_start_dates > settings.game_started_max_count_stats do
		table.remove(game.game_start_dates, 1)
	end

	if game.first_start_time == 0 then
		game.first_start_time = M.get_time()
	end
	if game.last_play_date == 0 then
		game.last_play_date = M.get_current_date_code()
	end

	check_session()
	window.set_listener(on_window_event)
end


function M.on_eva_update(dt)
	app.game_data.current_time = app.game_data.current_time + dt
	app[const.EVA.GAME].played_time = app[const.EVA.GAME].played_time + dt
	app[const.EVA.GAME].last_play_timepoint = M.get_time()
end


return M
