local eva = require("eva.eva")

return function()
	describe("Eva tokens", function()
		before(function()
			eva.init("/resources/tests/eva_tests.json")
		end)

		it("Should make group of tokens", function()
			local tokens = eva.tokens.get_tokens({
				money = 100,
				exp = 50,
				item = 10
			})

			assert(#tokens.tokens == 3)
			assert(tokens.tokens[1].token_id)
			assert(tokens.tokens[1].amount)
		end)

		it("Should add/pay/is_enough by tokens_group", function()
			local tokens = eva.tokens.get_tokens({
				money = 100,
				exp = 50,
				item = 10
			})

			assert(not eva.tokens.is_enough(tokens))
			eva.tokens.add(tokens)

			assert(eva.tokens.is_enough(tokens))
			assert(eva.token.get("money") == 100)
			assert(eva.token.get("exp") == 50)
			assert(eva.token.get("item") == 10)

			eva.tokens.pay(tokens)
			assert(eva.token.get("money") == 0)
			assert(eva.token.get("exp") == 0)
			assert(eva.token.get("item") == 0)
			assert(not eva.tokens.is_enough(tokens))
		end)

		it("Should add/pay/is_enough by token_group_id", function()
			assert(not eva.tokens.is_enough_group("iap_2"))

			eva.tokens.add_group("iap_2")
			assert(eva.tokens.is_enough_group("iap_2"))
			assert(eva.token.get("money") == 1000)
			assert(eva.token.get("energy") == 10)

			eva.tokens.pay_group("iap_2")
			assert(eva.token.get("money") == 0)
			assert(eva.token.get("energy") == 0)
		end)

		it("Should get tokens by group_id", function()
			local tokens = eva.tokens.get_token_group("reward2")
			assert(#tokens.tokens == 2)

			eva.tokens.add(tokens)
			assert(eva.token.get("energy") == 50)
			assert(eva.token.get("level") == 2)
		end)

		it("Should get tokens from lot reward and lot price", function()
			local price = eva.tokens.get_lot_price("lot1")
			local reward = eva.tokens.get_lot_reward("lot1")

			assert(#price.tokens == 1)
			assert(#reward.tokens == 2)
			assert(price.tokens[1].token_id == "money")
			assert(price.tokens[1].amount == 100)
		end)
	end)
end