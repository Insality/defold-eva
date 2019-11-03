local eva = require("eva.eva")

return function()
	describe("Eva window", function()
		before(function()
			eva.init("/resources/tests/eva_tests.json")
		end)

		it("Window test", function()
		end)
	end)
end