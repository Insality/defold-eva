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
-- Started
-- Can finish
-- Finished


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


local function update_quests_callback()
	if not app.quests_info.is_started then
		return
	end

	M.update_quests()
end


local function is_tokens_ok(tokens_list)
	return tokens.is_enough(tokens_list)
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

	M.update_quests()
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

	if quest_data.autofinish then
		-- It will check before complete quests
		M.complete_quest(quest_id)
	end
end


local function update_quests_list()
	local quests_data = app.db.Quests.quests
	local quests = app[const.EVA.QUESTS]

	-- TODO: Optimize
	-- TODO: Check complete only on started quests
	-- TODO: Check start quests only what can be started (Make separate list)
	for quest_id, quest in pairs(quests_data) do
		-- Complete quests
		if quest.autofinish then
			M.complete_quest(quest_id)
		end

		-- Register quests
		if not quests.current[quest_id] then
			if is_catch_offline(quest_id) then
				register_quest(quest_id)
			end
		end

		-- Start autoquests
		if quest.autostart then
			M.start_quest(quest_id)
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


function M.get_progress(quest_id)
	local quests = app[const.EVA.QUESTS]
	return quests.current[quest_id] and quests.current[quest_id].progress or {}
end


function M.get_current()
	return fun.filter(function(quest_id, quest)
		return quest.is_active
	end, app[const.EVA.QUESTS].current):totable()
end


function M.get_completed()
	return app[const.EVA.QUESTS].completed
end


function M.is_active(quest_id)
	local quests = app[const.EVA.QUESTS]
	local quest = quests.current[quest_id]
	return quest and quest.is_active
end


function M.is_completed(quest_id)
	local quests = app[const.EVA.QUESTS]
	return luax.table.contains(quests.completed, quest_id)
end


function M.is_can_start_quest(quest_id)
	local quest_data = app.db.Quests.quests[quest_id]

	local is_can_start_extra = true
	if app.quests_settings.is_can_start then
		is_can_start_extra = app.quests_settings.is_can_start(quest_id, quest_data)
	end

	return is_can_start_extra and is_available(quest_id) and not M.is_active(quest_id)
end


function M.start_quest(quest_id)
	if M.is_can_start_quest(quest_id) then
		start_quest(quest_id)
	end
end


function M.is_can_complete_quest(quest_id)
	local quest_data = app.db.Quests.quests[quest_id]

	local is_can_complete_extra = true
	if app.quests_settings.is_can_complete then
		is_can_complete_extra = app.quests_settings.is_can_complete(quest_id, quest_data)
	end

	return is_can_complete_extra and M.is_active(quest_id) and is_tasks_completed(quest_id)
end


function M.complete_quest(quest_id)
	if M.is_can_complete_quest(quest_id) then
		finish_quest(quest_id)
	end
end


function M.quest_event(action, object, amount)
	local current = app[const.EVA.QUESTS].current
	local is_need_update = false

	for quest_id, quest in pairs(current) do
		local quest_data = app.db.Quests.quests[quest_id]

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


--- Start eva quests system
-- Call it to activate quests. If you has the quest custom settings
-- you should pass it in eva.init settings
-- @function eva.quests.start_quests
function M.start_quests()
	app.quests_info.is_started = true
	M.update_quests()
end


--- Update quests list
-- It will start and end quests, by checking quests condition
-- @function eva.quests.update_quests
function M.update_quests()
	update_quests_list()
end


--- Add event, to trigger quest list update
-- Example: you have a condition to start quest only if festival is enabled
-- So add event FESTIVAL_START to update quests on this update
-- @function eva.quests.add_update_quest_event
function M.add_update_quest_event(event)
	events.subscribe(event, update_quests_callback)
end


--- Set game quests settings. Setup settings before
-- call eva.quest.start_quests
-- @function eva.quests.set_settings
function M.set_settings(quests_settings)
	app.quests_settings = quests_settings
end


function M.on_eva_init()
	app.quests_settings = {}
	app.quests_info = {
		is_started = false
	}
	app[const.EVA.QUESTS] = proto.get(const.EVA.QUESTS)
	saver.add_save_part(const.EVA.QUESTS, app[const.EVA.QUESTS])
	M.add_update_quest_event(const.EVENT.TOKEN_CHANGE)
end


return M
