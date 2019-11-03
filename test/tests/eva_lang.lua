local eva = require("eva.eva")

return function()
	describe("Eva lang", function()
		before(function()
			eva.init("/resources/tests/eva_tests.json")
		end)

		it("Lang test", function()
		end)
	end)
end