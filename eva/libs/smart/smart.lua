local value = require("eva.libs.smart.value")

local M = {}

--- Params is rules for value
-- default - default value, 0 by default
-- name - name of value
-- min
-- max
-- restore - table for specify restoring value params
-- restore.timer in seconds
-- restore.value, default 1
-- restore.max - how much restore by one time. default inf
-- restore.last_restore_time -- need to pass if restore data, point last generation time
function M.new(params, data_table)
	data_table = data_table or {
		amount = 0,
		last_restore_time = 0,
		infinity_time_end = 0,
	}
	local v = setmetatable({}, {__index = value})
	v:init(params, data_table)
	return v
end


function M.set_time_function(cb)
	value.get_time = cb
end


return M