--- Eva events module
-- Send all game events and can include different event systems
-- If subscribe on event, you should call eva.events.on_message to
-- like systems for analytics and game-logic
-- @submodule eva


local app = require("eva.app")
local log = require("eva.log")

local logger = log.get_logger("eva.events")

local M = {}


--- Throws the game event
-- @function eva.events.event
-- @tparam string event name of event
-- @tparam[opt={}] table params params
function M.event(event, params)
	logger:debug("Event", { event = event, params = params })

	local current_context = lua_script_instance.Get()
	local listeners = app.event_listeners[event]
	if listeners then
		for i = 1, #listeners do
			local info = listeners[i]
			lua_script_instance.Set(info.context)
			local context = info.callback_context or info.context
			local ok, errors = pcall(info.callback, context, params)
			if not ok then
				pprint(errors)
			end
		end
	end

	lua_script_instance.Set(current_context)
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
	app.event_listeners[event_name] = app.event_listeners[event_name] or {}

	if M.is_subscribed(event_name, callback, callback_context) then
		logger:warn("The callback is already add to events. Aborting", { event_name = event_name })
		return
	end

	table.insert(app.event_listeners[event_name], {
		callback = callback,
		callback_context = callback_context,
		context = lua_script_instance.Get()
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
function M.unsubscribe(event_name, callback, callback_context)
	local index = M.is_subscribed(event_name, callback, callback_context)
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
function M.is_subscribed(event_name, callback, callback_context)
	app.event_listeners[event_name] = app.event_listeners[event_name] or {}
	for i = 1, #app.event_listeners[event_name] do
		if app.event_listeners[event_name][i].callback == callback and
			app.event_listeners[event_name][i].callback_context == callback_context then
			return i
		end
	end
	return false
end


function M.before_eva_init()
	app.event_listeners = {}
end


return M
