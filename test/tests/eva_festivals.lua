local mock_time = require("deftest.mock.time")
local mock = require("deftest.mock.mock")
local time_string = require("eva.libs.time_string")
local const = require("eva.const")
local eva = require("eva.eva")
local luax = require("eva.luax")

local function set_time(iso_time)
	local time = time_string.parse_ISO(iso_time)
	mock_time.set(time)
	eva.update(1)
	return time
end

local mock_cb = {
	callback = function(event, params)
	end
}

return function()
	describe("Eva Festivals", function()
		before(function()
			eva.init("/resources/tests/eva_tests.json")

			local eva_events = {
				event = function(event, params)
					mock_cb.callback(event, params)
				end
			}
			mock.mock(mock_cb)
			eva.events.add_event_system(eva_events)

			mock_time.mock()
		end)

		after(function()
			mock_time.unmock()
			mock.unmock(mock_cb)
		end)

		it("It should return correct start time (repeat festivals too)", function()
			-- event_festivals start at 2019-10-20, end after 14d
			-- weekly_festival start at 2019-10-07, end after 24h, every 7D
			local current_time = set_time("2019-10-05Z")
			local to_start = eva.festivals.get_start_time("event_festival")
			assert((to_start - current_time) == 60 * 60 * 24 * 15)

			local to_start_weekly = eva.festivals.get_start_time("weekly_festival")
			assert((to_start_weekly - current_time) == 60 * 60 * 24 * 2)

			current_time = set_time("2019-10-07T12:00:00Z")
			to_start_weekly = eva.festivals.get_start_time("weekly_festival")
			assert((to_start_weekly - current_time) == -60 * 60 * 12)

			current_time = set_time("2019-10-09Z")
			to_start_weekly = eva.festivals.get_start_time("weekly_festival")
			assert((to_start_weekly - current_time) == 60 * 60 * 24 * 5)

			current_time = set_time("2019-10-25Z")
			to_start = eva.festivals.get_start_time("event_festival")
			assert((to_start - current_time) == 60 * 60 * 24 * -5)

			to_start_weekly = eva.festivals.get_start_time("weekly_festival")
			assert((to_start_weekly - current_time) == 60 * 60 * 24 * 3)
		end)

		it("It should return correct end time", function()
			local current_time = set_time("2019-10-05Z")
			local to_end = eva.festivals.get_end_time("event_festival")
			assert((to_end - current_time) == 60 * 60 * 24 * (15 + 14))

			local to_end_weekly = eva.festivals.get_end_time("weekly_festival")
			assert((to_end_weekly - current_time) == ((60 * 60 * 24 * 2) + (60 * 60 * 24)))

			current_time = set_time("2019-10-07T10:00:00Z")
			to_end_weekly = eva.festivals.get_end_time("weekly_festival")
			assert((to_end_weekly - current_time) == 60 * 60 * 14)

			current_time = set_time("2019-10-22Z")
			to_end = eva.festivals.get_end_time("event_festival")
			assert((to_end - current_time) == 60 * 60 * 24 * 12)

			to_end_weekly = eva.festivals.get_end_time("weekly_festival")
			assert((to_end_weekly - current_time) == 60 * 60 * 24 * (6+1))

			current_time = set_time("2019-11-10Z")
			to_end = eva.festivals.get_end_time("event_festival")
			assert((to_end - current_time) == 60 * 60 * 24 * -7)
		end)

		it("It should correct start and end festival", function()
			set_time("2019-10-05Z")
			assert(not eva.festivals.is_active("event_festival"))
			assert(not eva.festivals.is_active("weekly_festival"))
			assert(mock_cb.callback.calls == 0)

			local completed = eva.festivals.get_completed()
			assert(not luax.table.contains(completed, "weekly_festival"))
			assert(not luax.table.contains(completed, "event_festival"))
			local current = eva.festivals.get_current()
			assert(not luax.table.contains(current, "weekly_festival"))
			assert(not luax.table.contains(current, "event_festival"))


			set_time("2019-10-07T10:00:00Z")
			assert(not eva.festivals.is_active("event_festival"))
			assert(eva.festivals.is_active("weekly_festival"))
			assert(mock_cb.callback.calls == 1)
			assert(mock_cb.callback.params[1] == const.EVENT.FESTIVAL_START)
			assert(mock_cb.callback.params[2].id == "weekly_festival")

			set_time("2019-10-21T8:00:00Z")
			assert(eva.festivals.is_active("event_festival"))
			assert(not eva.festivals.is_active("weekly_festival"))
			assert(eva.festivals.is_completed("weekly_festival"))

			set_time("2019-11-10T8:00:00Z")
			assert(not eva.festivals.is_active("event_festival"))
			assert(eva.festivals.is_completed("event_festival"))
			assert(not eva.festivals.is_active("weekly_festival"))
			assert(mock_cb.callback.calls == 4)
			assert(mock_cb.callback.params[1] == const.EVENT.FESTIVAL_END)
			assert(mock_cb.callback.params[2].id == "event_festival")

			set_time("2019-11-11T8:00:00Z")
			assert(not eva.festivals.is_active("event_festival"))
			assert(eva.festivals.is_completed("event_festival"))
			assert(eva.festivals.is_active("weekly_festival"))
			assert(eva.festivals.is_completed("weekly_festival"))
			assert(mock_cb.callback.calls == 5)
			assert(mock_cb.callback.params[1] == const.EVENT.FESTIVAL_START)
			assert(mock_cb.callback.params[2].id == "weekly_festival")

			completed = eva.festivals.get_completed()
			assert(luax.table.contains(completed, "weekly_festival"))
			assert(luax.table.contains(completed, "event_festival"))
			current = eva.festivals.get_current()
			assert(luax.table.contains(current, "weekly_festival"))
			assert(not luax.table.contains(current, "event_festival"))
		end)

		it("Should not start before the end", function()
			set_time("2019-10-19Z")
			assert(not eva.festivals.is_active("event_festival"))
			set_time("2019-11-01Z")
			assert(not eva.festivals.is_active("event_festival"))
			assert(mock_cb.callback.calls == 0)
		end)

		it("Should not enable, if festival end until player is offline", function()
			set_time("2019-10-19Z")
			assert(not eva.festivals.is_active("event_festival"))
			set_time("2019-11-10Z")
			assert(not eva.festivals.is_active("event_festival"))
			assert(mock_cb.callback.calls == 0)
		end)
	end)
end
