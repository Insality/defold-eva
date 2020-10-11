--- Eva callbacks system module.
-- Using for pass callbacks though context
-- It make wrap callbacks to call it via messages by callback index
-- @submodule eva


local app = require("eva.app")

local M = {}


--- Wrap callback
-- It return index for callback, You can call it now
-- via eva.callbacks.call(index, ...)
-- @function eva.callbacks.create
-- @tparam function callback Callback to wrap
-- @treturn number index New index of wrapped callback
function M.create(callback)
	local data = app.callbacks_data
	data.last_index = data.last_index + 1
	data.callbacks[data.last_index] = {
		context = lua_script_instance.Get(),
		callback = callback
	}

	return data.last_index
end


--- Call wrapped callback
-- @function eva.callbacks.call
-- @tparam number index Index of wrapped callback
-- @tparam args ... Args of calling callback
function M.call(index, ...)
	local data = app.callbacks_data

	if data.callbacks[index] then
		local callback_data = data.callbacks[index]
		-- data.callbacks[index] = nil

		local current_context = lua_script_instance.Get()

		lua_script_instance.Set(callback_data.context)
		local ok, result = pcall(callback_data.callback, ...)
		lua_script_instance.Set(current_context)

		if not ok then
			error(result)
		end

		return result
	end

	return false
end


--- Clear callback
-- @function eva.callbacks.clear
-- @tparam number index Index of wrapped callback
function M.clear(index)
	local data = app.callbacks_data
	if data.callbacks[index] then
		data.callbacks[index] = nil
		return true
	end

	return false
end


function M.before_eva_init()
	app.callbacks_data = {
		callbacks = {},
		last_index = 0
	}
end


return M
