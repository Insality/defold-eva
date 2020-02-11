local smart = require("eva.libs.smart.smart")
local value = require("eva.libs.smart.value")

return function()
	describe("Smart value test", function()
		it("Should have set and get", function()
			local v = smart.new()
			v:set(3)
			assert(v:get(), 3)

			v:set(5)
			assert(v:get(), 5)
		end)


		it("Can have min and max range", function()
			local v1 = smart.new({min = 2})
			local v2 = smart.new({min = 4, max = 10})
			local v3 = smart.new({max = 15})

			assert(v1:get() == 2)
			v1:set(1)
			assert(v1:get() == 2)
			v1:set(3)
			assert(v1:get() == 3)

			assert(v2:get() == 4)
			v2:set(12)
			assert(v2:get() == 10)
			v2:set(6)
			assert(v2:get() == 6)

			v3:set(-5)
			assert(v3:get() == -5)
			v3:set(20)
			assert(v3:get() == 15)
		end)


		it("Should have add method", function()
			local v = smart.new()
			v:add(4)
			assert(v:get() == 4)
			v:add(-2)
			assert(v:get() == 2)
		end)


		it("Should have default value", function()
			local v = smart.new()
			assert(v:get() == 0)
			v = smart.new({default = 3})
			assert(v:get() == 3)
		end)


		it("Should be useful for gui. Visual and real values", function()
			local coins = smart.new({default = 100})
			assert(coins:get() == 100)

			coins:add(50, "simple", true) -- add 50 later
			assert(coins:get() == 150)
			assert(coins:get_visual() == 100)

			coins:add_visual(25)
			assert(coins:get() == 150)
			assert(coins:get_visual() == 125)
			coins:sync_visual()
			assert(coins:get_visual() == coins:get())
		end)
	end)
end