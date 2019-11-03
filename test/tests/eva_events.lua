local broadcast = require("eva.libs.broadcast")
local eva = require("eva.eva")

return function()
	describe("Eva events", function()
		local message_arrived = false

		before(function()
			-- Subscribe on event
			eva.init("/resources/tests/eva_tests.json")

			broadcast.register("Custom_event", function()
				message_arrived = true
			end)
		end)
		after(function()
			-- Unsubscribe from event
		end)

		it("Event test", function()
			eva.events.event("Custom_event", {arg1 = 1, arg2 = 2})
		end)
	end)
end