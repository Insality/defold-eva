local luax = require("eva.luax")

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
	M._saver_prefs = M._eva.proto.get("eva.Saver")
	M._eva.saver.add_save_part("eva.Saver", M._saver_prefs)
end


function M.after_game_start(settings)
	if settings.autosave > 0 then
		timer.delay(settings.autosave, true, M.save)
	end

	-- pprint(save_table)
end


return M
