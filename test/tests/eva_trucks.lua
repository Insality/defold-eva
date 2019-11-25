local eva = require("eva.eva")
local mock_time = require("deftest.mock.time")
local const = require("eva.const")
local luax = require("eva.luax")
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
			assert(eva.trucks.is_can_arrive("foodtruck"))
			assert(not eva.trucks.is_can_arrive("merchant"))

			assert(not eva.trucks.is_can_leave("foodtruck"))
			assert(not eva.trucks.is_can_leave("merchant"))
		end)

		it("Should work autoarrive truck", function()
			eva.trucks.set_enabled("foodtruck", true)
			set_time(1)
			assert(not eva.trucks.is_can_arrive("foodtruck"))
			assert(not eva.trucks.is_can_leave("foodtruck"))
			assert(eva.trucks.is_arrived("foodtruck"))
			assert(events[ARRIVE].calls == 1)
			assert(events[LEAVE].calls == 0)
		end)

		it("Should not autoarrive, if disabled", function()
			eva.trucks.set_enabled("merchant", true)
			assert(eva.trucks.is_can_arrive("merchant"))
			set_time(1)
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

			-- Do we need enabled on next update or instanly?
			set_time(1)
			print(eva.trucks.get_time_to_leave("foodtruck"))
			assert(eva.trucks.get_time_to_leave("foodtruck") == 50)
			set_time(51)
			assert(events[ARRIVE].calls == 1)
			assert(events[LEAVE].calls == 1)
			assert(eva.trucks.get_time_to_arrive("foodtruck") == 25)
			set_time(56)
			assert(eva.trucks.get_time_to_arrive("foodtruck") == 20)
		end)

		it("Should correct work custom settings", function()

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

		it("Should not leave, if not autoleave is enabled", function()

		end)

		it("Should arrive at game start with big time skip", function()

		end)
	end)
end