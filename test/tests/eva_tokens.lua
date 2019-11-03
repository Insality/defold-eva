local eva = require("eva.eva")

return function()
	describe("Eva tokens", function()
		before(function()
			eva.init("/resources/tests/eva_tests.json")
		end)

		it("Tokens test", function()
		end)
	end)
end