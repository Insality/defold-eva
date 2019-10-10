--- Eva saver module
-- Carry on saving and loading game profile
-- Any save contains from different parts
-- Every part should be described via protobuf
-- @submodule eva


local app = require("eva.app")
local log = require("eva.log")
local luax = require("eva.luax")
local const = require("eva.const")

local proto = require("eva.modules.proto")
local utils = require("eva.modules.utils")

local logger = log.get_logger("eva.saver")

local M = {}


local function get_save_path(save_name)
	local project_name = sys.get_config("project.title")
	return sys.get_save_file(project_name, save_name)
end


--- Load the game save
-- @function eva.saver.load
function M.load()
	local settings = app.settings.saver
	local path = get_save_path(settings.save_name)
	return sys.load(path)
end


--- Save the game save
-- @function eva.saver.save
function M.save()
	local data = app[const.EVA.SAVER]
	data.version = data.version + 1

	local settings = app.settings.saver
	local path = get_save_path(settings.save_name)
	sys.save(path, app.save_table)
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

	-- Clear the variables via protobuf
	if pb then
		prev_ref = proto.decode(name, proto.encode(name, prev_ref))
	end

	save_table[name] = table_ref
	luax.table.override(prev_ref, table_ref)
end


function M.before_eva_init()
	app.save_table = M.load()
	M.can_load_save = true
end


function M.on_eva_init()
	app[const.EVA.SAVER] = proto.get(const.EVA.SAVER)
	M.add_save_part(const.EVA.SAVER, app[const.EVA.SAVER])
end


function M.after_eva_init()
	local settings = app.settings.saver
	if settings.autosave > 0 then
		timer.delay(settings.autosave, true, M.save)
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

	if settings.print_save_at_start then
		pprint(app.save_table)
	end

	logger:info("Save successful loaded", { version = app[const.EVA.SAVER].version })
end


return M
