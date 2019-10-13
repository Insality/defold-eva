--- Eva hex grid module
-- It contains some functions to calculate positions
-- on map in hexagon grid representation
-- @submodule eva

local app = require("eva.app")
local luax = require("eva.luax")

local M = {}


local function get_scene_size()
	local data = app.hexgrid_data

	local double_size = data.tileheight + data.hexsidelength

	local width = (data.width+0.5) * data.tilewidth
	local height = (data.height/2 * double_size) + (data.tileheight-data.hexsidelength)/2
	return vmath.vector3(width, height, 0)
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
	local part_size = (data.tileheight - data.hexsidelength)

	local x = data.tilewidth * (i + 0.5 * (bit.band(j, 1)))
	local y = double_side / 2 * j

	-- invert
	y = scene_size.y - y
	-- add half offset
	x = x + data.tilewidth/2
	y = y - part_size

	return x, y
end


function M.pos_to_cell(x, y)
	local data = app.hexgrid_data
	local scene_size = app.hexgrid_meta.scene_size
	local double_side = data.tileheight + data.hexsidelength
	local part_size = (data.tileheight - data.hexsidelength)

	-- add half offset
	x = x - data.tilewidth/2
	y = y + part_size
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
