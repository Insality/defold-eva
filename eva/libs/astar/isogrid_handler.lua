--- Handler for isometric grid astar

local luax = require("eva.luax")
local const = require("eva.const")
local node = require("eva.libs.astar.node")


local M = {}


local function handle_node(map_handler, x, y, from_node, destx, desty)
	-- Fetch a Node for the given location and set its parameters
	local n = map_handler.get_node(x, y)

	if n and n.move_cost then
		local em_cost = luax.math.distance(x, y, destx, desty)

		n.move_cost = n.move_cost + from_node.move_cost
		n.score = n.move_cost + em_cost
		n.parent = from_node

		return n
	end

	return nil
end


function M.get_node(x, y, move_cost)
	move_cost = move_cost or 1
	return node.get(x, y, move_cost)
end


function M.locations_are_equal(a, b)
	return a.x == b.x and a.y == b.y
end


function M.get_adjacent_nodes(map_handler, from_node, to_node)
	local nodes = {}
	local x, y = from_node.x, from_node.y

	local neighbors = map_handler.neighbors[(bit.band(y, 1)) + 1]

	for i = 1, #neighbors do
		local offset = neighbors[i]
		local n = handle_node(map_handler, x + offset[1], y + offset[2], from_node, to_node.x, to_node.y)
		if n then
			table.insert(nodes, n)
		end
	end

	return nodes
end


--- Get new handler for astar api
-- get_node_fn - function to get tile: function(i, j)
-- should return Node (astar.node)
-- Set move_cost to nil, if cell is unpassable
function M.new_handler(get_node_fn, options)
	local data = {
		get_node = function(x, y)
			local cost = get_node_fn(x, y)
			return node.get(x, y, cost)
		end
	}

	data.neighbors = const.ASTAR.ISO.NEIGHBORS
	if options and options.diagonal then
		data.neighbors = const.ASTAR.ISO.NEIGHBORS_DIAGONAL
	end

	return setmetatable(data, { __index = M })
end


return M
