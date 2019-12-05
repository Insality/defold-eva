--- Eva push module
-- @submodule eva


local app = require("eva.app")
local log = require("eva.log")
local luax = require("eva.luax")
local const = require("eva.const")

local game = require("eva.modules.game")
local proto = require("eva.modules.proto")
local saver = require("eva.modules.saver")
local events = require("eva.modules.events")

local logger = log.get_logger("eva.push")

local M = {}


local function push_listener(self, payload, origin)
	pprint(payload, origin)
end


local function push_schedule(delta_time, title, text, data)
	if not push then
		return game.get_session_uid()
	end

	data = data or luax.table.empty
	local id = push.schedule(delta_time, title, text, cjson.encode(data), {})
	return id
end


local function push_cancel(id)
	if not push then
		return
	end
	push.cancel(id)
end


local function get_time_code(date)
	date = date or os.date("*t", game.get_time())
	return date.month * 100 + date.day
end


local function is_can_schedule(push_time, category)
	local settings = app.settings.push
	local max_per_day = settings.max_per_day
	local max_category_per_day = settings.max_category_per_day

	if max_per_day == 0 and max_category_per_day == 0 then
		return true
	end

	local push_date = os.date("*t", push_time)
	local push_code = get_time_code(push_date)

	local category_counter = 0
	local push_counter = 0

	local pushes = app[const.EVA.PUSH].pushes

	for i = 1, #pushes do
		local push = pushes[i]
		local code = get_time_code(os.date("*t", push.time))

		if push_code == code then
			push_counter = push_counter + 1
			if push.category == category and category ~= luax.string.empty then
				category_counter = category_counter + 1
			end
		end
	end

	if max_per_day > 0 and push_counter >= max_per_day then
		return false
	end

	if max_category_per_day > 0 and category_counter >= max_category_per_day then
		return false
	end

	return true
end


local function get_correct_push_time(seconds_after)
	local current_time = game.get_time()
	local push_time = current_time + seconds_after
	local settings = app.settings.push

	local push_date = os.date("*t", push_time)

	if push_date.hour >= settings.snooze_hour_start then
		push_date.day = push_date.day + 1
		push_date.hour = settings.snooze_hour_end
	end

	return os.time(push_date)
end


--- Clear all pushes, what already
-- should be invoked.
-- @function eva.push.clear_old_pushes
function M.clear_old_pushes()
	local pushes = app[const.EVA.PUSH].pushes

	local cur_day_code = get_time_code()

	for i = #pushes, 1, -1 do
		local push_code = get_time_code(os.date("*t", pushes[i].time))

		if push_code < cur_day_code then
			table.remove(pushes, i)
		end

		if push_code == cur_day_code then
			pushes[i].is_triggered = true
		end
	end
end


--- Schedule notification
-- @function eva.push.schedule
function M.schedule(seconds_after, title, text, category, payload)
	local push_time = get_correct_push_time(seconds_after)
	local delta_time = push_time - game.get_time()

	if delta_time <= app.settings.push.clear_push_in_next_seconds then
		logger:info("Can't schedule push, to soon", { after = delta_time, category = category })
		return
	end

	if not is_can_schedule(push_time, category) then
		logger:info("Can't schedule push", { after = delta_time, category = category })
		return
	end

	local id = push_schedule(delta_time, title, text, payload)

	if id then
		local push_info = proto.get(const.EVA.PUSH_INFO)
		push_info.id = id
		push_info.time = push_time
		push_info.category = category or ""

		table.insert(app[const.EVA.PUSH].pushes, push_info)
		events.event(const.EVENT.PUSH_SCHEDULED, {
			id = id,
			time = push_time,
			category = push_info.category
		})

		return push_info
	end
end


--- Schedule by list
-- Every notifications have: after, title, text, category, payload
-- @function eva.push.schedule_list
function M.schedule_list(notifications)
	for i = 1, #notifications do
		local n = notifications[i]
		M.schedule(n.after, n.title, n.text, n.payload, n.payload)
	end
end


--- Unschedule the push notification
-- @function eva.push.unschedule
function M.unschedule(id)
	local pushes = app[const.EVA.PUSH].pushes

	local push_index = -1
	for i = 1, #pushes do
		if pushes[i].id == id then
			push_index = i
		end
	end
	local push = pushes[push_index]

	if not push then
		logger:info("No push with id to unschedule", { id = id })
		return
	end

	if not push.is_triggered then
		push_cancel(push.id)
	end
	table.remove(pushes, push_index)

	events.event(const.EVENT.PUSH_CANCEL, { id = id, category = push.category })
end


--- Cancel all pushes with category
-- If category is not provided, cancel all pushes
-- @function eva.push.unschedule_all
function M.unschedule_all(category)
	local pushes = app[const.EVA.PUSH].pushes

	for i = #pushes, 1, -1 do
		local push = pushes[i]
		local category_match = true
		if category and category ~= luax.string.empty then
			category_match = (push.category == category)
		end
		if category_match and not push.is_triggered then
			M.unschedule(push.id)
		end
	end
end


function M.on_eva_init()
	app[const.EVA.PUSH] = proto.get(const.EVA.PUSH)
	saver.add_save_part(const.EVA.PUSH, app[const.EVA.PUSH])

	M.clear_old_pushes()
	--[[
	print("Try register push")
	push.register({}, function (self, token, error)
		if token then
			push.set_listener(push_listener)
			print("Token", token)
		else
			-- Push registration failed.
			print(error.error)
		end
	end)
	--]]
	if push then
		push.set_listener(push_listener)
	end
end


function M.on_eva_second()
	local settings = app.settings.push
	local pushes = app[const.EVA.PUSH].pushes
	local current_time = game.get_time()
	local time_gap = settings.clear_push_in_next_seconds or 0

	for i = #pushes, 1, -1 do
		local push = pushes[i]
		if push.time < (current_time + time_gap) and push.time >= current_time then
			M.unschedule(push.id)
		end
	end
end


return M
