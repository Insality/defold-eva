--- Eva camera module
-- Can hanlde sweet dragging, zooming with gestures
-- and correct camera soft and hard zones
-- @submodule eva


local app = require("eva.app")
local const = require("eva.const")
local camera_drag = require("eva.modules.camera.camera_drag")
local camera_pinch = require("eva.modules.camera.camera_pinch")

local input = require("eva.modules.input")

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


local function on_input(_, input_type, input_state)
	if input_type == const.INPUT_TYPE.DRAG then
		camera_drag.handle_drag(input_type, input_state)
	end
	if input_type == const.INPUT_TYPE.PINCH then
		camera_drag.handle_drag(input_type, input_state)
		camera_pinch.handle_pinch(input_type, input_state)
	end

	local camera_state = app.camera_state
	if input_type == const.INPUT_TYPE.KEY_RELEASED or input_type == const.INPUT_TYPE.KEY_REPEATED then
		if input_state.key_id == const.INPUT.SCROLL_UP then
			camera_state.target_zoom = camera_state.target_zoom - 0.025
		end
		if input_state.key_id == const.INPUT.SCROLL_DOWN then
			camera_state.target_zoom = camera_state.target_zoom + 0.025
		end
	end
end


function M.before_eva_init()
	app.camera_state = get_initial_state()
end


function M.after_eva_init()
	local settings = app.settings.camera
	input.register(nil, "eva.camera", on_input, settings.input_priority)
end


function M.on_eva_update(dt)
	local state = app.camera_state
	local settings = app.settings.camera

	camera_drag.update_camera_pos(state, dt, settings)
	camera_pinch.update_camera_zoom(state, dt, settings)
end


return M
