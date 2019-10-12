--- Eva quests module
-- Carry for some quest type data
-- Can be used for different quests, tasks, achievements etc
-- It can be required by another quests
-- It can be required by tokens
-- You can expand the quest data and start/progress/end logic
-- @submodule eva


local log = require("eva.log")
local app = require("eva.app")
local luax = require("eva.luax")
local const = require("eva.const")
local fun = require("eva.libs.fun")

local proto = require("eva.modules.proto")
local saver = require("eva.modules.saver")
local tokens = require("eva.modules.tokens")
local events = require("eva.modules.events")

local logger = log.get_logger("eva.quests")

local M = {}


local function is_tokens_ok(tokens_list)
	return tokens.is_enough_tokens(tokens_list)
end


local function is_quests_ok(quests_list)
	if not quests_list then
		return true
	end

	local quests = app[const.EVA.QUESTS]

	if type(quests_list) == "string" then
		return luax.table.contains(quests.completed, quests_list)
	else
		return fun.all(function(quest_id)
			return luax.table.contains(quests.completed, quest_id)
		end, quests_list)
	end
end


--- All requirements is satisfied
local function is_available(quest_id)
	local quests_data = app.db.Quests.quests
	local quest = quests_data[quest_id]

	return not M.is_completed(quest_id) and
			 is_quests_ok(quest.required_quests) and
			 is_tokens_ok(quest.required_tokens)
end


local function is_catch_offline(quest_id)
	local quests_data = app.db.Quests.quests
	return not M.is_completed(quest_id) and quests_data[quest_id].catch_events_offline
end


local function is_tasks_completed(quest_id)
	local quests_data = app.db.Quests.quests[quest_id]
	local quests = app[const.EVA.QUESTS].current[quest_id]

	for i = 1, #quests_data.tasks do
		local required = quests_data.tasks[i].required
		local current = quests.progress[i]

		if current < required then
			return false
		end
	end

	return true
end


local function start_quest(quest_id)
	local quests = app[const.EVA.QUESTS]
	local quests_data = app.db.Quests.quests[quest_id]
	if quests.current[quest_id] then
		logger:warn("Quest already started", { quest_id = quest_id })
		return
	end

	quests.current[quest_id] = proto.get("eva.QuestData")
	for i = 1, #quests_data.tasks do
		quests.current[quest_id].progress[i] = 0
	end

	events.event(const.EVENT.QUEST_START, { quest_id = quest_id })
end


local function end_quest(quest_id)
	local quests = app[const.EVA.QUESTS]
	if not quests.current[quest_id] then
		logger:warn("No quest in current list to end it", { quest_id = quest_id })
		return
	end
	if M.is_completed(quest_id) then
		logger:warn("Quest already completed", { quest_id = quest_id })
		return
	end

	quests.current[quest_id] = nil
	table.insert(quests.completed, quest_id)
	events.event(const.EVENT.QUEST_END, { quest_id = quest_id })
end


local function update_quests_list()
	local quests_data = app.db.Quests.quests
	local quests = app[const.EVA.QUESTS]

	for quest_id, quest in pairs(quests_data) do
		if M.is_active(quest_id) and is_tasks_completed(quest_id) then
			local is_can_end = true

			if app.quests_settings.check_end then
				is_can_end = app.quests_settings.check_end(quest_id)
			end

			if is_can_end then
				end_quest(quest_id)
			end
		end

		if not quests.current[quest_id] and (is_available(quest_id) or is_catch_offline(quest_id)) then
			local is_can_start = true

			if app.quests_settings.check_start then
				is_can_start = app.quests_settings.check_start(quest_id)
			end

			if is_can_start then
				start_quest(quest_id)
			end
		end
	end
end


local function apply_event(quest_id, quest, action, object, amount)
	local quests_data = app.db.Quests.quests
	local quest_data = quests_data[quest_id]
	local is_updated = false

	for i = 1, #quest_data.tasks do
		local task_data = quest_data.tasks[i]
		local match_action = task_data.action == action
		local match_object = (task_data.object == object or task_data.object == luax.string.empty)

		if match_action and match_object then
			is_updated = true

			local prev_value = quest.progress[i]
			quest.progress[i] = luax.math.clamp(quest.progress[i] + amount, 0, task_data.required)

			local delta = quest.progress[i] - prev_value

			events.event(const.EVENT.QUEST_PROGRESS, {
				quest_id = quest_id,
				delta = delta,
				total = quest.progress[i],
				task_index = i
			})

			if quest.progress[i] == task_data.required then
				events.event(const.EVENT.QUEST_TASK_COMPLETE, {
					quest_id = quest_id,
					task_index = i
				})
			end
		end
	end

	return is_updated
end


function M.get_progress(quest_id)
	local quests = app[const.EVA.QUESTS]
	return quests.current[quest_id] and quests.current[quest_id].progress or {}
end


function M.get_current()
	return luax.table.list(app[const.EVA.QUESTS].current)
end


function M.get_completed()
	return app[const.EVA.QUESTS].completed
end


function M.is_active(quest_id)
	local quests = app[const.EVA.QUESTS]
	return quests.current[quest_id] and is_available(quest_id)
end


function M.is_completed(quest_id)
	local quests = app[const.EVA.QUESTS]
	return luax.table.contains(quests.completed, quest_id)
end


function M.quest_event(action, object, amount)
	local current = app[const.EVA.QUESTS].current
	local is_need_update = false

	for quest_id, quest in pairs(current) do
		local is_can_event = true

		if app.quests_settings.check_event then
			is_can_event = app.quests_settings.check_event(quest_id)
		end

		if is_can_event then
			if apply_event(quest_id, quest, action, object, amount) then
				is_need_update = true
			end
		end
	end

	if is_need_update then
		update_quests_list()
	end
end


local base_quest_system = {
	event = function(event, params)
		if event == const.EVENT.TOKEN_CHANGE then
			update_quests_list()
		end
	end
}


--- Set game quests settings
-- @function eva.quests.set_settings
function M.set_settings(quests_settings)
	app.quests_settings = quests_settings
end


function M.on_eva_init()
	app.quests_settings = {}
	app[const.EVA.QUESTS] = proto.get(const.EVA.QUESTS)
	saver.add_save_part(const.EVA.QUESTS, app[const.EVA.QUESTS])
	events.add_event_system(base_quest_system)
end


function M.after_eva_init()
	update_quests_list()
end


return M
