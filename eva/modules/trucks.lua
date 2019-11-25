--- Eva truck module.
-- Implement behaviour on periodic events like
-- food truck or periodic merchants.
-- It has limited enabled time, some cooldown time
-- and special logic to time, when player is offline.
-- It is always appear on long user non-played time,
-- Can be speed up, can have some rewards and progress
-- Ability to custom life and leave time via custom settings
-- @submodule eva


local app = require("eva.app")
local const = require("eva.const")

local game = require("eva.modules.game")
local saver = require("eva.modules.saver")
local proto = require("eva.modules.proto")
local events = require("eva.modules.events")

local M = {}


local function get_truck(truck_id)
	local trucks = app[const.EVA.TRUCKS].trucks
	return trucks[truck_id]
end


local function get_truck_config(truck_id)
	return app.db.Trucks.trucks[truck_id]
end


local function update_trucks()
	local trucks = app.db.Trucks.trucks
	for truck_id, truck_config in pairs(trucks) do
		if M.is_enabled(truck_id) then
			if truck_config.autoarrive and M.is_can_arrive(truck_id) then
				M.arrive(truck_id)
			end
			if truck_config.autoleave and M.is_can_leave(truck_id) then
				M.leave(truck_id)
			end
		end
	end
end


function M.is_arrived(truck_id)
	return not get_truck(truck_id).is_cooldown
end


function M.get_time_to_arrive(truck_id)
	local truck = get_truck(truck_id)
	local truck_config = get_truck_config(truck_id)

	local cooldown = truck_config.cooldown
	if app.trucks_settings.get_truck_cooldown then
		cooldown = app.trucks_settings.get_truck_cooldown(truck_id, truck_config)
	end

	return game.get_time() - (truck.leave_time + cooldown)
end


function M.is_can_arrive(truck_id)
	local truck_config = get_truck_config(truck_id)

	local is_arrived = M.is_arrived(truck_id)
	local arrive_time = M.get_time_to_arrive(truck_id)

	local is_can_arrive = true
	if app.trucks_settings.on_truck_arrive then
		is_can_arrive = app.trucks_settings.is_can_arrive(truck_id, truck_config)
	end

	return not is_arrived and is_can_arrive and arrive_time <= 0
end


function M.arrive(truck_id)
	local truck = get_truck(truck_id)
	local truck_config = get_truck_config(truck_id)
	truck.is_cooldown = false
	truck.appear_time = game.get_time()

	if app.trucks_settings.on_truck_arrive then
		app.trucks_settings.on_truck_arrive(truck_id, truck_config)
	end
	events.event(const.EVENT.TRUCK_ARRIVE, { truck_id = truck_id })
end


function M.get_time_to_leave(truck_id)
	local truck = get_truck(truck_id)
	local truck_config = get_truck_config(truck_id)

	local lifetime = truck_config.lifetime
	if app.trucks_settings.get_truck_lifetime then
		lifetime = app.trucks_settings.get_truck_lifetime(truck_id, truck_config)
	end

	return game.get_time() - (truck.arrive_time + lifetime)
end


function M.is_can_leave(truck_id)
	local truck_config = get_truck_config(truck_id)

	local is_arrived = M.is_arrived(truck_id)
	local leave_time = M.get_time_to_leave(truck_id)

	local is_can_leave = true
	if app.trucks_settings.on_truck_arrive then
		is_can_leave = app.trucks_settings.is_can_leave(truck_id, truck_config)
	end

	return is_arrived and is_can_leave and leave_time <= 0
end


function M.leave(truck_id)
	local truck = get_truck(truck_id)
	local truck_config = get_truck_config(truck_id)
	truck.is_cooldown = true
	truck.leave_time = game.get_time()

	if app.trucks_settings.on_truck_arrive then
		app.trucks_settings.on_truck_arrive(truck_id, truck_config)
	end
	events.event(const.EVENT.TRUCK_LEAVE, { truck_id = truck_id} )
end


function M.set_enabled(truck_id, state)
	local truck = get_truck(truck_id)
	truck.is_enabled = state
end


function M.is_enabled(truck_id, state)
	local truck = get_truck(truck_id)
	if not truck then
		return false
	end

	return truck.is_enabled
end


function M.set_settings(trucks_settings)
	app.trucks_settings = trucks_settings
end


function M.on_eva_init()
	app.trucks_settings = {}
	app[const.EVA.TRUCKS] = proto.get(const.EVA.TRUCKS)
	saver.add_save_part(const.EVA.TRUCKS, app[const.EVA.TRUCKS])
end


function M.on_eva_second()
	update_trucks()
end


return M
