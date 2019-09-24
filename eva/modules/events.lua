--- Defold-Eva events module
-- Send all game events and can include different event systems
-- like systems for analytics and game-logic
-- @submodule eva eva.events

local log = require("eva.log")
local broadcast = require("eva.libs.broadcast")
local const = require("eva.const")

local logger = log.get_logger("eva.events")

local M = {}
M.event_system = {}

--- Throws the game event
function M.event(event, params)
	logger:debug("Game event", {event = event, params = params})
	broadcast.send(const.MSG.EVENT, {event = event, params = params})

	for i = 1, #M.event_systems do
		M.event_systems[i].event(event, params)
	end
end


function M.screen()

end


function M.add_event_system(event_system)
	assert(event_system.event, "The event system should have `event` method")
	table.insert(M.event_systems, event_system)
end


function M.before_game_start(settings)
	M.event_systems = {}
end


return M
