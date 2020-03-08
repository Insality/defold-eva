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
-- @module eva


local app = require("eva.app")
local log = require("eva.log")
local luax = require("eva.luax")
local const = require("eva.const")

local utils = require("eva.modules.utils")

local logger = log.get_logger("eva")

local M = {}


local function load_modules()
	local modules = {
		ads = require("eva.modules.ads"),
		cache = require("eva.modules.cache"),
		callbacks = require("eva.modules.callbacks"),
		camera = require("eva.modules.camera"),
		daily = require("eva.modules.daily"),
		db = require("eva.modules.db"),
		debug = require("eva.modules.debug"),
		device = require("eva.modules.device"),
		errors = require("eva.modules.errors"),
		events = require("eva.modules.events"),
		festivals = require("eva.modules.festivals"),
		game = require("eva.modules.game"),
		gdpr = require("eva.modules.gdpr"),
		generator = require("eva.modules.generator"),
		grid = require("eva.modules.grid"),
		hexgrid = require("eva.modules.hexgrid"),
		iaps = require("eva.modules.iaps"),
		input = require("eva.modules.input"),
		invoices = require("eva.modules.invoices"),
		isogrid = require("eva.modules.isogrid"),
		labels = require("eva.modules.labels"),
		lang = require("eva.modules.lang"),
		loader = require("eva.modules.loader"),
		migrations = require("eva.modules.migrations"),
		offers = require("eva.modules.offers"),
		pathfinder = require("eva.modules.pathfinder"),
		proto = require("eva.modules.proto"),
		push = require("eva.modules.push"),
		quests = require("eva.modules.quests"),
		queue = require("eva.modules.queue"),
		random = require("eva.modules.random"),
		rate = require("eva.modules.rate"),
		rating = require("eva.modules.rating"),
		render = require("eva.modules.render"),
		resources = require("eva.modules.resources"),
		saver = require("eva.modules.saver"),
		server = require("eva.modules.server"),
		status = require("eva.modules.status"),
		skill = require("eva.modules.skill"),
		social = require("eva.modules.social"),
		sound = require("eva.modules.sound"),
		storage = require("eva.modules.storage"),
		tiled = require("eva.modules.tiled"),
		timers = require("eva.modules.timers"),
		token = require("eva.modules.token"),
		trucks = require("eva.modules.trucks"),
		utils = require("eva.modules.utils"),
		wallet = require("eva.modules.wallet"),
		window = require("eva.modules.window")
	}

	M.modules_callbacks = {
		before_eva_init = {},
		on_eva_init = {},
		after_eva_init = {},
		on_eva_update = {},
		on_eva_second = {},
		on_eva_message = {},
	}

	for name, eva_module in pairs(modules) do
		local settings = app.settings[name]

		if not settings or settings and not settings.is_disabled then
			M[name] = eva_module

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

	if settings.migrations then
		M.migrations.set_migrations(settings.migrations)
	end

	if settings.window_settings then
		M.window.set_settings(settings.window_settings)
	end

	if settings.festivals_settings then
		M.festivals.set_settings(settings.festivals_settings)
	end

	if settings.trucks_settings then
		M.trucks.set_settings(settings.trucks_settings)
	end

	if settings.quests_settings then
		M.quests.set_settings(settings.quests_settings)
	end

	if settings.db_settings then
		M.db.set_settings(settings.db_settings)
	end
end


local function call_each_module(func_name, ...)
	for i = 1, #M.modules_callbacks[func_name] do
		M.modules_callbacks[func_name][i](...)
	end
end


local function load_settings(settings_path)
	local settings = utils.load_json(const.DEFAULT_SETTINGS_PATH)
	if settings_path then
		local custom_settings = utils.load_json(settings_path)
		for key, value in pairs(custom_settings) do
			luax.table.extend(settings[key], value)
		end
	end
	app.settings = settings

	assert(const.EVA_VERSION <= settings.eva.version, "Eva resources outdated, please update eva_settings, eva.proto and evadata.proto files")
end


--- Call this to init Eva module
-- @function eva.init
-- @tparam string settings_path path to eva_settings.json
-- @tparam table module_settings Settings to modules. See description on eva.lua
function M.init(settings_path, module_settings)
	app.clear()
	app.eva_basic = {
		second_counter = 1
	}

	load_settings(settings_path)
	load_modules()
	apply_module_settings(module_settings)

	log.init(app.settings.log)

	call_each_module("before_eva_init")
	call_each_module("on_eva_init")
	call_each_module("after_eva_init")

	logger:debug("Eva init completed", { settings = settings_path, version = app.settings.eva.version })
end


--- Call this on main update loop
-- @function eva.update
-- @tparam number dt delta time
function M.update(dt)
	local current_time = M.game.get_time()
	call_each_module("on_eva_update", dt, current_time)

	local eva_basic = app.eva_basic
	eva_basic.second_counter = eva_basic.second_counter - dt
	if eva_basic.second_counter <= 0 then
		eva_basic.second_counter = 1
		call_each_module("on_eva_second", current_time)
	end
end


--- Call this on main game on_input
-- @function eva.on_input
function M.on_input(action_id, action)
	M.input.on_input(action_id, action)
end


--- Call this on main game on_message
-- @function eva.on_message
function M.on_message(message_id, message, sender)
	call_each_module("on_eva_message", message_id, message, sender)
end


return M
