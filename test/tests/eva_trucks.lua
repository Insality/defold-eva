local eva = require("eva.eva")
local const = require("eva.const")
local luax = require("eva.luax")
local mock = require("deftest.mock.mock")

local ARRIVE = const.EVENT.TRUCK_ARRIVE
local LEAVE = const.EVENT.TRUCK_LEAVE

local events = {
	[ARRIVE] = function() end,
	[LEAVE] = function() end
}


return function()
	describe("Eva Trucks", function()
		before(function()
			eva.init("/resources/tests/eva_tests.json")
			mock.mock(events)
			eva.events.subscribe_map(events)
		end)

		after(function()
			mock.unmock(events)
		end)

		it("Test1", function()
		end)
	end)
end