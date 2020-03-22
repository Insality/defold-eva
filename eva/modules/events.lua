--- Eva events module
-- Send all game events and can include different event systems
-- like systems for analytics and game-logic
-- @submodule eva


local app = require("eva.app")
local log = require("eva.log")
local const = require("eva.const")

local callbacks = require("eva.modules.callbacks")

local logger = log.get_logger("eva.events")

local M = {}


--- Throws the game event
-- @function eva.events.event
-- @tparam string event name of event
-- @tparam[opt={}] table params params
function M.event(event, params)
	logger:debug("Event", { event = event, params = params })

	local listeners = app.event_listeners[event]
	if listeners then
		local context = msg.url()

		for i = 1, #listeners do
			local info = listeners[i]
			if context == info.context then
				info.callback(event, params)
			else
				local callback_id = callbacks.create(info.callback)
				msg.post(".", const.INPUT.CALLBACK, { index = callback_id, args = {
					event = event,
					params = params
				}})
			end
		end
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
function M.subscribe(event_name, callback)
	app.event_listeners[event_name] = app.event_listeners[event_name] or {}

	if M.is_subscribed(event_name, callback) then
		logger:warn("The callback is already add to events. Aborting", { event_name = event_name })
		return
	end

	table.insert(app.event_listeners[event_name], {
		callback = callback,
		context = msg.url()
	})
end


--- Subscribe the pack of events by map
-- @function eva.events.subscribe_map
-- @tparam table map {Event = Callback} map
function M.subscribe_map(map)
	for event_name, callback in pairs(map) do
		M.subscribe(event_name, callback)
	end
end


--- Unsubscribe the event from events flow
-- @function eva.events.unsubscribe
-- @tparam string event_name Event name
-- @tparam function callback Event callback
function M.unsubscribe(event_name, callback)
	local index = M.is_subscribed(event_name, callback)
	if index then
		table.remove(app.event_listeners[event_name], index)
	else
		logger:warn("No event to unsubscribe", { event_name = event_name })
	end
end


--- Unsubscribe the pack of events by map
-- @function eva.events.unsubscribe_map
-- @tparam table map {Event = Callback} map
function M.unsubscribe_map(map)
	for event_name, callback in pairs(map) do
		M.unsubscribe(event_name, callback)
	end
end


--- Check if callback is already subscribed
-- @function eva.events.is_subscribed
-- @tparam string event_name Event name
-- @tparam function callback Event callback
function M.is_subscribed(event_name, callback)
	app.event_listeners[event_name] = app.event_listeners[event_name] or {}
	for i = 1, #app.event_listeners[event_name] do
		if app.event_listeners[event_name][i].callback == callback then
			return i
		end
	end
	return false
end


function M.before_eva_init()
	app.event_listeners = {}
end


function M.on_message(self, message_id, message, sender)
	if message_id == const.INPUT.CALLBACK then
		callbacks.call(message.index, message.args.event, message.args.params)
	end
end

return M
