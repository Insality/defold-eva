-- Handler for hexagonal grid astar

local const = require("eva.const")
local basic_handler = require("eva.libs.astar.basic_handler")

local M = {}


function M.new_handler(get_node_fn, options)
	local data = basic_handler.get_handler(get_node_fn)

	data.neighbors = const.ASTAR.HEX.NEIGHBORS

	data.get_neighbors = function(map_handler, x, y)
		return map_handler.neighbors[(bit.band(y, 1)) + 1]
	end

	return setmetatable(data, { __index = basic_handler })
end


return M
