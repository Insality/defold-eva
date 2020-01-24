--- Eva database module.
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


--- Return config by config_name
-- @function eva.db.get
-- @tparam string config_name Config name from eva settings
-- @treturn table Config table
function M.get(config_name)
	assert(config_name, "You should provide the config name")
	return app._db[config_name]
end


function M.before_eva_init()
	local settings = app.settings.db
	app._db = {}
	local paths = settings.paths

	for name, path in pairs(paths) do
		logger:debug("Load JSON data", { name = name, path = path })
		app._db[name] = utils.load_json(path)
	end
end


return M
