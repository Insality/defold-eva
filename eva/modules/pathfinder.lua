--- Eva pathfinder module
-- It carry on path finding on some map structure (grid or hex)
-- @submodule eva


local astar = require("eva.libs.astar.astar")

local log = require("eva.log")
local app = require("eva.app")

local logger = log.get_logger("eva.pathfinder")

local M = {}


--- Init astar for map, init get_tile callback
-- get_node_fn - function to get tile: function(i, j)
-- should return cost of node. Nil if cell is unpassable
-- @function eva.pathfinder.init_astar
-- @tparam map_data map_data Map data from eva.tiled.load_map
-- @tparam function get_node_fn Get node cost function from map
-- @tparam table options Options for map handlers:
-- - diagonal boolean, to grid and isogrid pathfinding
-- @treturn map_handler Handler for astar work
function M.init_astar(map_data, get_node_fn, options)
	local handler = map_data.astar_handler

	local map_handler = handler.new_handler(get_node_fn, options)
	app.clear("pathfinder_default_handler")
	app.pathfinder_default_handler = map_handler

	return map_handler
end


--- Return path between two points for map.
-- Call init_astar, to make map_handler param optional
-- @function eva.pathfinder.path
-- @param from_x Cell X from map
-- @param from_y Cell Y from map
-- @param to_x Cell X from map
-- @param to_y Cell Y from map
-- @tparam[opt] map_handler map_handler Map handler to handle map for astar
-- @treturn table|nil Table of points. See eva.libs.astar.path. Nil if path is not exist
function M.path(from_x, from_y, to_x, to_y, map_handler)
	map_handler = map_handler or app.pathfinder_default_handler

	if not map_handler then
		logger:error("No map handler for pathfinder")
		return false
	end

	return astar.find_path(map_handler, from_x, from_y, to_x, to_y)
end


function M.for_path(path, callback)
	if not path then
		return nil
	end

	for i = 1, #path.nodes do
		local x = path.nodes[i].x
		local y = path.nodes[i].y
		callback(x, y, i)
	end
end


return M
