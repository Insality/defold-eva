--- Defold-eva camera module
local gesture = require("in.gesture")
local camera_drag = require("eva.modules.camera.camera_drag")
local camera_gesture = require("eva.modules.camera.camera_gesture")

local params = {
	move_lerp_speed = 0.75,
	border_lerp_speed = 0.09,
	zoom_lerp_speed = 0.5,
	zoom_border_lerp_speed = 0.06,
	friction = 0.88,
	friction_hold = 0.68,
	inertion_koef = 0.33,
}

local M = {}

M.state = {
	cam_id = nil,
	pos = vmath.vector3(0),
	target_pos = vmath.vector3(0),
	zoom = 1,
	target_zoom = 1,

	inertion = vmath.vector3(0),
	border_soft = vmath.vector4(0),
	border_hard = vmath.vector4(0),
	-- zoom_border_soft = vmath.vector3(0.15, 0.65, 0),
	-- zoom_border_hard = vmath.vector3(0.1, 0.7, 0),
	zoom_border_soft = vmath.vector3(0.05, 2, 0),
	zoom_border_hard = vmath.vector3(0, 2.5, 0),

	is_drag = false,
	drag_info = {
		x = 0,
		y = 0,
	},
	touch_id = 0,

	is_pinch = false,
	pinch_zoom_start = 1,
}


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


function M.on_input(action_id, action)
	-- camera_drag.handle_drag(action_id, action, M.state)
	camera_gesture.handle_gesture(action_id, action, M.state)
end


function M.before_game_start(settings)
	camera_gesture.GESTURE = gesture.create({
		multi_touch = settings.multi_touch
	})
	camera_drag.IS_MOBILE = M._eva.device.is_mobile()
end


function M.on_game_update(dt)
	camera_drag.update_camera_pos(M.state, dt, params)
	camera_gesture.update_camera_zoom(M.state, dt, params)
end


return M
