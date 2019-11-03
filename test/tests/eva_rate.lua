local eva = require("eva.eva")

return function()
	describe("Eva rate", function()
		before(function()
			eva.init("/resources/tests/eva_tests.json")
		end)

		it("Rate test", function()
		end)
	end)
end