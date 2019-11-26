local eva = require("eva.eva")
local mock_time = require("deftest.mock.time")
local const = require("eva.const")
local mock = require("deftest.mock.mock")

local ARRIVE = const.EVENT.TRUCK_ARRIVE
local LEAVE = const.EVENT.TRUCK_LEAVE

local events = {
	[ARRIVE] = function() end,
	[LEAVE] = function() end
}

local function set_time(time)
	mock_time.set(time)
	eva.update(1)
	return time
end

return function()
	describe("Eva Trucks", function()
		before(function()
			eva.init("/resources/tests/eva_tests.json")
			mock.mock(events)
			eva.events.subscribe_map(events)
			mock_time.mock()
			set_time(0)
		end)

		after(function()
			mock.unmock(events)
			mock_time.unmock()
		end)

		it("Should be not enabled at start", function()
			assert(not eva.trucks.is_enabled("foodtruck"))
			assert(not eva.trucks.is_enabled("merchant"))
		end)

		it("Should be enable correctly", function()
			eva.trucks.set_enabled("foodtruck", true)
			assert(eva.trucks.is_enabled("foodtruck"))
			assert(not eva.trucks.is_enabled("merchant"))
		end)

		it("Should correct arrive/leave state", function()
			eva.trucks.set_enabled("foodtruck", true)
			assert(not eva.trucks.is_can_arrive("foodtruck"))
			assert(not eva.trucks.is_can_arrive("merchant"))

			assert(not eva.trucks.is_can_leave("foodtruck"))
			assert(not eva.trucks.is_can_leave("merchant"))
		end)

		it("Should work autoarrive truck", function()
			eva.trucks.set_enabled("foodtruck", true)
			assert(not eva.trucks.is_can_arrive("foodtruck"))
			assert(not eva.trucks.is_can_leave("foodtruck"))
			assert(eva.trucks.is_arrived("foodtruck"))
			assert(events[ARRIVE].calls == 1)
			assert(events[LEAVE].calls == 0)
		end)

		it("Should not autoarrive, if disabled", function()
			eva.trucks.set_enabled("merchant", true)
			assert(eva.trucks.is_can_arrive("merchant"))
			assert(not eva.trucks.is_arrived("merchant"))
			assert(events[ARRIVE].calls == 0)

			eva.trucks.arrive("merchant")
			assert(events[ARRIVE].calls == 1)
			assert(eva.trucks.is_arrived("merchant"))
			assert(not eva.trucks.is_can_arrive("merchant"))
		end)

		it("Should correct return time to arrive/leave", function()
			assert(eva.trucks.get_time_to_arrive("foodtruck") == 0)
			eva.trucks.set_enabled("foodtruck", true)
			assert(eva.trucks.get_time_to_leave("foodtruck") == 50)
			set_time(50)
			assert(events[ARRIVE].calls == 1)
			assert(events[LEAVE].calls == 1)
			assert(eva.trucks.get_time_to_arrive("foodtruck") == 25)
			set_time(55)
			assert(eva.trucks.get_time_to_arrive("foodtruck") == 20)
		end)

		it("Should correct work custom settings", function()
			local can_arrive = false
			local can_leave = false
			local mock_cb = {
				arrive = function() end,
				leave = function() end
			}
			mock.mock(mock_cb)
			local settings = {
				get_truck_lifetime = function() return 10 end,
				is_can_arrive = function() return can_arrive end,
				on_truck_arrive = mock_cb.arrive,
				get_truck_cooldown = function() return 5 end,
				is_can_leave = function() return can_leave end,
				on_truck_leave = mock_cb.leave
			}
			eva.trucks.set_settings(settings)

			eva.trucks.set_enabled("foodtruck", true)
			assert(eva.trucks.get_time_to_leave("foodtruck") == 0)
			assert(not eva.trucks.is_arrived("foodtruck"))
			assert(not eva.trucks.is_can_arrive("foodtruck"))

			set_time(1)
			assert(eva.trucks.get_time_to_arrive("foodtruck") == 0)
			assert(eva.trucks.get_time_to_leave("foodtruck") == 0)
			assert(not eva.trucks.is_arrived("foodtruck"))
			assert(not eva.trucks.is_can_arrive("foodtruck"))

			can_arrive = true
			assert(eva.trucks.is_can_arrive("foodtruck"))
			set_time(2)
			assert(eva.trucks.get_time_to_arrive("foodtruck") == 0)
			assert(eva.trucks.get_time_to_leave("foodtruck") == 10)
			assert(eva.trucks.is_arrived("foodtruck"))
			assert(not eva.trucks.is_can_arrive("foodtruck"))
			assert(mock_cb.arrive.calls == 1)

			set_time(12)
			assert(mock_cb.leave.calls == 0)
			assert(eva.trucks.get_time_to_leave("foodtruck") == 0)
			assert(eva.trucks.get_time_to_arrive("foodtruck") == 0)

			can_leave = true
			set_time(13)
			assert(eva.trucks.get_time_to_leave("foodtruck") == 0)
			assert(eva.trucks.get_time_to_arrive("foodtruck") == 5)
			assert(mock_cb.leave.calls == 1)

			set_time(18)
			assert(eva.trucks.get_time_to_arrive("foodtruck") == 0)
			assert(eva.trucks.get_time_to_leave("foodtruck") == 10)

			assert(mock_cb.arrive.calls == 2)
			assert(mock_cb.leave.calls == 1)
		end)

		it("Should correct work autoleave", function()
			eva.trucks.set_enabled("foodtruck", true)
			set_time(45)
			assert(events[ARRIVE].calls == 1)
			assert(events[LEAVE].calls == 0)
			set_time(52)
			assert(events[LEAVE].calls == 1)
			set_time(90)
			assert(events[ARRIVE].calls == 2)
		end)

		it("Should not leave, if autoleave is disabled", function()
			eva.trucks.set_enabled("merchant", true)
			assert(not eva.trucks.is_arrived("merchant"))
			set_time(100)
			assert(not eva.trucks.is_arrived("merchant"))
			eva.trucks.arrive("merchant")
			assert(eva.trucks.get_time_to_leave("merchant") == 100)
			assert(not eva.trucks.is_can_leave("merchant"))
			set_time(200)
			assert(eva.trucks.get_time_to_leave("merchant") == 0)
			assert(eva.trucks.is_can_leave("merchant"))
			set_time(300)
			assert(eva.trucks.is_arrived("merchant"))
			assert(eva.trucks.get_time_to_leave("merchant") == 0)
			assert(eva.trucks.is_can_leave("merchant"))

			eva.trucks.leave("merchant")
			assert(not eva.trucks.is_arrived("merchant"))
			assert(not eva.trucks.is_can_leave("merchant"))
			assert(eva.trucks.get_time_to_arrive("merchant") == 50)
			assert(not eva.trucks.is_can_arrive("merchant"))
		end)

		it("Should arrive at game start with big time skip", function()
			eva.trucks.set_enabled("foodtruck", true)
			eva.trucks.leave("foodtruck")
			assert(events[ARRIVE].calls == 1)
			set_time(1000)
			assert(eva.trucks.get_time_to_leave("foodtruck") == 50)

			set_time(2000)
			assert(events[LEAVE].calls == 2)
			assert(not eva.trucks.is_arrived("foodtruck"))
			assert(eva.trucks.get_time_to_arrive("foodtruck") == 60)
		end)

		it("Should arrive at set enabled", function()
			eva.trucks.set_enabled("foodtruck", true)
			assert(events[ARRIVE].calls == 1)
		end)

		it("Should leave at set disabled", function()
			eva.trucks.set_enabled("foodtruck", true)
			assert(eva.trucks.is_arrived("foodtruck"))
			assert(events[ARRIVE].calls == 1)
			assert(events[LEAVE].calls == 0)

			eva.trucks.set_enabled("foodtruck", false)
			assert(events[ARRIVE].calls == 1)
			assert(events[LEAVE].calls == 1)
			assert(not eva.trucks.is_enabled("foodtruck"))
			assert(not eva.trucks.is_arrived("foodtruck"))
		end)
	end)
end