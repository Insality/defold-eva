--- Eva tiled module
-- Can load maps, exported from tiled
-- Need to bind some objects before creating stuff
--
-- Tiled configuration:
-- Layers:
--  Layer can have properties:
--      grid_center (bool) - if true, center every object to map grid
--      z_layer (int) - z_layer of the layer
-- @submodule eva


local log = require("eva.log")
local app = require("eva.app")
local luax = require("eva.luax")

local db = require("eva.modules.db")
local grid = require("eva.modules.grid")
local hexgrid = require("eva.modules.hexgrid")
local isogrid = require("eva.modules.isogrid")

local hexgrid_handler = require("eva.scripts.hexgrid_handler")
local isogrid_handler = require("eva.scripts.isogrid_handler")
local grid_handler = require("eva.scripts.grid_handler")

local logger = log.get_logger("eva.tiled")

local M = {}

local TEMP_POS_VECTOR = vmath.vector3()
local TEMP_SCALE_VECTOR = vmath.vector3()

local function get_tileset_name_by_index(tiled_data, gid)
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
	local name = get_tileset_name_by_index(tiled_data, gid)
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
		layer_props.offsetx = (layer.offsetx or 0)
		layer_props.offsety = -(layer.offsety or 0)
		props[name] = layer_props
	end

	return props
end


local function add_tile(map_data, layer_name, tileset_name, mapping_id, i, j)
	local settings = app.settings.tiled
	local mapping = M.get_mapping()
	if not mapping[tileset_name] then
		return
	end

	local mapping_data = mapping[tileset_name][tostring(mapping_id)]
	if not mapping_data then
		return
	end

	local tile_layer = map_data.tiles[layer_name]
	tile_layer[i] = tile_layer[i] or {}

	if tile_layer[i][j] then
		logger:error("Tile already exist", { layer_name = layer_name, i = i, j = j })
		return
	end

	local z_layer = map_data.layer_props[layer_name].z_layer or settings.z_layer_tiles_default
	local pos_x, pos_y, pos_z = map_data.grid.get_tile_pos(i, j, z_layer)
	pos_x = pos_x + (map_data.layer_props[layer_name].offsetx or 0)
	pos_y = pos_y + (map_data.layer_props[layer_name].offsety or 0)

	-- Vector usage optimization
	TEMP_POS_VECTOR.x = pos_x
	TEMP_POS_VECTOR.y = pos_y
	TEMP_POS_VECTOR.z = pos_z

	local game_object_id, collection_table = map_data.create_object_fn(tileset_name, mapping_id, TEMP_POS_VECTOR)

	--@type tiled.object_info
	local object_info = {
		game_object_id = game_object_id,
		collection_table = collection_table,
		object_name = mapping_data.object_name,
		scene_id = nil,
		scene_name = nil,
		tileset_name = tileset_name,
		layer_id = layer_name,
		mapping_id = mapping_id,
		mapping_data = mapping_data,
		properties = nil,
		is_tile = true,
		is_enabled = true,
		transform = {
			position_x = pos_x,
			position_y = pos_y,
			position_z = pos_z,
			rotation = 0,
			scale = 1
		}
	}

	map_data.game_objects[game_object_id] = object_info
	tile_layer[i][j] = object_info
end


local function add_object(map_data, layer_name, tileset_name, mapping_id, position_x, position_y, scale, rotation, props)
	local settings = app.settings.tiled
	local mapping = M.get_mapping()
	local mapping_data = mapping[tileset_name][tostring(mapping_id)]

	local z_layer = map_data.layer_props[layer_name].z_layer or settings.z_layer_objects_default
	local pos_x, pos_y, pos_z = map_data.grid.get_object_pos(position_x, position_y, z_layer)
	if props and props.z_position then
		pos_z = props.z_position
	end
	pos_x = pos_x + (map_data.layer_props[layer_name].offsetx or 0)
	pos_y = pos_y + (map_data.layer_props[layer_name].offsety or 0)

	local base_props = {
		_object_full_id = M.get_object_full_id(tileset_name, mapping_data.object_name, mapping_data.image_name),
	}
	local object_properties = luax.table.extend(base_props, mapping_data.properties)
	luax.table.extend(object_properties, props)

	-- Vector usage optimization
	TEMP_POS_VECTOR.x = pos_x
	TEMP_POS_VECTOR.y = pos_y
	TEMP_POS_VECTOR.z = pos_z
	TEMP_SCALE_VECTOR.x = scale or 1
	TEMP_SCALE_VECTOR.y = scale or 1
	TEMP_SCALE_VECTOR.z = 1
	local rotation_vector = nil
	if rotation and rotation ~= 0 then
		rotation_vector = luax.vmath.rad2quat(rotation * math.pi/180)
	end

	local game_object_id, collection_table = map_data.create_object_fn(
		tileset_name,
		mapping_id,
		TEMP_POS_VECTOR,
		TEMP_SCALE_VECTOR,
		rotation_vector,
		object_properties)

	--@type tiled.object_info
	local object_info = {
		game_object_id = game_object_id,
		collection_table = collection_table,
		object_name = mapping_data.object_name,
		scene_id = nil,
		scene_name = nil,
		tileset_name = tileset_name,
		layer_id = layer_name,
		mapping_id = mapping_id,
		is_tile = false,
		is_enabled = true,
		mapping_data = mapping_data,
		properties = object_properties,
		transform = {
			position_x = pos_x,
			position_y = pos_y,
			position_z = pos_z,
			rotation = rotation or 0,
			scale = scale or 1
		}
	}

	map_data.game_objects[game_object_id] = object_info

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
		local tileset_name = get_tileset_name_by_index(tiled_data, layer.data[i])
		local object_id = get_id_by_gid(tiled_data, layer.data[i])

		local cell_j = math.floor((i-1) / width)
		local cell_i = (i-1) - (cell_j * width)
		tile_layer[cell_i] = tile_layer[cell_i] or {}

		if layer.data[i] > 0 then
			add_tile(map_data, layer_name, tileset_name, object_id, cell_i, cell_j)
		else
			tile_layer[cell_i][cell_j] = false
		end
	end
end


local FLIPPED_HORIZONTALLY_FLAG  = 0x80000000;
local FLIPPED_VERTICALLY_FLAG    = 0x40000000;
local FLIPPED_DIAGONALLY_FLAG    = 0x20000000;
local function get_gid(object)
	local gid = object.gid

	local is_flip_horizontal = bit.band(gid, FLIPPED_HORIZONTALLY_FLAG) ~= 0
	gid = bit.band(gid, bit.bnot(FLIPPED_HORIZONTALLY_FLAG))

	local is_flip_vertical = bit.band(gid, FLIPPED_VERTICALLY_FLAG) ~= 0
	gid = bit.band(gid, bit.bnot(FLIPPED_VERTICALLY_FLAG))

	return gid, is_flip_vertical, is_flip_horizontal
end


local function process_objects(map_data, tiled_data, layer)
	local mapping_data = M.get_mapping()
	local layer_name = layer.name

	if map_data.tiles[layer_name] then
		logger:error("Wrong objects layer name. Duplicate", { layer_name = layer_name })
		return
	end

	local objects = layer.objects
	for i = 1, #objects do
		local object = objects[i]
		local gid, is_flip_vertical, is_flip_horizontal = get_gid(object)
		local tileset_name = get_tileset_name_by_index(tiled_data, gid)
		local object_id = get_id_by_gid(tiled_data, gid)
		-- TODO: Take object name from GID? in one layer can be different tilesets
		local mapping_info = mapping_data[tileset_name][tostring(object_id)]
		local is_grid_center = map_data.layer_props[layer_name].grid_center or false

		local rotation = -object.rotation
		local rotation_rad = -rotation * math.pi/180
		local scale_x = luax.math.round(object.width / mapping_info.width, 3)
		local scale_y = luax.math.round(object.height / mapping_info.height, 3)
		local scale = math.min(scale_x, scale_y)

		if (scale_x ~= scale_y)  then
			logger:error("Object scale sides is different! It's forbidden due the physics can't scale in right way", {
				object = object,
				scale_x = scale_x,
				scale_y = scale_y
			})
		end

		-- Get offset from object point in Tiled to Defold assets object
		-- Tiled point in left bottom, Defold - in object center
		-- And add sprite anchor.x for visual correct posing from tiled (In Tiled we pos the image)
		local offset = {
			x = (mapping_info.width/2 - mapping_info.anchor.x) * scale_x,
			y = (mapping_info.height/2 - mapping_info.anchor.y) * scale_y,
		}
		-- Rotate offset in case of rotated object
		local rotated_offset = {
			x = offset.x * math.cos(rotation_rad) + offset.y * math.sin(rotation_rad),
			y = -offset.x * math.sin(rotation_rad) + offset.y * math.cos(rotation_rad),
		}

		local scene_x, scene_y = map_data.grid.get_tiled_scene_pos(object.x, object.y, rotated_offset, is_grid_center)
		local object_props = get_object_properties(object) or {}
		object_props.scale = scale

		local object_info = add_object(map_data, layer_name, tileset_name, object_id, scene_x, scene_y, scale, rotation, object_props)
		M.set_scene_id(object_info, object.id)

		local scene_name = object_info.object_name
		if object.name and object.name ~= "" then
			scene_name = object.name
		end
		M.set_scene_name(object_info, scene_name)
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
		tiles = {},
		grid = grid_module,
		astar_handler = astar_handler,
		map_props = get_map_properties(tiled_data),
		layer_props = get_layer_props(tiled_data),
		create_object_fn = create_object_fn,
		map_params = grid_module.get_map_params_from_tiled(tiled_data)
	}

	map_data.grid.set_default_map_params(map_data.map_params)

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

	logger:debug("Tiled map loaded", { objects = luax.table.length(map_data.game_objects) })
	return map_data
end


--- Add tile to the map by tile index from tiled tileset
-- @function eva.tiled.add_tile
-- @tparam string layer_name Name of tiled layer
-- @tparam string tileset_name Name of tileset
-- @tparam number mapping_id Tile mapping_id from tileset
-- @tparam number i Cell x position
-- @tparam number j Cell y position
-- @tparam[opt] map_data map_data Map_data returned by eva.tiled.load_map.
-- Last map by default
function M.add_tile(layer_name, tileset_name, mapping_id, i, j, map_data)
	map_data = map_data or app.tiled_map_default
	add_tile(map_data, layer_name, tileset_name, mapping_id, i, j)
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
		-- logger:warn("No layer witn name in map_data", { layer_name = layer_name })
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
-- @tparam number i Cell i position
-- @tparam number j Cell j position
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
		go.delete(layer[i][j].go, true)

		map_data.game_objects[layer[i][j].go] = nil
		layer[i][j] = false

		return true
	end

	return false
end


--- Add object to the map by object index from tiled tileset
-- @function eva.tiled.add_object
-- @tparam string layer_name Name of tiled layer
-- @tparam string object_full_id Object full id
-- @tparam number x x position
-- @tparam number y y position
-- @tparam[opt=1] number scale Object scale
-- @tparam[opt=0] number rotation Rotation in euler
-- @tparam[opt] table props Object additional properties. Field, z_position, tiled_id, tiled_name
-- @tparam[opt] map_data map_data Map_data returned by eva.tiled.load_map.
-- Last map by default
function M.add_object(layer_name, object_full_id, x, y, scale, rotation, props, map_data)
	if not app.tiled_object_full_ids[object_full_id] then
		logger:warn("No object name in tiled mapping", { name = object_full_id })
	end
	map_data = map_data or app.tiled_map_default
	local tileset_name = app.tiled_object_full_ids[object_full_id].tileset_name
	local mapping_id = app.tiled_object_full_ids[object_full_id].mapping_id

	return add_object(map_data, layer_name, tileset_name, mapping_id, x, y, scale, rotation, props)
end


--- Get object to the map by game_object id
-- @function eva.tiled.get_object
-- @tparam hash game_object_id Game object id
-- @tparam[opt] map_data map_data Map_data returned by eva.tiled.load_map. Last loaded map by default
-- @treturn table Object data
function M.get_object_by_gameobject_id(game_object_id, map_data)
	map_data = map_data or app.tiled_map_default
	return map_data.game_objects[game_object_id]
end


--- Get mapping object info by name
-- @function eva.tiled.get_object_data
-- @tparam string object_name The game object name
function M.get_object_data(object_name)
	object_name = hash(object_name)

	local info = app.tiled_object_full_ids[object_name]
	return M.get_mapping()[info.tileset_name][info.mapping_id]
end


--- Get mapping object info by mapping_id
-- @function eva.tiled.get_object_data
-- @tparam string object_name The game object name
function M.get_object_data_by_mapping_id(tileset_name, mapping_id)
	return M.get_mapping()[tileset_name] and M.get_mapping()[tileset_name][mapping_id]
end


function M.get_object_by_scene_id(scene_id, map_data)
	scene_id = tostring(scene_id)
	map_data = map_data or app.tiled_map_default

	for _, object_info in pairs(map_data.game_objects) do
		if object_info.scene_id == scene_id then
			return object_info
		end
	end

	return nil
end


function M.get_objects(object_name, map_data)
	object_name = hash(object_name)
	map_data = map_data or app.tiled_map_default

	if not app.tiled_object_full_ids[object_name] then
		logger:warn("No object name in tiled mapping", { name = object_name })
	end
	local objects = {}
	local mapping_id = app.tiled_object_full_ids[object_name].mapping_id

	for go_id, object in pairs(map_data.game_objects)do
		if mapping_id then
			if object.mapping_id == mapping_id then
				table.insert(objects, go_id)
			end
		else
			table.insert(objects, go_id)
		end
	end

	return objects
end


function M.clear_all_objects(map_data)
	map_data = map_data or app.tiled_map_default

	local objects = map_data.game_objects

	for go_id in pairs(objects) do
		go.delete(go_id, true)
	end

	map_data.game_objects = {}
end


--- Get object property
-- @function eva.tiled.get_property
-- @tparam tiled.object_info object_info Object info
-- @tparam string object_name Object name
-- @tparam string script_name Script name
-- @tparam string property_name Property name
-- @treturn string|boolean|number|nil
function M.get_property(object_info, object_name, script_name, property_name)
	local properties = object_info.properties
	local full_property_name = object_name .. ":" .. script_name .. ":" .. property_name
	return properties[full_property_name]
end


--- Get object property by name
-- @function eva.tiled.get_property_by_name
-- @tparam tiled.object_info object_info Object info
-- @tparam string property_name Property name
-- @treturn string|boolean|number|nil
function M.get_property_by_name(object_info, property_name)
	local properties = object_info.properties

	if properties[property_name] then
		return properties[property_name]
	end

	for key, value in pairs(properties) do
		if luax.string.ends(key, property_name) then
			return value
		end
	end

	return nil
end


function M.get_map_property(key, map_data)
	map_data = map_data or app.tiled_map_default
	return map_data.map_props[key]
end


function M.get_object_full_id(tileset_name, object_name, image_name)
	image_name = image_name or object_name
	return tileset_name .. ":" .. object_name .. ":" .. image_name
end


--- Set unique id for the object
-- @function eva.tiled.set_object_id
-- @tparam tiled.object_info object_info Object info
-- @tparam string scene_id Scene id
-- @treturn tiled.object_info
function M.set_scene_id(object_info, scene_id)
	scene_id = scene_id and tostring(scene_id) or nil
	if luax.string.is_empty(scene_id) then
		scene_id = nil
	end
	object_info.scene_id = scene_id
	return object_info
end


--- Set scene name for the object
-- @function eva.tiled.set_scene_name
-- @tparam tiled.object_info object_info Object info
-- @tparam string scene_name Scene name
-- @treturn tiled.object_info
function M.set_scene_name(object_info, scene_name)
	scene_name = scene_name and tostring(scene_name) or nil
	if luax.string.is_empty(scene_name) then
		scene_name = nil
	end
	object_info.scene_name = scene_name
	return object_info
end


--- Set object enabled state
-- @function eva.tiled.set_enabled
-- @tparam tiled.object_info object_info Object info
-- @tparam boolean is_enabled Is object enabled
-- @treturn tiled.object_info
function M.set_enabled(object_info, is_enabled)
	object_info.is_enabled = is_enabled
	local msg_name = is_enabled and "enable" or "disable"

	msg.post(object_info.game_object_id, msg_name)
	if object_info.collection_table then
		for _, object_id in pairs(object_info.collection_table) do
			msg.post(object_id, msg_name)
		end
	end

	return object_info
end


--- Return if object is enabled
-- @function eva.tiled.is_enabled
-- @tparam tiled.object_info object_info Object info
-- @treturn boolean
function M.is_enabled(object_info)
	return object_info.is_enabled
end


--- Delete object from the map by game_object id
-- @function eva.tiled.delete_object
-- @tparam hash game_object_id Game object id
-- @tparam[opt] map_data map_data Map_data returned by eva.tiled.load_map.
-- Last map by default
function M.delete_object(game_object_id, map_data)
	game_object_id = game_object_id or go.get_id()
	map_data = map_data or app.tiled_map_default
	local object = M.get_object_by_gameobject_id(game_object_id)
	if not object then
		logger:warn("No object with ID", { id = game_object_id })
		return
	end

	map_data.game_objects[object.game_object_id] = nil
	go.delete(object.game_object_id, true)
end


function M.get_mapping()
	return db.get(app.settings.tiled.mapping_config) or {}
end


function M.after_eva_init()
	local mapping = M.get_mapping()
	app.tiled_object_full_ids = {}
	for tileset_name, objects in pairs(mapping) do
		for mapping_id, object in pairs(objects) do
			local object_full_id = M.get_object_full_id(tileset_name, object.object_name, object.image_name)
			if app.tiled_object_full_ids[object_full_id] then
				logger:fatal("Tiled object mapping duplicate", { name = object_full_id, tileset_name = tileset_name, mapping_id = mapping_id })
			end

			app.tiled_object_full_ids[object_full_id] = {
				mapping_id = mapping_id,
				tileset_name = tileset_name
			}
		end
	end
end


return M
