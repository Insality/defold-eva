--- Defold-eva camera module
-- Can hanlde sweet dragging, zooming with gestures
-- and correct camera soft and hard zones
-- @submodule eva

local gesture = require("in.gesture")
local camera_drag = require("eva.modules.camera.camera_drag")
local camera_gesture = require("eva.modules.camera.camera_gesture")

local M = {}

-- for now global camera state. It is baaad...
M.state = {
	cam_id = nil,

	pos = vmath.vector3(0),
	target_pos = vmath.vector3(0),
	zoom = 1,
	target_zoom = 1,

	inertion = vmath.vector3(0),
	camera_box = vmath.vector3(0),
	border_soft = vmath.vector4(0),
	border_hard = vmath.vector4(0),
	zoom_border_soft = vmath.vector3(1),
	zoom_border_hard = vmath.vector3(1),

	is_drag = false,
	is_pinch = false,

	touch_id = 0,
	drag_pos = vmath.vector3(0),
	pinch_distance = 0,
	pinch_pos = vmath.vector3(0),
}


--- Set the camera game object and size of the camera
-- @function eva.camera.set_camera
-- @tparam string cam_id url of camera game object
-- @tparam vector3 camera_box size of the camera at zoom=1
function M.set_camera(cam_id, camera_box)
	M.state.cam_id = cam_id

	M.state.pos = go.get_position(cam_id)
	M.state.target_pos = vmath.vector3(M.state.pos)

	if camera_box then
		M.state.camera_box = camera_box
	end
end


--- Set the borders of the camera zone
-- @function eva.camera.set_borders
-- @tparam vector4 border_soft. Soft zones of camera. Order is: left-top-right-bot.
-- @tparam vector4 border_hard. Hard zones of camera. Order is: left-top-right-bot.
function M.set_borders(border_soft, border_hard)
	M.state.border_soft = border_soft
	M.state.border_hard = border_hard
end


--- Set the camera game object and size of the camera
-- @function eva.camera.set_zoom_borders
-- @tparam vector3 zoom_soft Setup zoom soft values. vector3(min_value, max_value, 0)
-- @tparam vector3 zoom_hard Setup zoom hard values. vector3(min_value, max_value, 0)
function M.set_zoom_borders(zoom_soft, zoom_hard)
	M.state.zoom_border_soft = zoom_soft
	M.state.zoom_border_hard = zoom_hard
end


function M.on_input(action_id, action)
	camera_drag.handle_drag(action_id, action, M.state)
	camera_gesture.handle_gesture(action_id, action, M.state)
end


function M.before_game_start(settings)
	M.settings = settings
	camera_gesture.GESTURE = gesture.create({
		multi_touch = settings.multi_touch
	})
	camera_drag.IS_MOBILE = M._eva.device.is_mobile()
end


function M.on_game_update(dt)
	camera_drag.update_camera_pos(M.state, dt, M.settings)
	camera_gesture.update_camera_zoom(M.state, dt, M.settings)
end


return M
