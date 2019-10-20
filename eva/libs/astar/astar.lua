--  astar.lua
--  lua-astar, modified by Insality
--
--  Based on John Eriksson's Python A* implementation.
--  http://www.pygame.org/project-AStar-195-.html
--
--  Created by Jay Roberts on 2011-01-08.
--  Copyright 2011 Jay Roberts All rights reserved.
--
--  Licensed under the MIT License
--
--  Permission is hereby granted, free of charge, to any person obtaining a copy
--  of this software and associated documentation files (the "Software"), to deal
--  in the Software without restriction, including without limitation the rights
--  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
--  copies of the Software, and to permit persons to whom the Software is
--  furnished to do so, subject to the following conditions:
--
--  The above copyright notice and this permission notice shall be included in
--  all copies or substantial portions of the Software.
--
--  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
--  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
--  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
--  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
--  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
--  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
--  THE SOFTWARE.


local path = require("eva.libs.astar.path")

local M = {}


local function get_best_open_node(data)
	local best_node = nil

	for uid, n in pairs(data.open) do
		if best_node == nil then
			best_node = n
		else
			if n.score <= best_node.score then
				best_node = n
			end
		end
	end

	return best_node
end


local function trace_path(n)
	local nodes = {}
	local total_cost = n.move_cost
	local p = n.parent

	table.insert(nodes, 1, n)

	while true and p do
		if p.parent == nil then
			break
		end
		table.insert(nodes, 1, p)
		p = p.parent
	end

	return path.get(nodes, total_cost)
end


local function handle_node(data, map_handler, node, to)
	data.open[node.uid] = nil
	data.closed[node.uid] = node.uid

	assert(node.x ~= nil, 'About to pass a node with nil location to get_adjacent_nodes')
	assert(node.y ~= nil, 'About to pass a node with nil location to get_adjacent_nodes')

	if map_handler.locations_are_equal(node, to) then
		return node
	end

	if not node.move_cost then
		return nil
	end

	local nodes = map_handler.get_adjacent_nodes(map_handler, node, to)

	for i = 1, #nodes do repeat
		local n = nodes[i]
		if map_handler.locations_are_equal(n, to) then
			return n
		elseif data.closed[n.uid] then -- Alread in close, skip this
			break
		elseif data.open[n.uid] then -- Already in open, check if better score
			local on = data.open[n.uid]

			if n.move_cost < on.move_cost then
				data.open[n.uid] = n
			end
		else -- New node, append to open list
			data.open[n.uid] =  n
		end
	until true end

	return nil
end


function M.find_path(map_handler, from_x, from_y, to_x, to_y)
	local data = {
		open = {},
		closed = {}
	}

	local from_node = map_handler.get_node(from_x, from_y, 0)

	local next_node = nil

	if from_node then
		data.open[from_node.uid] = from_node
		next_node = from_node
	end

	while next_node do
		local to = map_handler.get_node(to_x, to_y)
		local finish = handle_node(data, map_handler, next_node, to)
		if finish then
			return trace_path(finish)
		end
		next_node = get_best_open_node(data)
	end

	return nil
end


return M
