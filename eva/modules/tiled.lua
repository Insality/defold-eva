--- Eva tiled	 module
-- Can load maps, exported from tiled
-- Need to bind some objects before creating stuff
-- @submodule eva

local hexgrid = require("eva.modules.hexgrid")

local M = {}


local function process_tiles(data, layer, mapping, index)
	assert(mapping[layer.name], "Should be mapping for layer name")
	local width = layer.width
	local layer_mapping = mapping[layer.name]

	for i = 1, #layer.data do
		local value = layer.data[i]
		if value > 0 and layer_mapping[value-1] then
			local cell_x = (i % width) - 1
			local cell_y = math.floor(i / width)

			local position = hexgrid.get_tile_pos(cell_x, cell_y)
			layer_mapping[value-1](position)
		end
	end
end


local function process_objects(data, layer, mapping, index)
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
		layer_mapping[object_id](position)
	end
end


function M.load_map(data, mapping)
	hexgrid.set_data(data)
	local map_layers = data.layers

	for i = 1, #map_layers do
		if map_layers[i].type == "tilelayer" then
			process_tiles(data, map_layers[i], mapping, i)
		end
		if map_layers[i].type == "objectgroup" then
			-- process_objects(data, map_layers[i], mapping, i)
		end
	end
end


return M
