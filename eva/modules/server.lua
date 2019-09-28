local server_helper = require("eva.modules.server.server_helper")
local log = require("eva.log")

local logger = log.get_logger("eva.server")

local M = {}


function M.login(callback)
	local settings = M._eva.app.settings.server
	if not settings.is_enabled then
		logger:debug("The server is disabled")
		return
	end

	logger:debug("Start connection to PlayFab server")
	server_helper.setup_playfab()
end


function M.send_save(json_data)

end


return M
