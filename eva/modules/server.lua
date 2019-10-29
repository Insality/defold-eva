--- Eva server module
-- Take all fucntions on client-server communication
-- @submodule eva


local app = require("eva.app")
local log = require("eva.log")
local server_helper = require("eva.modules.server.server_helper")

local logger = log.get_logger("eva.server")

local M = {}


--- Login at playfab server
-- @function eva.server.login
-- @tparam function callback Callback after login
function M.login(callback)
	local settings = app.settings.server
	if not settings.is_enabled then
		logger:debug("The server is disabled")
		return
	end

	logger:debug("Start connection to PlayFab server")
	server_helper.setup_playfab()
end


--- Send save to the server
-- @function eva.server.send_save
-- @tparam string json_data JSON data
function M.send_save(json_data)

end


return M
