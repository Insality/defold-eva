--- Defold-Eva saver module
-- @submodule eva

local log = require("eva.log")
local luax = require("eva.luax")
local const = require("eva.const")

local logger = log.get_logger("eva.saver")

local M = {}
local save_table = {}


local function get_save_path(save_name)
	local project_name = sys.get_config("project.title")
	return sys.get_save_file(project_name, save_name)
end


--- Load the game save
-- @function eva.saver.load
function M.load()
	local path = get_save_path(M.settings.save_name)
	return sys.load(path)
end


--- Save the game save
-- @function eva.saver.save
function M.save()
	M._saver_prefs.version = M._saver_prefs.version + 1

	local path = get_save_path(M.settings.save_name)
	sys.save(path, save_table)
end


--- Reset the game profile
-- @function eva.saver.reset
function M.reset()
	save_table = {}
end


--- Add save part to the save table
-- @function eva.saver.add_save_part
function M.add_save_part(name, table_ref)
	assert(M.can_load_save, "Add save part should be called after eva init")

	if not save_table[name] then
		-- Add save template as new
		save_table[name] = table_ref
		return
	end

	local prev_ref = save_table[name]
	-- Clear the variables via protobuf
	prev_ref = pb.decode(name, pb.encode(name, prev_ref))

	save_table[name] = table_ref
	luax.table.override(prev_ref, table_ref)
end


function M.before_game_start(settings)
	M.settings = settings
	save_table = M.load()
	M.can_load_save = true
end


function M.on_game_start(settings)
	M._saver_prefs = M._eva.proto.get(const.EVA.SAVER)
	M._eva.saver.add_save_part(const.EVA.SAVER, M._saver_prefs)
end


function M.after_game_start(settings)
	if settings.autosave > 0 then
		timer.delay(settings.autosave, true, M.save)
	end

	local last_version = M._saver_prefs.last_game_version
	local current_version = sys.get_config("project.version")

	if last_version ~= "" then
		local compare = M._eva.utils.compare_versions(last_version, current_version)
		if compare == -1 then
			-- For some reasons, current version is lower when last one
			-- TODO: Check this out later
			logger:fatal("Downgrading game version", { previous = last_version, current = current_version })
		end
	end

	M._saver_prefs.last_game_version = sys.get_config("project.version")

	if settings.print_save_at_start then
		pprint(save_table)
	end

	logger:info("Save successful loaded", { version = M._saver_prefs.version })
end


return M
