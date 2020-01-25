--- Eva simply daily bonus module
-- daily types: reset, skip, wait
-- (what we do at end of prize timer)
-- @submodule eva


local app = require("eva.app")
local luax = require("eva.luax")
local const = require("eva.const")
local log = require("eva.log")

local proto = require("eva.modules.proto")
local saver = require("eva.modules.saver")
local game = require("eva.modules.game")
local events = require("eva.modules.events")
local wallet = require("eva.modules.wallet")

local logger = log.get_logger("eva.daily")

local M = {}


local function check_days()
	local settings = app.settings.daily
	local data = app[const.EVA.DAILY]

	if not data.is_active then
		return
	end

	if #data.reward_state >= #settings.reward then
		data.reward_state = {}
		events.event(const.EVENT.DAILY_NEW_CYCLE)
	end
end


local function reset_daily()
	local data = app[const.EVA.DAILY]

	events.event(const.EVENT.DAILY_RESET, { day = #data.reward_state })

	data.last_pick_time = 0
	data.reward_state = {}
end


local function lost_daily()
	local settings = app.settings.daily

	local data = app[const.EVA.DAILY]
	-- New pick time: need to calc extra time more than wait_time + interval
	-- last_pick_time = [cur_time - extra_time .. cur_time]
	local extra_time = game.get_time() - data.last_pick_time
	extra_time = extra_time - settings.interval - settings.wait_time
	extra_time = luax.math.clamp(extra_time, 0, settings.interval)

	data.last_pick_time = game.get_time() - extra_time
	table.insert(data.reward_state, false)

	events.event(const.EVENT.DAILY_LOST, { day = #data.reward_state - 1 })

	check_days()
end


local function check_states()
	local settings = app.settings.daily
	local data = app[const.EVA.DAILY]

	if #data.reward_state == 0 then
		-- Do nothing at first day
		return
	end

	local state = settings.type
	if M.get_wait_time() == 0 then
		-- Do nothing and state const.DAILY.WAIT
		if state == const.DAILY.RESET then
			reset_daily()
		end
		if state == const.DAILY.SKIP then
			lost_daily()
		end
	end
end


--- Return is active now daily system
-- @function eva.daily.is_active
function M.is_active()
	return app[const.EVA.DAILY].is_active
end


--- Set active daily system
-- It will reset last pick time
-- @function eva.daily.set_active
function M.set_active(state)
	local data = app[const.EVA.DAILY]
	data.is_active = state
	data.last_pick_time = 0
end


--- Pick current prize
-- @function eva.daily.pick
function M.pick()
	local settings = app.settings.daily
	local data = app[const.EVA.DAILY]

	if not data.is_active or M.get_time() > 0 then
		return
	end

	data.last_pick_time = game.get_time()

	table.insert(data.reward_state, true)

	local reward_id = settings.reward[#data.reward_state]
	wallet.add_group(reward_id)

	events.event(const.EVENT.DAILY_REWARD, { reward_id = reward_id, day = #data.reward_state })

	check_days()
	return true
end


--- Return time until you can pickup prize
-- @function eva.daily.get_time
function M.get_time()
	local settings = app.settings.daily
	local data = app[const.EVA.DAILY]
	local elapsed = (game.get_time() - data.last_pick_time)
	if not data.is_active then
		return 0
	end

	return math.max(0, settings.interval - elapsed)
end


--- Return time until you can lose the unpicked reward
-- @function eva.daily.get_wait_time
function M.get_wait_time()
	local settings = app.settings.daily
	local data = app[const.EVA.DAILY]
	local elapsed = (game.get_time() - data.last_pick_time)
	if not data.is_active then
		return 0
	end

	return math.max(0, (settings.interval + settings.wait_time) - elapsed)
end


--- Return current state
-- @function eva.daily.get_current_state
-- @treturn table Array with booleans to show picked rewards
function M.get_current_state()
	local data = app[const.EVA.DAILY]
	return data.reward_state
end


function M.on_eva_init()
	app[const.EVA.DAILY] = proto.get(const.EVA.DAILY)
	saver.add_save_part(const.EVA.DAILY, app[const.EVA.DAILY])
end


function M.on_eva_second()
	check_states()
end


return M
