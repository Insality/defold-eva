--- Eva hex grid module
-- It contains some functions to calculate positions
-- on map in hexagon grid representation
-- Cells starts from 0, 0 from left top corner
-- Hexagon grid type: oddr, pointytop
-- For more info see here: https://www.redblobgames.com/grids/hexagons/#coordinates-offset
-- @submodule eva


local app = require("eva.app")
local log = require("eva.log")
local const = require("eva.const")

local hexgrid_convert = require("eva.modules.hexgrid.hexgrid_convertations")
local logger = log.get_logger("exa.hexgrid")

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
-- @tparam number tileside Hexagon side length (flat side)
-- @tparam number width Map width in tiles count
-- @tparam number height Map height in tiles count
-- @tparam boolean invert_y If true, zero pos will be at top, else on bot
-- @treturn map_params Map params data
function M.get_map_params(options)
	local map_params = {}
	map_params.tile = {
		width = options.tilewidth,
		height = options.tileheight,
		side = options.tileside,
	}
	map_params.scene = {
		invert_y = options.invert_y,
		tiles_x = options.width,
		tiles_y = options.height,
		size_x = 0,
		size_y = 0,
		hexmap_type = options.hexmap_type or const.HEXMAP_TYPE.POINTYTOP
	}

	local size_x, size_y = get_scene_size(map_params)
	map_params.scene.size_x = size_x
	map_params.scene.size_y = size_y

	return map_params
end


function M.get_map_params_from_tiled(tiled_data)
	return M.get_map_params({
		tilewidth = tiled_data.tilewidth,
		tileheight = tiled_data.tileheight,
		tileside = tiled_data.hexsidelength,
		width = tiled_data.width,
		height = tiled_data.height,
		hexmap_type = tiled_data.staggeraxis == "x" and const.HEXMAP_TYPE.FLATTOP or const.HEXMAP_TYPE.POINTYTOP,
		invert_y = true
	})
end


--- Set default map params
-- To dont pass it every time in transform functions
-- @function eva.hexgrid.set_default_map_params
-- @tparam map_params map_params Params from eva.hexgrid.get_map_params
function M.set_default_map_params(map_params)
	app.clear("hexgrid_default")
	app.hexgrid_default = map_params
end


--- Transform hex to pixel position. Offset coordinates
-- @function eva.hexgrid.cell_to_pos
-- @tparam number i Cell i coordinate
-- @tparam number j Cell j coordinate
-- @tparam map_params map_params Params from eva.hexgrid.get_map_params
function M.cell_to_pos(i, j, map_params)
	map_params = map_params or app.hexgrid_default

	if map_params.scene.hexmap_type == const.HEXMAP_TYPE.POINTYTOP then
		return hexgrid_convert.cell_to_pos_pointytop(i, j, map_params)
	end
	if map_params.scene.hexmap_type == const.HEXMAP_TYPE.FLATTOP then
		return hexgrid_convert.cell_to_pos_flattop(i, j, map_params)
	end

	logger.error("Unknown hexmap type")
end


--- Transform pixel to hex. Offset coordinates
-- @function eva.hexgrid.pos_to_cell
-- @tparam number x World x position
-- @tparam number y World y position
-- @tparam map_params map_params Params from eva.hexgrid.get_map_params
function M.pos_to_cell(x, y, map_params)
	map_params = map_params or app.hexgrid_default

	if map_params.scene.hexmap_type == const.HEXMAP_TYPE.POINTYTOP then
		return hexgrid_convert.pos_to_cell_pointytop(x, y, map_params)
	end
	if map_params.scene.hexmap_type == const.HEXMAP_TYPE.FLATTOP then
		return hexgrid_convert.pos_to_cell_flattop(x, y, map_params)
	end

	logger.error("Unknown hexmap type")
end


--- Transform hex to pixel position. Offset coordinates
-- @function eva.hexgrid.cell_cube_to_pos
-- @tparam number i Cell i coordinate
-- @tparam number j Cell j coordinate
-- @tparam number k Cell k coordinate
-- @tparam[opt] map_params map_params Params from eva.hexgrid.get_map_params
function M.cell_cube_to_pos(i, j, k, map_params)
	map_params = map_params or app.hexgrid_default

	if map_params.scene.hexmap_type == const.HEXMAP_TYPE.POINTYTOP then
		return hexgrid_convert.cell_cube_to_pos_pointytop(i, j, k, map_params)
	end
	if map_params.scene.hexmap_type == const.HEXMAP_TYPE.FLATTOP then
		return hexgrid_convert.cell_cube_to_pos_flattop(i, j, k, map_params)
	end

	logger.error("Unknown hexmap type")
end


--- Transform pixel to hex. Cube coordinates
-- @function eva.hexgrid.pos_to_cell_cube
-- @tparam number x World x position
-- @tparam number y World y position
-- @tparam map_params map_params Params from eva.hexgrid.get_map_params
function M.pos_to_cell_cube(x, y, map_params)
	map_params = map_params or app.hexgrid_default

	if map_params.scene.hexmap_type == const.HEXMAP_TYPE.POINTYTOP then
		return hexgrid_convert.pos_to_cell_cube_pointytop(x, y, map_params)
	end
	if map_params.scene.hexmap_type == const.HEXMAP_TYPE.FLATTOP then
		return hexgrid_convert.pos_to_cell_cube_flattop(x, y, map_params)
	end

	logger.error("Unknown hexmap type")
end


--- Transfrom offset coordinates to cube coordinates
-- @function eva.hexgrid.offset_to_cube
-- @tparam number i I coordinate
-- @tparam number j J coordinate
-- @tparam[opt] map_params map_params Params from eva.hexgrid.get_map_params
function M.offset_to_cube(i, j, map_params)
	map_params = map_params or app.hexgrid_default

	if map_params.scene.hexmap_type == const.HEXMAP_TYPE.POINTYTOP then
		return hexgrid_convert.offset_to_cube_pointytop(i, j, map_params)
	end
	if map_params.scene.hexmap_type == const.HEXMAP_TYPE.FLATTOP then
		return hexgrid_convert.offset_to_cube_flattop(i, j, map_params)
	end

	logger.error("Unknown hexmap type")
end


--- Transfrom cube coordinates to offset coordinates
-- @function eva.hexgrid.cube_to_offset
-- @tparam number i I coordinate
-- @tparam number j J coordinate
-- @tparam number k K coordinate
-- @tparam[opt] map_params map_params Params from eva.hexgrid.get_map_params
function M.cube_to_offset(i, j, k, map_params)
	assert((i + j + k) == 0, "Wrong cube coordinates")

	map_params = map_params or app.hexgrid_default

	if map_params.scene.hexmap_type == const.HEXMAP_TYPE.POINTYTOP then
		return hexgrid_convert.cube_to_offset_pointytop(i, j, k, map_params)
	end
	if map_params.scene.hexmap_type == const.HEXMAP_TYPE.FLATTOP then
		return hexgrid_convert.cube_to_offset_flattop(i, j, k, map_params)
	end

	logger.error("Unknown hexmap type")
end


--- Rotate offset coordinate by N * 60degree
-- @function eva.hexgrid.rotate_offset
-- @tparam number i I coordinate
-- @tparam number j J coordinate
-- @tparam number k K coordinate
-- @tparam number N Number, how much rotate on 60 degrees. Positive - rotate right, Negative - left
---@treturn number, number, number Offset coordinate
function M.rotate_offset(i, j, k, N)
	while N > 0 do
		N = N - 1
		i, j, k = -k, -i, -j
	end

	while N < 0 do
		N = N + 1
		i, j, k = -j, -k, -i
	end

	return i, j, k
end


--- Get Z position from object Y position and his z_layer
-- @function eva.hexgrid.get_z
-- @tparam number y Object Y position
-- @tparam number z_layer Object Z layer index
-- @treturn map_params Map params data
function M.get_z(y, z_layer, map_params)
	z_layer = z_layer or 0
	local data = map_params or app.hexgrid_default

	local y_value = (y - z_layer * 100000)
	y_value = data.scene.size_y - y_value

	local z_pos = y_value / 100000

	return z_pos
end


--- Get object position
-- Can pass the offset to calculate it correctly (+ z coordinate)
-- @function eva.hexgrid.get_object_pos
-- @treturn number, number, number Object position
function M.get_object_pos(x, y, z_layer, map_params)
	return x, y, M.get_z(y, z_layer, map_params)
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
-- @treturn number, number, number Tile position
function M.get_tile_pos(i, j, z_layer, map_params)
	z_layer = z_layer or 0
	local x, y = M.cell_to_pos(i, j, map_params)

	return x, y, M.get_z(y, z_layer)
end


return M
