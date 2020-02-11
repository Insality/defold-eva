local mock_time = require("deftest.mock.time")
local mock = require("deftest.mock.mock")
local const = require("eva.const")
local eva = require("eva.eva")

local function set_time(time)
	mock_time.set(time)
	eva.update(1)
end

local CHANGE = const.EVENT.TOKEN_CHANGE
local TEST_CONTAINER = "test_container"

local events = {
	[CHANGE] = function() end,
}

return function()
	describe("Eva token", function()
		before(function()
			eva.init("/resources/tests/eva_tests.json")
			eva.token.create_container(TEST_CONTAINER, "wallet")

			mock_time.mock()
			mock_time.set(0)

			mock.mock(events)
			eva.events.subscribe_map(events)
		end)

		after(function()
			mock_time.unmock()
			mock.unmock(events)
		end)

		it("Should have basic api get/set/add/pay", function()
			assert(eva.token.get(TEST_CONTAINER, "money") == 0)

			local delta = eva.token.add(TEST_CONTAINER, "money", 10)
			assert(delta == 10)
			assert(eva.token.get(TEST_CONTAINER, "money") == 10)

			delta = eva.token.set(TEST_CONTAINER, "money", 20)
			assert(delta == 10)
			assert(eva.token.get(TEST_CONTAINER, "money") == 20)

			delta = eva.token.pay(TEST_CONTAINER, "money", 5)
			assert(delta == -5)
			assert(eva.token.get(TEST_CONTAINER, "money") == 15)
		end)

		it("Should correct work check functions", function()
			eva.token.add(TEST_CONTAINER, "money", 100)
			assert(not eva.token.is_empty(TEST_CONTAINER, "money"))
			assert(eva.token.is_empty(TEST_CONTAINER, "exp"))

			assert(eva.token.is_enough(TEST_CONTAINER, "money", 50))
			assert(eva.token.is_enough(TEST_CONTAINER, "money", 100))
			assert(not eva.token.is_enough(TEST_CONTAINER, "money", 150))

			assert(not eva.token.is_max(TEST_CONTAINER, "money"))

			local delta = eva.token.add(TEST_CONTAINER, "level", 90)
			-- Default: 1, max: 80
			assert(delta == 79)
			assert(eva.token.is_max(TEST_CONTAINER, "level"))
		end)

		it("Should save token values on game save/load", function()
			assert(eva.wallet.get("ruby") == 0)
			eva.wallet.add("ruby", 100)
			assert(eva.wallet.get("ruby") == 100)
			eva.saver.save()
			eva.init("/resources/tests/eva_tests.json")
			print(eva.wallet.get("ruby"))
			assert(eva.wallet.get("ruby") == 100)
		end)

		it("Should correct work with infinity values", function()
			eva.token.add(TEST_CONTAINER, "money", 100)
			eva.token.add_infinity_time(TEST_CONTAINER, "money", 10)

			eva.token.pay(TEST_CONTAINER, "money", 50)
			assert(eva.token.get(TEST_CONTAINER, "money") == 100)

			eva.token.pay(TEST_CONTAINER, "money", 50)
			assert(eva.token.get(TEST_CONTAINER, "money") == 100)

			eva.token.set(TEST_CONTAINER, "money", 50)
			assert(eva.token.get(TEST_CONTAINER, "money") == 50)

			assert(eva.token.is_infinity(TEST_CONTAINER, "money"))
			assert(eva.token.get_infinity_seconds(TEST_CONTAINER, "money") == 10)
			assert(not eva.token.is_infinity(TEST_CONTAINER, "level"))
			assert(eva.token.get_infinity_seconds(TEST_CONTAINER, "level") == 0)

			assert(eva.token.is_enough(TEST_CONTAINER, "money", 50))
			assert(eva.token.is_enough(TEST_CONTAINER, "money", 100))
			assert(eva.token.is_enough(TEST_CONTAINER, "money", 150))
		end)

		it("Should correct work visual api", function()
			eva.token.add(TEST_CONTAINER, "money", 1000)
			assert(eva.token.get(TEST_CONTAINER, "money") == 1000)
			assert(eva.token.get_visual(TEST_CONTAINER, "money") == 1000)

			eva.token.add_visual(TEST_CONTAINER, "money", -100)
			assert(eva.token.get_visual(TEST_CONTAINER, "money") == 900)

			eva.token.sync_visual(TEST_CONTAINER, "money")
			assert(eva.token.get_visual(TEST_CONTAINER, "money") == 1000)

			eva.token.add(TEST_CONTAINER, "money", 100, "test", true)
			assert(eva.token.get(TEST_CONTAINER, "money") == 1100)
			assert(eva.token.get_visual(TEST_CONTAINER, "money") == 1000)

			eva.token.add_visual(TEST_CONTAINER, "money", 50)
			assert(eva.token.get_visual(TEST_CONTAINER, "money") == 1050)

			local delta = eva.token.sync_visual(TEST_CONTAINER, "money")
			assert(eva.token.get_visual(TEST_CONTAINER, "money") == 1100)
			assert(delta == 50)
		end)

		it("Should correct work restoring", function()
			eva.token.set_restore_config(TEST_CONTAINER, "energy", {
				timer = 60,
				value = 1,
				max = 20
			})
			set_time(60)
			assert(eva.wallet.get("energy") == 0)
			assert(eva.token.get(TEST_CONTAINER, "energy") == 1)

			set_time(120)
			assert(eva.token.get(TEST_CONTAINER, "energy") == 2)

			-- max 20 restore
			set_time(60 * 40)
			assert(eva.token.get(TEST_CONTAINER, "energy") == 22)
		end)

		it("Should throw event on token change", function()
			eva.wallet.set_restore_config("energy", {
				timer = 60,
				value = 1,
				max = 20
			})

			assert(events[CHANGE].calls == 0)
			assert(eva.wallet.get("energy") == 0)

			set_time(60)
			assert(eva.wallet.get("energy") == 1)
			assert(events[CHANGE].calls == 1)

			eva.wallet.add("money", 500)
			assert(events[CHANGE].calls == 2)
		end)

		it("Should have restore timer", function()
			eva.wallet.set_restore_config("energy", {
				timer = 5
			})

			assert(eva.wallet.get("energy") == 0)
			set_time(5)
			assert(eva.wallet.get("energy") == 1)
			set_time(50)
			assert(eva.wallet.get("energy") == 10)
			set_time(0)
			assert(eva.wallet.get("energy") == 10)
			assert(eva.wallet.get_seconds_to_restore("energy") == 5)
			set_time(4)
			assert(eva.wallet.get_seconds_to_restore("energy") == 1)
			set_time(3)
			assert(eva.wallet.get_seconds_to_restore("energy") == 2)
			set_time(0)
			assert(eva.wallet.get_seconds_to_restore("energy") == 5)
			set_time(4)
			assert(eva.wallet.get("energy") == 10)
			set_time(5)
			assert(eva.wallet.get("energy") == 11)
		end)


		it("Should have advanced restore params", function()
			eva.wallet.set_restore_config("energy", {
				timer = 5,
				max = 5,
				value = 2
			})

			-- cur time = 0
			assert(eva.wallet.get("energy") == 0)
			set_time(5)
			assert(eva.wallet.get("energy") == 2)
			set_time(19)
			-- elapsed 14 secs, need to add 2 * 2
			assert(eva.wallet.get("energy") == 6)
			set_time(20)
			assert(eva.wallet.get("energy") == 8)
			set_time(100)
			assert(eva.wallet.get("energy") == 13)
			-- elapsed 100 secs. want to add 16 * 2, but max restore 5, max value 15
			set_time(200)
			-- TODO: HACK, while now we can't setup max token value in restore config
			eva.wallet.set("energy", 15)
			assert(eva.wallet.get("energy") == 15)

			-- time return back (hackers?)
			set_time(0)
			assert(eva.wallet.get("energy") == 15)
			assert(eva.wallet.get_seconds_to_restore("energy") == 5)
			eva.wallet.add("energy", -5)
			set_time(5)
			assert(eva.wallet.get("energy") == 12)
			eva.wallet.set("energy", 0)
			set_time(55) -- elapsed 50 secods, want to add 10 * 2, but max restore 5
			assert(eva.wallet.get("energy") == 5)
		end)

		it("Should have correct infinity timer", function()
			eva.wallet.set("energy", 10)

			eva.wallet.add_infinity_time("energy", 10)

			assert(eva.wallet.pay("energy", 5))
			assert(eva.wallet.pay("energy", 10))
			assert(eva.wallet.pay("energy", 15))

			assert(eva.wallet.get("energy") == 10)

			assert(eva.wallet.is_infinity("energy"))
			assert(eva.wallet.get_infinity_seconds("energy") == 10)
		end)
	end)
end