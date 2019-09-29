local mock_time = require("deftest.mock.time")
local eva = require("eva.eva")

return function()
	describe("Eva Offers", function()
		local offer_fast = "test_fast"
		local offer_iap = "test_iap"

		before(function()
			eva.init("/resources/tests/eva_tests.json")
			mock_time.mock()
			mock_time.set(0)
		end)

		after(function()
			mock_time.unmock()
		end)

		it("Create offers", function()
			eva.offers.add(offer_fast)

			assert(eva.offers.get_time(offer_fast) == 20)
			assert(not eva.offers.is_iap(offer_fast))

			eva.offers.add(offer_iap)
			assert(eva.offers.is_iap(offer_iap))
		end)

		it("Should have limited time", function()
			local offer = eva.offers.add(offer_fast)

			assert(eva.offers.is_active(offer_fast))

			mock_time.elapse(19)
			eva.offers.on_game_second()
			assert(eva.timers.get(offer.timer_id) ~= nil)
			assert(eva.offers.is_active(offer_fast))

			-- remove at 20 seconds
			mock_time.elapse(1)
			eva.offers.on_game_second()
			assert(not eva.offers.is_active(offer_fast))

			assert(eva.timers.get(offer.timer_id) == nil)
		end)

		it("Should return price and value", function()
			local reward = eva.offers.get_reward(offer_fast)

			local first = reward[1]
			assert(first.token_id == "energy")
			assert(first.amount == 50)

			local price = eva.offers.get_price(offer_fast)
			first = price[1]
			assert(first.token_id == "money")
			assert(first.amount == 1000)
		end)
	end)
end