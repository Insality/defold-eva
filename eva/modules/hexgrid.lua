--- Eva hex grid module
-- It contains some functions to calculate positions
-- on map in hexagon grid representation
-- Cells starts from 0, 0 from left top corner
-- Hexagon grid type: oddr, pointytop
-- For more info see here: https://www.redblobgames.com/grids/hexagons/#coordinates-offset
-- @submodule eva

local app = require("eva.app")
local luax = require("eva.luax")

local M = {}


local function get_scene_size(map_params)
	local data = map_params or app.hexgrid_default

	local double_size = data.tile.height + data.tile.side

	local width = (data.scene.tiles_x+0.5) * data.tile.width
	local height = (data.scene.tiles_y/2 * double_size) + (data.tile.height-data.tile.side)/2
	return width, height
end


--- Get map params data to work with it
-- You can pass directly params in every method or set is as default
-- with eva.hexgrid.set_default_map_params
-- Pass the map sizes to calculate correct coordinates
-- @function eva.hexgrid.get_map_params
-- @tparam number tilewidth Hexagon width
-- @tparam number tileheight Hexagon height
-- @tparam number tileside Hexagon side height
-- @tparam number tiles_x Map width in tiles count
-- @tparam number tiles_y Map height in tiles count
-- @treturn map_params Map params data
function M.get_map_params(tilewidth, tileheight, tileside, tiles_x, tiles_y, invert_y)
	local map_params = {}
	map_params.tile = {
		width = tilewidth,
		height = tileheight,
		side = tileside,
		double_side = tileheight + tileside
	}
	map_params.scene = {
		invert_y = invert_y,
		tiles_x = tiles_x,
		tiles_y = tiles_y,
		size_x = 0,
		size_y = 0
	}

	local size_x, size_y = get_scene_size(map_params)
	map_params.scene.size_x = size_x
	map_params.scene.size_y = size_y

	return map_params
end


--- Set default map params
-- To dont pass it every time in transform functions
-- @function eva.hexgrid.set_default_map_params
-- @tparam map_params map_params Params from eva.hexgrid.get_map_params
function M.set_default_map_params(map_params)
	app.hexgrid_default = map_params
end


--- Transform hex to pixel position
-- @function eva.hexgrid.cell_to_pos
function M.cell_to_pos(i, j, map_params)
	local data = map_params or app.hexgrid_default

	local part_size = data.tile.height - data.tile.side

	local x = data.tile.width * (i + 0.5 * (bit.band(j, 1)))
	local y = data.tile.double_side / 2 * j

	-- invert
	if data.scene.invert_y then
		y = data.scene.size_y - y
	end
	-- add half offset
	x = x + data.tile.width/2
	y = y + (data.scene.invert_y and -part_size or part_size)

	return x, y
end


--- Transform pixel to hex
-- @function eva.hexgrid.pos_to_cell
function M.pos_to_cell(x, y, map_params)
	local data = map_params or app.hexgrid_default

	local part_size = (data.tile.height - data.tile.side)

	-- add half offset
	x = x - data.tile.width/2
	y = y - (data.scene.invert_y and -part_size or part_size)
	-- invert
	if data.scene.invert_y then
		y = data.scene.size_y - y
	end

	local j = 2 * y / data.tile.double_side
	local i = x / data.tile.width - 0.5 * bit.band(j, 1)

	return luax.math.round(i), luax.math.round(j)
end


--- Get Z position from object Y position and his z_layer
-- @function eva.hexgrid.get_z
-- @tparam number y Object Y position
-- @tparam number z_layer Object Z layer index
-- @treturn map_params Map params data
function M.get_z(y, z_layer, map_params)
	z_layer = z_layer or 0
	local data = map_params or app.hexgrid_default

	local y_value = (y - z_layer * 200)
	y_value = data.scene.size_y - y_value

	local z_pos = y_value / 200

	return z_pos
end


--- Get object position
-- Can pass the offset to calculate it correctly (+ z coordinate)
-- @function eva.hexgrid.get_object_pos
-- @treturn vector3 Object position
function M.get_object_pos(x, y, z_layer, map_params)
	return vmath.vector3(x, y, M.get_z(y, z_layer, map_params))
end


--- Convert tiled object position to scene position
-- @function eva.hexgrid.get_tiled_scene_pos
-- @treturn number,number x,y Object scene position
function M.get_tiled_scene_pos(tiled_x, tiled_y, offset, is_grid_center, map_params)
	local data = map_params or app.hexgrid_default

	local x = tiled_x
	local y = tiled_y
	if data.scene.invert_y then
		y = data.scene.size_y - y
	end

	if offset then
		x = x + offset.x
		y = y + (data.scene.invert_y and offset.y or -offset.y)
	end

	if is_grid_center then
		x, y = M.cell_to_pos(M.pos_to_cell(x, y))
	end

	return x, y
end


--- Get tile position. Convert from i, j to map position
-- @function eva.hexgrid.get_tile_pos
-- @treturn vector3 Tile position
function M.get_tile_pos(i, j, z_layer, map_params)
	z_layer = z_layer or 0
	local x, y = M.cell_to_pos(i, j, map_params)

	return vmath.vector3(x, y, M.get_z(y, z_layer))
end


return M
