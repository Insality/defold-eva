local log = require("eva.log")

local logger = log.get_logger("eva.db")

local M = {}


function M.before_game_start()
	local settings = M._eva.app.settings.db
	M._eva.app.db_data = {}
	local paths = settings.paths

	for name, path in pairs(paths) do
		logger:debug("Load JSON data", { name = name, path = path })
		M._eva.app.db_data[name] = M._eva.utils.load_json(path)
	end
end


return M
