--- Part of Eva Camera module
-- Handle the camera gestures like zoom and multitouchs
-- @local


local app = require("eva.app")
local luax = require("eva.luax")
local const = require("eva.const")
local rendercam = require("rendercam.rendercam")

local M = {}

M.SCREEN = vmath.vector3(
	sys.get_config("display.width")/2,
	sys.get_config("display.height")/2,
	0)

local function handle_pinch(state, camera_state)
	-- Pinch delta
	local delta_koef = math.sqrt(camera_state.target_zoom)
	local delta = state.pinch_delta * delta_koef
	local hard = camera_state.zoom_border_hard

	-- Adjust zoom
	camera_state.target_zoom = camera_state.target_zoom - delta

	if camera_state.target_zoom > hard.x and camera_state.target_zoom < hard.y then
		-- Move to zoom position if zoom legal (in hard zone)
		local move_vector = vmath.vector3(state.pinch_pos.x - M.SCREEN.x, state.pinch_pos.y - M.SCREEN.y, 0)
		camera_state.target_pos.x = camera_state.target_pos.x + move_vector.x * delta
		camera_state.target_pos.y = camera_state.target_pos.y + move_vector.y * delta
	end
end


function M.handle_pinch(input_type, input_state)
	handle_pinch(input_state, app.camera_state)
end


function M.update_camera_zoom(state, dt, params)
	local input_state = app.input.state
	local soft = state.zoom_border_soft
	local hard = state.zoom_border_hard

	-- Soft border
	if not input_state.is_pinch then
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
