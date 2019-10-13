--- Eva tiled	 module
-- Can load maps, exported from tiled
-- Need to bind some objects before creating stuff
-- @submodule eva


local M = {}


local function process_tiles(data, layer, mapping, index)
	assert(mapping[layer.name], "Should be mapping for layer name")
	local width = layer.width
	local height = layer.height
	local layer_mapping = mapping[layer.name]
	local tile_width = data.tilewidth - 1
	local tile_height = data.tileheight / 2 - 3

	for i = 1, #layer.data do
		local value = layer.data[i]
		if value > 0 and layer_mapping[value-1] then

			-- To calc from hexgrid position
			local pos_x = i % width
			local pos_y = height - math.floor(i / width)

			if (pos_y % 2 == 0) then
				pos_x = pos_x - 0.5
			end


			local position = vmath.vector3(pos_x * tile_width, pos_y * tile_height, pos_y/100)
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

	local height = data.height
	local tile_height = data.tileheight
	local scene_height = height * tile_height

	local objects = layer.objects
	for i = 1, #objects do
		local object = objects[i]
		local gid_offset = data.tilesets[index].firstgid
		local object_id = object.gid - gid_offset
		local position = vmath.vector3(object.x, scene_height/2 - object.y, 50 - (scene_height/2 - object.y) / 100)
		layer_mapping[object_id](position)
	end
end


function M.load_map(data, mapping)
	local map_layers = data.layers

	for i = 1, #map_layers do
		if map_layers[i].type == "tilelayer" then
			process_tiles(data, map_layers[i], mapping, i)
		end
		if map_layers[i].type == "objectgroup" then
			process_objects(data, map_layers[i], mapping, i)
		end
	end
end


return M
