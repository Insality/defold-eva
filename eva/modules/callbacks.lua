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
	data.callbacks[data.last_index] = callback

	return data.last_index
end


--- Call wrapped callback
-- @function eva.callbacks.call
-- @tparam number index Index of wrapped callback
-- @tparam args ... Args of calling callback
function M.call(index, ...)
	local data = app.callbacks_data

	if data.callbacks[index] then
		data.callbacks[index](...)
		data.callbacks[index] = nil
	end
end


--- Clear callback
-- @function eva.callbacks.clear
-- @tparam number index Index of wrapped callback
function M.clear(index)
	local data = app.callbacks_data
	if data.callbacks[index] then
		data.callbacks[index] = nil
	end
end


function M.before_game_start()
	app.callbacks_data = {
		callbacks = {},
		last_index = 0
	}
end


return M
