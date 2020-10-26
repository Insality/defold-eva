--- Eva events module
-- Send all game events and can include different event systems
-- If subscribe on event, you should call eva.events.on_message to
-- like systems for analytics and game-logic
-- @submodule eva


local app = require("eva.app")
local log = require("eva.log")
local Event = require("eva.event")

local logger = log.get_logger("eva.events")

local M = {}


--- Throws the game event
-- @function eva.events.event
-- @tparam string event name of event
-- @tparam[opt={}] table params params
function M.event(event_name, params)
	logger:debug("Event", { event = event_name, params = params })
	if app.event_listeners[event_name] then
		app.event_listeners[event_name]:trigger(params)
	end
end


--- Setup current game screen
-- @function eva.events.screen
-- @tparam string screen_id screen id
function M.screen(screen_id)

end


--- Subscribe the callback on event
-- @function eva.events.subscribe
-- @tparam string event_name Event name
-- @tparam function callback Event callback
function M.subscribe(event_name, callback, callback_context)
	app.event_listeners[event_name] = app.event_listeners[event_name] or Event()

	if M.is_subscribed(event_name, callback, callback_context) then
		logger:warn("The callback is already add to events. Aborting", { event_name = event_name })
		return
	end

	app.event_listeners[event_name]:subscribe(callback, callback_context)
end


--- Subscribe the pack of events by map
-- @function eva.events.subscribe_map
-- @tparam table map {Event = Callback} map
function M.subscribe_map(map, callback_context)
	for event_name, callback in pairs(map) do
		M.subscribe(event_name, callback, callback_context)
	end
end


--- Unsubscribe the event from events flow
-- @function eva.events.unsubscribe
-- @tparam string event_name Event name
-- @tparam function callback Event callback
function M.unsubscribe(event_name, callback, callback_context)
	if not M.is_subscribed(event_name, callback, callback_context) then
		logger:warn("No event to unsubscribe", { event_name = event_name })
	end

	app.event_listeners[event_name]:unsubscribe(callback, callback_context)
end


--- Unsubscribe the pack of events by map
-- @function eva.events.unsubscribe_map
-- @tparam table map {Event = Callback} map
function M.unsubscribe_map(map, callback_context)
	for event_name, callback in pairs(map) do
		M.unsubscribe(event_name, callback, callback_context)
	end
end


--- Check if callback is already subscribed
-- @function eva.events.is_subscribed
-- @tparam string event_name Event name
-- @tparam function callback Event callback
function M.is_subscribed(event_name, callback, callback_context)
	app.event_listeners[event_name] = app.event_listeners[event_name] or Event()
	return app.event_listeners[event_name]:is_subscribed(callback, callback_context)
end


function M.before_eva_init()
	---@type map<string, eva.event>
	app.event_listeners = {}
end


return M
