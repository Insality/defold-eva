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
	trucks[truck_id] = trucks[truck_id] or proto.get("eva.Truck")
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
		else
			if M.is_arrived(truck_id) then
				M.leave(truck_id)
			end
		end
	end
end


local function get_lifetime(truck_id)
	local truck_config = get_truck_config(truck_id)

	local lifetime = truck_config.lifetime
	if app.trucks_settings.get_truck_lifetime then
		lifetime = app.trucks_settings.get_truck_lifetime(truck_id, truck_config)
	end

	return lifetime
end


local function get_cooldown(truck_id)
	local truck_config = get_truck_config(truck_id)

	local cooldown = truck_config.cooldown
	if app.trucks_settings.get_truck_cooldown then
		cooldown = app.trucks_settings.get_truck_cooldown(truck_id, truck_config)
	end

	return cooldown
end


--- Check if truck is already arrived
-- @function eva.trucks.is_arrived
-- @tparam string truck_id Truck id
-- @treturn bool Is arrived now
function M.is_arrived(truck_id)
	return get_truck(truck_id).is_arrived
end


--- Get time for next truck arrive
-- @function eva.trucks.get_time_to_arrive
-- @tparam string truck_id Truck id
-- @treturn number Time in seconds
function M.get_time_to_arrive(truck_id)
	local truck = get_truck(truck_id)
	return math.max(0, truck.arrive_time - game.get_time())
end


--- Check if truck can be arrived now
-- @function eva.trucks.is_can_arrive
-- @tparam string truck_id Truck id
-- @treturn bool Is can arrive now
function M.is_can_arrive(truck_id)
	local truck_config = get_truck_config(truck_id)

	if not M.is_enabled(truck_id) then
		return false
	end

	local is_arrived = M.is_arrived(truck_id)
	local arrive_time = M.get_time_to_arrive(truck_id)

	local is_can_arrive = true
	if app.trucks_settings.is_can_arrive then
		is_can_arrive = app.trucks_settings.is_can_arrive(truck_id, truck_config)
	end

	return not is_arrived and is_can_arrive and arrive_time <= 0
end


--- Arrive truck right now, even it can't be
-- arrived now.
-- @function eva.trucks.arrive
-- @tparam string truck_id Truck id
function M.arrive(truck_id)
	local truck = get_truck(truck_id)
	local truck_config = get_truck_config(truck_id)
	truck.is_arrived = true
	truck.arrive_time = game.get_time()
	truck.leave_time = truck.arrive_time + get_lifetime(truck_id)

	if app.trucks_settings.on_truck_arrive then
		app.trucks_settings.on_truck_arrive(truck_id, truck_config)
	end
	events.event(const.EVENT.TRUCK_ARRIVE, { truck_id = truck_id })
end


--- Get time for next truck leave
-- @function eva.trucks.get_time_to_leave
-- @tparam string truck_id Truck id
-- @treturn number Time in seconds
function M.get_time_to_leave(truck_id)
	local truck = get_truck(truck_id)
	return math.max(0, truck.leave_time - game.get_time())
end


--- Check if truck can leave now
-- @function eva.trucks.is_can_leave
-- @tparam string truck_id Truck id
-- @treturn bool Is can leave now
function M.is_can_leave(truck_id)
	local truck_config = get_truck_config(truck_id)

	if not M.is_enabled(truck_id) then
		return false
	end

	local is_arrived = M.is_arrived(truck_id)
	local leave_time = M.get_time_to_leave(truck_id)

	local is_can_leave = true
	if app.trucks_settings.is_can_leave then
		is_can_leave = app.trucks_settings.is_can_leave(truck_id, truck_config)
	end

	return is_arrived and is_can_leave and leave_time <= 0
end


--- Leave truck right now, even it can
-- leave now.
-- @function eva.trucks.leave
-- @tparam string truck_id Truck id
function M.leave(truck_id)
	local truck = get_truck(truck_id)
	local truck_config = get_truck_config(truck_id)

	truck.is_arrived = false

	local time_elapsed = game.get_time() - truck.leave_time
	truck.leave_time = game.get_time()

	local cooldown = get_cooldown(truck_id)
	if time_elapsed > get_lifetime(truck_id) then
		-- Decrease leave timer on elapsed time?
		local truck_settings = app.settings.trucks
		local min_return_time = truck_settings.min_return_timer_on_long_return
		cooldown = math.max(min_return_time, cooldown - time_elapsed)
	end

	truck.arrive_time = truck.leave_time + cooldown

	if app.trucks_settings.on_truck_leave then
		app.trucks_settings.on_truck_leave(truck_id, truck_config)
	end
	events.event(const.EVENT.TRUCK_LEAVE, { truck_id = truck_id} )
end


--- Check is truck enabled now
-- @function eva.trucks.is_enabled
-- @tparam string truck_id Truck id
-- @treturn bool Is truck enabled
function M.is_enabled(truck_id)
	local truck = get_truck(truck_id)
	if not truck then
		return false
	end

	return truck.is_enabled
end


--- Set truck enabled state
-- @function eva.trucks.set_enabled
-- @tparam string truck_id Truck id
function M.set_enabled(truck_id, state)
	local truck = get_truck(truck_id)
	truck.is_enabled = state
	update_trucks()
end


--- Set trucks settings with custom callbacks.
-- See trucks_settings_example.lua
-- @function eva.trucks.set_settings
-- @tparam table trucks_settings Table with callbacks
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
