local eva = require("eva.eva")

return function()
	describe("Eva storage", function()
		before(function()
			eva.init("/resources/tests/eva_tests.json")
		end)

		it("Storage test", function()
		end)
	end)
end