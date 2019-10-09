--- Defold Eva library
-- Eva library carry on all basic mobile game
-- functions like iaps, camera, offers and other
-- a lot of basic stuffs. Designed for fast integration
-- and single code base.
-- @module eva


local log = require("eva.log")
local luax = require("eva.luax")
local const = require("eva.const")

local logger = log.get_logger("eva")
local M = {}


local modules = {
	ads = require("eva.modules.ads"),
	camera = require("eva.modules.camera"),
	callbacks = require("eva.modules.callbacks"),
	daily = require("eva.modules.daily"),
	device = require("eva.modules.device"),
	debug = require("eva.modules.debug"),
	festival = require("eva.modules.festival"),
	generator = require("eva.modules.generator"),
	grid = require("eva.modules.grid"),
	hexgrid = require("eva.modules.hexgrid"),
	rating = require("eva.modules.rating"),
	pathfinder = require("eva.modules.pathfinder"),
	tiled = require("eva.modules.tiled"),
	quest = require("eva.modules.quest"),
	db = require("eva.modules.db"),
	errors = require("eva.modules.errors"),
	events = require("eva.modules.events"),
	game = require("eva.modules.game"),
	gdpr = require("eva.modules.gdpr"),
	iaps = require("eva.modules.iaps"),
	lang = require("eva.modules.lang"),
	loader = require("eva.modules.loader"),
	migrations = require("eva.modules.migrations"),
	push = require("eva.modules.push"),
	proto = require("eva.modules.proto"),
	rate = require("eva.modules.rate"),
	resources = require("eva.modules.resources"),
	render = require("eva.modules.render"),
	saver = require("eva.modules.saver"),
	server = require("eva.modules.server"),
	social = require("eva.modules.social"),
	stats = require("eva.modules.stats"),
	storage = require("eva.modules.storage"),
	sound = require("eva.modules.sound"),
	timers = require("eva.modules.timers"),
	tokens = require("eva.modules.tokens"),
	offers = require("eva.modules.offers"),
	utils = require("eva.modules.utils"),
	window = require("eva.modules.window")
}


local function call_each_module(func_name, ...)
	for name, component in pairs(modules) do
		local csettings = M.app.settings[name]
		if not csettings or csettings and not csettings.is_disabled then
			if component[func_name] then
				component[func_name](...)
			end
		end
	end
end


--- Call this to init Eva module
-- @function eva.on_game_start
-- @tparam string settings_path path to eva_settings.json
function M.init(settings_path)
	M.app = {}
	M.app._second_counter = 1

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

	M.app.settings = settings
	log.init(M.app.settings.log)

	call_each_module("before_game_start")
	call_each_module("on_game_start")
	call_each_module("after_game_start")

	logger:debug("Eva init completed", { settings = settings_path })
end


--- Call this on main update loop
-- @function eva.on_game_update
-- @tparam number dt delta time
function M.on_game_update(dt)
	call_each_module("on_game_update", dt)

	M.app._second_counter = M.app._second_counter - dt
	if M.app._second_counter <= 0 then
		M.app._second_counter = 1
		call_each_module("on_game_second")
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
