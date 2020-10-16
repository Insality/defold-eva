---@type eva
local eva = require("eva.eva")
local const = require("eva.const")
local luax = require("eva.luax")
local mock = require("deftest.mock.mock")

local REGISTER = const.EVENT.QUEST_REGISTER
local START = const.EVENT.QUEST_START
local PROGRESS = const.EVENT.QUEST_PROGRESS
local TASK_COMPLETE = const.EVENT.QUEST_TASK_COMPLETE
local END = const.EVENT.QUEST_END

local events = {
	[REGISTER] = function() end,
	[START] = function() end,
	[PROGRESS] = function() end,
	[TASK_COMPLETE] = function() end,
	[END] = function() end
}

return function()
	describe("Eva Quests", function()
		before(function()
			eva.init("/resources/tests/eva_tests.json")

			mock.mock(events)
			eva.events.subscribe_map(events)
		end)

		after(function()
			eva.saver.delete()
			mock.unmock(events)
		end)

		it("Should correct start quests", function()
			eva.quests.start_quests()
			local current = eva.quests.get_current()
			assert(events[REGISTER].calls == 5)
			assert(events[START].calls == 1)
			assert(luax.table.contains(current, "quest_1"))
			assert(#current == 1)
		end)

		it("Should catch events", function()
			eva.quests.start_quests()
			eva.quests.quest_event("get", "money", 5)
			assert(events[PROGRESS].calls == 1)
			assert(events[PROGRESS].params[2].quest_id == "quest_1")
			assert(events[PROGRESS].params[2].delta == 5)
			assert(events[PROGRESS].params[2].total == 5)
			assert(events[PROGRESS].params[2].task_index == 1)

			eva.quests.quest_event("get", "exp", 20)
			assert(events[PROGRESS].calls == 2)

			eva.quests.quest_event("get", "money", 4)
			assert(events[PROGRESS].calls == 3)
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

		it("Should give rewards", function()
			eva.quests.start_quests()
			assert(eva.wallet.get("money") == 0)
			eva.quests.quest_event("get", "money", 10)
			assert(eva.wallet.get("money") == 100)
		end)

		it("Should end quests after complete tasks", function()
			eva.quests.start_quests()
			eva.quests.quest_event("get", "money", 2000)
			assert(events[PROGRESS].calls == 1)
			assert(events[PROGRESS].params[2].delta == 10)
			assert(events[PROGRESS].params[2].total == 10)


			assert(events[END].calls == 1)
			assert(events[END].params[2].quest_id == "quest_1")
		end)

		it("Should start new quests after complete other", function()
			eva.quests.start_quests()
			eva.wallet.add("level", 1, "test")
			eva.quests.quest_event("get", "money", 2000)
			assert(events[END].calls == 1)
			assert(events[END].params[2].quest_id == "quest_1")

			assert(events[REGISTER].calls == 6)
			assert(events[START].calls == 2)
			assert(events[START].params[2].quest_id == "quest_2")
			local current = eva.quests.get_current()
			assert(luax.table.contains(current, "quest_2"))
		end)

		it("Should check start quests after changing tokens", function()
			eva.quests.start_quests()
			eva.quests.quest_event("get", "money", 2000)
			assert(events[END].calls == 1)
			assert(events[START].calls == 1)
			assert(events[REGISTER].calls == 5)

			eva.wallet.add("level", 1, "test")
			assert(events[START].calls == 2)
			assert(events[START].params[2].quest_id == "quest_2")
		end)

		it("Should not complete, before become available (offline quests)", function()
			eva.quests.start_quests()
			eva.quests.quest_event("get", "exp", 90)
			assert(events[PROGRESS].calls == 1)
			assert(events[END].calls == 0)

			eva.quests.quest_event("get", "exp", 20)
			assert(events[PROGRESS].calls == 2)
			assert(events[PROGRESS].params[2].delta == 10)
			assert(events[END].calls == 0)

			eva.wallet.add("level", 2, "test")
			assert(events[END].calls == 1)
		end)

		it("Should can be required by multiply quests", function()
			eva.quests.start_quests()
			assert(not eva.quests.is_active("quest_5"))
			assert(eva.quests.is_active("quest_1"))
			assert(not eva.quests.is_active("quest_4"))

			eva.quests.quest_event("get", "exp", 100)
			assert(not eva.quests.is_completed("quest_4"))
			eva.wallet.add("level", 3, "test")
			assert(eva.quests.is_completed("quest_4"))

			assert(not eva.quests.is_active("quest_5"))

			eva.quests.quest_event("get", "money", 100)
			assert(eva.quests.is_completed("quest_1"))
			assert(eva.quests.is_active("quest_5"))
		end)

		it("Should correct save quest progress", function()
			eva.quests.start_quests()
			eva.wallet.add("level", 3, "test")
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

			eva.saver.save()
			eva.init("/resources/tests/eva_tests.json")
			eva.quests.start_quests()

			q2_progress = eva.quests.get_progress("quest_2")
			q5_progress = eva.quests.get_progress("quest_5")
			assert(q2_progress[1] == 150)
			assert(q5_progress[1] == 0)
		end)

		it("Should have custom logic to start, send events, and to end quests", function()
			local is_can_start = false
			local is_can_end = false
			local is_can_event = false

			local settings = {
				is_can_start = function(quest_id)
					return is_can_start
				end,
				is_can_complete = function(quest_id)
					return is_can_end
				end,
				is_can_event = function(quest_id)
					return is_can_event
				end,
			}
			eva.quests.set_settings(settings)
			eva.quests.start_quests()

			assert(events[START].calls == 0)
			assert(events[REGISTER].calls == 4)
			is_can_start = true
			eva.quests.update_quests()
			eva.quests.update_quests()
			assert(events[START].calls == 1)
			assert(events[REGISTER].calls == 5)

			eva.quests.quest_event("get", "money", 10)
			assert(events[PROGRESS].calls == 0)

			is_can_event = true
			eva.quests.quest_event("get", "money", 10)
			assert(events[PROGRESS].calls == 1)
			assert(events[END].calls == 0)

			is_can_end = true
			eva.quests.update_quests()
			assert(events[END].calls == 1)
		end)

		it("Should have custom callbacks on main quest events", function()
			local settings = {
				on_quest_start = function() end,
				on_quest_progress = function() end,
				on_quest_task_completed = function() end,
				on_quest_completed = function() end,
			}
			mock.mock(settings)
			eva.quests.set_settings(settings)
			eva.quests.start_quests()
			assert(settings.on_quest_start.calls == 1)

			eva.quests.quest_event("get", "exp", 90)
			assert(settings.on_quest_progress.calls == 1)

			eva.quests.quest_event("get", "exp", 20)
			assert(settings.on_quest_progress.calls == 2)
			assert(settings.on_quest_task_completed.calls == 1)

			eva.wallet.add("level", 2, "test")
			assert(settings.on_quest_start.calls == 2)
			assert(settings.on_quest_completed.calls == 1)
		end)

		it("Should register offline quests", function()
			eva.quests.start_quests()
			assert(events[REGISTER].calls == 5)
			eva.wallet.add("level", 1) -- up to 2 level
			assert(events[REGISTER].calls == 5)
			assert(events[END].calls == 0)
		end)

		it("Should autostart quests, what have been registered", function()
			eva.quests.start_quests()
			assert(events[START].calls == 1)
			eva.wallet.add("level", 2) -- up to 3 level
			assert(events[START].calls == 2)
			assert(events[START].params[2].quest_id == "quest_4")
		end)

		it("Should manual start quests without offline mode", function()
			eva.quests.start_quests()
			assert(events[START].calls == 1)
			eva.quests.start_quest("quest_8")
			assert(events[START].calls == 2)

			assert(not eva.quests.is_can_start_quest("quest_6"))
			eva.quests.start_quest("quest_6") -- cant start, need level 2
			assert(not eva.quests.is_can_start_quest("quest_9"))
			eva.quests.start_quest("quest_9") -- cant start, need quest_8
			assert(events[START].calls == 2)
			assert(events[REGISTER].calls == 6)
			assert(events[REGISTER].params[2].quest_id == "quest_8")

			assert(events[END].calls == 0)
			eva.quests.quest_event("get", "item", 1)
			assert(events[END].calls == 1)
			assert(events[START].calls == 2)

			assert(eva.quests.is_can_start_quest("quest_9"))
			eva.quests.start_quest("quest_9")
			assert(events[START].calls == 3)

			assert(not eva.quests.is_can_start_quest("quest_9"))
			eva.quests.start_quest("quest_9") -- We should not start quest twice
			assert(events[START].calls == 3)

			eva.wallet.add("level", 1)
			assert(events[START].calls == 3)
			assert(events[END].calls == 1)
		end)

		it("Should manual start quests with offline mode", function()
			eva.quests.start_quests()
			assert(events[START].calls == 1)
			eva.quests.quest_event("get", "item", 1)

			assert(events[END].calls == 0)
			assert(events[START].calls == 1)

			assert(not eva.quests.is_can_start_quest("quest_6"))
			eva.quests.start_quest("quest_6")
			assert(events[END].calls == 0)
			assert(events[START].calls == 1)

			eva.wallet.add("level", 1)
			assert(eva.quests.is_can_start_quest("quest_6"))
			eva.quests.start_quest("quest_6")
			assert(events[END].calls == 1)
			assert(events[START].calls == 2)
		end)

		it("Should not autofinish quest without autofinish", function()
			eva.quests.start_quests()
			assert(events[START].calls == 1)
			assert(events[REGISTER].calls == 5)
			eva.quests.start_quest("quest_10")
			assert(events[REGISTER].calls == 6)
			assert(events[START].calls == 2)
			assert(events[END].calls == 0)
			assert(not eva.quests.is_can_complete_quest("quest_10"))
			eva.quests.complete_quest("quest_10")
			assert(events[END].calls == 0)

			eva.quests.quest_event("get", "gold", 1)
			assert(events[END].calls == 0)
			assert(eva.quests.is_can_complete_quest("quest_10"))

			eva.quests.complete_quest("quest_10")
			assert(events[END].calls == 1)
			assert(not eva.quests.is_can_complete_quest("quest_10"))

			assert(eva.quests.is_can_start_quest("quest_11"))
			eva.quests.start_quest("quest_11")
			assert(events[START].calls == 3)

			eva.quests.quest_event("get", "gold", 1)
			eva.quests.complete_quest("quest_11")
			assert(events[START].calls == 4)
			assert(eva.quests.is_active("quest_12"))
			assert(eva.quests.is_can_complete_quest("quest_12"))
		end)

		it("Should correct work quest without autostart and autofinish", function()
			eva.quests.start_quests()
			assert(events[START].calls == 1)
			eva.wallet.add("gold", 100)
			assert(events[START].calls == 2)
			assert(events[END].calls == 0)
			eva.quests.quest_event("get", "gold", 1)
			assert(events[END].calls == 0)
			assert(eva.quests.is_can_complete_quest("quest_14"))
			eva.quests.complete_quest("quest_14")
			assert(events[END].calls == 1)
		end)

		it("Should correct work with repeatable quests (daily example)", function()
			eva.quests.start_quests()
			assert(events[START].calls == 1)

			assert(not eva.quests.is_active("quest_daily_1"))
			eva.quests.start_quest("quest_daily_1")
			assert(events[START].calls == 2)
			assert(eva.quests.is_active("quest_daily_1"))
			assert(not eva.quests.is_can_complete_quest("quest_daily_1"))

			eva.quests.quest_event("win", "game", 1)
			assert(not eva.quests.is_can_complete_quest("quest_daily_1"))
			eva.quests.quest_event("play", "hero", 1)
			assert(eva.quests.is_can_complete_quest("quest_daily_1"))
			eva.quests.complete_quest("quest_daily_1")
			assert(not eva.quests.is_active("quest_daily_1"))
			assert(eva.quests.is_can_start_quest("quest_daily_1"))
			eva.quests.start_quest("quest_daily_1")

			assert(events[END].calls == 1)
			assert(events[START].calls == 3)
		end)

		it("Should work with single progress tasks", function()
			eva.quests.start_quests()
			eva.quests.start_quest("earn_max_score")
			assert(eva.quests.is_active("earn_max_score"))
			assert(not eva.quests.is_can_complete_quest("earn_max_score"))

			eva.quests.quest_event("get", "score", 4000)
			assert(not eva.quests.is_can_complete_quest("earn_max_score"))

			eva.quests.quest_event("get", "score", 4000)
			assert(not eva.quests.is_can_complete_quest("earn_max_score"))

			eva.quests.quest_event("get", "score", 5000)
			assert(eva.quests.is_can_complete_quest("earn_max_score"))
		end)
	end)
end
