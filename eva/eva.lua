--- Custom Eva header setup
-- Copy this file to your project, comment/uncomment required libraries
-- and dynamic libraries and use it
-- You can use eva.eva module to use all eva modules (all modules will be included in your build)
--
-- Access for module is eva[module_name]
-- @module eva

local log = require("eva.log")
local eva_system = require("eva.eva_system")

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
	migrations = require("eva.modules.migrations"),
	offers = require("eva.modules.offers"),
	pathfinder = require("eva.modules.pathfinder"),
	promocode = require("eva.modules.promocode"),
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
	share = require("eva.modules.share"),
	skill = require("eva.modules.skill"),
	social = require("eva.modules.social"),
	sound = require("eva.modules.sound"),
	status = require("eva.modules.status"),
	storage = require("eva.modules.storage"),
	tiled = require("eva.modules.tiled"),
	timers = require("eva.modules.timers"),
	token = require("eva.modules.token"),
	trucks = require("eva.modules.trucks"),
	vibrate = require("eva.modules.vibrate"),
	utils = require("eva.modules.utils"),
	wallet = require("eva.modules.wallet"),
	window = require("eva.modules.window")
}

-- DYNAMIC LIBRARIES SECTION
-- Uncomment if unity ads adapter is used
require("eva.modules.ads.ads_unity")

-- Uncomment if yandex ads adapter is used
-- require("eva.modules.ads.ads_yandex")
-- require("yagames.yagames")

-- Uncomment is nakama server is used
-- require("nakama.engine.defold")
-- require("nakama.nakama")
-- require("nakama.session")
-- require("nakama.util.log")


local Eva = {}

--- Call this to init Eva module
-- @function eva.init
-- @tparam string settings_path path to eva_settings.json
-- @tparam table module_settings Settings to modules. See description on eva.lua
function Eva.init(settings_path, module_settings)
	-- Set eva.* module access
	for name, module in pairs(modules) do
		Eva[name] = module
	end
	Eva.log = log.get_logger("eva")

	-- Init eva
	eva_system.init(settings_path, module_settings, modules)
end


--- Call this on main update loop
-- @function eva.update
-- @tparam number dt delta time
function Eva.update(dt)
	eva_system.update(dt)
end


--- Return logger from eva.log module
-- @function eva.get_logger
-- @tparam string[opt=default] logger_name The logger name
-- @treturn logger The logger instance
function Eva.get_logger(logger_name)
	return eva_system.get_logger(logger_name)
end


return Eva
