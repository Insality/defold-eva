--- Eva base event class

local class = require("eva.libs.middleclass")
local log = require("eva.log")

local logger = log.get_logger("eva.event")

---@type eva.event
local Event = class("eva.event")


function Event:initialize(callback, callback_context)
    self._callbacks = {}
    self:subscribe(callback, callback_context)
end


function Event:subscribe(callback, callback_context)
    if self:is_subscribed(callback, callback_context) then
        logger:error("Event is already subscribed")
        return
    end

    table.insert(self._callbacks, {
        script_context = lua_script_instance.Get(),
        callback = callback,
        callback_context = callback_context,
    })
end


function Event:unsubscribe(callback, callback_context)
    for index = 1, #self._callbacks do
        local cb = self._callbacks[index]
        if cb.callback == callback and cb.callback_context == callback_context then
            table.remove(self._callbacks, index)
            return true
        end
    end

    return false
end


function Event:is_subscribed(callback, callback_context)
    for index = 1, #self._callbacks do
        local cb = self._callbacks[index]
        if cb.callback == callback and cb.callback_context == callback_context then
            return true
        end
    end

    return false
end


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
            logger:error("Error in event")
            print(errors)
            print(debug.traceback())
        end

    end
end


function Event:is_empty()
    return #self._callbacks == 0
end


function Event:clear()
    self._callbacks = {}
end


return Event
