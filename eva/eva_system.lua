--- Defold Eva library
-- Eva library carry on all basic mobile game
-- functions like iaps, camera, offers and other
-- a lot of basic stuffs. Designed for fast integration
-- and single code base.
--
-- module_settings: {
-- 	migrations: see migrations_example,
-- 	window_settings: see window_settings_example
-- 	festivals_settings: see festival_settings_example,
-- 	quests_settings: see quest_settings_example,
-- }
-- Eva game.project params:
-- eva.log_level Default: "DEBUG". Variables: FATAL ERROR WARN INFO DEBUG
-- ios.id The app id from iOS AppStore. Required for generate shop url
-- @module eva
-- @local


local app = require("eva.app")
local log = require("eva.log")
local const = require("eva.const")

local utils = require("eva.modules.utils")

local logger = log.get_logger("eva")

local M = {}


local function load_modules(modules)
	M.modules = modules

	M.modules_callbacks = {
		before_eva_init = {},
		on_eva_init = {},
		after_eva_init = {},
		on_eva_update = {},
		on_eva_second = {},
	}

	for name, eva_module in pairs(modules) do
		local settings = app.settings[name]

		if not settings or settings and not settings.is_disabled then
			for func_name, callbacks in pairs(M.modules_callbacks) do
				if eva_module[func_name] then
					table.insert(callbacks, eva_module[func_name])
				end
			end
		end
	end
end


local function apply_module_settings(settings)
	if not settings then
		return
	end

	if M.modules.migrations and settings.migrations then
		M.modules.migrations.set_migrations(settings.migrations)
	end

	if M.modules.window and settings.window_settings then
		M.modules.window.set_settings(settings.window_settings)
	end

	if M.modules.festivals and settings.festivals_settings then
		M.modules.festivals.set_settings(settings.festivals_settings)
	end

	if M.modules.trucks and settings.trucks_settings then
		M.modules.trucks.set_settings(settings.trucks_settings)
	end

	if M.modules.quests and settings.quests_settings then
		M.modules.quests.set_settings(settings.quests_settings)
	end

	if M.modules.db and settings.db_settings then
		M.modules.db.set_settings(settings.db_settings)
	end

	if M.modules.promocode and settings.promocode_settings then
		M.modules.promocode.set_settings(settings.promocode_settings)
	end
end


local function call_each_module(func_name, ...)
	for i = 1, #M.modules_callbacks[func_name] do
		M.modules_callbacks[func_name][i](...)
	end
end


local function load_settings(settings_path)
	local settings = utils.load_json(settings_path)
	assert(settings, "No eva settings finded on path: " .. (settings_path or ""))

	app.settings = settings
	assert(const.EVA_VERSION <= app.settings.eva.version, "Eva resources outdated, please update eva_settings, eva.proto and evadata.proto files")
end


--- Call this to init Eva module
-- @function eva.init
-- @tparam string settings_path path to eva_settings.json
-- @tparam table module_settings Settings to modules. See description on eva.lua
-- @tparam table modules The list of used eva modules, setup it in your eva file
function M.init(settings_path, module_settings, modules)
	app.clear()
	app.eva_basic = {
		second_counter = 1
	}

	load_settings(settings_path)
	load_modules(modules)
	apply_module_settings(module_settings)

	log.init(app.settings.log, sys.get_config("eva.log_level", "DEBUG"))

	call_each_module("before_eva_init")
	call_each_module("on_eva_init")
	call_each_module("after_eva_init")

	logger:debug("Eva init completed", { settings = settings_path, version = app.settings.eva.version })
end


--- Call this on main update loop
-- @function eva.update
-- @tparam number dt delta time
function M.update(dt)
	local current_time = M.modules.game.get_time()
	call_each_module("on_eva_update", dt, current_time)

	local eva_basic = app.eva_basic
	eva_basic.second_counter = eva_basic.second_counter - dt
	if eva_basic.second_counter <= 0 then
		eva_basic.second_counter = 1
		call_each_module("on_eva_second", current_time)
	end
end


--- Return logger from eva.log module
-- @function eva.get_logger
-- @tparam string[opt=default] logger_name The logger name
-- @treturn logger The logger instance
function M.get_logger(logger_name)
	return log.get_logger(logger_name)
end


return M
