local eva = require("eva.eva")

return function()
	describe("Eva Saver", function()
		before(function()
			eva.init("/resources/tests/eva_tests.json")
		end)

		it("Saver test", function()
		end)
	end)
end