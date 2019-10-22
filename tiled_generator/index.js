const fs = require("fs")
const path = require("path")
const process = require("process")
const tilesets = require("./scripts/tilesets")

function process_tileset(data, output_path, mapping) {
	console.log("Process tileset", data.name)
	tilesets.generate_atlas(data, output_path)
	tilesets.generate_objects(data, output_path, mapping)
}


function process_json(export_path, name, output_path, mapping) {
	let json_content  = JSON.parse(fs.readFileSync(export_path + name + ".json"))
	let json_type = json_content.type

	if (json_type == "tileset") {
		process_tileset(json_content, output_path, mapping)
		console.log("")
	}
	if (json_type == "map") {
		// Make collection for every map?
	}
}


function start_process_dir(export_path, output_path) {
	let json_list = fs.readdirSync(export_path)
		.filter(name => name.endsWith(".json"))
		.map(name => name.split(".")[0])

	console.log("Process next files:", json_list)

	let mapping = {}
	for (let i in json_list) {
		process_json(export_path, json_list[i], output_path, mapping)
	}

	let mapping_path = path.join(output_path, "mapping.json")
	fs.writeFileSync(mapping_path, JSON.stringify(mapping))
	console.log("Write", mapping_path)
}


function main() {
	console.log("Start tiled generator")
	let export_path = path.join(process.cwd(), process.argv[2])
	let output_path = path.join(process.cwd(), process.argv[3])

	if (!fs.existsSync(path.join(process.cwd(), "game.project"))) {
		console.log("Error: you should run script inside the root of game.project")
		return
	}

	start_process_dir(export_path, output_path)
}

main()