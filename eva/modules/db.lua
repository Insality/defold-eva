local log = require("eva.log")

local logger = log.get_logger("eva.db")

local M = {}

-- Place to store all JSON data
M.data = {}

function M.before_game_start(settings)
	M.data = {}
	local paths = settings.paths

	for name, path in pairs(paths) do
		logger:debug("Load JSON data", { name = name, path = path })
		M.data[name] = M._eva.utils.load_json(path)
	end
end


return M
