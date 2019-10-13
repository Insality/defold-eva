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


local function get_pos_y(cell_y)
	local data = app.hexgrid_data
	local scene_size = app.hexgrid_meta.scene_size

	local tile_height = data.tileheight
	local tile_hex_size = data.hexsidelength

	local y = math.floor(cell_y/2) * (tile_height + tile_hex_size)

	if cell_y % 2 == 1 then
		y = y + tile_height/2
	else
		y = y - tile_hex_size/2
	end

	return scene_size.y - y - (tile_height + tile_hex_size)/2
end


function M.set_data(data)
	app.hexgrid_data = data
	app.hexgrid_meta = {
		scene_size = get_scene_size()
	}
end


function M.cell_to_pos(i, j)
	local data = app.hexgrid_data
	local size = data.hexsidelength
	local scene_size = app.hexgrid_meta.scene_size

	local x = size * math.sqrt(3) * (i + 0.5 * (bit.band(j, 1)))
	local y = size * 3/2 * j

	-- just offset
	x = x - scene_size.x/2
	-- invert and offset
	y = scene_size.y - y
	y = y - scene_size.y/2

	return x, y
end


local function cube_round(x, y, z)
	local rx = luax.math.round(x)
	local ry = luax.math.round(y)
	local rz = luax.math.round(z)

	local x_diff = math.abs(rx - x)
	local y_diff = math.abs(ry - y)
	local z_diff = math.abs(rz - z)

	if x_diff > y_diff and x_diff > z_diff then
		rx = -ry-rz
	elseif y_diff > z_diff then
		ry = -rx-rz
	else
		rz = -rx-ry
	end

	return rx, ry, rz
end


local function hex_round(i, j)
	local x, _, z = cube_round(i, -i-j, j)
	local col = x + (z - (bit.band(z, 1))) / 2
	local row = z
	return col, row
end


function M.pos_to_cell(px, py)
	local data = app.hexgrid_data
	local scene_size = app.hexgrid_meta.scene_size
	px = px + scene_size.x/2
	py = py + scene_size.y/2
	py = scene_size.y - py

	local i = (math.sqrt(3)/3 * px - py/3) / data.hexsidelength
	local j = (2*py/3) / data.hexsidelength

	return hex_round(i, j)
end


function M.get_object_pos(object)
	local scene_size = app.hexgrid_meta.scene_size

	local x = object.x - scene_size.x/2
	-- invert Y, - scene offset
	local y = scene_size.y - object.y - scene_size.y/2
	local z = 50 - (scene_size.y/2 - object.y) / 100

	return vmath.vector3(x, y, z)
end


function M.get_tile_pos(i, j)
	local x, y = M.cell_to_pos(i, j)

	return vmath.vector3(x, y, j/100)
end


return M
