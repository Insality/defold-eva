--- Defold db module
-- It carry for loading all jsons from
-- game configs, pointed in eva settings.json.
-- You need to point name of config and his path in
-- game eva settings.
-- @submodule eva


local app = require("eva.app")
local log = require("eva.log")

local utils = require("eva.modules.utils")


local logger = log.get_logger("eva.db")

local M = {}


function M.before_eva_init()
	local settings = app.settings.db
	app.db = {}
	local paths = settings.paths

	for name, path in pairs(paths) do
		logger:debug("Load JSON data", { name = name, path = path })
		app.db[name] = utils.load_json(path)
	end
end


return M
