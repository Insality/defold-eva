local eva = require("eva.eva")
local const = require("eva.const")
local mock = require("deftest.mock.mock")


local IAP_CANCEL = const.EVENT.IAP_CANCEL
local IAP_PURCHASE = const.EVENT.IAP_PURCHASE
local IAP_UPDATE = const.EVENT.IAP_UPDATE

local events = {
	[IAP_CANCEL] = function() end,
	[IAP_PURCHASE] = function() end,
	[IAP_UPDATE] = function() end
}

return function()
	describe("Eva iaps", function()
		before(function()
			eva.init("/resources/tests/eva_tests.json")

			mock.mock(events)
			eva.events.subscribe_map(events)
		end)

		after(function()
			mock.unmock(events)
		end)

		it("Should correct return iap list", function()
			local iaps = eva.iaps.get_iaps()
			assert(iaps["pack1"])
			assert(iaps["pack2"])
			assert(iaps["starter1"])
			assert(not iaps["starter2"])
			assert(iaps["no_ads"])
		end)

		it("Should correct return iaps by category", function()
			local iaps = eva.iaps.get_iaps("money")
			assert(iaps["pack1"])
			assert(iaps["pack2"])
			assert(not iaps["starter1"])
			assert(not iaps["no_ads"])
			assert(iaps["test_iap"])
		end)

		it("Should be all available on desktops", function()
			assert(eva.iaps.is_available("pack1"))
			assert(eva.iaps.is_available("pack2"))
			assert(eva.iaps.is_available("starter1"))
			assert(not eva.iaps.is_available("starter2"))
		end)

		it("Should return correct price", function()
			assert(eva.iaps.get_price("pack1") == 0.99)
			assert(eva.iaps.get_price_string("pack1") == "$0.99")
			assert(eva.iaps.get_price("pack2") == 4.99)
			assert(eva.iaps.get_price_string("pack2") == "$4.99")
		end)

		it("Should return iap by id", function()
			local iap = eva.iaps.get_iap("pack1")
			assert(iap.price == 0.99)
			assert(iap.ident == "com.test.pack1")
			assert(iap.is_available)
		end)

		it("Should call update iaps event after update", function()
			eva.iaps.refresh_iap_list()
			assert(events[IAP_UPDATE].calls == 1)
		end)

		it("Should correct buy iap", function()
			assert(events[IAP_PURCHASE].calls == 0)
			assert(eva.token.get("money") == 0)

			eva.iaps.buy("pack1")
			assert(events[IAP_PURCHASE].calls == 1)
			assert(eva.token.get("money") == 500)
		end)

		it("Should correct work test_buy iap", function()
			assert(events[IAP_PURCHASE].calls == 0)
			assert(eva.token.get("money") == 0)

			eva.iaps.test_buy_with_fake_state("pack1")
			assert(events[IAP_PURCHASE].calls == 1)
			assert(events[IAP_CANCEL].calls == 0)
			assert(eva.token.get("money") == 500)
		end)

		it("Should correct return iap reward", function()
			local reward = eva.iaps.get_reward("pack1")

			assert(reward.tokens[1].token_id == "money")
			assert(reward.tokens[1].amount == 500)
		end)

		it("Should correct throw cancel event", function()
			eva.iaps.test_buy_with_fake_state("pack1", const.IAP.STATE.PURCHASED, true)
			assert(events[IAP_PURCHASE].calls == 0)
			assert(events[IAP_CANCEL].calls == 1)
			assert(eva.token.get("money") == 0)
		end)

		it("Should return state of operations", function()
			assert(not eva.iaps.buy("unknown_iap"))
			assert(eva.iaps.buy("pack1"))
			assert(not eva.iaps.test_buy_with_fake_state("unknown_iap"))
			assert(eva.iaps.test_buy_with_fake_state("pack1"))
		end)
	end)
end