local eva = require("eva.eva")

return function()
	describe("Eva token", function()
		before(function()
			eva.init("/resources/tests/eva_tests.json")
		end)

		it("Token test", function()
		end)
	end)
end