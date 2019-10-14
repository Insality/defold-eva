--- Eva saver module
-- Carry on saving and loading game profile
-- Any save contains from different parts
-- Every part should be described via protobuf
-- @submodule eva


local app = require("eva.app")
local log = require("eva.log")
local luax = require("eva.luax")
local const = require("eva.const")
local protoc = require("pb.protoc")

local proto = require("eva.modules.proto")
local utils = require("eva.modules.utils")
local migrations = require("eva.modules.migrations")

local logger = log.get_logger("eva.saver")

local M = {}


local function get_save_path(save_name)
	local project_name = sys.get_config("project.title")
	return sys.get_save_file(project_name, save_name)
end


local function apply_migrations()
	local save_data = app[const.EVA.SAVER]

	local current_version = save_data.migration_version
	local migrations_count = migrations.get_count()

	while current_version < migrations_count do
		current_version = current_version + 1
		migrations.apply(current_version, app.save_table)
	end

	save_data.migration_version = migrations_count
end


local function get_loaded_proto()
	local result = {}
	local loaded = protoc.loaded
	for filename, data in pairs(loaded) do
		local package = data.package
		for i = 1, #data.message_type do
			local name = data.message_type[i].name
			table.insert(result, package .. "." .. name)
		end
	end

	return result
end


local function clean_up_save()
	if not pb then
		return
	end

	local save_table = app.save_table
	local loaded_proto = get_loaded_proto()

	for name, save_ref in pairs(save_table) do
		if luax.table.contains(loaded_proto, name) then
			save_table[name] = proto.decode(name, proto.encode(name, save_ref))
		else
			logger:warn("No proto to save part. Remove it from save", {
				proto_name = name
			})
		end
	end
end


--- Load the game save
-- @function eva.saver.load
function M.load(filename)
	-- Load via game project settings. Used in reload with filename
	local settings = app.settings.saver
	filename = filename or sys.get_config("eva.load_filename") or settings.save_name

	if filename == "" then
		filename = settings.save_name
	end

	local path = get_save_path(filename)

	if luax.string.ends(filename, ".json") then
		logger:info("Load save from json", { path = path })

		local file = io.open(path)
		if file then
			local save_data = file:read("*all")
			file:close()
			if save_data then
				local save = cjson.decode(save_data)
				if save then
					return save
				end
			end
		end

		return {}
	else
		return sys.load(path)
	end
end


--- Save the game save
-- @function eva.saver.save
function M.save(filename)
	local data = app[const.EVA.SAVER]
	data.version = data.version + 1

	local settings = app.settings.saver
	local path = get_save_path(filename or settings.save_name)

	if filename and luax.string.ends(filename, ".json") then
		logger:info("Save custom filename", { path = path })

		local file = io.open(path, "w+")
		file:write(cjson.encode(app.save_table))
		file:close()
	else
		sys.save(path, app.save_table)
	end
end


function M.delete(filename)
	local path = get_save_path(filename or app.settings.saver.save_name)
	os.remove(path)
end


--- Reset the game profile
-- @function eva.saver.reset
function M.reset()
	app.save_table = {}
end


--- Add save part to the save table
-- @function eva.saver.add_save_part
function M.add_save_part(name, table_ref)
	assert(M.can_load_save, "Add save part should be called after eva init")
	local save_table = app.save_table

	if not save_table[name] then
		-- Add save template as new
		save_table[name] = table_ref
		return
	end

	local prev_ref = save_table[name]

	save_table[name] = table_ref
	luax.table.override(prev_ref, table_ref)
end


function M.before_eva_init()
	app.save_table = M.load()
	M.can_load_save = true
end


function M.on_eva_init()
	app[const.EVA.SAVER] = proto.get(const.EVA.SAVER)
	app[const.EVA.SAVER].migration_version = migrations.get_count()
	M.add_save_part(const.EVA.SAVER, app[const.EVA.SAVER])
end


function M.after_eva_init()
	local settings = app.settings.saver
	if settings.autosave > 0 then
		timer.delay(settings.autosave, true, function()
			M.save()
		end)
	end

	local last_version = app[const.EVA.SAVER].last_game_version
	local current_version = sys.get_config("project.version")

	if last_version ~= "" then
		local compare = utils.compare_versions(last_version, current_version)
		if compare == -1 then
			-- For some reasons, current version is lower when last one
			-- TODO: Check this out later
			logger:fatal("Downgrading game version", { previous = last_version, current = current_version })
		end
	end

	app[const.EVA.SAVER].last_game_version = sys.get_config("project.version")

	apply_migrations()
	clean_up_save()

	if settings.print_save_at_start then
		pprint(app.save_table)
	end

	logger:info("Save successful loaded", {
		version = app[const.EVA.SAVER].version,
		migration_version = app[const.EVA.SAVER].migration_version
	})
end


return M
