-- Handler for usual grid astar

local const = require("eva.const")
local basic_handler = require("eva.libs.astar.basic_handler")

local M = {}


function M.new_handler(get_node_fn, options)
	local data = basic_handler.get_handler(get_node_fn)

	data.neighbors = const.ASTAR.GRID.NEIGHBORS
	if options and options.diagonal then
		data.neighbors = const.ASTAR.GRID.NEIGHBORS_DIAGONAL
	end

	return setmetatable(data, { __index = basic_handler })
end


return M
