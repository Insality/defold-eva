local const = require("eva.const")
local luax = require("eva.luax")
local eva = require("eva.eva")
local mock = require("deftest.mock.mock")
local mock_time = require("deftest.mock.time")

local ADD = const.EVENT.INVOICE_ADD
local EXPIRE = const.EVENT.INVOICE_EXPIRE
local CONSUME = const.EVENT.INVOICE_CONSUME

local events = {
	[ADD] = function() end,
	[EXPIRE] = function() end,
	[CONSUME] = function() end
}

local function set_time(time)
	mock_time.set(time)
	eva.update(1)
	return time
end

local test_tokens = {
	tokens = {
		{ token_id = "money", amount = 10},
		{ token_id = "exp", amount = 100}
	}
}

return function()
	describe("Eva invoices", function()
		before(function()
			eva.init("/resources/tests/eva_tests.json")
			local eva_events = {
				event = function(event, params)
					if events[event] then
						events[event](event, params)
					end
				end
			}
			eva.events.add_event_system(eva_events)
			mock.mock(events)
			mock_time.mock()
			set_time(5000)
		end)

		after(function()
			mock.unmock(events)
			mock_time.unmock()
		end)

		it("Should correct add invoices", function()
			eva.invoices.add("mail", test_tokens)
			assert(events[ADD].calls == 1)
			assert(luax.table.length(eva.invoices.get_invoices()) == 1)

			eva.invoices.add("mail", test_tokens, nil, 0, "title", "text")
			assert(events[ADD].calls == 2)
			assert(luax.table.length(eva.invoices.get_invoices()) == 2)

			set_time(6000)
			assert(events[ADD].calls == 2)
			assert(luax.table.length(eva.invoices.get_invoices()) == 2)
		end)

		it("Should correct add delayed invoices", function()
			local id = eva.invoices.add("mail", test_tokens, 7000)
			assert(events[ADD].calls == 1)
			assert(luax.table.length(eva.invoices.get_invoices()) == 1)
			assert(eva.invoices.can_consume(id) == false)

			set_time(7000)
			assert(eva.invoices.can_consume(id) == true)
			assert(luax.table.length(eva.invoices.get_invoices()) == 1)
		end)

		it("Should correct get invoices list", function()
			eva.invoices.add("mail")
			eva.invoices.add("mail")
			eva.invoices.add("push")
			eva.invoices.add("reward")
			assert(events[ADD].calls == 4)
			assert(luax.table.length(eva.invoices.get_invoices()) == 4)
			assert(luax.table.length(eva.invoices.get_invoices("mail")) == 2)
			assert(luax.table.length(eva.invoices.get_invoices("push")) == 1)
			assert(luax.table.length(eva.invoices.get_invoices("reward")) == 1)
		end)

		it("Should correct consume invoices", function()
			local id = eva.invoices.add("mail", test_tokens)
			local id2 = eva.invoices.add("mail", test_tokens)
			assert(events[ADD].calls == 2)
			assert(events[CONSUME].calls == 0)
			assert(eva.token.get("money") == 0)
			assert(eva.token.get("exp") == 0)


			assert(eva.invoices.can_consume(id) == true)
			eva.invoices.consume(id)
			assert(events[CONSUME].calls == 1)
			assert(eva.token.get("money") == 10)
			assert(eva.token.get("exp") == 100)

			assert(eva.invoices.can_consume(id) == false)
			eva.invoices.consume(id)
			assert(events[CONSUME].calls == 1)
			assert(eva.token.get("money") == 10)
			assert(eva.token.get("exp") == 100)

			eva.invoices.consume(id2)
			assert(events[CONSUME].calls == 2)
			assert(eva.token.get("money") == 20)
			assert(eva.token.get("exp") == 200)
		end)

		it("Should have limited time", function()
			local id = eva.invoices.add("mail", test_tokens, 6000, 1000)
			assert(eva.invoices.can_consume(id) == false)
			assert(eva.invoices.get_invoice(id) ~= nil)

			set_time(6000)
			assert(events[EXPIRE].calls == 0)
			assert(eva.invoices.can_consume(id) == true)
			assert(eva.invoices.get_invoice(id) ~= nil)

			set_time(7001)
			assert(events[EXPIRE].calls == 1)
			assert(eva.invoices.can_consume(id) == false)
			assert(eva.invoices.get_invoice(id) == nil)
		end)
	end)
end