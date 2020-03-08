--- Eva database module.
-- It carry for loading all jsons from
-- game configs, pointed in eva settings.json.
-- You need to point name of config and his path in
-- game eva settings.
-- @submodule eva


local app = require("eva.app")
local log = require("eva.log")

local utils = require("eva.modules.utils")
local proto = require("eva.modules.proto")

local logger = log.get_logger("eva.db")

local M = {}


--- Return config by config_name
-- @function eva.db.get
-- @tparam string config_name Config name from eva settings
-- @treturn table Config table
function M.get(config_name)
	assert(config_name, "You should provide the config name")

	if app._db_custom then
		local custom = app._db_custom[config_name]
		if custom then
			return custom
		end
	end

	local data = app._db[config_name]
	if not data then
		logger:error("The database config is not exist", { name = config_name })
	end

	return data
end


--- Can override db with custom tables (useful for tests)
-- @function eva.db.set_settings
-- @tparam table settings Custom db settings
function M.set_settings(settings)
	app._db_custom = settings
end



function M.check_config(config_name, proto_name)
	if app._db[config_name] then
		app._db[config_name] = proto.verify(proto_name, app._db[config_name])
	end

	if app._db_custom[config_name] then
		app._db_custom[config_name] = proto.verify(proto_name, app._db_custom[config_name])
	end
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
