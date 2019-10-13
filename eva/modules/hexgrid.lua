--- Eva hex grid module
-- It contains some functions to calculate positions
-- on map in hexagon grid representation
-- @submodule eva

local app = require("eva.app")
local luax = require("eva.luax")

local M = {}


local function get_scene_size()
	local data = app.hexgrid_data
	local tile_count = data.height

	local tile_height = data.tileheight
	local tile_hex_size = data.hexsidelength

	local size_y = math.floor(tile_count/2) * (tile_height + tile_hex_size)
	if tile_count % 2 == 1 then
		size_y = size_y + tile_height
	end

	return vmath.vector3(data.width * data.tilewidth, size_y, 0)
end


function M.set_data(data)
	app.hexgrid_data = data
	app.hexgrid_meta = {
		scene_size = get_scene_size()
	}
end


function M.cell_to_pos(i, j)
	local data = app.hexgrid_data
	local scene_size = app.hexgrid_meta.scene_size
	local double_side = (data.tileheight + data.hexsidelength)

	local x = data.tilewidth * (i + 0.5 * (bit.band(j, 1)))
	local y = double_side / 2 * j

	-- invert
	y = scene_size.y - y

	return x, y
end


function M.pos_to_cell(x, y)
	local data = app.hexgrid_data
	local scene_size = app.hexgrid_meta.scene_size
	local double_side = data.tileheight + data.hexsidelength

	-- invert
	y = scene_size.y - y

	local j = 2 * y / double_side
	local i = x / data.tilewidth - 0.5 * bit.band(j, 1)

	return luax.math.round(i), luax.math.round(j)
end


function M.get_object_pos(object)
	local scene_size = app.hexgrid_meta.scene_size

	local x = object.x
	local y = scene_size.y - object.y
	-- TODO: wtf?
	local z = 50 - (scene_size.y/2 - object.y) / 100

	return vmath.vector3(x, y, z)
end


function M.get_tile_pos(i, j)
	local x, y = M.cell_to_pos(i, j)

	return vmath.vector3(x, y, j/100)
end


return M
