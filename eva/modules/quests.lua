--- Eva quests module
-- Carry for some quest type data
-- Can be used for different quests, tasks, achievements etc
-- It can be required by another quests
-- It can be required by tokens
-- You can expand the quest data and start/progress/end logic
-- @submodule eva

-- Quest stages:
-- No registered
-- Registered
-- Started (Auto start if autostart flag)
-- Can finish
-- Finished (Auto finish if autofinish flag)


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


local function make_relative_quests_map()
	local quests_data = app.db.Quests.quests
	local map = {}

	for quest_id, quest in pairs(quests_data) do
		if quest.required_quests then
			for i = 1, #quest.required_quests do
				map[quest.required_quests[i]] = map[quest.required_quests[i]] or {}
				table.insert(map[quest.required_quests[i]], quest_id)
			end
		end
	end


	return map
end


local function is_tokens_ok(tokens_list)
	return tokens.is_enough(tokens_list)
end


local function is_quests_ok(quests_list)
	if not quests_list then
		return true
	end

	local quests = app[const.EVA.QUESTS]

	return fun.all(function(quest_id)
		return luax.table.contains(quests.completed, quest_id)
	end, quests_list)
end


--- All requirements is satisfied for start quest
local function is_available(quest_id)
	local quests_data = app.db.Quests.quests
	local quest = quests_data[quest_id]

	return not M.is_completed(quest_id) and
			 is_quests_ok(quest.required_quests) and
			 is_tokens_ok(quest.required_tokens)
end


local function is_catch_offline(quest_id)
	local quests_data = app.db.Quests.quests
	return not M.is_completed(quest_id) and quests_data[quest_id].events_offline
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


local function can_be_started_quest(quest_id)
	local quest = app.db.Quests.quests[quest_id]

	local is_completed = M.is_completed(quest_id)
	local is_active = M.is_active(quest_id)
	local quests_ok = is_quests_ok(quest.required_quests)
	return not is_completed and not is_active and quests_ok
end


local function update_can_be_started_list()
	local quests_data = app.db.Quests.quests

	app.quests_info.can_be_started = {}
	local can_be_started = app.quests_info.can_be_started

	for quest_id, quest in pairs(quests_data) do
		if can_be_started_quest(quest_id) then
			table.insert(can_be_started, quest_id)
		end
	end
end


local function remove_from_started_list(quest_id)
	local can_be_started = app.quests_info.can_be_started

	local index = luax.table.contains(can_be_started, quest_id)
	if index then
		table.remove(can_be_started, index)
	end
end


local function on_complete_quest_update_started_list(quest_id)
	local can_be_started = app.quests_info.can_be_started
	local relative_quests = app.quests_info.quest_relative_map

	if not relative_quests[quest_id] then
		return
	end

	for i = 1, #relative_quests[quest_id] do
		local q = relative_quests[quest_id][i]
		if can_be_started_quest(q) and not luax.table.contains(can_be_started) then
			table.insert(can_be_started, q)
		end
	end
end


--- Register quest to catch events even it not started
local function register_quest(quest_id)
	local quests = app[const.EVA.QUESTS]
	local quest_data = app.db.Quests.quests[quest_id]
	if quests.current[quest_id] then
		logger:warn("Quest already started", { quest_id = quest_id })
		return
	end

	quests.current[quest_id] = proto.get("eva.QuestData")
	for i = 1, #quest_data.tasks do
		quests.current[quest_id].progress[i] = 0
	end

	events.event(const.EVENT.QUEST_REGISTER, { quest_id = quest_id })
end


local function start_quest(quest_id)
	local quest_data = app.db.Quests.quests[quest_id]
	local quests = app[const.EVA.QUESTS]
	if not quests.current[quest_id] then
		register_quest(quest_id)
	end

	quests.current[quest_id].is_active = true
	events.event(const.EVENT.QUEST_START, { quest_id = quest_id })
	if app.quests_settings.on_quest_start then
		app.quests_settings.on_quest_start(quest_id, quest_data)
	end

	remove_from_started_list(quest_id)
	if quest_data.autofinish then
		M.complete_quest(quest_id)
	end
end


local function finish_quest(quest_id)
	local quests = app[const.EVA.QUESTS]
	local quest_data = app.db.Quests.quests[quest_id]

	if not quests.current[quest_id] then
		logger:warn("No quest in current list to end it", { quest_id = quest_id })
		return
	end

	if M.is_completed(quest_id) then
		logger:warn("Quest already completed", { quest_id = quest_id })
		return
	end

	quests.current[quest_id] = nil
	if not quest_data.repeatable then
		table.insert(quests.completed, quest_id)
	end

	events.event(const.EVENT.QUEST_END, { quest_id = quest_id })
	if app.quests_settings.on_quest_completed then
		app.quests_settings.on_quest_completed(quest_id, quest_data)
	end

	on_complete_quest_update_started_list(quest_id)
	M.update_quests()
end


local function register_offline_quests()
	local quests_data = app.db.Quests.quests

	for quest_id, quest in pairs(quests_data) do
		if is_catch_offline(quest_id) then
			register_quest(quest_id)
		end
	end
end


local function update_quests_list()
	local quests_data = app.db.Quests.quests

	local current = app[const.EVA.QUESTS].current
	for quest_id, quest in pairs(current) do
		if quest.is_active and quests_data[quest_id].autofinish then
			M.complete_quest(quest_id)
		end
	end

	local can_be_started = app.quests_info.can_be_started
	for i = #can_be_started, 1, -1 do
		local quest_id = can_be_started[i]
		local quest = quests_data[quest_id]

		if quest.autostart then
			M.start_quest(quest_id)
		end
	end
end


local function apply_event(quest_id, quest, action, object, amount)
	local quest_data = app.db.Quests.quests[quest_id]
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

			if app.quests_settings.on_quest_progress then
				app.quests_settings.on_quest_progress(quest_id, quest_data)
			end

			if quest.progress[i] == task_data.required then
				events.event(const.EVENT.QUEST_TASK_COMPLETE, {
					quest_id = quest_id,
					task_index = i
				})

				if app.quests_settings.on_quest_task_completed then
					app.quests_settings.on_quest_task_completed(quest_id, quest_data)
				end
			end
		end
	end

	return is_updated
end


--- Get current progress on quest
-- @function eva.quests.get_progress
-- @tparam string quest_id Quest id
-- @treturn table List of progress of quest tasks in task order
function M.get_progress(quest_id)
	local quests = app[const.EVA.QUESTS]
	return quests.current[quest_id] and quests.current[quest_id].progress or {}
end


--- Get current active quests
-- @function eva.quests.get_current
-- @treturn table List of active quests
function M.get_current()
	return fun.filter(function(quest_id, quest)
		return quest.is_active
	end, app[const.EVA.QUESTS].current):totable()
end


--- Get completed quests list
-- @function eva.quests.get_completed
-- @treturn table List of active quests
function M.get_completed()
	return app[const.EVA.QUESTS].completed
end


--- Check quest is active
-- @function eva.quests.is_active
-- @treturn bool Quest active state
function M.is_active(quest_id)
	local quests = app[const.EVA.QUESTS]
	local quest = quests.current[quest_id]
	return quest and quest.is_active
end


--- Check quest is completed
-- @function eva.quests.is_completed
-- @treturn bool Quest completed state
function M.is_completed(quest_id)
	local quests = app[const.EVA.QUESTS]
	return luax.table.contains(quests.completed, quest_id)
end


--- Check quest is can be started now
-- @function eva.quests.is_can_start_quest
-- @treturn bool Quest is can start state
function M.is_can_start_quest(quest_id)
	local quest_data = app.db.Quests.quests[quest_id]

	local is_can_start_extra = true
	if app.quests_settings.is_can_start then
		is_can_start_extra = app.quests_settings.is_can_start(quest_id, quest_data)
	end

	return is_can_start_extra and is_available(quest_id) and not M.is_active(quest_id)
end


--- Start quest, if it can be started
-- @function eva.quests.start_quest
-- @tparam string quest_id Quest id
function M.start_quest(quest_id)
	if M.is_can_start_quest(quest_id) then
		start_quest(quest_id)
	end
end


--- Check quest is can be completed now
-- @function eva.quests.is_can_complete_quest
-- @treturn bool Quest is can complete quest state
function M.is_can_complete_quest(quest_id)
	local quest_data = app.db.Quests.quests[quest_id]

	local is_can_complete_extra = true
	if app.quests_settings.is_can_complete then
		is_can_complete_extra = app.quests_settings.is_can_complete(quest_id, quest_data)
	end

	return is_can_complete_extra and M.is_active(quest_id) and is_tasks_completed(quest_id)
end


--- Complete quest, if it can be completed
-- @function eva.quests.complete_quest
-- @tparam string quest_id Quest id
function M.complete_quest(quest_id)
	if M.is_can_complete_quest(quest_id) then
		finish_quest(quest_id)
	end
end


--- Apply quest event to all current quests
-- @function eva.quests.quest_event
-- @tparam string action Type of event
-- @tparam string object Object of event
-- @tparam number amount Amount of event
function M.quest_event(action, object, amount)
	local quests_data = app.db.Quests.quests
	local current = app[const.EVA.QUESTS].current
	local is_need_update = false

	for quest_id, quest in pairs(current) do
		local quest_data = quests_data[quest_id]

		local is_can_event = true
		if app.quests_settings.is_can_event then
			is_can_event = app.quests_settings.is_can_event(quest_id, quest_data)
		end

		if is_can_event then
			if apply_event(quest_id, quest, action, object, amount) then
				is_need_update = true
			end
		end
	end

	if is_need_update then
		M.update_quests()
	end
end


--- Start eva quests system.
-- Need to call, when game is prepared for quests
-- Call it to activate quests
-- @function eva.quests.start_quests
function M.start_quests()
	app.quests_info.is_started = true

	update_can_be_started_list()
	register_offline_quests()
	M.update_quests()
end


--- Update quests list
-- It will start and end quests, by checking quests condition
-- @function eva.quests.update_quests
function M.update_quests()
	if not app.quests_info.is_started then
		return
	end

	update_quests_list()
end


--- Add event, to trigger quest list update.
-- Example: you have a condition to start quest only if festival is enabled
-- So add event FESTIVAL_START to update quests on this update
-- @function eva.quests.add_update_quest_event
function M.add_update_quest_event(event)
	events.subscribe(event, M.update_quests)
end


--- Set game quests settings.
-- Pass settings in eva.init function
-- @function eva.quests.set_settings
function M.set_settings(quests_settings)
	app.quests_settings = quests_settings
end


function M.on_eva_init()
	app.quests_settings = {}
	app.quests_info = {
		is_started = false,
		can_be_started = {},
		quest_relative_map = make_relative_quests_map()
	}
	app[const.EVA.QUESTS] = proto.get(const.EVA.QUESTS)
	saver.add_save_part(const.EVA.QUESTS, app[const.EVA.QUESTS])
	M.add_update_quest_event(const.EVENT.TOKEN_CHANGE)
end


return M
