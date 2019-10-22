--- Basic astar handler for reuse

local luax = require("eva.luax")
local node = require("eva.libs.astar.node")


local M = {}


function M.locations_are_equal(a, b)
	return a.x == b.x and a.y == b.y
end


function M.get_score(from_node, to_node, dest_node)
	return luax.math.manhattan(from_node.x, from_node.y, to_node.x, to_node.y)
end


function M.handle_node(map_handler, from_node, to_node, dest_node)
	if to_node and to_node.move_cost then
		local em_cost = map_handler.get_score(from_node, to_node, dest_node)

		to_node.move_cost = to_node.move_cost + from_node.move_cost
		to_node.score = to_node.move_cost + em_cost
		to_node.parent = from_node

		return to_node
	end

	return nil
end


function M.get_adjacent_nodes(map_handler, from_node, dest_node)
	local nodes = {}
	local x, y = from_node.x, from_node.y

	local neighbors = map_handler.get_neighbors(map_handler, x, y)

	for i = 1, #neighbors do
		local offset = neighbors[i]
		local to_node = map_handler.get_node(x + offset[1], y + offset[2])
		local n = M.handle_node(map_handler, from_node, to_node, dest_node)
		if n then
			table.insert(nodes, n)
		end
	end

	return nodes
end


function M.get_neighbors(map_handler, x, y)
	return map_handler.neighbors or {}
end


function M.get_handler(get_node_fn)
	return {
		get_node = function(x, y)
			local cost = get_node_fn(x, y)
			return node.get(x, y, cost)
		end,
		neighbors = {}
	}
end


return M
