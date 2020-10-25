--- Eva base event class

local class = require("eva.libs.middleclass")
local log = require("eva.log")

local logger = log.get_logger("eva.event")

local Event = class("eva.event")


function Event:initialize(context_or_callback, callback)
    self._callbacks = {}

    if context_or_callback then
        self:subscribe(context_or_callback, callback)
    end
end


function Event:subscribe(context_or_callback, callback)
    if self:is_subscribed(context_or_callback, callback) then
        logger:error("Event is already subscribed")
        return
    end

    table.insert(self._callbacks, {
        script_context = lua_script_instance.Get(),
        context_or_callback = context_or_callback,
        callback = callback,
    })
end


function Event:unsubscribe(context_or_callback, callback)
    for index = 1, #self._callbacks do
        local cb = self._callbacks[index]
        if cb.context_or_callback == context_or_callback and cb.callback == callback then
            table.remove(self._callbacks, index)
            return true
        end
    end

    return false
end


function Event:is_subscribed(context_or_callback, callback)
    for index = 1, #self._callbacks do
        local cb = self._callbacks[index]
        if cb.context_or_callback == context_or_callback and cb.callback == callback then
            return true
        end
    end

    return false
end


function Event:trigger(...)
    local current_script_context = lua_script_instance.Get()

    for index = 1, #self._callbacks do
        local callback = self._callbacks[index]

        lua_script_instance.Set(callback.script_context)
        local ok, errors
        if callback.callback then
            ok, errors = pcall(callback.callback, callback.context_or_callback, ...)
        else
            ok, errors = pcall(callback.context_or_callback, ...)
        end

        if not ok then
            logger:error("Error in event")
            print(errors)
            print(debug.traceback())
        end
    end

    lua_script_instance.Set(current_script_context)
end


function Event:is_empty()
    return #self._callbacks == 0
end


function Event:clear()
    self._callbacks = {}
end


return Event
