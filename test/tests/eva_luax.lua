local luax = require("eva.luax")

return function()
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

		it("Step", function()
			assert(luax.math.step(1, 10, 1) == 2)
			assert(luax.math.step(1, 10, 20) == 10)
			assert(luax.math.step(5, 1, 1) == 4)
			assert(luax.math.step(5, 1, 20) == 1)
			assert(luax.math.step(5, 0, 10) == 0)
			assert(luax.math.step(5, 5, 10) == 5)
			assert(luax.math.step(5, -2, 10) == -2)
		end)

		it("Lerp", function()
			assert(luax.math.lerp(0, 100, 0.5) == 50)
			assert(luax.math.lerp(0, 100, 0) == 0)
			assert(luax.math.lerp(0, 100, 1) == 100)
		end)

		it("Clamp", function()
			assert(luax.math.clamp(0, -100, 100) == 0)
			assert(luax.math.clamp(200, -100, 100) == 100)
			assert(luax.math.clamp(-200, -100, 100) == -100)
			assert(luax.math.clamp(-100, -100, 100) == -100)
		end)

		it("Round", function()
			assert(luax.math.round(2.51, 0) == 3)
			assert(luax.math.round(2.51, 1) == 2.5)
			assert(luax.math.round(2.51, 2) == 2.51)
			assert(luax.math.round(2.51, 3) == 2.51)
			assert(luax.math.round(2.55, 1) == 2.6)
		end)

		it("Empty", function()
			assert(luax.table.is_empty({}))
			assert(luax.table.is_empty())
			assert(luax.table.is_empty(false))
			assert(not luax.table.is_empty({1}))
		end)

		it("Table add", function()
			local a = {1, 2, 3}
			local b = {6, 7}
			luax.table.add(a, b)
			assert(#a == 5)
			assert(luax.table.contains(a, 2))
			assert(luax.table.contains(a, 6))
		end)

		it("List", function()
			local a = {
				a = {key = 1},
				b = {key = 2},
				c = {key = 3}
			}
			local key_list = luax.table.list(a)
			local value_list = luax.table.list(a, "key")
			assert(luax.table.contains(key_list, "a"))
			assert(luax.table.contains(key_list, "b"))
			assert(luax.table.contains(key_list, "c"))
			assert(#key_list == 3)

			assert(luax.table.contains(value_list, 1))
			assert(luax.table.contains(value_list, 2))
			assert(luax.table.contains(value_list, 3))
			assert(#value_list == 3)
		end)

		it("Starts", function()
			assert(luax.string.starts("Test string", "Tes"))
			assert(not luax.string.starts("Test string", "Tess"))
		end)

		it("Ends", function()
			assert(luax.string.ends("Test string", "ing"))
			assert(not luax.string.ends("Test string", "fing"))
		end)
	end)
end