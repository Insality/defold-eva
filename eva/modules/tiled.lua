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
local app = require("eva.app")

local hexgrid = require("eva.modules.hexgrid")
local isogrid = require("eva.modules.isogrid")
local grid = require("eva.modules.grid")

local hexgrid_handler = require("eva.libs.astar.hexgrid_handler")
local isogrid_handler = require("eva.libs.astar.isogrid_handler")
local grid_handler = require("eva.libs.astar.grid_handler")

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
	local settings = app.settings.tiled
	local mapping_data = app.db[settings.mapping_config]
	local object_data = mapping_data[name][tostring(index)]

	local tile_layer = map_data.tiles[name]
	tile_layer[i] = tile_layer[i] or {}

	if tile_layer[i][j] then
		logger:error("Tile already exist", { name = name, i = i, j = j })
		return
	end

	local z_layer = map_data.layer_props[name].z_layer or settings.z_layer_tiles_default
	local position = map_data.grid.get_tile_pos(i, j, z_layer)
	local gameobject = map_data.create_object_fn(name, index, position)

	local object_info = {
		go = gameobject,
		index = index,
		layer = name,
		properties = object_data.properties
	}

	map_data.game_objects[gameobject] = object_info
	tile_layer[i][j] = object_info
end


local function add_object(map_data, name, x, y, index)
	local settings = app.settings.tiled
	local mapping_data = app.db[settings.mapping_config]
	local object_data = mapping_data[name][tostring(index)]

	local z_layer = map_data.layer_props[name].z_layer or settings.z_layer_objects_default
	local position = map_data.grid.get_object_pos(x, y, z_layer)
	local gameobject = map_data.create_object_fn(name, index, position)

	local object_info = {
		go = gameobject,
		index = index,
		layer = name,
		properties = object_data.properties
	}

	map_data.game_objects[gameobject] = object_info
	map_data.objects[gameobject] = object_info
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
		local scene_x, scene_y = map_data.grid.get_scene_pos(object.x, object.y, offset, is_grid_center)

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

	local grid_module = nil
	local astar_handler = nil

	if tiled_data.orientation == "hexagonal" then
		astar_handler = hexgrid_handler
		grid_module = hexgrid
	end
	if tiled_data.orientation == "isometric" then
		astar_handler = isogrid_handler
		grid_module = isogrid
	end
	if tiled_data.orientation == "grid" then
		astar_handler = grid_handler
		grid_module = grid
	end

	local map_data = {
		game_objects = {},
		objects = {},
		tiles = {},
		grid = grid_module,
		astar_handler = astar_handler,
		layer_props = get_layer_props(tiled_data),
		create_object_fn = create_object_fn,
	}

	local map_params = map_data.grid.get_map_params(tiled_data.tilewidth, tiled_data.tileheight,
		tiled_data.hexsidelength, tiled_data.width, tiled_data.height, true)
	map_data.grid.set_default_map_params(map_params)

	local map_layers = tiled_data.layers

	for index = 1, #map_layers do
		if map_layers[index].type == "tilelayer" then
			process_tiles(map_data, tiled_data, index)
		end
		if map_layers[index].type == "objectgroup" then
			process_objects(map_data, tiled_data, index)
		end
	end

	app.tiled_map_default = map_data
	return map_data
end


--- Add tile to the map by tile index from tiled tileset
-- @function eva.tiled.add_tile
-- @tparam string name Name of tileset
-- @tparam number i Cell x position
-- @tparam number j Cell y position
-- @tparam number index Tile index from tileset
-- @tparam[opt] map_data map_data Map_data returned by eva.tiled.load_map.
-- Last map by default
function M.add_tile(name, i, j, index, map_data)
	map_data = map_data or app.tiled_map_default
	add_tile(map_data, name, i, j, index)
end


--- Get tile from the map by tile pos
-- @function eva.tiled.get_tile
-- @tparam string name Name of tileset
-- @tparam number i Cell x position
-- @tparam number j Cell y position
-- @tparam[opt] map_data map_data Map_data returned by eva.tiled.load_map.
-- Last map by default
function M.get_tile(name, i, j, map_data)
	map_data = map_data or app.tiled_map_default

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


--- Delete tile from the map by tile pos
-- @function eva.tiled.delete_tile
-- @tparam string name Name of tileset
-- @tparam number i Cell x position
-- @tparam number j Cell y position
-- @tparam[opt] map_data map_data Map_data returned by eva.tiled.load_map.
-- Last map by default
function M.delete_tile(name, i, j, map_data)
	map_data = map_data or app.tiled_map_default

	local layer = map_data.tiles[name]
	if not layer then
		logger.warn("No layer witn name in map_data", { name = name })
		return nil
	end

	if not layer[i] then
		return false
	end

	if layer[i][j] then
		go.delete(layer[i][j].go)

		map_data.game_objects[layer[i][j].go] = nil
		layer[i][j] = false

		return true
	end

	return false
end


--- Add object to the map by object index from tiled tileset
-- @function eva.tiled.add_object
-- @tparam string name Name of tileset
-- @tparam number x x position
-- @tparam number y y position
-- @tparam number index Object index from tileset
-- @tparam[opt] map_data map_data Map_data returned by eva.tiled.load_map.
-- Last map by default
function M.add_object(name, x, y, index, map_data)
	map_data = map_data or app.tiled_map_default
	add_object(map_data, name, x, y, index)
end


--- Get object to the map by game_object id
-- @function eva.tiled.get_object
-- @tparam hash game_object_id Game object id
-- @tparam[opt] map_data map_data Map_data returned by eva.tiled.load_map.
-- Last map by default
function M.get_object(game_object_id, map_data)
	map_data = map_data or app.tiled_map_default
	return map_data.game_objects[game_object_id]
end


--- Delete object from the map by game_object id
-- @function eva.tiled.delete_object
-- @tparam hash game_object_id Game object id
-- @tparam[opt] map_data map_data Map_data returned by eva.tiled.load_map.
-- Last map by default
function M.delete_object(game_object_id, map_data)
	map_data = map_data or app.tiled_map_default
	local object = M.get_object_by_id(game_object_id)
	if not object then
		logger:warn("No object with ID", { id = game_object_id })
		return
	end

	go.delete(object.go)
	map_data.game_objects[object.go] = nil
	map_data.objects[object.layer][object.go] = nil
end


return M
