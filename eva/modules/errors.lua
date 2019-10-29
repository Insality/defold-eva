--- Eva error module.
-- Handle and store all lua errors in the game
-- Can send error to the server, pointed in eva
-- settings.json
-- @submodule eva


local app = require("eva.app")
local log = require("eva.log")
local luax = require("eva.luax")

local game = require("eva.modules.game")

local logger = log.get_logger("eva.errors")

local M = {}


local send_traceback = function(message, traceback)
	local errors_sended = app.errors_sended
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


function M.on_eva_init()
	app.errors_sended = {}

	if game.is_debug() then
		return
	end

	sys.set_error_handler(function(source, message, traceback)
		send_traceback(message, traceback)
	end)
end


return M
