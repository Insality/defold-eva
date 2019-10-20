local M = {}


function M.get(nodes, total_cost)
	return {
		nodes = nodes,
		total_cost = total_cost
	}
end


function M.get_nodes(self)
	return self.nodes
end


function M.get_total_move_cost(self)
	return self.total_cost
end


return M
