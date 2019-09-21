local M = {}

function M.on_game_start()
	M._stat_prefs = M._eva.proto.get("eva.Stats")

	M._eva.saver.add_save_part("eva.Stats", M._stat_prefs)
end


function M.after_game_start()
	M._stat_prefs.game_start_count = M._stat_prefs.game_start_count + 1
end


function M.on_game_update(dt)
	M._stat_prefs.game_time = M._stat_prefs.game_time + dt
end


return M
