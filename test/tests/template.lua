local eva = require("eva.eva")

return function()
	describe("Section", function()
		before(function()
			eva.init("/resources/tests/eva_tests.json")
		end)

		it("Test1", function()
		end)


		it("Test2", function()
		end)
	end)
end