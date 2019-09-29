--- Defold-eva simply daily bonus module
-- daily types: reset, skip, wait
-- (what we do at end of prize timer)
-- @submodule eva

local luax = require("eva.luax")
local const = require("eva.const")

local M = {}


local function check_days()
	local settings = M._eva.app.settings.daily
	local data = M._eva.app[const.EVA.DAILY]

	assert(#data.reward_state == data.current_day - 1)

	local max_days = #settings.reward

	if data.current_day > #max_days then
		data.current_day = 1
		data.reward_state = {}
	end
end


local function reset_daily()
	local data = M._eva.app[const.EVA.DAILY]
	data.current_day = 1
	data.last_pick_time = 0
	data.reward_state = {}
end


local function lost_daily()
	local settings = M._eva.app.settings.daily

	local data = M._eva.app[const.EVA.DAILY]
	data.current_day = data.current_day + 1
	-- New pick time: need to calc extra time more than wait_time + interval
	-- last_pick_time = [cur_time - extra_time .. cur_time]
	local extra_time = M._eva.game.get_time() - data.last_pick_time
	extra_time = extra_time - settings.interval - settings.wait_time
	extra_time = luax.math.clamp(extra_time, 0, settings.interval)

	data.last_pick_time = M._eva.game.get_time() - extra_time
	table.insert(data.reward_state, false)

	check_days()
end


local function check_states()
	local settings = M._eva.app.settings.daily

	local state = settings.type
	if M.get_wait_time() == 0 then
		if state == const.DAILY.WAIT then
			-- do nothing and waiting until pickup
		end
		if state == const.DAILY.RESET then
			reset_daily()
		end
		if state == const.DAILY.LOST then
			lost_daily()
		end
	end
end


--- Return is active now daily system
-- @function eva.daily.is_active
function M.is_active()
	return M._eva.app[const.EVA.DAILY].is_active
end


--- Set active daily system
-- It will reset last pick time
-- @function eva.daily.set_active
function M.set_active(state)
	local data = M._eva.app[const.EVA.DAILY]
	data.is_active = state
	data.last_pick_time = 0
end


--- Pick current prize
-- @function eva.daily.pick_current
function M.pick_current()
	if M.get_time() > 0 then
		return false
	end

	local settings = M._eva.app.settings.daily
	local data = M._eva.app[const.EVA.DAILY]

	data.last_pick_time = M._eva.game.get_time()

	data.current_day = data.current_day + 1
	table.insert(data.reward_state, true)

	local reward_id = settings.reward[data.current_day - 1]
	M._eva.tokens.add_group(reward_id)

	check_days()
	return true
end


--- Return time until you can pickup prize
-- @function eva.daily.get_time()
function M.get_time()
	local settings = M._eva.app.settings.daily
	local data = M._eva.app[const.EVA.DAILY]
	local elapsed = (M._eva.game.get_time() - data.last_pick_time)
	return math.max(0, settings.interval - elapsed)
end


--- Return time until you can lose the unpicked reward
-- @function eva.daily.get_time()
function M.get_wait_time()
	local settings = M._eva.app.settings.daily
	local data = M._eva.app[const.EVA.DAILY]
	local elapsed = (M._eva.game.get_time() - data.last_pick_time)
	return math.max(0, (settings.interval + settings.wait_time) - elapsed)
end


function M.on_game_start()
	M._eva.app[const.EVA.DAILY] = M._eva.proto.get(const.EVA.DAILY)
	M._eva.app[const.EVA.DAILY].current_day = 1

	M._eva.saver.add_save_part(const.EVA.DAILY, M._eva.app[const.EVA.DAILY])
end


function M.on_game_second()
	check_states()
end


return M
