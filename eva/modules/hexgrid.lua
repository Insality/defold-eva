--- Eva hex grid module
-- It contains some functions to calculate positions
-- on map in hexagon grid representation
-- Cells starts from 0, 0 from left top corner
-- Hexagon grid type: oddr, pointytop
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



function M.get_map_params(tilewidth, tileheight, tileside, tiles_x, tiles_y)
	local map_params = {}
	map_params.tile = {
		width = tilewidth,
		height = tileheight,
		side = tileside,
		double_side = tileheight + tileside
	}
	map_params.scene = {
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


function M.cell_to_pos(i, j, map_params)
	local data = map_params or app.hexgrid_default

	local part_size = data.tile.height - data.tile.side

	local x = data.tile.width * (i + 0.5 * (bit.band(j, 1)))
	local y = data.tile.double_side / 2 * j

	-- invert
	y = data.scene.size_y - y
	-- add half offset
	x = x + data.tile.width/2
	y = y - part_size

	return x, y
end


function M.pos_to_cell(x, y, map_params)
	local data = map_params or app.hexgrid_default

	local part_size = (data.tile.height - data.tile.side)

	-- add half offset
	x = x - data.tile.width/2
	y = y + part_size
	-- invert
	y = data.scene.size_y - y

	local j = 2 * y / data.tile.double_side
	local i = x / data.tile.width - 0.5 * bit.band(j, 1)

	return luax.math.round(i), luax.math.round(j)
end


function M.get_object_pos(object, offset, map_params)
	local data = map_params or app.hexgrid_default

	local x = object.x
	local y = data.scene.size_y - object.y

	if offset then
		x = x + offset.x
		y = y + offset.y
	end

	local z = (data.scene.size_y - y) / 100

	return vmath.vector3(x, y, z)
end


function M.get_tile_pos(i, j, map_params)
	local x, y = M.cell_to_pos(i, j, map_params)

	return vmath.vector3(x, y, j/100)
end


return M
