local mock = require("deftest.mock.mock")
local mock_time = require("deftest.mock.time")

---@type eva
local eva = require("eva.eva")
local const = require("eva.const")

local function set_time(time)
	mock_time.set(time)
	eva.update(1)
	return time
end

local ADS_SHOW = const.EVENT.ADS_SHOW
local ADS_SUCCESS = const.EVENT.ADS_SUCCESS
local ADS_SUCCESS_REWARDED = const.EVENT.ADS_SUCCESS_REWARDED

local events = {
	[ADS_SUCCESS_REWARDED] = function() end,
	[ADS_SUCCESS] = function() end,
	[ADS_SHOW] = function() end
}

return function()
	describe("Eva ads", function()
		before(function()
			mock_time.mock()
			mock_time.set(100000)
			mock.mock(events)

			eva.init("/resources/tests/eva_tests.json")

			eva.events.subscribe_map(events)
		end)

		after(function()
			mock_time.unmock()
			mock.unmock(events)
		end)

		it("Should correct work is_ready", function()
			assert(eva.ads.is_ready("double_exp"))
			assert(not eva.ads.is_ready("page"))
			assert(eva.ads.is_ready("double_exp"))
			assert(not eva.ads.is_ready("page"))
		end)

		it("Should correct work with ads conditions", function()
			assert(not eva.ads.is_ready("page"))
			mock_time.elapse(60)
			assert(not eva.ads.is_ready("page"))
			eva.wallet.add("level", 2)
			assert(eva.ads.is_ready("page"))
		end)

		it("Should send ads events", function()
			mock_time.elapse(60)
			eva.wallet.add("level", 2)
			eva.ads.show("page")

			assert(events[ADS_SUCCESS].calls == 1)
			assert(events[ADS_SUCCESS_REWARDED].calls == 0)
			assert(not eva.ads.is_ready("page"))

			mock_time.elapse(120)
			assert(not eva.ads.is_ready("page"))
			mock_time.elapse(120)
			assert(eva.ads.is_ready("page"))
		end)

		it("Should correct check daily limit", function()
			eva.update(1)
			mock_time.elapse(60)
			eva.wallet.add("level", 2)
			for i = 1, 5 do
				assert(eva.ads.is_ready("page"))
				eva.ads.show("page")
				mock_time.elapse(240)
				eva.update(1)
			end

			assert(not eva.ads.is_ready("page"))

			mock_time.elapse(120)
			eva.update(1)
			assert(not eva.ads.is_ready("page"))

			mock_time.elapse(599)
			eva.update(1)
			-- Still daily limit
			assert(not eva.ads.is_ready("page"))

			mock_time.elapse(600)
			eva.update(1)

			-- Daily limit
			assert(not eva.ads.is_ready("page"))

			-- skip one day
			mock_time.elapse(60 * 60 * 24 + 1)
			eva.update(1)
			assert(eva.ads.is_ready("page"))
		end)

		it("Should work with rewarded ads", function()
			assert(eva.ads.is_ready("double_exp"))
			eva.ads.show("double_exp")
			assert(eva.ads.is_ready("double_exp"))
			assert(events[ADS_SUCCESS].calls == 1)
			assert(events[ADS_SUCCESS_REWARDED].calls == 1)
		end)

		it("Can be disabled by daily limit", function()
			assert(not eva.ads.is_ready("disabled"))
		end)

		it("Should correct work with all_ads_daily_limit", function()
			assert(eva.ads.is_ready("some_limit"))
			eva.ads.show("double_exp")
			eva.ads.show("double_exp")
			eva.ads.show("double_exp")
			assert(not eva.ads.is_ready("some_limit"))

			mock_time.elapse(24 * 60 * 60)
			eva.update(1)

			assert(eva.ads.is_ready("some_limit"))
		end)

		it("Should be correct with time between same ad", function()
			mock_time.elapse(60)
			eva.wallet.add("level", 2)
			assert(eva.ads.is_ready("page"))
			eva.ads.show("page")

			mock_time.elapse(120)
			assert(not eva.ads.is_ready("page"))
			mock_time.elapse(120)
			assert(eva.ads.is_ready("page"))
		end)

		it("Should be correct with time between any ads", function()
			mock_time.elapse(60)
			eva.wallet.add("level", 2)
			assert(eva.ads.is_ready("page"))
			assert(eva.ads.is_ready("double_exp"))
			eva.ads.show("double_exp")
			assert(eva.ads.is_ready("double_exp"))
			assert(not eva.ads.is_ready("page"))
			mock_time.elapse(5)
			assert(not eva.ads.is_ready("page"))
			mock_time.elapse(5)
			assert(eva.ads.is_ready("page"))
		end)
	end)
end
