local eva = require("eva.eva")

return function()
	describe("Eva invoices", function()
		before(function()
			eva.init("/resources/tests/eva_tests.json")
		end)

		it("Should correct add invoices", function()
		end)

		it("Should correct add delayed invoices", function()
		end)

		it("Should correct get invoices list", function()
		end)

		it("Should correct get invoices list by category", function()
		end)

		it("Should correct consume invoices", function()
		end)

		it("Should have limited time", function()
		end)
	end)
end