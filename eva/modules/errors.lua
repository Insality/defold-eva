local luax = require("eva.luax")
local log = require("eva.log")

local logger = log.get_logger()

local M = {}


local errors_sended = {}
local send_traceback = function(message, traceback)
	local is_sended = luax.table.contains(errors_sended, message)

	if not is_sended then
		local sinfo = sys.get_sys_info()

		traceback = string.gsub(traceback, "\n", " ")
		traceback = string.gsub(traceback, "\t", " ")
		logger:with_context({
			error_message = message,
			traceback = traceback,
			version = sys.get_config("project.version"),
			id = M.eva.device.get_id(),
			sys_name = sinfo.system_name,
			sys_version = sinfo.system_version,
			model = sinfo.device_model,
			manufacturer = sinfo.manufacturer
		}):fatal("Error in lua module")
		table.insert(errors_sended, message)
	end
end


function M.apply_error_handler()
	if sys.get_engine_info().is_debug then
		return
	end

	sys.set_error_handler(function(source, message, traceback)
		send_traceback(message, traceback)
	end)
end

return M
