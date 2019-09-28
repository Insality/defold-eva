--- Defold-Eva events module
-- Send all game events and can include different event systems
-- like systems for analytics and game-logic
-- @submodule eva

local log = require("eva.log")
local broadcast = require("eva.libs.broadcast")
local const = require("eva.const")

local logger = log.get_logger("eva.events")

local M = {}


--- Throws the game event
-- @function eva.events.event
-- @tparam string event name of event
-- @tparam[opt={}] table params params
function M.event(event, params)
	logger:debug("Game event", {event = event, params = params})
	broadcast.send(const.EVENT.EVENT, {event = event, params = params})

	local systems = M._eva.app.event_systems
	for i = 1, #systems do
		systems[i].event(event, params)
	end
end


--- Setup current game screen
-- @function eva.events.screen
-- @tparam string screen_id screen id
function M.screen(screen_id)

end


--- Add event system
-- @function eva.events.add_event_system
-- @tparam table event_system custom event handler
function M.add_event_system(event_system)
	assert(event_system.event, "The event system should have `event` method")
	table.insert(M._eva.app.event_systems, event_system)
end


function M.before_game_start(settings)
	M._eva.app.event_systems = {}
end


return M
