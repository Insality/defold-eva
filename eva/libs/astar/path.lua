local M = {}


function M.get(nodes, total_cost, total_score)
	return {
		nodes = nodes,
		total_cost = total_cost,
		total_score = total_score
	}
end


return M
