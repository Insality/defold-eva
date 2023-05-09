--- Eva grid module
-- It contains some functions to calculate positions
-- on map in grid representation
-- @submodule eva


local app = require("eva.app")

local M = {}


local function get_scene_size(map_params)
	local data = map_params or app.grid_default

	local width = data.scene.tiles_x * data.tile.width
	local height = data.scene.tiles_y * data.tile.height
	return width, height
end


--- Get map params data to work with it
-- You can pass directly params in every method or set is as default
-- with eva.grid.set_default_map_params
-- Pass the map sizes to calculate correct coordinates
-- @function eva.grid.get_map_params
-- @treturn map_params Map params data
function M.get_map_params(options)
	local map_params = {}
	map_params.tile = {
		width = options.tilewidth,
		height = options.tileheight
	}
	map_params.scene = {
		invert_y = options.invert_y,
		tiles_x = options.width,
		tiles_y = options.height,
		size_x = 0,
		size_y = 0
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
		width = tiled_data.width,
		height = tiled_data.height,
		invert_y = true
	})
end



--- Set default map params
-- To don`t pass it every time in transform functions
-- @function eva.grid.set_default_map_params
-- @tparam map_params map_params Params from eva.grid.get_map_params
function M.set_default_map_params(map_params)
	app.clear("grid_default")
	app.grid_default = map_params
end


--- Transform hex to pixel position
-- @function eva.grid.cell_to_pos
function M.cell_to_pos(i, j, map_params)
	local data = map_params or app.grid_default

	local x = data.tile.width * i
	local y = data.tile.height * j

	-- invert
	if data.scene.invert_y then
		y = data.scene.size_y - y
	end

	-- add half offset
	x = x + data.tile.width/2
	y = y + (data.scene.invert_y and -data.tile.height/2 or data.tile.height/2)

	return x, y
end


--- Transform pixel to hex
-- @function eva.grid.pos_to_cell
function M.pos_to_cell(x, y, map_params)
	local data = map_params or app.grid_default

	-- add half offset
	x = x - data.tile.width
	y = y - (data.scene.invert_y and -data.tile.height or data.tile.height)

	-- invert
	if data.scene.invert_y then
		y = data.scene.size_y - y
	end

	local i = x / data.tile.width
	local j = y / data.tile.height

	return math.ceil(i), math.ceil(j)
end


--- Get Z position from object Y position and his z_layer
-- @function eva.grid.get_z
-- @tparam number y Object Y position
-- @tparam number z_layer Object Z layer index
-- @treturn map_params Map params data
function M.get_z(y, z_layer, map_params)
	z_layer = z_layer or 0
	local data = map_params or app.grid_default

	local y_value = (y - z_layer * 100000)
	y_value = data.scene.size_y - y_value

	local z_pos = y_value / 100000

	return z_pos
end


--- Get object position
-- Can pass the offset to calculate it correctly (+ z coordinate)
-- @function eva.grid.get_object_pos
-- @treturn number, number, number Object position
function M.get_object_pos(x, y, z_layer, map_params)
	return x, y, M.get_z(y, z_layer, map_params)
end


--- Convert tiled object position to scene position
-- @function eva.grid.get_tiled_scene_pos
-- @treturn number,number x,y Object scene position
function M.get_tiled_scene_pos(tiled_x, tiled_y, offset, is_grid_center, map_params)
	local data = map_params or app.grid_default

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
-- @function eva.grid.get_tile_pos
-- @treturn number, number, number Tile position
function M.get_tile_pos(i, j, z_layer, map_params)
	z_layer = z_layer or 0
	local x, y = M.cell_to_pos(i, j, map_params)

	return x, y, M.get_z(y, z_layer)
end


return M
