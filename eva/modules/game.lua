local uuid = require("eva.libs.uuid")
local gui_extra_functions = require "gui_extra_functions.gui_extra_functions"
local iso_parser = require("eva.libs.iso_parser")

local M = {}


function M.reboot(delay)
	delay = delay or 0

	M._eva.sound.stol_all()
	timer.delay(delay, false, function()
		msg.post("@system:", "reboot")
	end)
end


function M.exit(code)
	code = code or 0
	msg.post("@system:", "exit", {code = code})
end


function M.is_debug()
	return sys.get_engine_info().is_debug
end


function M.get_time()
	return socket.gettime()
end


function M.get_current_time_string()
	return iso_parser.get_time(M.get_time())
end


function M.on_game_start()
	math.randomseed(os.time())
	math.random()
	uuid.randomseed(socket.gettime() * 10000)

	window.set_dim_mode(window.DIMMING_OFF)

	gui_extra_functions.init()
end


return M
