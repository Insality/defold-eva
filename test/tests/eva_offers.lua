local mock_time = require("deftest.mock.time")
local eva = require("eva.eva")

return function()
	describe("Offers", function()
		local category = "test"
		local id = "offer"
		local lot = {
			reward = {},
			price = {},
		}

		before(function()
			eva.init("/resources/eva_settings_tests.json")
			mock_time.mock()
			mock_time.set(0)
		end)

		after(function()
			mock_time.unmock()
		end)

		it("Create offers", function()
			local id2 = "offer2"
			eva.offers.add(id, category, 20, lot)

			print(eva.offers.get_time(id))
			assert(eva.offers.get_time(id) == 20)
			assert(not eva.offers.is_iap(id))

			eva.offers.add(id2, category, 20, lot, "com.test.iap")
			assert(eva.offers.is_iap(id2))
		end)

		it("Should have limited time", function()
			local offer = eva.offers.add(id, category, 20, lot)

			assert(eva.offers.is_active(id))

			mock_time.elapse(19)
			eva.offers.on_game_second()
			assert(eva.timers.get(offer.timer_id) ~= nil)
			assert(eva.offers.is_active(id))

			-- remove at 20 seconds
			mock_time.elapse(1)
			eva.offers.on_game_second()
			assert(not eva.offers.is_active(id))

			mock_time.elapse(1)
			eva.offers.on_game_second()
			assert(not eva.offers.is_active(id))

			assert(eva.timers.get(offer.timer_id) == nil)
		end)
	end)
end