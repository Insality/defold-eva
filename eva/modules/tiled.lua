--- Eva tiled	 module
-- Can load maps, exported from tiled
-- Need to bind some objects before creating stuff
--
-- Tiled configuration:
-- Layers:
-- 	Layer can have properties:
-- 	- grid_center (bool) - if true, center every object to map grid
-- 	- z_layer (int) - z_layer of the layer
-- @submodule eva

local luax = require("eva.luax")
local app = require("eva.app")

local utils = require("eva.modules.utils")
local hexgrid = require("eva.modules.hexgrid")

local M = {}


local function process_tiles(data, layer, create_object_fn, index)
	local width = layer.width

	local z_layer = 0
	local props = layer.properties
	if props then
		local layer_prop = luax.table.get_item_from_array(props, "name", "z_layer")
		if layer_prop then
			z_layer = layer_prop.value
		end
	end

	for i = 1, #layer.data do
		local value = layer.data[i]
		if value > 0 then
			local cell_y = math.floor((i-1) / width)
			local cell_x = (i-1) - (cell_y * width)

			local position = hexgrid.get_tile_pos(cell_x, cell_y, z_layer)
			create_object_fn(layer.name, value-1, position)
		end
	end
end


local function process_objects(data, layer, create_object_fn, index)
	local is_grid_center = false
	local z_layer = 3
	local props = layer.properties
	if props then
		local is_grid_prop = luax.table.get_item_from_array(props, "name", "grid_center")
		if is_grid_prop then
			is_grid_center = is_grid_prop.value
		end
		local layer_prop = luax.table.get_item_from_array(props, "name", "z_layer")
		if layer_prop then
			z_layer = layer_prop.value
		end
	end


	local objects = layer.objects
	for i = 1, #objects do
		local object = objects[i]
		local gid_offset = data.tilesets[index].firstgid
		local object_id = object.gid - gid_offset

		local mapping_config_name = app.settings.tiled.mapping_config
		local mapping_data = app.db[mapping_config_name]
		local odata = mapping_data[layer.name][tostring(object_id)]
		local offset = vmath.vector3(
			odata.width/2 - odata.anchor.x,
			odata.height/2 - odata.anchor.y - 2,
		0)

		local position = hexgrid.get_object_pos(object.x, object.y, offset, is_grid_center, z_layer)
		create_object_fn(layer.name, object_id, position)
	end
end


--- Load map from tiled json data
-- @function eva.tiled.load_map
-- @tparam table data Json map data
-- @tparam callback create_object_fn Module call this with param(object_layer, object_id, position)
function M.load_map(data, create_object_fn)
	data.tilewidth = data.tilewidth - 1
	data.tileheight = data.tileheight - 1
	data.hexsidelength = data.hexsidelength - 1

	local map_params = hexgrid.get_map_params(data.tilewidth, data.tileheight,
		data.hexsidelength, data.width, data.height)
	hexgrid.set_default_map_params(map_params)
	local map_layers = data.layers

	for i = 1, #map_layers do
		if map_layers[i].type == "tilelayer" then
			process_tiles(data, map_layers[i], create_object_fn, i)
		end
		if map_layers[i].type == "objectgroup" then
			process_objects(data, map_layers[i], create_object_fn, i)
		end
	end
end


return M
