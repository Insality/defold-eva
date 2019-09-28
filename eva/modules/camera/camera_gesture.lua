local luax = require("eva.luax")
local const = require("eva.const")
local rendercam = require("rendercam.rendercam")

local M = {}
M.GESTURE = nil

M.ZOOM_SPEED = 0.85
M.CENTER = vmath.vector3(sys.get_config("display.width")/2, sys.get_config("display.height")/2, 0)

local function get_distance(action)
	if not action.touch then
		return 0
	end

	local t1 = action.touch[1]
	local t2 = action.touch[2]

	return luax.math.distance(t1.screen_x, t1.screen_y, t2.screen_x, t2.screen_y)
end

local function handle_pinch(data, state, action)
	-- Zooming start
	if not state.is_pinch then
		state.is_pinch = true
		state.pinch_distance = data.dist
		state.center = data.center
	end

	-- Pinch delta
	local delta = (data.dist - state.pinch_distance) / (1000 * M.ZOOM_SPEED)
	local delta_koef = math.sqrt(state.target_zoom)
	delta = delta * delta_koef

	-- Adjust zoom
	state.target_zoom = state.target_zoom - delta
	state.pinch_distance = data.dist

	-- Move to zoom position
	local move_vector = vmath.vector3(data.center.x - M.CENTER.x, data.center.y - M.CENTER.y, 0)
	state.target_pos.x = state.target_pos.x + move_vector.x * delta
	state.target_pos.y = state.target_pos.y + move_vector.y * delta

	-- Move by center
	state.target_pos.x = state.target_pos.x + (state.center.x - data.center.x) * state.zoom
	state.target_pos.y = state.target_pos.y + (state.center.y - data.center.y) * state.zoom
	state.center = data.center
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
