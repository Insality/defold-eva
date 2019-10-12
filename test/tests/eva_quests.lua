local eva = require("eva.eva")
local luax = require("eva.luax")

return function()
	describe("Eva quests", function()
		before(function()
			eva.init("/resources/tests/eva_tests.json")
		end)

		it("Should correct start quests", function()
			local current = eva.quests.get_current()
			assert(luax.table.contains(current, "quest_1"))
			assert(luax.table.contains(current, "quest_4"))
			assert(#current == 2)
		end)

		it("Should catch events", function()

		end)

		it("Should end quests after complete tasks", function()

		end)

		it("Should start new quests after complete other", function()

		end)

		it("Should check start quests after changing tokens", function()

		end)

		it("Should not complete, before become available (offline quests)", function()

		end)

		it("Should can be required by multiply quests", function()

		end)

		it("Should send progress events", function()

		end)

		it("Should send task complete events", function()

		end)

		it("Should correct save quest progress", function()

		end)

		it("Should have custom logic to start and end quests", function()

		end)
	end)
end