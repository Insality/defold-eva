--- Eva festivals module
-- It carry on some time events, like halloween,
-- new year, foodtracks in some games.
-- It can start and end events by date with some logic
-- It can be repeatable every day, week, year etc
-- It have deadzone at end, to not start before festival end
-- It throws events on start/end festival
-- @submodule eva


local log = require("eva.log")
local luax = require("eva.luax")
local app = require("eva.app")
local const = require("eva.const")
local time_string = require("eva.libs.time_string")

local game = require("eva.modules.game")
local proto = require("eva.modules.proto")
local timers = require("eva.modules.timers")
local saver = require("eva.modules.saver")
local events = require("eva.modules.events")

local logger = log.get_logger("eva.festivals")

local M = {}


local function get_timer_slot(festival_id)
	return "eva.festivals." .. festival_id
end


local function is_time_to_start(festival_id)
	local festivals = app.db.Festivals.festivals
	local festival = festivals[festival_id]
	local current_time = game.get_time()

	local start_time = M.get_start_time(festival_id)
	local end_start_time = start_time + festival.duration - festival.close_time

	if start_time <= current_time and current_time <= end_start_time then
		return true
	end
end


local function is_need_to_start(festival_id)
	local festivals = app.db.Festivals.festivals
	local festival = festivals[festival_id]

	-- Festivals with repeat time never can be fully completed
	local is_completed = M.is_completed(festival_id) and not festival.repeat_time
	local is_current = M.is_active(festival_id)
	local is_time_to = is_time_to_start(festival_id)
	local is_can_start_custom = true
	if app.festivals_settings.is_can_start then
		is_can_start_custom = app.festivals_settings.is_can_start(festival_id, festival)
	end

	if not is_completed and not is_current and is_time_to and is_can_start_custom then
		return true
	end
end


local function start_festival(festival_id)
	local festival_data = app[const.EVA.FESTIVALS]
	local festival = app.db.Festivals.festivals[festival_id]

	local is_current = M.is_active(festival_id)
	if is_current then
		logger:warn("Trying to start already started festival", { id = festival_id })
		return
	end

	table.insert(festival_data.current, festival_id)

	local festival_slot = get_timer_slot(festival_id)
	local time = M.get_end_time(festival_id) - game.get_time()
	timers.add(festival_slot, festival_id, time)

	if app.festivals_settings.on_festival_start then
		app.festivals_settings.on_festival_start(festival_id, festival)
	end

	events.event(const.EVENT.FESTIVAL_START, {
		id = festival_id,
		time = time
	})
end


local function end_festival(festival_id)
	local festival_data = app[const.EVA.FESTIVALS]
	local festival = app.db.Festivals.festivals[festival_id]

	local is_current = M.is_active(festival_id)
	if not is_current then
		logger:warn("Trying to end non current festival", { id = festival_id })
		return
	end

	local festival_slot = get_timer_slot(festival_id)
	timers.clear(festival_slot)
	table.remove(festival_data.current, is_current)
	festival_data.completed[festival_id] = (festival_data.completed[festival_id] or 0) + 1

	if app.festivals_settings.on_festival_end then
		app.festivals_settings.on_festival_end(festival_id, festival)
	end

	events.event(const.EVENT.FESTIVAL_END, {
		id = festival_id,
		completed_times = festival_data.completed[festival_id]
	})
end


--- Return is festival is active now
-- @function eva.festivals.is_active
-- @tparam string festival_id Festival id from Festivals json
-- @treturn boolean Current festival state
function M.is_active(festival_id)
	local festival_data = app[const.EVA.FESTIVALS]
	return luax.table.contains(festival_data.current, festival_id)
end


--- Return is festival is completed
-- Return true for repeated festivals, is they are completed now
-- @function eva.festivals.is_completed
-- @tparam string festival_id Festival id from Festivals json
-- @treturn number Festival completed counter (For repeat festivals can be > 1)
function M.is_completed(festival_id)
	local festival_data = app[const.EVA.FESTIVALS]
	return festival_data.completed[festival_id]
end


--- Return next start time for festival_id
-- @function eva.festivals.get_start_time
-- @tparam string festival_id Festival id from Festivals json
-- @treturn number Time in seconds since epoch
function M.get_start_time(festival_id)
	local festivals = app.db.Festivals.festivals
	local festival = festivals[festival_id]

	if not festival then
		logger:warn("No festival with id", { id = festival_id })
		return
	end

	local current_time = game.get_time()
	local start_time = app.festivals_cache[festival_id] or time_string.parse_ISO(festival.start_date)

	if start_time > current_time then
		return start_time
	end

	local is_going_now = start_time + festival.duration > current_time
	if not is_going_now and festival.repeat_time then
		start_time = time_string.get_next_time(start_time, festival.repeat_time, current_time)
		app.festivals_cache[festival_id] = start_time
	end

	return start_time
end


--- Return next end time for festival_id
-- @function eva.festivals.get_end_time
-- @tparam string festival_id Festival id from Festivals json
-- @treturn number Time in seconds since epoch
function M.get_end_time(festival_id)
	local festivals = app.db.Festivals.festivals
	local festival = festivals[festival_id]

	if not festival then
		logger:warn("No festival with id", { id = festival_id })
		return
	end

	local start_time = M.get_start_time(festival_id)
	return start_time + festival.duration
end


--- Return current festivals
-- @function eva.festivals.get_current
-- @treturn table array of current festivals
function M.get_current()
	return app[const.EVA.FESTIVALS].current
end


--- Return completed festivals
-- @function eva.festivals.get_completed
-- @treturn table array of completed festivals
function M.get_completed()
	return luax.table.list(app[const.EVA.FESTIVALS].completed)
end


--- Start festival without check any condition
-- @function eva.festivals.debug_start_festival
-- @tparam string festival_id Festival id from Festivals json
function M.debug_start_festival(festival_id)
	start_festival(festival_id)
end

--- End festival without check any condition
-- @function eva.festivals.debug_end_festival
-- @tparam string festival_id Festival id from Festivals json
function M.debug_end_festival(festival_id)
	end_festival(festival_id)
end


--- Set game festivals settings.
-- See festivals_settings_example.lua
-- @function eva.festivals.set_settings
function M.set_settings(festivals_settings)
	app.festivals_settings = festivals_settings
end


function M.on_eva_init()
	app.festivals_settings = {}
	app.festivals_cache = {}
	app[const.EVA.FESTIVALS] = proto.get(const.EVA.FESTIVALS)
	saver.add_save_part(const.EVA.FESTIVALS, app[const.EVA.FESTIVALS])
end


function M.on_eva_second()
	local festivals = app.db.Festivals.festivals
	for festival_id in pairs(festivals) do
		if is_need_to_start(festival_id) then
			start_festival(festival_id)
		end

		local festival_slot = get_timer_slot(festival_id)
		if timers.is_end(festival_slot) then
			end_festival(festival_id)
		end
	end
end



return M
