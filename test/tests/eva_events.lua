local eva = require("eva.eva")

return function()
	describe("Eva events", function()
		local message_arrived = false

		before(function()
			-- Subscribe on event
			eva.init("/resources/tests/eva_tests.json")
		end)
		after(function()
			-- Unsubscribe from event
		end)

		it("Event test", function()
			eva.events.event("Custom_event", {arg1 = 1, arg2 = 2})
		end)
	end)
end
