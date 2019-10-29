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
local luax = require("eva.luax")
local const = require("eva.const")
local gui_extra_functions = require "gui_extra_functions.gui_extra_functions"
local time_string = require("eva.libs.time_string")

local proto = require("eva.modules.proto")
local sound = require("eva.modules.sound")
local saver = require("eva.modules.saver")
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


local function on_window_event(self, event, data)
	if luax.math.is(event, window.WINDOW_EVENT_FOCUS_GAINED, window.WINDOW_EVENT_RESIZED) then
		sync_time()
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
		msg.post("@system:", "reboot", {arg1 = arg1, arg2 = arg2})
	end)
end


--- Exit from the game
-- @function eva.game.exit
-- @tparam int code The exit code
function M.exit(code)
	code = code or 0
	msg.post("@system:", "exit", {code = code})
end


--- Check game on debug mode
-- @function eva.game.is_debug
function M.is_debug()
	return sys.get_engine_info().is_debug
end


--- Get game time
-- @function eva.game.get_time
-- @treturn number return game time in seconds
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


--- Get current time in string format
-- @function eva.game.get_current_time_string
-- @treturn string Time format in iso e.g. "2019-09-25T01:48:19Z"
function M.get_current_time_string(time)
	return time_string.get_ISO(time or M.get_time())
end


function M.on_eva_init()
	math.randomseed(os.time())
	math.random()

	app.game_data = {
		current_time = 0
	}
	if device.is_mobile() then
		window.set_dim_mode(window.DIMMING_OFF)
	end

	gui_extra_functions.init()

	app[const.EVA.GAME] = proto.get(const.EVA.GAME)
	saver.add_save_part(const.EVA.GAME, app[const.EVA.GAME])
	sync_time()

	window.set_listener(on_window_event)
end


function M.after_eva_init()
	local settings = app.settings.game
	local game = app[const.EVA.GAME]
	game.game_start_count = game.game_start_count + 1

	table.insert(game.game_start_dates, M.get_current_time_string())
	while #game.game_start_dates > settings.game_started_max_count_stats do
		table.remove(game.game_start_dates, 1)
	end
end


function M.on_eva_update(dt)
	app.game_data.current_time = app.game_data.current_time + dt
	app[const.EVA.GAME].played_time = app[const.EVA.GAME].played_time + dt
end


return M
