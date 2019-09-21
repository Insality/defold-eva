local log = require("eva.log")
local broadcast = require("eva.libs.broadcast")
local const = require("eva.const")

local logger = log.get_logger("eva.events")

local M = {}


function M.event(event, params)
	logger:debug("Game event", {event = event, params = params})
	broadcast.send(const.MSG.EVENT, {event = event, params = params})
end


function M.screen()

end


function M.add_event_system(event_system)

end


return M
