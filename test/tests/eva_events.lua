local broadcast = require("eva.libs.broadcast")
local eva = require("eva.eva")

return function()
	describe("Eva events", function()
		local message_arrived = false

		before(function()
			-- Subscribe on event
			eva.on_game_start("/resources/eva_settings_tests.json")

			broadcast.register("Custom_event", function()
				message_arrived = true
			end)
		end)
		after(function()
			-- Unsubscribe from event
		end)

		it("Test1", function()
			eva.events.event("Custom_event", {arg1 = 1, arg2 = 2})
		end)

		-- it("Test2", function()

		-- end)
	end)
end