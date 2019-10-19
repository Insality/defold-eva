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

local log = require("eva.log")
local luax = require("eva.luax")
local app = require("eva.app")

local hexgrid = require("eva.modules.hexgrid")

local logger = log.get_logger("eva.tiled")

local M = {}


local function get_layer_props(tiled_data)
	local props = {}

	for i = 1, #tiled_data.layers do
		local layer = tiled_data.layers[i]
		local name = layer.name
		local layer_props = {}

		if layer.properties then
			for j = 1, #layer.properties do
				layer_props[layer.properties[j].name] = layer.properties[j].value
			end
		end
		props[name] = layer_props
	end

	return props
end


local function add_tile(map_data, name, i, j, index)
	local mapping_config_name = app.settings.tiled.mapping_config
	local mapping_data = app.db[mapping_config_name]
	local object_data = mapping_data[name][tostring(index)]

	local tile_layer = map_data.tiles[name]
	tile_layer[i] = tile_layer[i] or {}

	if tile_layer[i][j] then
		logger:error("Tile already exist", { name = name, i = i, j = j })
		return
	end

	local z_layer = map_data.layer_props[name].z_layer or 0
	local position = hexgrid.get_tile_pos(i, j, z_layer)
	local gameobject = map_data.create_object_fn(name, index, position)

	table.insert(map_data.game_objects, gameobject)
	tile_layer[i][j] = {
		go = gameobject,
		index = index,
		properties = object_data.properties
	}
end


local function add_object(map_data, name, x, y, index)
	local mapping_config_name = app.settings.tiled.mapping_config
	local mapping_data = app.db[mapping_config_name]
	local object_data = mapping_data[name][tostring(index)]

	local z_layer = map_data.layer_props[name].z_layer or 3
	local position = hexgrid.get_object_pos(x, y, z_layer)
	local gameobject = map_data.create_object_fn(name, index, position)

	table.insert(map_data.game_objects, gameobject)
	table.insert(map_data.objects[name], {
		go = gameobject,
		index = index,
		properties = object_data.properties
	})
end


local function process_tiles(map_data, tiled_data, index)
	local layer = tiled_data.layers[index]
	local width = layer.width
	local name = layer.name

	if map_data.tiles[name] then
		logger:error("Wrong tiles layer name. Duplicate", { name = name })
		return
	end

	map_data.tiles[name] = {}
	local tile_layer = map_data.tiles[name]

	for i = 1, #layer.data do
		local value = layer.data[i]
		local cell_y = math.floor((i-1) / width)
		local cell_x = (i-1) - (cell_y * width)
		tile_layer[cell_x] = tile_layer[cell_x] or {}

		if value > 0 then
			add_tile(map_data, name, cell_x, cell_y, value - 1)
		else
			tile_layer[cell_x][cell_y] = false
		end
	end
end


local function process_objects(map_data, tiled_data, index)
	local mapping_config_name = app.settings.tiled.mapping_config
	local mapping_data = app.db[mapping_config_name]
	local layer = tiled_data.layers[index]
	local name = layer.name

	if map_data.tiles[name] then
		logger:error("Wrong tiles layer name. Duplicate", { name = name })
		return
	end

	map_data.objects[name] = {}

	local objects = layer.objects
	for i = 1, #objects do
		local object = objects[i]
		local gid_offset = tiled_data.tilesets[index].firstgid
		local object_id = object.gid - gid_offset
		local object_data = mapping_data[name][tostring(object_id)]

		local is_grid_center = map_data.layer_props[name].grid_center or false

		-- Offset is anchor from tiled object setup
		local offset = vmath.vector3(
			object_data.width/2 - object_data.anchor.x,
			object_data.height/2 - object_data.anchor.y - 2,
		0)
		local scene_x, scene_y = hexgrid.get_scene_pos(object.x, object.y, offset, is_grid_center)

		add_object(map_data, name, scene_x, scene_y, object_id)
	end
end


--- Load map from tiled json data
-- @function eva.tiled.load_map
-- @tparam table data Json map data
-- @tparam callback create_object_fn Module call this with param(object_layer, object_id, position)
function M.load_map(tiled_data, create_object_fn)
	tiled_data.tilewidth = tiled_data.tilewidth - 1
	tiled_data.tileheight = tiled_data.tileheight - 1
	tiled_data.hexsidelength = tiled_data.hexsidelength - 1

	local map_params = hexgrid.get_map_params(tiled_data.tilewidth, tiled_data.tileheight,
		tiled_data.hexsidelength, tiled_data.width, tiled_data.height)
	hexgrid.set_default_map_params(map_params)
	local map_layers = tiled_data.layers

	local map_data = {
		game_objects = {},
		objects = {},
		tiles = {},
		layer_props = get_layer_props(tiled_data),
		create_object_fn = create_object_fn,
	}

	for index = 1, #map_layers do
		if map_layers[index].type == "tilelayer" then
			process_tiles(map_data, tiled_data, index)
		end
		if map_layers[index].type == "objectgroup" then
			process_objects(map_data, tiled_data, index)
		end
	end

	return map_data
end


function M.get_tile(map_data, name, i, j)
	local layer = map_data.tiles[name]
	if not layer then
		logger.warn("No layer witn name in map_data", { name = name })
		return nil
	end

	if not layer[i] then
		return false
	end

	return layer[i][j]
end


function M.delete_tile(map_data, name, i, j)
	local layer = map_data.tiles[name]
	if not layer then
		logger.warn("No layer witn name in map_data", { name = name })
		return nil
	end

	if not layer[i] then
		return false
	end

	if layer[i][j] then
		local object = layer[i][j].go
		go.delete(object)

		luax.table.remove_item(map_data.game_objects, object)
		layer[i][j] = false
		return true
	end

	return false
end


function M.add_tile(map_data, name, i, j, index)
	add_tile(map_data, name, i, j, index)
end

function M.add_object(map_data, name, x, y, index)
	add_object(map_data, name, x, y, index)
end

return M
