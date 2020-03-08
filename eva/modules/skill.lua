--- Eva skill module.
-- Have logic to proceed skills, their cooldown, usage
-- and other settings
-- @submodule eva

local app = require("eva.app")
local const = require("eva.const")

local db = require("eva.modules.db")
local game = require("eva.modules.game")
local proto = require("eva.modules.proto")
local saver = require("eva.modules.saver")
local events = require("eva.modules.events")

local M = {}


local function get_skill_config(skill_id)
	return db.get(app.settings.skill.config).skills[skill_id]
end


local function get_containers()
	return app[const.EVA.SKILL_CONTAINERS].containers
end

--- @treturn eva.Skills
local function get_container(container_id)
	local container = get_containers()
	container[container_id] = container[container_id] or proto.get(const.EVA.SKILLS)
	return container[container_id]
end


--- @treturn eva.Skill
local function get_skill_data(container_id, skill_id)
	local container = get_container(container_id).skill_data

	if not container[skill_id] then
		local skill_info = get_skill_config(skill_id)
		container[skill_id] = proto.get(const.EVA.SKILL)
		container[skill_id].stacks = skill_info.max_stack
	end

	return container[skill_id]
end


local function update_skill(container_id, skill_id, current_time)
	current_time = current_time or game.get_time()
	local skill_data = get_skill_data(container_id, skill_id)
	local skill_info = get_skill_config(skill_id)

	if skill_data.stacks < skill_info.max_stack then
		local next_restore_time = skill_data.last_restore_time + skill_info.cooldown
		if next_restore_time <= current_time then
			skill_data.stacks = math.min(skill_data.stacks + skill_info.restore_amount, skill_info.max_stack)
			skill_data.last_restore_time = next_restore_time

			events.event(const.EVENT.SKILL_COOLDOWN_END, {
				container_id = container_id,
				skill_id = skill_id
			})

			if skill_data.stacks < skill_info.max_stack then
				events.event(const.EVENT.SKILL_COOLDOWN_START, {
					container_id = container_id,
					skill_id = skill_id
				})
			end

			-- Restore next, if cooldown was big
			update_skill(container_id, skill_id, current_time)
		end
	end
end

function M.use(container_id, skill_id)
	if not M.is_can_use(container_id, skill_id) then
		-- TODO: error
		print("CANT USE SKILL")
		return false
	end

	local skill_data = get_skill_data(container_id, skill_id)

	if M.is_full_stack(container_id, skill_id) then
		skill_data.last_restore_time = game.get_time()
		events.event(const.EVENT.SKILL_COOLDOWN_START, {
			container_id = container_id,
			skill_id = skill_id
		})
	end

	skill_data.stacks = skill_data.stacks - 1
	skill_data.last_use_time = game.get_time()

	events.event(const.EVENT.SKILL_USE, {
		container_id = container_id,
		skill_id = skill_id
	})
end


--- End use of channeling spell or end effect of skill
-- with duration
function M.end_use(container_id, skill_id)
	local skill_data = get_skill_data(container_id, skill_id)

	events.event(const.EVENT.SKILL_USE_END, {
		container_id = container_id,
		skill_id = skill_id
	})
end


function M.skip_cooldown_time()

end


--- Time between use and end_use
function M.is_active(container_id, skill_id)
	return false
end


function M.is_on_cooldown(container_id, skill_id)
	return not M.is_full_stack(container_id, skill_id)
end


function M.get_cooldown_time(skill_id)
	return get_skill_config(skill_id).cooldown
end


function M.get_cooldown_time_left(container_id, skill_id)
	local skill_data = get_skill_data(container_id, skill_id)
	if M.is_full_stack(container_id, skill_id) then
		return 0
	else
		local restore_time = skill_data.last_restore_time + M.get_cooldown_time(skill_id)
		return math.max(restore_time - game.get_time(), 0)
	end
end


function M.get_cooldown_progress(container_id, skill_id)
	return 1 - (M.get_cooldown_time_left(container_id, skill_id) / M.get_cooldown_time(skill_id))
end


function M.get_stack_amount(container_id, skill_id)
	return get_skill_data(container_id, skill_id).stacks
end


function M.add_stack(container_id, skill_id, amount)
	local skill_data = get_skill_data(container_id, skill_id)
	local skill_info = get_skill_config(skill_id)
	skill_data.stacks = math.min(skill_data.stacks + amount, skill_info.max_stack)
end


function M.is_full_stack(container_id, skill_id)
	local skill_info = get_skill_config(skill_id)
	return M.get_stack_amount(container_id, skill_id) == skill_info.max_stack
end


function M.is_empty_stack(container_id, skill_id)
	return M.get_stack_amount(container_id, skill_id) == 0
end


function M.is_can_use(container_id, skill_id)
	return M.get_stack_amount(container_id, skill_id) > 0
end


function M.restore_all(container_id)
	local container = get_container(container_id)
	for skill_id, skill_data in pairs(container.skill_data) do
		local skill_info = get_skill_config(skill_id)
		M.add_stack(container_id, skill_id, skill_info.max_stack)
	end
end


function M.on_eva_init()
	app[const.EVA.SKILL_CONTAINERS] = proto.get(const.EVA.SKILL_CONTAINERS)
	saver.add_save_part(const.EVA.SKILL_CONTAINERS, app[const.EVA.SKILL_CONTAINERS])
	db.check_config(app.settings.skill.config, "evadata.Skills")
end


function M.on_eva_update(dt, current_time)
	local containers = get_containers()

	for container_id, container in pairs(containers) do
		for skill_id, skill_data in pairs(container.skill_data) do
			update_skill(container_id, skill_id, current_time)
		end
	end
end

return M
