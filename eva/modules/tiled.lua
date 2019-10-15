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


local function process_objects(data, layer, create_object_fn, index, objects_data)
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
		local offset = nil

		-- Calc offset from object anchor
		local obj_data = luax.table.get_item_from_array(objects_data.tiles, "id", object_id)
		local object_objects = obj_data.objectgroup.objects
		if #object_objects > 0 then
			local point = luax.table.get_item_from_array(object_objects, "point", true)
			offset = vmath.vector3(point.x, (obj_data.imageheight - point.y), 0)
		end

		local position = hexgrid.get_object_pos(object.x, object.y, offset, is_grid_center, z_layer)
		create_object_fn(layer.name, object_id, position)
	end
end


--- Load map from tiled json data
-- @function eva.tiled.load_map
-- @tparam table data Json map data
-- @tparam callback create_object_fn Module call this with param(object_layer, object_id, position)
-- @tparam string path_to_objects Path with all tilesets jsons. Need to get anchor (need to remove it to automapping)
function M.load_map(data, create_object_fn, path_to_objects)
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
			local objects = utils.load_json(path_to_objects .. map_layers[i].name .. ".json")
			process_objects(data, map_layers[i], create_object_fn, i, objects)
		end
	end
end


return M
