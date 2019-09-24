local log = require("eva.log")
local luax = require("eva.luax")

local logger = log.get_logger("eva.errors")

local M = {}


local errors_sended = {}
local send_traceback = function(message, traceback)
	local is_sended = luax.table.contains(errors_sended, message)

	if not is_sended then
		local info = sys.get_sys_info()

		traceback = string.gsub(traceback, "\n", " ")
		traceback = string.gsub(traceback, "\t", " ")
		logger:fatal("Error in lua module", {
			error_message = message,
			traceback = traceback,
			version = sys.get_config("project.version"),
			id = M.eva.device.get_id(),
			sys_name = info.system_name,
			sys_version = info.system_version,
			model = info.device_model,
			manufacturer = info.manufacturer
		})
		table.insert(errors_sended, message)
	end
end


function M.on_game_start()
	if M._eva.game.is_debug() then
		return
	end

	sys.set_error_handler(function(source, message, traceback)
		send_traceback(message, traceback)
	end)
end


return M
