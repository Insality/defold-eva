local luax = require("eva.luax")
local const = require("eva.const")
local rendercam = require("rendercam.rendercam")

local M = {}
M.IS_MOBILE = false

local function start_drag(state, touch)
	state.is_drag = true
	state.drag_pos.x = touch.screen_x
	state.drag_pos.y = touch.screen_y
end


local function end_drag(state)
	state.is_drag = false
	state.touch_id = 0
end


local function find_touch(action_id, action, touch_id)
	local act = M.IS_MOBILE and const.INPUT.MULTITOUCH or const.INPUT.TOUCH

	if action_id ~= act then
		return
	end

	if action.touch then
		local touch = action.touch
		for i = 1, #touch do
			if touch[i].id == touch_id then
				return touch[i]
			end
		end
		return touch[1]
	else
		return action
	end
end



local function on_touch_release(action_id, action, state)
	if #action.touch >= 2 then
		-- Find next unpressed
		local next_touch
		for i = 1, #action.touch do
			if not action.touch[i].released then
				next_touch = action.touch[i]
				break
			end
		end

		if next_touch then
			start_drag(state, next_touch)
			state.touch_id = next_touch.id
		else
			end_drag(state)
		end

		return next_touch
	elseif #action.touch == 1 then
		end_drag(state)
	end
end


function M.handle_drag(action_id, action, state)
	local touch = find_touch(action_id, action, state.touch_id)
	if not touch then
		return
	end

	if touch.id then
		state.touch_id = touch.id
	end

	if touch.pressed and not state.is_drag then
		start_drag(state, touch)
	end

	if touch.released and state.is_drag then
		if action.touch then
			-- Mobile
			touch = on_touch_release(action_id, action, state)

			if not touch then
				end_drag(state)
				return
			end
		else
			-- PC
			end_drag(state)
		end
	end

	if state.is_drag and not state.is_pinch then
		local dx = touch.screen_x - state.drag_pos.x
		local dy = touch.screen_y - state.drag_pos.y

		local x, y = rendercam.screen_to_world_2d(dx, dy, true, nil, true)
		state.target_pos.x = state.target_pos.x - x
		state.target_pos.y = state.target_pos.y - y

		state.inertion.x = state.inertion.x - x
		state.inertion.y = state.inertion.y - y

		state.drag_pos.x = touch.screen_x
		state.drag_pos.y = touch.screen_y
	end

	if state.is_pinch then
		state.drag_pos.x = touch.screen_x
		state.drag_pos.y = touch.screen_y
	end
end


function M.update_camera_pos(state, dt, params)
	if not state.cam_id then
		return
	end

	local pos = state.pos
	local target = state.target_pos
	local border_soft = state.border_soft
	local border_lerp = params.move_border_lerp_speed * const.FPS * dt

	-- Soft border
	if not state.is_drag then
		luax.math.lerp_box(target, border_soft, border_lerp, state.camera_box * state.zoom, true)
	end

	-- Inertion friction
	local friction_koef = state.is_drag and params.friction_hold or params.friction
	state.inertion = state.inertion * friction_koef

	-- Inertion apply
	if not state.is_drag then
		local inertion_koef = const.FPS * dt * params.inertion_koef
		target.x = target.x + state.inertion.x * inertion_koef
		target.y = target.y + state.inertion.y * inertion_koef
	end

	-- Hard border
	luax.math.clamp_box(target, state.border_hard, state.camera_box * state.zoom, true)

	-- Lerp position
	pos.x = luax.math.lerp(pos.x, target.x, params.move_lerp_speed * const.FPS * dt)
	pos.y = luax.math.lerp(pos.y, target.y, params.move_lerp_speed * const.FPS * dt)

	go.set_position(state.pos, state.cam_id)
end


return M
