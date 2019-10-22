const fs = require("fs")
const path = require("path")
const process = require("process")
const settings = require("../settings.json")

const COLLECTION_TEMPLATE = fs.readFileSync(path.join(__dirname, "../templates/collection.template")).toString('utf8')
const COLLECTION_GO_TEMPLATE = fs.readFileSync(path.join(__dirname, "../templates/collection_go.template")).toString('utf8')

const M = {}


M.generate_spawners = function(name, data, output_path) {
	console.log("Start generate map_spawner for", name)
	let filename = "map_spawner_" + name
	let collection = COLLECTION_TEMPLATE.replace("{1}", filename)
	let generated_path = output_path.replace(process.cwd(), "")

	let tilesets = data.tilesets
	let spawners_go = []

	for (let i in tilesets) {
		let tileset = tilesets[i]
		let tileset_name = path.basename(tileset.source, ".tsx")

		let spawner_name = "spawner_" + tileset_name
		let spawner_go = COLLECTION_GO_TEMPLATE.replace("{1}", spawner_name)
		
		let spawner_path = path.join(generated_path, "spawners", spawner_name + ".go")
		spawner_go = spawner_go.replace("{2}", spawner_path)
		console.log("Add spawner:", spawner_path)
		spawners_go.push(spawner_go)
	}

	collection += spawners_go.join("\n")

	let map_spawners_path = path.join(output_path, "map_spawners")
	fs.mkdirSync(map_spawners_path, { recursive: true })

	let output_file = path.join(map_spawners_path, filename + ".collection")
	fs.writeFileSync(output_file, collection)
	console.log("Write map spawners:", output_file)
}


module.exports = M