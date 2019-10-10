--- Eva stats module
-- Collect basic game statistics about player
-- @submodule eva


-- TODO: Can we calculate average FPS statistic? and other system

local app = require("eva.app")
local const = require("eva.const")

local game = require("eva.modules.game")
local proto = require("eva.modules.proto")
local saver = require("eva.modules.saver")


local M = {}


function M.on_eva_init()
	app[const.EVA.STATS] = proto.get(const.EVA.STATS)
	saver.add_save_part(const.EVA.STATS, app[const.EVA.STATS])
end


function M.after_eva_init()
	local settings = app.settings.stats
	local stats = app[const.EVA.STATS]
	stats.game_start_count = stats.game_start_count + 1

	table.insert(stats.game_start_dates, game.get_current_time_string())
	while #stats.game_start_dates > settings.game_started_max_count do
		table.remove(stats.game_start_dates, 1)
	end
end


function M.on_eva_update(dt)
	app[const.EVA.STATS].game_time = app[const.EVA.STATS].game_time + dt
end


return M
