local eva = require("eva.eva")

return function()
	describe("Eva callbacks", function()
		before(function()
			eva.init("/resources/tests/eva_tests.json")
		end)

		it("Callback test", function()
		end)
	end)
end