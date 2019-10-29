local const = require("eva.const")
local eva = require("eva.eva")

return function()
	describe("Eva push", function()
		before(function()
			eva.init("/resources/tests/eva_tests.json")
		end)

		it("Should correct schedule push", function()
		end)

		it("Should not to be scheduled at snooze time", function()
		end)

		it("Should have max push per day", function()
		end)

		it("Should have max push per category and day", function()
		end)

		it("Should remove soon pushes in-game", function()
		end)

		it("Should mark today early pushes as triggered", function()
		end)

		it("Should correct unschedule all pushes", function()
		end)

		it("Should correct unschedule category pushes", function()
		end)

		it("Should have callback on run game from push", function()
		end)
	end)
end