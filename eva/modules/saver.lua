local log = require("eva.log")
local luax = require("eva.luax")
local const = require("eva.const")

local logger = log.get_logger("eva.saver")

local M = {}
local save_table = {}


local project_name = sys.get_config("project.title")
local save_path = sys.get_save_file(project_name, "eva")


function M.load()
	return sys.load(save_path)
end


function M.save()
	M._saver_prefs.version = M._saver_prefs.version + 1

	sys.save(save_path, save_table)
end


function M.reset()
	save_table = {}
end


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


function M.before_game_start()
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
