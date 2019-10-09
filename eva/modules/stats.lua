--- Eva stats module
-- Collect basic game statistics about player
-- @submodule eva


-- TODO: Can we calculate average FPS statistic? and other system

local app = require("eva.app")
local const = require("eva.const")

local M = {}


function M.on_game_start()
	app[const.EVA.STATS] = M._eva.proto.get(const.EVA.STATS)
	M._eva.saver.add_save_part(const.EVA.STATS, app[const.EVA.STATS])
end


function M.after_game_start()
	local settings = app.settings.stats
	local stats = app[const.EVA.STATS]
	stats.game_start_count = stats.game_start_count + 1

	table.insert(stats.game_start_dates, M._eva.game.get_current_time_string())
	while #stats.game_start_dates > settings.game_started_max_count do
		table.remove(stats.game_start_dates, 1)
	end
end


function M.on_game_update(dt)
	app[const.EVA.STATS].game_time = app[const.EVA.STATS].game_time + dt
end


return M
