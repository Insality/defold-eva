local value = require("eva.libs.smart.value")

local M = {}

--- Params is rules for value
-- default - default value, 0 by default
-- name - name of value
-- min
-- max
-- restore - table for specify restoring value params
-- restore.timer in seconds
-- restore.restore_value, default 1
-- restore.restore_max - how much restore by one time. default inf
-- restore.last_time -- need to pass if restore data, point last generation time
function M.new(params)
	local v = setmetatable({}, {__index = value})
	v:init(params)
	return v
end

function M.timer(time, name)
	return M.new({min = 0, max = 1, default = 0, name = name, restore = {
		timer = time
	}})
end

function M.set_time_function(cb)
	value.get_time = cb
end

return M