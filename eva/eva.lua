--- Defold Eva library
-- Eva library carry on all basic mobile game
-- functions like iaps, camera, offers and other
-- a lot of basic stuffs. Designed for fast integration
-- and single code base.
-- @module eva


local app = require("eva.app")
local log = require("eva.log")
local luax = require("eva.luax")
local const = require("eva.const")

local logger = log.get_logger("eva")
local M = {}


local modules = {
	ads = require("eva.modules.ads"),
	callbacks = require("eva.modules.callbacks"),
	camera = require("eva.modules.camera"),
	daily = require("eva.modules.daily"),
	db = require("eva.modules.db"),
	debug = require("eva.modules.debug"),
	device = require("eva.modules.device"),
	errors = require("eva.modules.errors"),
	events = require("eva.modules.events"),
	festival = require("eva.modules.festival"),
	game = require("eva.modules.game"),
	gdpr = require("eva.modules.gdpr"),
	generator = require("eva.modules.generator"),
	grid = require("eva.modules.grid"),
	hexgrid = require("eva.modules.hexgrid"),
	iaps = require("eva.modules.iaps"),
	lang = require("eva.modules.lang"),
	loader = require("eva.modules.loader"),
	migrations = require("eva.modules.migrations"),
	offers = require("eva.modules.offers"),
	pathfinder = require("eva.modules.pathfinder"),
	proto = require("eva.modules.proto"),
	push = require("eva.modules.push"),
	quest = require("eva.modules.quest"),
	rate = require("eva.modules.rate"),
	rating = require("eva.modules.rating"),
	render = require("eva.modules.render"),
	resources = require("eva.modules.resources"),
	saver = require("eva.modules.saver"),
	server = require("eva.modules.server"),
	social = require("eva.modules.social"),
	sound = require("eva.modules.sound"),
	stats = require("eva.modules.stats"),
	storage = require("eva.modules.storage"),
	tiled = require("eva.modules.tiled"),
	timers = require("eva.modules.timers"),
	tokens = require("eva.modules.tokens"),
	utils = require("eva.modules.utils"),
	window = require("eva.modules.window")
}


local function call_each_module(func_name, ...)
	for name, component in pairs(modules) do
		local csettings = app.settings[name]
		if not csettings or csettings and not csettings.is_disabled then
			if component[func_name] then
				component[func_name](...)
			end
		end
	end
end


--- Call this to init Eva module
-- @function eva.on_eva_init
-- @tparam string settings_path path to eva_settings.json
function M.init(settings_path)
	print("Before App keys:", #luax.table.list(app))
	app.clear()
	print("After clear App keys:", #luax.table.list(app))

	app._second_counter = 1

	for name, component in pairs(modules) do
		M[name] = component
		component._eva = M
	end

	local settings = M.utils.load_json(const.DEFAULT_SETTINGS_PATH)
	if settings_path then
		local custom_settings = M.utils.load_json(settings_path)
		for key, value in pairs(custom_settings) do
			luax.table.extend(settings[key], value)
		end
	end

	app.settings = settings
	log.init(app.settings.log)

	call_each_module("before_eva_init")
	call_each_module("on_eva_init")
	call_each_module("after_eva_init")

	logger:debug("Eva init completed", { settings = settings_path })

	print("App keys:", #luax.table.list(app))
end


--- Call this on main update loop
-- @function eva.on_eva_update
-- @tparam number dt delta time
function M.on_eva_update(dt)
	call_each_module("on_eva_update", dt)

	app._second_counter = app._second_counter - dt
	if app._second_counter <= 0 then
		app._second_counter = 1
		call_each_module("on_eva_second")
	end
end


--- Call this on main game on_input
-- @function eva.on_input
function M.on_input(action_id, action)
	call_each_module("on_input", action_id, action)
end


--- Call this on main game on_message
-- @function eva.on_message
function M.on_message(message_id, message, sender)
	call_each_module("on_message", message_id, message, sender)
end


return M
