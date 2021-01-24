# Eva Setup

## Dependencies

You can use the **Eva** extension in your own project by adding this project as a [Defold library dependency](https://www.defold.com/manuals/libraries/). Open your game.project file and in the dependencies field under project add:

> [https://github.com/Insality/defold-eva/archive/master.zip](https://github.com/Insality/defold-eva/archive/master.zip)

Or point to the ZIP file of a [specific release](https://github.com/Insality/defold-eva/releases).


Eva required other dependencies for work. Full list you can find here: https://github.com/Insality/defold-eva/blob/master/dependencies.txt

There is two list of dependencies. Add all important dependencies and use optional dependencies, if you need that stuff


## Eva Settings file

Copy eva settings file from /eva/resources/eva_settings.json to you project resource folder (The custom resource field from game.project).

For example you have custom resource folder `resources` and place `eva_settings.json` file inside, your settings path will be `/resources/eva_settings.json`


## Eva proto files

Eva work with proto files, so you need copy two proto files to your resources folder: `eva.proto` and `evadata.proto` to you custom resources folder from `/eva/resources/*.proto`.
Set proto paths inside your eva.settings file in `proto` section:

Json Key is the folder path. Value is array of proto files inside this folder.

```json
	"proto": {
		"default_nest_messages": true,
		"proto_paths": {
			"/resources": [
				"eva.proto",
				"evadata.proto"
			]
		}
	},
```


## Init Eva

In your start script file init eva:

```lua
local eva = require("eva.eva")

function init(self)
	eva.init("/resources/eva_settings.json")
end

```

You should get no errors in the log and message like this

`D[eva]</eva/eva.lua:178>: Eva init completed {settings = "/resources/eva_settings.json",version = 1}`


## Setup Databases

Eva uses sheets-exporter to manage all modules data.

All config paths described in eva_settings.json in "db" section. All config data structure described in `evadata.proto`

Example for google docs you can see here: https://docs.google.com/spreadsheets/d/1-kbuk5avCvjkAgUwKM29fHf77Uc1-jZ5TtS3EHZbY4g
Rules for sheets-exporter you can get here: https://github.com/Insality/defold-eva/blob/master/export_config/rules_eva.json