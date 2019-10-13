--- Eva tiled	 module
-- Can load maps, exported from tiled
-- Need to bind some objects before creating stuff
-- @submodule eva


local M = {}


local function get_y_size(tile_pos_y, data)
	local tile_height = data.tileheight
	local tile_hex_size = data.hexsidelength

	local y = math.floor(tile_pos_y/2) * (tile_height + tile_hex_size)
	if tile_pos_y % 2 == 1 then
		y = y + tile_height
	end
	return y
end

local function get_y_pos(tile_pos_y, data)
	local scene_size_y = get_y_size(data.height, data)

	local tile_height = data.tileheight
	local tile_hex_size = data.hexsidelength

	local y = math.floor(tile_pos_y/2) * (tile_height + tile_hex_size)
	if tile_pos_y % 2 == 1 then
		y = y + tile_height
		y = y - tile_height/2
	else
		y = y - tile_hex_size/2
	end


	return scene_size_y - y
end



local function process_tiles(data, layer, mapping, index)
	assert(mapping[layer.name], "Should be mapping for layer name")
	local width = layer.width
	local height = layer.height
	local layer_mapping = mapping[layer.name]
	local tile_width = data.tilewidth

	local scene_size = vmath.vector3(
		width * data.tilewidth,
		get_y_size(height, data),
		0
	)

	pprint("Scene size", scene_size)

	for i = 1, #layer.data do
		local value = layer.data[i]
		if value > 0 and layer_mapping[value-1] then

			-- To calc from hexgrid position
			local pos_x = (i % width) - 1
			local pos_y = math.floor(i / width) + 1

			if (pos_y % 2 == 0) then
				pos_x = pos_x + 0.5
			end

			local pos_y_pixel = get_y_pos(pos_y, data) - scene_size.y/2
			local position = vmath.vector3(pos_x * tile_width - scene_size.x/2, pos_y_pixel, pos_y/100)
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

	local scene_size = vmath.vector3(
		data.width * data.tilewidth,
		get_y_size(data.height, data),
		0
	)
	pprint("Scene size", scene_size)

	local height = data.height
	local tile_height = data.tileheight
	local scene_height = height * tile_height

	local objects = layer.objects
	for i = 1, #objects do
		local object = objects[i]
		local gid_offset = data.tilesets[index].firstgid
		local object_id = object.gid - gid_offset
		local position = vmath.vector3(object.x - scene_size.x/2, scene_size.y - (object.y + scene_size.y/2), 50 - (scene_height/2 - object.y) / 100)
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
