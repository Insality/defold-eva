local eva = require("eva.eva")

return function()
	describe("Eva migrations", function()
		before(function()
			eva.init("/resources/tests/eva_tests.json")
		end)

		it("Migrations test", function()
		end)
	end)
end