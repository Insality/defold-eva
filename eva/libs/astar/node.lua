local M = {}


function M.get(x, y, move_cost, parent)
	return {
		x = x, -- Where is the node located
		y = y, -- Where is the node located
		move_cost = move_cost, -- Total move cost to reach this node
		parent = parent, -- Parent node
		score = 0, -- Calculated score for this node
		uid = x*10000+y -- set the location id - unique for each location in the map
	}
end


return M
