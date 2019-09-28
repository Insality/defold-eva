--- Defold-eva camera module
local luax = require("eva.luax")
local gesture = require("in.gesture")
local camera_drag = require("eva.modules.camera.camera_drag")
local rendercam = require("rendercam.rendercam")

local params = {
	move_lerp_speed = 0.75,
	border_lerp_speed = 0.09,
	friction = 0.88,
	friction_hold = 0.68,
	inertion_koef = 0.33,
}

local M = {}
M.ZOOM_SPEED = 0.65
M.CENTER = vmath.vector3(450, 800, 0)

M.state = {
	cam_id = nil,
	pos = vmath.vector3(0),
	target_pos = vmath.vector3(0),
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


function M.on_input(action_id, action)
	camera_drag.handle_drag(action_id, action, M.state)
	handle_gesture(action_id, action, M.state)
end


function M.before_game_start(settings)
	M.gesture = gesture.create({
		multi_touch = settings.multi_touch
	})
	camera_drag.IS_MOBILE = M._eva.device.is_mobile()
end


function M.on_game_update(dt)
	camera_drag.update_camera_pos(M.state, dt, params)
end


return M
