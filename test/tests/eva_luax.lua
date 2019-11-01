return function()
	local luax = require("eva.luax")

	describe("Eva luax library", function()
		it("Contains", function()
			assert(luax.table.contains({"a", "b"}, "b"))
			assert(not luax.table.contains({"a", "b"}, "c"))
		end)

		it("Sign", function()
			assert(luax.math.sign(-2) == -1)
			assert(luax.math.sign(2) == 1)
			assert(luax.math.sign(0) == 0)
		end)
	end)
end