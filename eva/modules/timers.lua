--- Eva Timer module
-- Use to make some action on future, in concrete time
-- Can be used for crafts, long-time upgrades, special events.
-- You need check timers mostly by youself.
-- Auto_trigger events fire the TIMER_TRIGGER event, but in response
-- you should clear the timer (in case, if you did not catch the event).
-- @submodule eva


local app = require("eva.app")
local log = require("eva.log")
local const = require("eva.const")

local game = require("eva.modules.game")
local saver = require("eva.modules.saver")
local proto = require("eva.modules.proto")
local events = require("eva.modules.events")

local logger = log.get_logger("eva.timers")

local M = {}


--- Add new timer
-- Timer with slot_id should no exist
-- @function eva.timers.add
-- @tparam string slot_id identificator of timer
-- @tparam string timer_id string param of timer
-- @tparam number time time of timer, in seconds
-- @tparam[opt] bool auto_trigger true, if event should fire event at end
function M.add(slot_id, timer_id, time, auto_trigger)
	if M.get(slot_id) then
		logger:error("Timer with slot_id already exist", { slot_id = slot_id, timer_id = timer_id })
		return false
	end

	local timer = proto.get(const.EVA.TIMER)
	timer.timer_id = timer_id
	timer.end_time = game.get_time() + time
	timer.auto_trigger = auto_trigger

	app[const.EVA.TIMERS].timers[slot_id] = timer
	logger:debug("New timer created", timer)

	return timer
end


--- Get timer
-- @function eva.timers.get
function M.get(slot_id)
	return app[const.EVA.TIMERS].timers[slot_id]
end


--- Get time until end, in seconds
-- @function eva.timers.get_time
-- @tparam string slot_id identificator of timer
-- @treturn number Time until end of timer. -1 if timer is not exist
function M.get_time(slot_id)
	local timer = M.get(slot_id)

	if timer then
		local till_end = timer.end_time - game.get_time()

		if timer.is_pause then
			till_end = till_end + game.get_time() - timer.pause_time
		end

		return math.max(0, till_end)
	else
		return -1
	end
end


--- Check is timer has ended
-- @function eva.timers.is_end
-- @tparam string slot_id identificator of timer
function M.is_end(slot_id)
	return M.get_time(slot_id) == 0
end


--- Clear the timer slot
-- @function eva.timers.clear
-- @tparam string slot_id identificator of timer
function M.clear(slot_id)
	logger:debug("Clear timer slot", { slot_id = slot_id })
	app[const.EVA.TIMERS].timers[slot_id] = nil
end


--- Set timer pause state
-- @function eva.timers.set_pause
-- @tparam string slot_id identificator of timer
-- @tparam boolean is_pause pause state
function M.set_pause(slot_id, is_pause)
	local timer = M.get(slot_id)
	if timer and timer.is_pause ~= is_pause then
		timer.is_pause = is_pause

		if is_pause then
			timer.pause_time = game.get_time()
		else
			local time_delta = game.get_time() - timer.pause_time
			timer.end_time = timer.end_time + time_delta
			timer.pause_time = 0
		end
		logger:debug("Change timer pause status", timer)
	end
end


function M.on_eva_init()
	app[const.EVA.TIMERS] = proto.get(const.EVA.TIMERS)
	saver.add_save_part(const.EVA.TIMERS, app[const.EVA.TIMERS])
end


function M.on_eva_second()
	local timers = app[const.EVA.TIMERS].timers
	for slot_id, timer in pairs(timers) do
		local can_trigger = timer.auto_trigger and not timer.is_pause
		if can_trigger and M.is_end(slot_id) then
			events.event(const.EVENT.TIMER_TRIGGER, {
				slot_id = slot_id,
				timer_id = timer.timer_id
			})
		end
	end
end


return M
