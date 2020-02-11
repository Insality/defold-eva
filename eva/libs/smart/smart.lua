local value = require("eva.libs.smart.value")

local M = {}


--- Params is rules for value
-- default - default value, 0 by default
-- name - name of value
-- min
-- max
function M.new(params, data_table)
	data_table = data_table or {
		amount = 0,
		offset = 0,
		infinity_time_end = 0,
	}

	local v = setmetatable({}, { __index = value })
	v:init(params, data_table)

	return v
end


function M.set_time_function(cb)
	value.get_time = cb
end


return M
