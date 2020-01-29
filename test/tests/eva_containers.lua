local eva = require("eva.eva")

local TEST_CONTAINER = "test_container"

return function()
	describe("Eva tokens", function()
		before(function()
			eva.init("/resources/tests/eva_tests.json")
			eva.token.create_container(TEST_CONTAINER, "drop_container")
		end)

		it("Should work add tokens from other container", function()
			assert(eva.token.get(TEST_CONTAINER, "money") == 0)
			eva.token.add(TEST_CONTAINER, "money", 10)
			assert(eva.token.get(TEST_CONTAINER, "money") == 10)


			assert(eva.wallet.get("money") == 0)
			local tokens = eva.token.get_many(TEST_CONTAINER)
			eva.wallet.add_many(tokens)
			assert(eva.wallet.get("money") == 10)
		end)
	end)
end