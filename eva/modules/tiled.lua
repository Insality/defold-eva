--- Eva tiled	 module
-- Can load maps, exported from tiled
-- Need to bind some objects before creating stuff
-- @submodule eva

local luax = require("eva.luax")

local utils = require("eva.modules.utils")
local hexgrid = require("eva.modules.hexgrid")

local M = {}


local function process_tiles(data, layer, mapping, index)
	assert(mapping[layer.name], "Should be mapping for layer name")
	local width = layer.width
	local layer_mapping = mapping[layer.name]

	for i = 1, #layer.data do
		local value = layer.data[i]
		if value > 0 and layer_mapping[value-1] then
			local cell_y = math.floor((i-1) / width)
			local cell_x = (i-1) - (cell_y * width)

			local position = hexgrid.get_tile_pos(cell_x, cell_y)
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

	local objects = layer.objects
	for i = 1, #objects do
		local object = objects[i]
		local gid_offset = data.tilesets[index].firstgid
		local object_id = object.gid - gid_offset
		local position = hexgrid.get_object_pos(object)

		local obj_data = luax.table.get_item_from_array(objects_data.tiles, "id", object_id)
		local object_objects = obj_data.objectgroup.objects

		if #object_objects > 0 then
			local point = luax.table.get_item_from_array(object_objects, "point", true)
			position.x = position.x + point.x
			position.y = position.y + (obj_data.imageheight - point.y)
		end

		layer_mapping[object_id](position)
	end
end


function M.load_map(data, mapping, path_to_objects)
	data.tilewidth = data.tilewidth - 1
	data.tileheight = data.tileheight - 1
	data.hexsidelength = data.hexsidelength - 1

	hexgrid.set_data(data)
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
