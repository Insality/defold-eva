--- Defold-Eva Timer module
-- Use to make some action on future, in concrete time
-- Can be used for crafts, long-time upgrades, special events.
-- You need check timers mostly by youself.
-- @submodule eva

local log = require("eva.log")
local const = require("eva.const")

local logger = log.get_logger("eva.timers")

local M = {}


--- Add new timer
-- Timer with slot_id should no exist
-- @tparam string slot_id identificator of timer
-- @tparam string timer_id string param of timer
-- @tparam number end_time. End time of timer, in seconds
-- @tparam[opt] bool auto_trigger true, if event should fire event at end
function M.add(slot_id, timer_id, end_time, auto_trigger)
	if M.get(slot_id) then
		logger:error("Timer with slot_id already exist", { slot_id = slot_id, timer_id = timer_id })
	end

	local timer = M._eva.proto.get(const.EVA.TIMER)
	timer.timer_id = timer_id
	timer.end_time = end_time
	timer.auto_trigger = auto_trigger

	M._timer_prefs.timers[slot_id] = timer
end


--- Get timer
function M.get(slot_id)
	return M._timer_prefs.timers[slot_id]
end


--- Get time until end, in seconds
function M.get_time(slot_id)
	local timer = M.get(slot_id)

	if timer then
		return math.max(0, timer.end_time - M._eva.game.get_time())
	else
		return -1
	end
end


--- Check is timer has ended
function M.is_end(slot_id)
	return M.get_time(slot_id) == 0
end


--- Clear the timer slot
function M.clear(slot_id)
	logger:debug("Clear timer slot", { slot_id = slot_id })
	M._timer_prefs.timers[slot_id] = nil
end


--- Set timer pause state
function M.set_pause(slot_id, is_pause)
	local timer = M.get(slot_id)
	if timer and timer.is_pause ~= is_pause then
		timer.is_pause = is_pause

		if is_pause then
			timer.pause_time = M._eva.game.get_time()
		else
			local time_delta = M._eva.game.get_time() - timer.pause_time
			timer.end_time = timer.end_time + time_delta
			timer.pause_time = 0
		end
	end
end


function M.on_game_start()
	M._timer_prefs = M._eva.proto.get(const.EVA.TIMERS)
	M._eva.saver.add_save_part(const.EVA.TIMERS, M._timer_prefs)
end


local skip_counter = 1
function M.on_game_update(dt)
	skip_counter = skip_counter - dt
	if skip_counter > 0 then
		return
	end
	skip_counter = 1

	local timers = M._timer_prefs.timers
	for slot_id, timer in pairs(timers) do
		if timer.auto_trigger and M.is_end(slot_id) then
			M._eva.events.event(const.EVENT.TIMER_TRIGGER, {
				slot_id = slot_id,
				timer_id = timer.timer_id
			})
		end
	end
end


return M
