--- Basic defold-eva module.
-- @module eva

local log = require("eva.log")

local logger = log.get_logger("eva")
local M = {}


local modules = {
	ads = require("eva.modules.ads"),
	device = require("eva.modules.device"),
	db = require("eva.modules.db"),
	errors = require("eva.modules.errors"),
	events = require("eva.modules.events"),
	game = require("eva.modules.game"),
	gdpr = require("eva.modules.gdpr"),
	iaps = require("eva.modules.iaps"),
	input = require("eva.modules.input"),
	lang = require("eva.modules.lang"),
	notifications = require("eva.modules.notifications"),
	proto = require("eva.modules.proto"),
	rate = require("eva.modules.rate"),
	render = require("eva.modules.render"),
	saver = require("eva.modules.saver"),
	server = require("eva.modules.server"),
	sound = require("eva.modules.sound"),
	stats = require("eva.modules.stats"),
	timers = require("eva.modules.timers"),
	tokens = require("eva.modules.tokens"),
	utils = require("eva.modules.utils"),
	window = require("eva.modules.window")
}


local function call_each_module(func_name, settings)
	for name, component in pairs(modules) do
		if component[func_name] then
			component[func_name](settings[name])
		end
	end
end


--- Call this to init Eva module
-- @function eva.on_game_start
-- @tparam string settings_path path to eva_settings.json
function M.on_game_start(settings_path)
	for name, component in pairs(modules) do
		M[name] = component
		component._eva = M
	end

	local settings = M.utils.load_json(settings_path)
	log.init(settings.log)

	call_each_module("before_game_start", settings)
	call_each_module("on_game_start", settings)
	call_each_module("after_game_start", settings)

	logger:debug("Eva init completed", {settings = settings_path})
end


--- Call this on main update loop
-- @function eva.on_game_update
-- @tparam number dt delta time
function M.on_game_update(dt)
	for name, component in pairs(modules) do
		if component.on_game_update then
			component.on_game_update(dt)
		end
	end
end


return M
