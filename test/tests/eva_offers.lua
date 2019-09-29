local mock_time = require("deftest.mock.time")
local eva = require("eva.eva")

return function()
	describe("Offers", function()
		local id = "test_fast"
		local id2 = "test_iap"

		before(function()
			eva.init("/resources/eva_settings_tests.json")
			mock_time.mock()
			mock_time.set(0)
		end)

		after(function()
			mock_time.unmock()
		end)

		it("Create offers", function()
			eva.offers.add(id)

			print(eva.offers.get_time(id))
			assert(eva.offers.get_time(id) == 20)
			print("T", eva.offers.is_iap(id))
			assert(not eva.offers.is_iap(id))

			eva.offers.add(id2)
			assert(eva.offers.is_iap(id2))
		end)

		it("Should have limited time", function()
			local offer = eva.offers.add(id)

			assert(eva.offers.is_active(id))

			mock_time.elapse(19)
			eva.offers.on_game_second()
			print("t", eva.timers.get(offer.timer_id))
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

		it("Should return price and value", function()
			local offer = eva.offers.add(id)
			local offer2 = eva.offers.add(id2)
		end)
	end)
end