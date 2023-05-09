--- Eva camera module
-- Can hanlde sweet dragging, zooming with gestures
-- and correct camera soft and hard zones
-- @submodule eva


local app = require("eva.app")
local luax = require("eva.luax")
local const = require("eva.const")
local tweener = require("eva.libs.tweener")
local rendercam = require("rendercam.rendercam")

local input = require("eva.modules.input")
local camera_drag = require("eva.modules.camera.camera_drag")
local camera_pinch = require("eva.modules.camera.camera_pinch")

local M = {}


local function get_initial_state()
	return {
		cam_id = nil,
		is_animate = false,
		is_animate_zoom = false,
		is_control = true,
		is_borders_enabled = true,

		pos = vmath.vector3(0),
		target_pos = vmath.vector3(0),
		zoom = 1,
		target_zoom = 1,

		inertion = vmath.vector3(0),
		camera_box = vmath.vector3(0),
		border_soft = nil, --vector4
		border_hard = nil, --vector4
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


--- Enable or disable camera user control
-- @function eva.camera.set_control
-- @tparam boolean enabled state
function M.set_control(is_enabled)
	local state = app.camera_state
	state.is_control = is_enabled
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


function M.set_borders_enabled(is_borders_enabled)
	local state = app.camera_state
	state.is_borders_enabled = is_borders_enabled
end


function M.shake(power, time)
	rendercam.shake(power, time)
end


--- Set the camera position
-- @function eva.camera.set_position
-- @tparam number x X position
-- @tparam number y Y position
function M.set_position(x, y)
	local state = app.camera_state
	local pos = vmath.vector3(x, y, 0)
	go.set_position(pos, state.cam_id)

	state.pos = pos
	state.target_pos = vmath.vector3(state.pos)
end


--- Get the camera position
-- @function eva.camera.get_position
-- @treturn number x X position
-- @treturn number y Y position
function M.get_position()
	local state = app.camera_state
	return state.pos.x, state.pos.y
end


--- Set target camera position
-- @function eva.camera.set_target_position
-- @tparam number x X position
-- @tparam number y Y position
-- @tparam function callback Callback function
function M.scroll_to(x, y, time, callback)
	time = time or 0.75
	local state = app.camera_state
	local pos = vmath.vector3(x, y, 0)
	state.is_animate = true
	state.target_pos = vmath.vector3(pos)

	go.animate(state.cam_id, luax.go.PROP_POS, go.PLAYBACK_ONCE_FORWARD, pos, go.EASING_OUTSINE, time, 0, function()
		state.pos = pos
		state.is_animate = false
		if callback then
			callback()
		end
	end)
end


function M.zoom_to(zoom, time, zoom_from)
	time = time or 0.75
	local state = app.camera_state

	state.is_animate_zoom = true
	local current_zoom = state.zoom
	if zoom_from then
		current_zoom = zoom_from
		rendercam.set_ortho_scale(zoom_from, state.cam_id)
	end

	tweener.tween(tweener.outSine, current_zoom, zoom, time, function(value, is_end)
		rendercam.set_ortho_scale(value, state.cam_id)
		if is_end then
			M.set_zoom(zoom)
			state.is_animate_zoom = false
		end
	end)
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


--- Set the camera zoom
-- @function eva.camera.set_zoom
-- @tparam number zoom Zoom
function M.set_zoom(zoom)
	app.camera_state.zoom = zoom
	app.camera_state.target_zoom = zoom
end


--- Set the camera target zoom
-- @function eva.camera.set_target_zoom
-- @tparam number zoom Target zoom
function M.set_target_zoom(zoom)
	app.camera_state.target_zoom = zoom
end


--- Get the camera zoom
-- @function eva.camera.get_zoom
-- @treturn number zoom
function M.get_zoom()
	return app.camera_state.zoom
end


local function on_input(_, input_type, input_state)
	local camera_state = app.camera_state

	if not camera_state.is_control then
		return
	end

	if input_type == const.INPUT_TYPE.DRAG then
		camera_drag.handle_drag(input_type, input_state)
	end
	if input_type == const.INPUT_TYPE.PINCH then
		camera_drag.handle_drag(input_type, input_state)
		camera_pinch.handle_pinch(input_type, input_state)
	end

	if input_type == const.INPUT_TYPE.KEY_HOLD then
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


--- Eva camera update should be called manually
-- Due the it uses context go.set_position
-- @function eva.camera.update
-- @tparam number dt Delta time
function M.update(dt)
	local state = app.camera_state
	local settings = app.settings.camera

	camera_drag.update_camera_pos(state, dt, settings)
	camera_pinch.update_camera_zoom(state, dt, settings)
end


return M
