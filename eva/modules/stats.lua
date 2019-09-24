local const = require("eva.const")

local M = {}


function M.on_game_start()
	M._stat_prefs = M._eva.proto.get(const.EVA.STATS)

	M._eva.saver.add_save_part(const.EVA.STATS, M._stat_prefs)
end


function M.after_game_start(settings)
	local stats = M._stat_prefs
	stats.game_start_count = stats.game_start_count + 1

	table.insert(stats.game_start_dates, M._eva.game.get_current_time_string())
	while #stats.game_start_dates > settings.game_started_max_count do
		table.remove(stats.game_start_dates, 1)
	end
end


function M.on_game_update(dt)
	M._stat_prefs.game_time = M._stat_prefs.game_time + dt
end


return M
