local luax = require("eva.luax")
local settings = require("eva.settings.default")

local M = {}
local save_table = {}

local project_name = sys.get_config("project.title")
local save_path = sys.get_save_file(project_name, "eva")


function M.load()
	return sys.load(save_path)
end


function M.save()
	sys.save(save_path, save_table)
end


function M.reset()
	save_table = {}
end


function M.add_save_part(name, table_ref)
	if not save_table[name] then
		-- Add save template as new
		save_table[name] = table_ref
		return
	end

	local prev_ref = save_table[name]
	save_table[name] = table_ref

	luax.table.override(prev_ref, table_ref)
end


function M.before_game_start()
	save_table = M.load()
end


function M.after_game_start()
	if settings.saver.autosave > 0 then
		timer.delay(settings.saver.autosave, true, M.save)
	end
end


return M
