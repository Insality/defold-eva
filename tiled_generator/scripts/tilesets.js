const fs = require("fs")
const path = require("path")
const process = require("process")
const settings = require("../settings.json")

const ATLAS_TEMPLATE = fs.readFileSync(path.join(__dirname, "../templates/atlas.template")).toString('utf8')
const ATLAS_NODE_TEMPLATE = fs.readFileSync(path.join(__dirname, "../templates/atlas_node.template")).toString('utf8')
const GO_SPRITE_TEMPLATE = fs.readFileSync(path.join(__dirname, "../templates/go_sprite.template")).toString('utf8')
const GO_COLLISION_TEMPLATE = fs.readFileSync(path.join(__dirname, "../templates/go_collision.template")).toString('utf8')
const GO_COLLISION_SHAPE_TEMPLATE = fs.readFileSync(path.join(__dirname, "../templates/go_collision_shape.template")).toString('utf8')
const GO_COLLISION_DATA_TEMPLATE = fs.readFileSync(path.join(__dirname, "../templates/go_collision_data.template")).toString('utf8')
const FACTORY_NODE_TEMPLATE = fs.readFileSync(path.join(__dirname, "../templates/factory_node.template")).toString('utf8')

const M = {}


function get_property(props, prop_name) {
	for (let i in props) {
		if (props[i].name == prop_name) {
			return props[i].value
		}
	}
}


function get_all_properies(props) {
	let map = {}
	for (let i in props) {
		map[props[i].name] = props[i].value
	}
	return map
}


function get_anchor(tile) {
	if (tile.objectgroup) {
		let objects = tile.objectgroup.objects
		for (let i in objects) {
			let object = objects[i]
			if (object.point) {
				return {
					x: tile.imagewidth/2 - object.x,
					y: tile.imageheight/2 - (tile.imageheight - object.y)
				}
			}
		}
	}
	return {
		x: 0,
		y: 0
	}
}


function make_with_sprite(tile, anchor, atlas_name) {
	let tile_name = path.basename(tile.image).split(".")[0]

	let object_data = GO_SPRITE_TEMPLATE.replace("{1}", atlas_name)
	object_data = object_data.replace("{2}", tile_name)
	object_data = object_data.replace("{3}", anchor.x)
	object_data = object_data.replace("{4}", anchor.y)
	object_data = object_data.replace("{5}", settings.sprite_material)

	return object_data
}


function check_colliders(object_data, anchor, tile) {
	let props = tile.properties

	let group = get_property(props, "group")
	if (!group) {
		return object_data
	}

	let collision_shape = GO_COLLISION_TEMPLATE.replace("{1}", group) // Group
	collision_shape = collision_shape.replace("{2}", "cursor") // Mask
	let shapes = ""
	let data = []
	let cur_index = 0

	if (!tile.objectgroup) {
		console.log("ERROR: no object at tile", tile.image)
	}
	let objects = tile.objectgroup.objects
	let width = tile.imagewidth
	let height = tile.imageheight
	for (let i in objects) {
		let object = objects[i]

		let pos_x = (object.width/2 - width/2 + object.x + anchor.x).toFixed(1)
		let pos_y = (-object.height/2 + height/2 - object.y + anchor.y).toFixed(1)

		if (object.ellipse) {
			if (object.width != object.height) {
				console.log("WARNING: in ellipse width and height should be equal.", tile.image)
			}
			let shape_data = GO_COLLISION_SHAPE_TEMPLATE.replace("{1}", "TYPE_SPHERE")
			shape_data = shape_data.replace("{2}", pos_x)
			shape_data = shape_data.replace("{3}", pos_y)
			shape_data = shape_data.replace("{4}", cur_index)
			shape_data = shape_data.replace("{5}", 1)
			cur_index += 1

			shapes += shape_data
			data.push(GO_COLLISION_DATA_TEMPLATE.replace("{1}", (object.width/2).toFixed(1)))
		}

		// This is the rectangle by default
		if (!object.ellipse && !object.point) {
			let shape_data = GO_COLLISION_SHAPE_TEMPLATE.replace("{1}", "TYPE_BOX")
			shape_data = shape_data.replace("{2}", pos_x)
			shape_data = shape_data.replace("{3}", pos_y)
			shape_data = shape_data.replace("{4}", cur_index)
			shape_data = shape_data.replace("{5}", 3)
			cur_index += 3

			shapes += shape_data
			data.push(GO_COLLISION_DATA_TEMPLATE.replace("{1}", (object.width/2).toFixed(1)))
			data.push(GO_COLLISION_DATA_TEMPLATE.replace("{1}", (object.height/2).toFixed(1)))
			data.push(GO_COLLISION_DATA_TEMPLATE.replace("{1}", (object.width/2).toFixed(1)))
		}
	}

	collision_shape = collision_shape.replace("{3}", shapes) // Shapes
	collision_shape = collision_shape.replace("{4}", data.join("\n")) // Data

	return object_data + collision_shape
}


/// Generate atlas for tileset
M.generate_atlas = function(data, output_path) {
	console.log("Start generate atlas for", data.name)
	let images = []
	let tiles = data.tiles

	for (let i in tiles) {
		let image_path = path.join(__dirname, tiles[i].image)
		let cwd = process.cwd()

		image_path = image_path.replace(cwd, "")

		let image_node = ATLAS_NODE_TEMPLATE.replace("{1}", image_path)
		images.push(image_node)
	}

	let atlas = ATLAS_TEMPLATE.replace("{1}", images.join("\n"))
	let atlas_name = data.name + ".atlas"
	let atlas_path = path.join(output_path, "atlases")
	fs.mkdirSync(atlas_path, { recursive: true })

	console.log("Write atlas", path.join(atlas_path, atlas_name))
	fs.writeFileSync(path.join(atlas_path, atlas_name), atlas)
}


/// Generate new objects for all images
// It is not override previous objects, due to customization
M.generate_objects = function(data, output_path, mapping) {
	console.log("Start generate game objects for", data.name)

	mapping[data.name] = mapping[data.name] || {}
	let tiles = data.tiles
	let generated = 0
	let skipped = 0

	let spawner_go = ""
	let objects_ready = {}

	for (let i in tiles) {
		let tile = tiles[i]
		let tile_image = path.basename(tile.image)
		let props = tile.properties

		if (!props) {
			console.log("No properties at object", tile_image)
			continue
		}

		let object_name = get_property(props, "object_name")
		if (!object_name) {
			console.log("No property `object_name` at object", tile_image)
			continue
		}
		let anchor = get_anchor(tile)

		mapping[data.name][tile.id] = {
			object_name: object_name,
			image_name: tile_image.split(".")[0],
			anchor: anchor,
			width: tile.imagewidth,
			height: tile.imageheight,
			properties: get_all_properies(tile.properties)
		}

		let object_path = path.join(output_path, "objects", data.name)
		fs.mkdirSync(object_path, { recursive: true })

		let object_full_path = path.join(object_path, object_name + ".go")
		let object_game_path = object_full_path.replace(process.cwd(), "")

		if (!objects_ready[object_name]) {
			let spawner_data = FACTORY_NODE_TEMPLATE.replace("{1}", object_name)
			spawner_data = spawner_data.replace("{2}", object_game_path)
			spawner_go += spawner_data 
			objects_ready[object_name] = true
		}

		if (fs.existsSync(object_full_path)) {
			skipped += 1
			// console.log(object_full_path, "is already exist. Skip generate")
			continue
		}


		let atlas_name = path.join(output_path, "atlases", data.name + ".atlas")
		atlas_name = atlas_name.replace(process.cwd(), "")
		object_data = make_with_sprite(tile, anchor, atlas_name)
		object_data = check_colliders(object_data, anchor, tile)

		console.log("Write game object", object_full_path)
		generated += 1
		fs.writeFileSync(object_full_path, object_data)
	}

	console.log("End generate objects. Generated: ", generated, "Skipped:", skipped)

	let spawner_folder = path.join(output_path, "spawners")
	fs.mkdirSync(spawner_folder, { recursive: true })
	let spawner_path = path.join(spawner_folder, "spawner_" + data.name + ".go")
	fs.writeFileSync(spawner_path, spawner_go)
	console.log("Add", spawner_path)
}


module.exports = M