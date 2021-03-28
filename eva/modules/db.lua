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


local function verify(config_name, data)
	local settings = app.settings.db

	if settings.verify and settings.verify[config_name] then
		return proto.verify(settings.verify[config_name], data)
	end

	return data
end

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


function M.before_eva_init()
	local settings = app.settings.db
	app._db = {}
	local paths = settings.paths

	for name, path in pairs(paths) do
		logger:debug("Load JSON data", { name = name, path = path })
		local ok, result = pcall(utils.load_json, path)

		if ok then
			app._db[name] = result
		else
			logger:fatal("Error on loading json file", { name = name, traceback = result})
			error(result)
		end
	end
end


function M.on_eva_init()
	if app._db_custom then
		for config_name, data in pairs(app._db_custom) do
			app._db_custom[config_name] = verify(config_name, data)
		end
	end

	for config_name, data in pairs(app._db) do
		app._db[config_name] = verify(config_name, data)
	end
end


return M
