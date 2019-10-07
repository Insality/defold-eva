--- Eva game module
-- Contains basic game functions
-- Like exit, reboot, open url etc
-- @submodule eva


local const = require("eva.const")
local uuid = require("eva.libs.uuid")
local gui_extra_functions = require "gui_extra_functions.gui_extra_functions"
local iso_format = require("eva.libs.iso_format")

local M = {}


local function select_url(url_ios, url_android)
	local android_id = sys.get_config("android.package") or ""
	local ios_id = sys.get_config("ios.id") or ""

	local is_ios = M._eva.device.is_ios()
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

	M._eva.sound.stop_all()
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
	return iso_format.get_time(M.get_time())
end


--- Generate uuid
-- @function eva.game.get_uuid
-- @treturn string the uuid
function M.get_uuid()
	return uuid()
end


function M.on_game_start()
	math.randomseed(os.time())
	math.random()
	uuid.randomseed(socket.gettime() * 10000)

	if M._eva.device.is_mobile() then
		window.set_dim_mode(window.DIMMING_OFF)
	end

	gui_extra_functions.init()
end


return M
