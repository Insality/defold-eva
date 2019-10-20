local node = require("eva.libs.astar.node")

local M = {}


-- EVEN ROW / ODD ROW
local hex_neighbors = {
    {{  1, 0 }, {  0,-1 }, { -1, -1 },
     { -1, 0 }, { -1, 1 }, {  0,  1 }},

    {{  1, 0 }, { 1, -1 }, { 0, -1 },
     { -1, 0 }, { 0,  1 }, { 1,  1 }},
}


local function handle_node(x, y, from_node, destx, desty)
	-- Fetch a Node for the given location and set its parameters
	local n = M.get_node(x, y)

	if n then
		local dx = math.max(x, destx) - math.min(x, destx)
		local dy = math.max(y, desty) - math.min(y, desty)
		local em_cost = dx + dy

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
	-- Here you check to see if two locations (not nodes) are equivalent
	-- If you are using a vector for a location you may be able to simply
	-- return a == b
	-- however, if your location is represented some other way, you can handle
	-- it correctly here without having to modufy the AStar class
	return a.x == b.x and a.y == b.y
end


function M.get_adjacent_nodes(from_node, to_node)
	local nodes = {}
	local x, y = from_node.x, from_node.y

	local neighbors = hex_neighbors[(bit.band(y, 1)) + 1]

	for i = 1, #neighbors do
		local offset = neighbors[i]
		local n = handle_node(x + offset[1], y + offset[2], from_node, to_node.x, to_node.y)
		if n then
			table.insert(nodes, n)
		end
	end

	return nodes
end


return M
