local eva = require("eva.eva")

return function()
	describe("Eva tokens", function()
		before(function()
			eva.init("/resources/tests/eva_tests.json")
		end)

		it("Should make group of tokens", function()
			local tokens = eva.token.get_tokens({
				money = 100,
				exp = 50,
				item = 10
			})

			assert(#tokens.tokens == 3)
			assert(tokens.tokens[1].token_id)
			assert(tokens.tokens[1].amount)
		end)

		it("Should add/pay/is_enough by tokens_group", function()
			local tokens = eva.token.get_tokens({
				money = 100,
				exp = 50,
				item = 10
			})

			assert(not eva.token.is_enough_many(tokens))
			eva.token.add_many(tokens)

			assert(eva.token.is_enough_many(tokens))
			assert(eva.token.get("money") == 100)
			assert(eva.token.get("exp") == 50)
			assert(eva.token.get("item") == 10)

			eva.token.pay_many(tokens)
			assert(eva.token.get("money") == 0)
			assert(eva.token.get("exp") == 0)
			assert(eva.token.get("item") == 0)
			assert(not eva.token.is_enough_many(tokens))
		end)

		it("Should add/pay/is_enough by token_group_id", function()
			assert(not eva.token.is_enough_group("iap_2"))

			eva.token.add_group("iap_2")
			assert(eva.token.is_enough_group("iap_2"))
			assert(eva.token.get("money") == 1000)
			assert(eva.token.get("energy") == 10)

			eva.token.pay_group("iap_2")
			assert(eva.token.get("money") == 0)
			assert(eva.token.get("energy") == 0)
		end)

		it("Should get tokens by group_id", function()
			local tokens = eva.token.get_token_group("reward2")
			assert(#tokens.tokens == 2)

			eva.token.add_many(tokens)
			assert(eva.token.get("energy") == 50)
			assert(eva.token.get("level") == 2)
		end)

		it("Should get tokens from lot reward and lot price", function()
			local price = eva.token.get_lot_price("lot1")
			local reward = eva.token.get_lot_reward("lot1")

			assert(#price.tokens == 1)
			assert(#reward.tokens == 2)
			assert(price.tokens[1].token_id == "money")
			assert(price.tokens[1].amount == 100)
		end)
	end)
end