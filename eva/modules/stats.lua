local M = {}

-- use part from saver? how?
local stats = {
	game_time = 0, -- in seconds, spent time in game
	game_start_count = 0,
	iaps_count = 0,
	ads_watched = 0,
	prefer_playing_time = 0, -- time (in local hours), when player offen starts the game
}


function M.on_game_start()
	stats.game_start_count = stats.game_start_count + 1
end


function M.on_game_update(dt)
	stats.game_time = stats.game_time + dt
end


return M
