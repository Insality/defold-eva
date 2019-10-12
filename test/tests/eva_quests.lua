local eva = require("eva.eva")
local const = require("eva.const")
local luax = require("eva.luax")
local mock = require("deftest.mock.mock")

local START = const.EVENT.QUEST_START
local PROGRESS = const.EVENT.QUEST_PROGRESS
local TASK_COMPLETE = const.EVENT.QUEST_TASK_COMPLETE
local END = const.EVENT.QUEST_END

local events = {
	[START] = function(event, params)
	end,
	[PROGRESS] = function(event, params)
	end,
	[TASK_COMPLETE] = function(event, params)
	end,
	[END] = function(event, params)
	end
}

return function()
	describe("Eva Quests", function()
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
		end)

		after(function()
			eva.saver.delete("eva_test.json")
			mock.unmock(events)
		end)

		it("Should correct start quests", function()
			local current = eva.quests.get_current()
			assert(luax.table.contains(current, "quest_1"))
			assert(luax.table.contains(current, "quest_4"))
			assert(#current == 2)
		end)

		it("Should catch events", function()
			eva.quests.quest_event("get", "money", 5)
			assert(events[PROGRESS].calls == 1)
			assert(events[PROGRESS].params[1] == PROGRESS)
			assert(events[PROGRESS].params[2].quest_id == "quest_1")
			assert(events[PROGRESS].params[2].delta == 5)
			assert(events[PROGRESS].params[2].total == 5)
			assert(events[PROGRESS].params[2].task_index == 1)

			eva.quests.quest_event("get", "exp", 20)
			assert(events[PROGRESS].calls == 2)

			eva.quests.quest_event("get", "money", 4)
			assert(events[PROGRESS].calls == 3)
			assert(events[PROGRESS].params[1] == PROGRESS)
			assert(events[PROGRESS].params[2].delta == 4)
			assert(events[PROGRESS].params[2].total == 9)

			eva.quests.quest_event("get", "money", 10)
			assert(events[PROGRESS].calls == 4)
			assert(events[PROGRESS].params[2].delta == 1)
			assert(events[PROGRESS].params[2].total == 10)
			assert(events[TASK_COMPLETE].calls == 1)
			assert(events[TASK_COMPLETE].params[2].quest_id == "quest_1")
			assert(events[TASK_COMPLETE].params[2].task_index == 1)
			assert(events[END].calls == 1)
			assert(events[END].params[2].quest_id == "quest_1")
		end)

		it("Should end quests after complete tasks", function()
			eva.quests.quest_event("get", "money", 2000)
			assert(events[PROGRESS].calls == 1)
			assert(events[PROGRESS].params[2].delta == 10)
			assert(events[PROGRESS].params[2].total == 10)


			assert(events[END].calls == 1)
			assert(events[END].params[2].quest_id == "quest_1")
		end)

		it("Should start new quests after complete other", function()
			eva.tokens.add("level", 2, "test")
			eva.quests.quest_event("get", "money", 2000)
			assert(events[END].calls == 1)
			assert(events[END].params[2].quest_id == "quest_1")

			assert(events[START].calls == 1)
			assert(events[START].params[2].quest_id == "quest_2")
			local current = eva.quests.get_current()
			assert(luax.table.contains(current, "quest_2"))
		end)

		it("Should check start quests after changing tokens", function()
			eva.quests.quest_event("get", "money", 2000)
			assert(events[END].calls == 1)
			assert(events[START].calls == 0)

			eva.tokens.add("level", 2, "test")
			assert(events[START].calls == 1)
			assert(events[START].params[2].quest_id == "quest_2")
		end)

		it("Should not complete, before become available (offline quests)", function()
			eva.quests.quest_event("get", "exp", 90)
			assert(events[PROGRESS].calls == 1)
			assert(events[END].calls == 0)

			eva.quests.quest_event("get", "exp", 20)
			assert(events[PROGRESS].calls == 2)
			assert(events[PROGRESS].params[2].delta == 10)
			assert(events[END].calls == 0)

			eva.tokens.add("level", 3, "test")
			assert(events[END].calls == 1)
		end)

		it("Should can be required by multiply quests", function()
			assert(not eva.quests.is_active("quest_5"))
			assert(eva.quests.is_active("quest_1"))
			assert(not eva.quests.is_active("quest_4"))

			eva.quests.quest_event("get", "exp", 100)
			assert(not eva.quests.is_completed("quest_4"))
			eva.tokens.add("level", 3, "test")
			assert(eva.quests.is_completed("quest_4"))

			assert(not eva.quests.is_active("quest_5"))

			eva.quests.quest_event("get", "money", 100)
			assert(eva.quests.is_completed("quest_1"))
			assert(eva.quests.is_active("quest_5"))
		end)

		it("Should correct save quest progress", function()
			eva.tokens.add("level", 3, "test")
			eva.quests.quest_event("get", "exp", 100)
			eva.quests.quest_event("get", "money", 10)
			eva.quests.quest_event("get", "money", 150)
			local completed = eva.quests.get_completed()
			assert(luax.table.contains(completed, "quest_1"))
			assert(luax.table.contains(completed, "quest_4"))
			assert(#completed == 2)
			local current = eva.quests.get_current()
			assert(luax.table.contains(current, "quest_2"))
			assert(luax.table.contains(current, "quest_5"))
			assert(#current == 2)

			local q2_progress = eva.quests.get_progress("quest_2")
			local q5_progress = eva.quests.get_progress("quest_5")
			assert(q2_progress[1] == 150)
			assert(q5_progress[1] == 0)

			eva.saver.save("eva_test.json")
			eva.init("/resources/tests/eva_tests.json")

			q2_progress = eva.quests.get_progress("quest_2")
			q5_progress = eva.quests.get_progress("quest_5")
			assert(q2_progress[1] == 150)
			assert(q5_progress[1] == 0)
		end)

		it("Should have custom logic to start and end quests", function()
			local is_can_start = false
			local is_can_end = false
			local is_can_event = false

			local settings = {
				check_start = function(quest_id)
					return is_can_start
				end,
				check_end = function(quest_id)
					return is_can_end
				end,
				check_event = function(quest_id)
					return is_can_event
				end,
			}
			eva.quests.set_settings(settings)
		end)
	end)
end