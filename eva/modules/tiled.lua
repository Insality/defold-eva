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


local function process_tiles(data, layer, mapping, index)
	assert(mapping[layer.name], "Should be mapping for layer name")
	local width = layer.width
	local layer_mapping = mapping[layer.name]

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
		if value > 0 and layer_mapping[value-1] then
			local cell_y = math.floor((i-1) / width)
			local cell_x = (i-1) - (cell_y * width)

			local position = hexgrid.get_tile_pos(cell_x, cell_y, z_layer)
			layer_mapping[value-1](position)
		end
	end
end


local function process_objects(data, layer, mapping, index, objects_data)
	local layer_mapping = mapping[layer.name]
	if not layer_mapping then
		print("No mapping for layer", layer.name)
		return
	end

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
		layer_mapping[object_id](position)
	end
end


function M.load_map(data, mapping, path_to_objects)
	data.tilewidth = data.tilewidth - 1
	data.tileheight = data.tileheight - 1
	data.hexsidelength = data.hexsidelength - 1

	local map_params = hexgrid.get_map_params(data.tilewidth, data.tileheight,
		data.hexsidelength, data.width, data.height)
	hexgrid.set_default_map_params(map_params)
	local map_layers = data.layers

	for i = 1, #map_layers do
		if map_layers[i].type == "tilelayer" then
			process_tiles(data, map_layers[i], mapping, i)
		end
		if map_layers[i].type == "objectgroup" then
			local objects = utils.load_json(path_to_objects .. map_layers[i].name .. ".json")
			process_objects(data, map_layers[i], mapping, i, objects)
		end
	end
end


return M
