local const = require("eva.const")
local app = require("eva.app")
local eva = require("eva.eva")
local mock = require("deftest.mock.mock")
local mock_time = require("deftest.mock.time")
local time_string = require("eva.libs.time_string")

local SCHEDULE = const.EVENT.PUSH_SCHEDULED
local CANCEL = const.EVENT.PUSH_CANCEL

local events = {
	[SCHEDULE] = function(event, params)
	end,
	[CANCEL] = function(event, params)
	end,
}

local function set_time(time)
	mock_time.set(time)
	eva.update(1)
	return time
end

local TEST_TIME = "2019-10-10T20:00:00Z"

return function()
	describe("Eva push", function()
		before(function()
			eva.init("/resources/tests/eva_tests.json")

			local eva_events = {
				event = function(event, params)
					if events[event] then
						events[event](event, params)
					end
				end
			}
			eva.events.add_event_system(eva_events)
			mock.mock(events)
			mock_time.mock()
			local time = time_string.parse_ISO(TEST_TIME)
			set_time(time)
		end)

		after(function()
			mock.unmock(events)
			mock_time.unmock()
		end)

		it("Should correct schedule push", function()
			eva.push.schedule(60 * 60 * 24, "Game", "Text", "return")
			assert(events[SCHEDULE].calls == 1)
			eva.push.schedule(60 * 60 * 24 * 2, "Game", "Text", "return")
			assert(events[SCHEDULE].calls == 2)
		end)

		it("Should correct schedule push list", function()
			local list = {
				{
					after = 4800,
					title = "Game",
					text = "text",
				},
				{
					after = 4800,
					title = "Game",
					text = "text",
					payload = {a = 2},
					category = "from_list"
				}
			}
			eva.push.schedule_list(list)
			assert(events[SCHEDULE].calls == 2)
		end)

		it("Should not to be scheduled at snooze time", function()
			local push = eva.push.schedule(60 * 60 * 2, "", "", "")
			assert(push.time == time_string.parse_ISO("2019-10-11T09:00:00Z"))
			local push2 = eva.push.schedule(60 * 60, "", "", "")
			assert(push2.time == time_string.parse_ISO("2019-10-11T09:00:00Z"))
			local push3 = eva.push.schedule(60 * 60 + 60 * 60 * 24, "", "", "")
			assert(push3.time == time_string.parse_ISO("2019-10-12T09:00:00Z"))
		end)

		it("Should have max push per day", function()
			for i = 1, 10 do
				eva.push.schedule(60 * 60 * 2, "", "", "")
			end
			assert(events[SCHEDULE].calls == 6)
			for i = 1, 10 do
				eva.push.schedule(60 * 60 * 26, "", "", "")
			end
			assert(events[SCHEDULE].calls == 12)
		end)

		it("Should have max push per category and day", function()
			for i = 1, 10 do
				eva.push.schedule(60 * 60 * 2, "", "", "return")
			end
			assert(events[SCHEDULE].calls == 2)
			for i = 1, 10 do
				eva.push.schedule(60 * 60 * 26, "", "", "return")
			end
			assert(events[SCHEDULE].calls == 4)
		end)

		it("Should not schedule soon pushes", function()
			eva.push.schedule(60 * 30, "", "")
			assert(events[SCHEDULE].calls == 0)
			eva.push.schedule(60 * 31, "", "")
			assert(events[SCHEDULE].calls == 1)
		end)

		it("Should remove soon pushes in-game", function()
			local push = eva.push.schedule(60 * 31, "", "")
			assert(events[SCHEDULE].calls == 1)
			mock_time.elapse(60 * 20)
			eva.update(1)

			assert(events[CANCEL].calls == 1)
			assert(events[CANCEL].params[2].id == push.id)
		end)

		it("Should mark today early pushes as triggered", function()
			local push = eva.push.schedule(60 * 31, "", "")

			mock_time.elapse(60 * 40)
			eva.push.clear_old_pushes()
			eva.update(1)

			assert(events[CANCEL].calls == 0)
			assert(push.is_triggered == true)
		end)

		it("Should correct unschedule all pushes", function()
			for i = 1, 10 do
				eva.push.schedule(60 * 60 * 2, "", "", "")
			end
			for i = 1, 10 do
				eva.push.schedule(60 * 60 * 26, "", "", "")
			end
			assert(#app[const.EVA.PUSH].pushes == 12)

			eva.push.unschedule_all()
			assert(#app[const.EVA.PUSH].pushes == 0)
			assert(events[CANCEL].calls == 12)
		end)

		it("Should correct unschedule category pushes", function()
			for i = 1, 10 do
				eva.push.schedule(60 * 60 * 2, "", "", "return")
			end
			for i = 1, 10 do
				eva.push.schedule(60 * 60 * 26, "", "", "craft")
			end

			assert(#app[const.EVA.PUSH].pushes == 4)
			eva.push.unschedule_all("return")
			assert(#app[const.EVA.PUSH].pushes == 2)
			assert(events[CANCEL].calls == 2)
			eva.push.unschedule_all("craft")
			assert(#app[const.EVA.PUSH].pushes == 0)
			assert(events[CANCEL].calls == 4)
		end)

		it("Should have callback on run game from push", function()
		end)
	end)
end