--- Eva tiled module
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
local luax = require("eva.luax")
local const = require("eva.const")

local db = require("eva.modules.db")
local grid = require("eva.modules.grid")
local hexgrid = require("eva.modules.hexgrid")
local isogrid = require("eva.modules.isogrid")

local hexgrid_handler = require("eva.scripts.hexgrid_handler")
local isogrid_handler = require("eva.scripts.isogrid_handler")
local grid_handler = require("eva.scripts.grid_handler")

local logger = log.get_logger("eva.tiled")

local M = {}


local function get_spawner_name_by_index(tiled_data, gid)
	local tilesets = tiled_data.tilesets

	local name
	for i = 1, #tilesets do
		if gid >= tilesets[i].firstgid then
			name = tilesets[i].name
		end
	end

	return name
end


local function get_id_by_gid(tiled_data, gid)
	local name = get_spawner_name_by_index(tiled_data, gid)
	local tilesets = tiled_data.tilesets

	for i = 1, #tilesets do
		if name == tilesets[i].name then
			return tostring(gid - tilesets[i].firstgid)
		end
	end
end


local function get_object_properties(object)
	if not object.properties then
		return nil
	end

	local props = {}
	for i = 1, #object.properties do
		props[object.properties[i].name] = object.properties[i].value
	end

	return props
end


local function get_object_name(spawner, object)
	return hash(spawner .. ":" .. object.object_name .. ":" .. object.image_name)
end


local function get_map_properties(tiled_data)
	local props = {}

	if tiled_data.properties then
		for j = 1, #tiled_data.properties do
			props[tiled_data.properties[j].name] = tiled_data.properties[j].value
		end
	end

	return props
end


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


local function add_tile(map_data, layer_name, spawner_name, index, i, j)
	local settings = app.settings.tiled
	local mapping_data = M.get_mapping()
	if not mapping_data[spawner_name] then
		return
	end

	local object_data = mapping_data[spawner_name][tostring(index)]
	if not object_data then
		return
	end

	local tile_layer = map_data.tiles[layer_name]
	tile_layer[i] = tile_layer[i] or {}

	if tile_layer[i][j] then
		logger:error("Tile already exist", { layer_name = layer_name, i = i, j = j })
		return
	end

	local z_layer = map_data.layer_props[layer_name].z_layer or settings.z_layer_tiles_default
	local position = map_data.grid.get_tile_pos(i, j, z_layer)
	local gameobject = map_data.create_object_fn(spawner_name, index, position)

	local object_info = {
		go = gameobject,
		index = index,
		layer_name = layer_name,
		spawner_name = spawner_name,
		properties = object_data.properties
	}

	map_data.game_objects[gameobject] = object_info
	tile_layer[i][j] = object_info
end


local function add_object(map_data, layer_name, spawner_name, index, x, y, props)
	local settings = app.settings.tiled
	local mapping_data = M.get_mapping()
	local object_data = mapping_data[spawner_name][tostring(index)]

	local z_layer = map_data.layer_props[layer_name].z_layer or settings.z_layer_objects_default
	local position = map_data.grid.get_object_pos(x, y, z_layer)

	local base_props = {
		_object_name = get_object_name(spawner_name, object_data),
	}
	local object_properties = luax.table.extend(base_props, object_data.properties)
	luax.table.extend(object_properties, props)

	for k, v in pairs(object_properties) do
		if type(v) == "string" then
			local hashed = hash(v)
			object_properties[k] = hashed
			app.tiled_hash_map[hashed] = v
		end
	end

	local gameobject = map_data.create_object_fn(spawner_name, index, position, object_properties)

	local object_info = {
		go = gameobject,
		index = index,
		layer_name = layer_name,
		spawner_name = spawner_name,
		properties = object_properties
	}

	map_data.game_objects[gameobject] = object_info
	map_data.objects[gameobject] = object_info

	return object_info
end


local function process_tiles(map_data, tiled_data, layer)
	local width = layer.width
	local layer_name = layer.name

	if map_data.tiles[layer_name] then
		logger:error("Wrong tiles layer name. Duplicate", { layer_name = layer_name })
		return
	end

	map_data.tiles[layer_name] = {}
	local tile_layer = map_data.tiles[layer_name]

	for i = 1, #layer.data do
		local spawner_name = get_spawner_name_by_index(tiled_data, layer.data[i])
		local object_id = get_id_by_gid(tiled_data, layer.data[i])

		local cell_y = math.floor((i-1) / width)
		local cell_x = (i-1) - (cell_y * width)
		tile_layer[cell_x] = tile_layer[cell_x] or {}

		if layer.data[i] > 0 then
			add_tile(map_data, layer_name, spawner_name, object_id, cell_x, cell_y)
		else
			tile_layer[cell_x][cell_y] = false
		end
	end
end


local function process_objects(map_data, tiled_data, layer)
	local mapping_data = M.get_mapping()
	local layer_name = layer.name

	if map_data.tiles[layer_name] then
		logger:error("Wrong objects layer name. Duplicate", { layer_name = layer_name })
		return
	end

	map_data.objects[layer_name] = {}

	local objects = layer.objects
	for i = 1, #objects do
		local object = objects[i]
		local gid = object.gid
		local spawner_name = get_spawner_name_by_index(tiled_data, gid)
		local object_id = get_id_by_gid(tiled_data, gid)
		-- TODO: Take object name from GID? in one layer can be different tilesets
		local object_data = mapping_data[spawner_name][tostring(object_id)]
		local is_grid_center = map_data.layer_props[layer_name].grid_center or false

		-- Offset is anchor from tiled object setup
		local offset = vmath.vector3(
			object_data.width/2 - object_data.anchor.x,
			object_data.height/2 - object_data.anchor.y,
		0)
		local scene_x, scene_y = map_data.grid.get_tiled_scene_pos(object.x, object.y, offset, is_grid_center)

		local object_info = add_object(map_data, layer_name, spawner_name, object_id, scene_x, scene_y, get_object_properties(object))

		object_info.tiled = {
			id = object.id,
			name = object.name,
		}
	end
end


--- Load map from tiled json data
-- @function eva.tiled.load_map
-- @tparam table data Json map data
-- @tparam callback create_object_fn Module call this with param(object_layer, object_id, position)
function M.load_map(tiled_data, create_object_fn)
	local grid_module = nil
	local astar_handler = nil

	if tiled_data.orientation == "hexagonal" then
		astar_handler = hexgrid_handler
		grid_module = hexgrid
	end
	if tiled_data.orientation == "staggered" then
		astar_handler = isogrid_handler
		grid_module = isogrid
	end
	if tiled_data.orientation == "orthogonal" then
		astar_handler = grid_handler
		grid_module = grid
	end

	local map_data = {
		game_objects = {},
		objects = {},
		tiles = {},
		grid = grid_module,
		astar_handler = astar_handler,
		map_props = get_map_properties(tiled_data),
		layer_props = get_layer_props(tiled_data),
		create_object_fn = create_object_fn,
	}

	local map_params = map_data.grid.get_map_params_from_tiled(tiled_data)
	map_data.grid.set_default_map_params(map_params)

	local map_layers = tiled_data.layers
	for index = 1, #map_layers do
		if map_layers[index].type == "tilelayer" then
			process_tiles(map_data, tiled_data, map_layers[index])
		end
		if map_layers[index].type == "objectgroup" then
			process_objects(map_data, tiled_data, map_layers[index])
		end
	end

	app.clear("tiled_map_default")
	app.tiled_map_default = map_data

	logger:debug("Map loaded")
	return map_data
end


--- Add tile to the map by tile index from tiled tileset
-- @function eva.tiled.add_tile
-- @tparam string layer_name Name of tiled layer
-- @tparam string spawner_name Name of tileset
-- @tparam number index Tile index from tileset
-- @tparam number i Cell x position
-- @tparam number j Cell y position
-- @tparam[opt] map_data map_data Map_data returned by eva.tiled.load_map.
-- Last map by default
function M.add_tile(layer_name, spawner_name, index, i, j, map_data)
	map_data = map_data or app.tiled_map_default
	add_tile(map_data, layer_name, spawner_name, index, i, j)
end


--- Get tile from the map by tile pos
-- @function eva.tiled.get_tile
-- @tparam string layer_name Name of tiled layer
-- @tparam number i Cell x position
-- @tparam number j Cell y position
-- @tparam[opt] map_data map_data Map_data returned by eva.tiled.load_map.
-- Last map by default
function M.get_tile(layer_name, i, j, map_data)
	map_data = map_data or app.tiled_map_default

	local layer = map_data.tiles[layer_name]
	if not layer then
		logger:warn("No layer witn name in map_data", { layer_name = layer_name })
		return nil
	end

	if not layer[i] then
		return false
	end

	return layer[i][j]
end


--- Delete tile from the map by tile pos
-- @function eva.tiled.delete_tile
-- @tparam string layer Name of the tiled layer
-- @tparam number i Cell x position
-- @tparam number j Cell y position
-- @tparam[opt] map_data map_data Map_data returned by eva.tiled.load_map.
-- Last map by default
function M.delete_tile(layer_name, i, j, map_data)
	map_data = map_data or app.tiled_map_default

	local layer = map_data.tiles[layer_name]
	if not layer then
		logger.warn("No layer witn name in map_data", { layer_name = layer_name })
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
-- @tparam string layer_name Name of tiled layer
-- @tparam string spawner_name Name of tileset
-- @tparam number index Object index from tileset
-- @tparam number x x position
-- @tparam number y y position
-- @tparam table props Object additional properties
-- @tparam[opt] map_data map_data Map_data returned by eva.tiled.load_map.
-- Last map by default
function M.add_object(layer_name, object_name, x, y, props, map_data)
	object_name = hash(object_name)
	if not app.tiled_objects_names[object_name] then
		logger:warn("No object name in tiled mapping", { name = object_name })
	end
	map_data = map_data or app.tiled_map_default
	local spawner_name = app.tiled_objects_names[object_name].spawner
	local index = app.tiled_objects_names[object_name].index

	return add_object(map_data, layer_name, spawner_name, index, x, y, props)
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


--- Get mapping object info by name
-- @function eva.tiled.get_object_data
-- @tparam string object_name The game object name
function M.get_object_data(object_name)
	object_name = hash(object_name)

	local info = app.tiled_objects_names[object_name]
	return M.get_mapping()[info.spawner][info.index]
end


function M.get_objects(object_name, map_data)
	object_name = hash(object_name)
	map_data = map_data or app.tiled_map_default

	if not app.tiled_objects_names[object_name] then
		logger:warn("No object name in tiled mapping", { name = object_name })
	end
	local objects = {}
	local index = app.tiled_objects_names[object_name].index

	for go_id, object in pairs(map_data.game_objects)do
		if index then
			if object.index == index then
				table.insert(objects, go_id)
			end
		else
			table.insert(objects, go_id)
		end
	end

	return objects
end


function M.get_object_by_id(id, map_data)
	map_data = map_data or app.tiled_map_default

	for go_id, object in pairs(map_data.game_objects) do
		if object.tiled and object.tiled.id == id then
			return go_id
		end
	end
end


function M.get_object_properties(game_object_id, map_data)
	map_data = map_data or app.tiled_map_default
	return map_data.game_objects[game_object_id].properties
end


function M.get_map_property(key, map_data)
	map_data = map_data or app.tiled_map_default
	return map_data.map_props[key]
end

--- Delete object from the map by game_object id
-- @function eva.tiled.delete_object
-- @tparam hash game_object_id Game object id
-- @tparam[opt] map_data map_data Map_data returned by eva.tiled.load_map.
-- Last map by default
function M.delete_object(game_object_id, map_data)
	map_data = map_data or app.tiled_map_default
	local object = M.get_object(game_object_id)
	if not object then
		logger:warn("No object with ID", { id = game_object_id })
		return
	end

	map_data.game_objects[object.go] = nil
	map_data.objects[object.layer_name][object.go] = nil
	go.delete(object.go)
end


function M.unhash_property(hash_string)
	return app.tiled_hash_map[hash_string]
end


function M.get_mapping()
	return db.get(app.settings.tiled.mapping_config) or {}
end


function M.after_eva_init()
	local mapping = M.get_mapping()
	app.tiled_hash_map = {}
	app.tiled_objects_names = {}
	for spawner, objects in pairs(mapping) do
		for index, object in pairs(objects) do
			local object_name = get_object_name(spawner, object)
			if app.tiled_objects_names[object_name] then
				logger:fatal("Tiled object mapping duplicate", { name = object_name, spawner = spawner, index = index })
			end

			app.tiled_objects_names[object_name] = {
				index = index,
				spawner = spawner
			}
		end
	end
end


return M
