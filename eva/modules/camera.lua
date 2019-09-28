--- Defold-eva camera module
local luax = require("eva.luax")
local const = require("eva.const")
local gesture = require("in.gesture")
local rendercam = require("rendercam.rendercam")

local MULTITOUCH = hash("touch_multi")
local TOUCH = hash("touch")

local params = {
	zoom_speed = 0.65,
	move_lerp_speed = 0.7,
	border_lerp_speed = 0.08,
	center = vmath.vector3(450, 800, 0),
	friction = 0.90,
	friction_hold = 0.65,
	inertion_koef = 0.35,
}

local M = {}
M.ZOOM_SPEED = 0.65
M.CENTER = vmath.vector3(450, 800, 0)

M.state = {
	cam_id = nil,
	pos = vmath.vector3(0, 0, 0),
	target_pos = vmath.vector3(0, 0, 0),
	zoom = 1,
	target_zoom = 1,

	inertion = vmath.vector3(0),

	border_soft = vmath.vector4(0),
	border_hard = vmath.vector4(0),
	zoom_border_soft = vmath.vector3(0.1, 1.25, 0),
	zoom_border_hard = vmath.vector3(0.05, 1.5, 0),

	is_drag = false,
	drag_info = {
		x = 0,
		y = 0,
	},
	touch_id = 0,

	is_pinch = false,
	pinch_zoom_start = 1,
}

local function handle_pinch(data)
	if not M.state.is_pinch then
		M.state.pinch_zoom_start = data.ratio
		M.state.zoom = rendercam.get_ortho_scale(M.state.cam_id)
		M.state.is_pinch = true
	end

	local old_zoom = M.state.zoom
	M.state.zoom = M.state.zoom - (data.ratio - M.state.pinch_zoom_start) * M.ZOOM_SPEED
	M.state.zoom = luax.math.clamp(M.state.zoom, 0.06, 1.25)
	rendercam.set_ortho_scale(M.state.zoom, M.state.cam_id)
	M.state.pinch_zoom_start = data.ratio

	local mv = vmath.vector3(data.center.x - M.CENTER.x, data.center.y - M.CENTER.y, 0)
	local dz = M.state.zoom - old_zoom
	local v = mv * dz
	rendercam.pan(-v.x, -v.y)
end


--- Can be nil to default camera
function M.set_camera(cam_id)
	M.state.cam_id = cam_id
	M.state.pos = go.get_position(cam_id)
	M.state.target_pos = vmath.vector3(M.state.pos)
end


function M.set_borders(border_soft, border_hard)
	M.state.border_soft = border_soft
	M.state.border_hard = border_hard
end


function M.set_zoom_borders(zoom_soft, zoom_hard)
	M.state.zoom_border_soft = zoom_soft
	M.state.zoom_border_hard = zoom_hard
end


local function handle_gesture(action_id, action, state)
	local g = M.gesture.on_input(action_id, action)

	if g then
		if g.two_finger then
			if g.two_finger.pinch then
				-- handle_pinch(g.two_finger.pinch)
			end
		end
	end

	if action.touch and #action.touch ~= 2 then
		M.state.is_pinch = false
	end
end


local function find_touch(action_id, action, touch_id)
	local act = TOUCH
	if M._eva.device.is_mobile() then
		act = MULTITOUCH
	end

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


local function start_drag(state, touch)
	state.is_drag = true
	state.drag_info.x = touch.screen_x
	state.drag_info.y = touch.screen_y
end


local function end_drag(state)
	state.is_drag = false
	state.touch_id = 0
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


local function handle_drag(action_id, action, state)
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
		else
			-- PC
			end_drag(state)
		end
	end

	if state.is_drag then
		local dx = touch.screen_x - state.drag_info.x
		local dy = touch.screen_y - state.drag_info.y

		local x, y = rendercam.screen_to_world_2d(dx, dy, true, nil, true)
		state.target_pos.x = state.target_pos.x - x
		state.target_pos.y = state.target_pos.y - y

		state.inertion.x = state.inertion.x - x
		state.inertion.y = state.inertion.y - y

		state.drag_info.x = touch.screen_x
		state.drag_info.y = touch.screen_y
	end
end


function M.on_input(action_id, action)
	handle_gesture(action_id, action, M.state)
	handle_drag(action_id, action, M.state)
end


function M.before_game_start(settings)
	M.gesture = gesture.create({
		multi_touch = settings.multi_touch
	})
end


local function update_camera_pos(state, dt)
	if not state.cam_id then
		return
	end

	local pos = state.pos
	local target = state.target_pos
	local border_soft = state.border_soft
	local border_lerp = params.border_lerp_speed * const.FPS * dt

	if not state.is_drag then
		if target.x < border_soft.x then
			target.x = luax.math.lerp(target.x, border_soft.x, border_lerp)
		end
		if target.x > border_soft.z then
			target.x = luax.math.lerp(target.x, border_soft.z, border_lerp)
		end
		if target.y < border_soft.y then
			target.y = luax.math.lerp(target.y, border_soft.y, border_lerp)
		end
		if target.y > border_soft.w then
			target.y = luax.math.lerp(target.y, border_soft.w, border_lerp)
		end
	end

	if state.is_drag then
		state.inertion = state.inertion * params.friction_hold
	else
		state.inertion = state.inertion * params.friction
	end

	if not state.is_drag then
		target.x = target.x + state.inertion.x * const.FPS * dt * params.inertion_koef
		target.y = target.y + state.inertion.y * const.FPS * dt * params.inertion_koef
	end

	state.target_pos.x = luax.math.clamp(state.target_pos.x, state.border_hard.x, state.border_hard.z)
	state.target_pos.y = luax.math.clamp(state.target_pos.y, state.border_hard.y, state.border_hard.w)

	pos.x = luax.math.lerp(pos.x, target.x, params.move_lerp_speed * const.FPS * dt)
	pos.y = luax.math.lerp(pos.y, target.y, params.move_lerp_speed * const.FPS * dt)
	go.set_position(state.pos, state.cam_id)
end


function M.on_game_update(dt)
	update_camera_pos(M.state, dt)
end


return M
