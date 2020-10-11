--- Eva saver module
-- Carry on saving and loading game profile
-- Any save contains from different parts
-- Every part should be described via protobuf
--
-- If save filename in settings.json ends with .json,
-- save file will be in json format
--
-- @submodule eva


local semver = require("eva.libs.semver")

local app = require("eva.app")
local log = require("eva.log")
local luax = require("eva.luax")
local const = require("eva.const")

local proto = require("eva.modules.proto")
local events = require("eva.modules.events")
local migrations = require("eva.modules.migrations")

local logger = log.get_logger("eva.saver")

local M = {}


local function get_save_path(save_name)
	local project_name = sys.get_config("project.title")
	return sys.get_save_file(project_name, save_name)
end


local function get_default_save_name()
	-- Load via game project settings. Used in reload with filename
	local settings = app.settings.saver
	local filename = sys.get_config("eva.load_filename") or settings.save_name

	if filename == "" then
		filename = settings.save_name
	end

	return filename
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


--- Load the file from save directory
-- @function eva.saver.load
function M.load(filename)
	filename = filename or get_default_save_name()
	local path = get_save_path(filename)

	-- TODO: make json/proto/usual format
	if luax.string.ends(filename, ".json") then
		local file = io.open(path)
		if file then
			local file_data = file:read("*all")
			file:close()
			if file_data then
				local parsed_data = cjson.decode(file_data)
				if parsed_data then
					return parsed_data
				end
			end
		end

		return {}
	else
		return sys.load(path)
	end
end


--- Save the game file in save directory
-- @function eva.saver.save
function M.save(filename)
	local data = app[const.EVA.SAVER]
	data.version = data.version + 1

	filename = filename or app.settings.saver.save_name
	M.save_data(app.save_table, filename)
end


--- Save the data in save directory
-- @function eva.saver.save_data
function M.save_data(data, filename)
	local path = get_save_path(filename)

	if filename and luax.string.ends(filename, ".json") then
		local file = io.open(path, "w+")
		file:write(cjson.encode(data))
		file:close()
	else
		sys.save(path, data)
	end
end


--- Delete the save
-- @function eva.saver.delete
-- @tparam[opt] string filename The save filename. Can be default by settings
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
	prev_ref = proto.decode(name, proto.encode(name, prev_ref))
	luax.table.override(prev_ref, table_ref)
end


function M.before_eva_init()
	app.save_table = M.load()
	local path = get_save_path(get_default_save_name())
	logger:info("Load save from json", { path = path })
	M.can_load_save = true
end


function M.on_eva_init()
	app[const.EVA.SAVER] = proto.get(const.EVA.SAVER)
	app[const.EVA.SAVER].migration_version = migrations.get_count()
	M.add_save_part(const.EVA.SAVER, app[const.EVA.SAVER])

	events.subscribe(const.EVENT.IAP_PURCHASE, function() M.save() end)
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

	if last_version ~= "" and semver(current_version) < semver(last_version) then
		-- For some reasons, current version is lower when last one
		-- TODO: Check this out later
		logger:fatal("Downgrading game version", { previous = last_version, current = current_version })
	end

	app[const.EVA.SAVER].last_game_version = sys.get_config("project.version")

	apply_migrations()

	if settings.print_save_at_start then
		pprint(app.save_table)
	end

	logger:info("Save successful loaded", {
		version = app[const.EVA.SAVER].version,
		migration_version = app[const.EVA.SAVER].migration_version
	})
end


return M
