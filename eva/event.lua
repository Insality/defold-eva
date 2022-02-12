--- Eva base event class
-- @module event

local class = require("eva.libs.middleclass")
local log = require("eva.log")

local logger = log.get_logger("eva.event")

local Event = class("eva.event")


--- Return traceback in one line for pass in as arg
-- @treturn string The traceback in one line
-- @local
local function get_line_traceback_in_line()
    local traceback = debug.traceback()
    return traceback
end


--- Event constructor
-- @function event.initialize
-- @tparam[opt] function callback The default event callback function
-- @tparam[opt] any callback_context The first argument for callback function
-- @local
function Event:initialize(callback, callback_context)
    self._callbacks = {}

    if callback then
        self:subscribe(callback, callback_context)
    end
end


--- Subscribe on the event
-- @function event.subscribe
-- @tparam function callback The event callback function
-- @tparam[opt] any callback_context The first argument for callback function
function Event:subscribe(callback, callback_context)
    assert(callback, "You should pass function to subscribe on event")

    if self:is_subscribed(callback, callback_context) then
        logger:error("Event is already subscribed", { traceback = get_line_traceback_in_line() })
        return
    end

    table.insert(self._callbacks, {
        script_context = lua_script_instance.Get(),
        callback = callback,
        callback_context = callback_context,
    })
end


--- Unsubscribe from the event
-- @function event.unsubscribe
-- @tparam function callback The event callback function
-- @tparam[opt] any callback_context The first argument for callback function
-- @treturn If event was unsubscribed or not
function Event:unsubscribe(callback, callback_context)
    assert(callback, "You should pass function to subscribe on event")

    for index = 1, #self._callbacks do
        local cb = self._callbacks[index]
        if cb.callback == callback and cb.callback_context == callback_context then
            table.remove(self._callbacks, index)
            return true
        end
    end

    return false
end



--- Unsubscribe from the event
-- @function event.unsubscribe
-- @tparam function callback The default event callback function
-- @tparam[opt] any callback_context The first argument for callback function
-- @treturn boolean Is there is event with callback and context
function Event:is_subscribed(callback, callback_context)
    for index = 1, #self._callbacks do
        local cb = self._callbacks[index]
        if cb.callback == callback and cb.callback_context == callback_context then
            return true
        end
    end

    return false
end


--- Trigger the even
-- @function event.trigger
-- @tparam args args The args for event trigger
function Event:trigger(...)
    local current_script_context = lua_script_instance.Get()

    for index = 1, #self._callbacks do
        local callback = self._callbacks[index]

        if current_script_context ~= callback.script_context then
            lua_script_instance.Set(callback.script_context)
        end

        local ok, errors
        if callback.callback_context then
            ok, errors = pcall(callback.callback, callback.callback_context, ...)
        else
            ok, errors = pcall(callback.callback, ...)
        end

        if current_script_context ~= callback.script_context then
            lua_script_instance.Set(current_script_context)
        end

        if not ok then
            local traceback = debug.traceback()
            logger:error("Error in event", { errors = errors, traceback = traceback })
            print(traceback)
        end

    end
end


--- Check is event is empty
-- @function event.is_empty
-- @treturn boolean True if event has no any subscribed callbacks
function Event:is_empty()
    return #self._callbacks == 0
end


--- Clear all event callbacks
-- @function event.clear
function Event:clear()
    self._callbacks = {}
end


return Event
