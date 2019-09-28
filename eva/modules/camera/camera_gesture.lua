local luax = require("eva.luax")
local const = require("eva.const")
local rendercam = require("rendercam.rendercam")

local M = {}
M.GESTURE = nil

M.ZOOM_SPEED = 0.85
M.CENTER = vmath.vector3(450, 800, 0)


local function get_distance(action)
	if not action.touch then
		return 0
	end

	local t1 = action.touch[1]
	local t2 = action.touch[2]

	return luax.math.distance(t1.screen_x, t1.screen_y, t2.screen_x, t2.screen_y)
end

local function handle_pinch(data, state, action)
	if not state.is_pinch then
		print("Start pinch")
		state.is_pinch = true
		state.pinch_distance = data.dist
	end

	local delta = (data.dist - state.pinch_distance) / (1000 * M.ZOOM_SPEED)
	local delta_koef = math.sqrt(state.target_zoom)

	state.target_zoom = state.target_zoom - delta * delta_koef
	state.pinch_distance = data.dist

	-- local mv = vmath.vector3(data.center.x - M.CENTER.x, data.center.y - M.CENTER.y, 0)
	-- local dz = state.zoom - old_zoom
	-- local v = mv * dz
	-- rendercam.pan(-v.x, -v.y)
end


function M.handle_gesture(action_id, action, state)
	local g = M.GESTURE.on_input(action_id, action)

	if g then
		if g.two_finger then
			if g.two_finger.pinch then
				g.two_finger.pinch.dist = get_distance(action)
				handle_pinch(g.two_finger.pinch, state)
			end
		end
	end

	if action.touch and state.is_pinch then
		local no_touch = #action.touch ~= 2

		local all_released = true
		for i = 1, #action.touch do
			if not action.touch[i].released then
				all_released = false
			end
		end

		if no_touch or all_released then
			print("End pinch")
			state.is_pinch = false
		end
	end
end


function M.update_camera_zoom(state, dt, params)
	local soft = state.zoom_border_soft
	local hard = state.zoom_border_hard

	-- Soft border
	if not state.is_pinch then
		if state.target_zoom < soft.x then
			state.target_zoom = luax.math.lerp(state.target_zoom, soft.x, params.zoom_border_lerp_speed)
		end
		if state.target_zoom > soft.y then
			state.target_zoom = luax.math.lerp(state.target_zoom, soft.y, params.zoom_border_lerp_speed)
		end
	end

	-- Hard border
	state.target_zoom = luax.math.clamp(state.target_zoom, hard.x, hard.y)

	-- Lerp zoom
	local zoom_lerp_speed = params.zoom_lerp_speed * const.FPS * dt
	state.zoom = luax.math.lerp(state.zoom, state.target_zoom, zoom_lerp_speed)

	rendercam.set_ortho_scale(state.zoom, state.cam_id)
end


return M
