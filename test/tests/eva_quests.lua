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
	end)
end