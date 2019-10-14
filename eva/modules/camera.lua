--- Eva camera module
-- Can hanlde sweet dragging, zooming with gestures
-- and correct camera soft and hard zones
-- @submodule eva


local app = require("eva.app")
local gesture = require("in.gesture")
local camera_drag = require("eva.modules.camera.camera_drag")
local camera_gesture = require("eva.modules.camera.camera_gesture")

local device = require("eva.modules.device")


local M = {}


local function get_initial_state()
	return {
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
end


--- Set the camera game object and size of the camera
-- @function eva.camera.set_camera
-- @tparam string cam_id url of camera game object
-- @tparam vector3 camera_box size of the camera at zoom=1
function M.set_camera(cam_id, camera_box)
	local state = app.camera_state

	state.cam_id = cam_id

	state.pos = go.get_position(cam_id)
	state.target_pos = vmath.vector3(state.pos)

	if camera_box then
		state.camera_box = camera_box
	end
end


--- Set the borders of the camera zone
-- @function eva.camera.set_borders
-- @tparam vector4 border_soft Soft zones of camera. Order is: left-top-right-bot.
-- @tparam vector4 border_hard Hard zones of camera. Order is: left-top-right-bot.
function M.set_borders(border_soft, border_hard)
	local state = app.camera_state

	state.border_soft = border_soft
	state.border_hard = border_hard
end


--- Set the camera position
-- @function eva.camera.set_position
-- @tparam number x X position
-- @tparam number y Y position
function M.set_position(x, y)
	local state = app.camera_state
	local pos = vmath.vector3(x, y, 0)
	go.set_position(pos,state.cam_id)

	state.pos = pos
	state.target_pos = vmath.vector3(state.pos)
end


--- Set the camera game object and size of the camera
-- @function eva.camera.set_zoom_borders
-- @tparam vector3 zoom_soft Setup zoom soft values. vector3(min_value, max_value, 0)
-- @tparam vector3 zoom_hard Setup zoom hard values. vector3(min_value, max_value, 0)
function M.set_zoom_borders(zoom_soft, zoom_hard)
	local state = app.camera_state

	state.zoom_border_soft = zoom_soft
	state.zoom_border_hard = zoom_hard
end


function M.on_input(action_id, action)
	local state = app.camera_state

	camera_drag.handle_drag(action_id, action, state)
	camera_gesture.handle_gesture(action_id, action, state)
end


function M.before_eva_init()
	app.camera_state = get_initial_state()

	local settings = app.settings.camera
	camera_gesture.GESTURE = gesture.create({
		multi_touch = settings.multi_touch
	})
	camera_drag.IS_MOBILE = device.is_mobile()
end


function M.on_eva_update(dt)
	local state = app.camera_state
	local settings = app.settings.camera

	camera_drag.update_camera_pos(state, dt, settings)
	camera_gesture.update_camera_zoom(state, dt, settings)
end


return M
