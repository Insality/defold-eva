--- Basic defold-eva module.
-- @module eva

local log = require("eva.log")
local luax = require("eva.luax")
local const = require("eva.const")

local logger = log.get_logger("eva")
local M = {}


local modules = {
	ads = require("eva.modules.ads"),
	camera = require("eva.modules.camera"),
	daily = require("eva.modules.daily"),
	device = require("eva.modules.device"),
	db = require("eva.modules.db"),
	errors = require("eva.modules.errors"),
	events = require("eva.modules.events"),
	game = require("eva.modules.game"),
	gdpr = require("eva.modules.gdpr"),
	iaps = require("eva.modules.iaps"),
	lang = require("eva.modules.lang"),
	migrations = require("eva.modules.migrations"),
	push = require("eva.modules.push"),
	proto = require("eva.modules.proto"),
	rate = require("eva.modules.rate"),
	render = require("eva.modules.render"),
	saver = require("eva.modules.saver"),
	server = require("eva.modules.server"),
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
	local custom_settings = M.utils.load_json(settings_path)

	luax.table.extend(settings, custom_settings)

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


function M.on_input(action_id, action)
	call_each_module("on_input", action_id, action)
end


function M.on_message(message_id, message, sender)
	call_each_module("on_message", message_id, message, sender)
end


return M
