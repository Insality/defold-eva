--- Eva game module
-- Contains basic game functions
-- Like exit, reboot, open url etc
-- @submodule eva


local app = require("eva.app")
local const = require("eva.const")
local gui_extra_functions = require "gui_extra_functions.gui_extra_functions"
local time_string = require("eva.libs.time_string")

local proto = require("eva.modules.proto")
local saver = require("eva.modules.saver")


local device = require("eva.modules.device")


local M = {}


local function select_url(url_ios, url_android)
	local android_id = sys.get_config("android.package") or ""
	local ios_id = sys.get_config("ios.id") or ""

	local is_ios = device.is_ios()
	local url_source = "game"
	local market_url = is_ios and url_ios or url_android

	return string.format(market_url, is_ios and ios_id or android_id, url_source)
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
function M.reboot(delay)
	delay = delay or 0

	sound.stop_all()
	timer.delay(delay, false, function()
		msg.post("@system:", "reboot")
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
	return socket.gettime()
end


--- Get current time in string format
-- @function eva.game.get_current_time_string
-- @treturn string Time format in iso e.g. "2019-09-25T01:48:19Z"
function M.get_current_time_string()
	return time_string.get_ISO(M.get_time())
end


function M.on_eva_init()
	math.randomseed(os.time())
	math.random()

	if device.is_mobile() then
		window.set_dim_mode(window.DIMMING_OFF)
	end

	gui_extra_functions.init()

	app[const.EVA.GAME] = proto.get(const.EVA.GAME)
	saver.add_save_part(const.EVA.GAME, app[const.EVA.GAME])
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
	app[const.EVA.GAME].game_time = app[const.EVA.GAME].game_time + dt
end


return M
