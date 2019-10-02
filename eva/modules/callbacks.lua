local M = {}


function M.create(callback)
	local data = M._eva.app.callbacks_data
	data.last_index = data.last_index + 1
	data.callbacks[data.last_index] = callback

	return data.last_index
end


function M.call(index, ...)
	local data = M._eva.app.callbacks_data

	if data.callbacks[index] then
		data.callbacks[index](...)
		data.callbacks[index] = nil
	end
end


function M.clear(index)
	local data = M._eva.app.callbacks_data
	if data.callbacks[index] then
		data.callbacks[index] = nil
	end
end


function M.before_game_start()
	M._eva.app.callbacks_data = {
		callbacks = {},
		last_index = 0
	}
end


return M
