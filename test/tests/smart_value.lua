local smart = require("libs.smart.smart")

return function()
	describe("Smart value test", function()
		it("Should have set and get", function()
			local value = smart.new()
			value:set(3)
			assert(value:get(), 3)
			value:set(5)
			assert(value:get(), 5)
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

		it("Can have restore timer", function()
			local v = smart.new({
				restore = {
					timer = 5
				}
			})

			assert(v:get() == 0)
			v:update(5)
			assert(v:get() == 1)
			v:update(50)
			assert(v:get() == 10)
			v:update(0)
			assert(v:get() == 10)
			assert(v:get_seconds_to_restore(10) == 0)
			assert(v:get_seconds_to_restore(4) == 1)
			assert(v:get_seconds_to_restore(3) == 2)
			assert(v:get_seconds_to_restore(0) == 5)
			v:update(4)
			assert(v:get() == 10)
			v:update(5)
			assert(v:get() == 11)
		end)

		it("Can have advanced restore params", function()
			local v = smart.new({
				restore = {
					timer = 5,
					max = 5,
					value = 2,
					last_time = 0
				},
				max = 15
			})
			-- cur time = 0
			assert(v:get() == 0)
			v:update(5)
			assert(v:get() == 2)
			v:update(19)
			-- elapsed 14 secs, need to add 2 * 2
			assert(v:get() == 6)
			v:update(20)
			assert(v:get() == 8)
			v:update(100)
			assert(v:get() == 13)
			-- elapsed 100 secs. want to add 16 * 2, but max restore 5, max value 15
			v:update(200)
			assert(v:get() == 15)

			-- time return back (hackers?)
			v:update(0)
			assert(v:get() == 15)
			assert(v:get_seconds_to_restore(0) == 5)
			v:add(-5)
			v:update(5)
			assert(v:get() == 12)
			v:set(0)
			v:update(55) -- elapsed 50 secods, want to add 10 * 2, but max restore 5
			assert(v:get() == 5)
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