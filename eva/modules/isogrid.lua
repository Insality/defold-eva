--- Eva isometric grid module
-- It contains some functions to calculate positions
-- on map in isometric grid representation
-- @submodule eva

local app = require("eva.app")

local M = {}


--- Get map params data to work with it
-- You can pass directly params in every method or set is as default
-- with eva.isogrid.set_default_map_params
-- Pass the map sizes to calculate correct coordinates
-- @function eva.isogrid.get_map_params
-- @treturn map_params Map params data
function M.get_map_params(tilewidth, tileheight, tileside, tiles_x, tiles_y)
end


--- Set default map params
-- To don`t pass it every time in transform functions
-- @function eva.isogrid.set_default_map_params
-- @tparam map_params map_params Params from eva.isogrid.get_map_params
function M.set_default_map_params(map_params)
	app.isogrid_default = map_params
end


--- Transform hex to pixel position
-- @function eva.isogrid.cell_to_pos
function M.cell_to_pos(i, j, map_params)
end


--- Transform pixel to hex
-- @function eva.isogrid.pos_to_cell
function M.pos_to_cell(x, y, map_params)
end


--- Get Z position from object Y position and his z_layer
-- @function eva.isogrid.get_z
-- @tparam number y Object Y position
-- @tparam number z_layer Object Z layer index
-- @treturn map_params Map params data
function M.get_z(y, z_layer, map_params)
	local data = map_params or app.isogrid_default
	return 0
end


--- Get object position
-- Can pass the offset to calculate it correctly (+ z coordinate)
-- @function eva.isogrid.get_object_pos
-- @treturn vector3 Object position
function M.get_object_pos(x, y, z_layer, map_params)
	return vmath.vector3(x, y, M.get_z(y, z_layer, map_params))
end


--- Convert tiled object position to scene position
-- @function eva.isogrid.get_tiled_scene_pos
-- @treturn number,number x,y Object scene position
function M.get_tiled_scene_pos(tiled_x, tiled_y, offset, is_grid_center, map_params)
	local data = map_params or app.isogrid_default
end


--- Get tile position. Convert from i, j to map position
-- @function eva.isogrid.get_tile_pos
-- @treturn vector3 Tile position
function M.get_tile_pos(i, j, z_layer, map_params)
end


return M
