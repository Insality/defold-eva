local M = {}


function M.get(nodes, total_cost)
	return {
		nodes = nodes,
		total_cost = total_cost
	}
end


return M
