local mock_time = require("deftest.mock.time")
local time_string = require("eva.libs.time_string")
local eva = require("eva.eva")

return function()
	describe("Eva Promocode", function()
		before(function()
			eva.init("/resources/tests/eva_tests.json")
			mock_time.mock()
			mock_time.set(0)
		end)

		it("Basic code redeem", function()
			assert(eva.promocode.is_can_redeem("AWSOME") == true)
			assert(eva.wallet.get("exp") == 0)

			eva.promocode.redeem_code("AWSOME")
			assert(eva.wallet.get("exp") == 100)
			assert(eva.promocode.is_can_redeem("AWSOME") == false)
		end)


		it("Code redeem with time restrictions", function()
			local time = time_string.parse_ISO("2019-09-07Z")
			mock_time.set(time)
			assert(eva.promocode.is_can_redeem("DEFOLD") == false)
			assert(eva.promocode.redeem_code("DEFOLD") == false)
			assert(eva.wallet.get("gold") == 0)

			local time2 = time_string.parse_ISO("2019-11-07Z")
			mock_time.set(time2)
			assert(eva.promocode.is_can_redeem("DEFOLD") == true)
			assert(eva.promocode.redeem_code("DEFOLD") == true)

			assert(eva.wallet.get("gold") == 10)
		end)
	end)
end
