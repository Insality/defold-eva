local mock_time = require("deftest.mock.time")
local mock = require("deftest.mock.mock")
local const = require("eva.const")
local eva = require("eva.eva")

local function set_time(time)
	mock_time.set(time)
	eva.update(1)
end

local CHANGE = const.EVENT.TOKEN_CHANGE

local events = {
	[CHANGE] = function() end,
}

return function()
	describe("Eva token", function()
		before(function()
			eva.init("/resources/tests/eva_tests.json")

			mock_time.mock()
			mock_time.set(0)

			local eva_events = {
				event = function(event, params)
					if events[event] then
						events[event](event, params)
					end
				end
			}
			eva.events.add_event_system(eva_events)
			mock.mock(events)

		end)

		after(function()
			mock_time.unmock()
			mock.unmock(events)
		end)

		it("Should have basic api get/set/add/pay", function()
			assert(eva.token.get("money") == 0)

			local delta = eva.token.add("money", 10)
			assert(delta == 10)
			assert(eva.token.get("money") == 10)

			delta = eva.token.set("money", 20)
			assert(delta == 10)
			assert(eva.token.get("money") == 20)

			delta = eva.token.pay("money", 5)
			assert(delta == -5)
			assert(eva.token.get("money") == 15)
		end)

		it("Should correct work check functions", function()
			eva.token.add("money", 100)
			assert(not eva.token.is_empty("money"))
			assert(eva.token.is_empty("exp"))

			assert(eva.token.is_enough("money", 50))
			assert(eva.token.is_enough("money", 100))
			assert(not eva.token.is_enough("money", 150))

			assert(not eva.token.is_max("money"))

			local delta = eva.token.add("level", 90)
			-- Default: 1, max: 80
			assert(delta == 79)
			assert(eva.token.is_max("level"))
		end)

		it("Should correct work with infinity values", function()
			eva.token.add("money", 100)
			eva.token.add_infinity_time("money", 10)

			eva.token.pay("money", 50)
			assert(eva.token.get("money") == 100)

			eva.token.pay("money", 50)
			assert(eva.token.get("money") == 100)

			eva.token.set("money", 50)
			assert(eva.token.get("money") == 50)

			assert(eva.token.is_infinity("money"))
			assert(eva.token.get_infinity_seconds("money") == 10)
			assert(not eva.token.is_infinity("level"))
			assert(eva.token.get_infinity_seconds("level") == 0)

			assert(eva.token.is_enough("money", 50))
			assert(eva.token.is_enough("money", 100))
			assert(eva.token.is_enough("money", 150))
		end)

		it("Should correct work visual api", function()
			eva.token.add("money", 1000)
			assert(eva.token.get("money") == 1000)
			assert(eva.token.get_visual("money") == 1000)

			eva.token.add_visual("money", -100)
			assert(eva.token.get_visual("money") == 900)

			eva.token.sync_visual("money")
			assert(eva.token.get_visual("money") == 1000)

			eva.token.add("money", 100, "test", true)
			assert(eva.token.get("money") == 1100)
			assert(eva.token.get_visual("money") == 1000)

			eva.token.add_visual("money", 50)
			assert(eva.token.get_visual("money") == 1050)

			local delta = eva.token.sync_visual("money")
			assert(eva.token.get_visual("money") == 1100)
			assert(delta == 50)
		end)

		it("Should correct work restoring", function()
			set_time(60)
			assert(eva.token.get("energy") == 1)

			set_time(120)
			assert(eva.token.get("energy") == 2)

			-- max 20 restore
			set_time(60 * 40)
			assert(eva.token.get("energy") == 22)
		end)

		it("Should throw event on token change", function()
			assert(events[CHANGE].calls == 0)
			assert(eva.token.get("energy" == 0))

			set_time(60)
			assert(eva.token.get("energy" == 1))
			assert(events[CHANGE].calls == 1)

			eva.token.add("money", 500)
			assert(events[CHANGE].calls == 2)
		end)
	end)
end