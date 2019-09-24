local server_helper = require("eva.modules.server.server_helper")
local log = require("eva.log")

local logger = log.get_logger("eva.server")

local M = {}


-- local function on_save_collision(response)
-- end


function M.login(callback)
	if not M.settings.is_enabled then
		logger:debug("The server is disabled")
		return
	end

	logger:debug("Start connection to PlayFab server")
	server_helper.setup_playfab()
end


function M.send_save(json_data)

end


function M.before_game_start(settings)
	M.settings = settings
end


return M
