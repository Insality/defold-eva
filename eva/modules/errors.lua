--- Eva error module.
-- Handle and store all lua errors in the game
-- Can send error to the server, pointed in eva
-- settings.json
-- @submodule eva


local app = require("eva.app")
local log = require("eva.log")
local luax = require("eva.luax")

local game = require("eva.modules.game")
local device = require("eva.modules.device")

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
			id = device.get_device_id(),
			sys_name = info.system_name,
			sys_version = info.system_version,
			model = info.device_model,
			manufacturer = info.manufacturer
		})
		table.insert(errors_sended, message)
	end
end


local function check_crash()
	local crash_previous = crash.load_previous()
    if crash_previous == nil then
        print("No crash dump found")
        return
	end

    print("Crash [" .. crash.get_sys_field(crash_previous, crash.SYSFIELD_ENGINE_VERSION) .. "] [" .. crash.get_sys_field(crash_previous, crash.SYSFIELD_ENGINE_HASH) .. "]")
    print("Signum [" .. crash.get_signum(crash_previous) .. "]")
    print("Userdata0 = [" .. crash.get_user_field(crash_previous, 0) .. "]")
    print("Pretty Backtrace:\n" .. crash.get_extra_data(crash_previous))

    crash.release(crash_previous)
end


function M.before_eva_init()
	check_crash()
end


function M.on_eva_init()
	app.errors_sended = {}

	if game.is_debug() and not device.is_web() then
		return
	end

	sys.set_error_handler(function(source, message, traceback)
		send_traceback(message, traceback)
	end)
end


return M
