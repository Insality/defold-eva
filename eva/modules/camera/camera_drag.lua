--- Part of Eva Camera module
-- Handle camera dragging
-- @local


local app = require("eva.app")
local luax = require("eva.luax")
local const = require("eva.const")
local rendercam = require("rendercam.rendercam")

local M = {}


function M.handle_drag(input_type, input_state)
	local camera_state = app.camera_state

	local x, y = rendercam.screen_to_world_2d(input_state.dx, input_state.dy, true, nil, true)
	camera_state.target_pos.x = camera_state.target_pos.x - x
	camera_state.target_pos.y = camera_state.target_pos.y - y

	camera_state.inertion.x = camera_state.inertion.x - x
	camera_state.inertion.y = camera_state.inertion.y - y
end


function M.update_camera_pos(state, dt, params)
	local input_state = app.input.state
	if not state.cam_id then
		return
	end

	local pos = state.pos
	local target = state.target_pos
	local border_soft = state.border_soft
	local border_lerp = params.move_border_lerp_speed * const.FPS * dt

	-- Soft border
	if not input_state.is_drag then
		luax.math.lerp_box(target, border_soft, border_lerp, state.camera_box * state.zoom, true)
	end

	-- Inertion friction
	local friction_koef = input_state.is_drag and params.friction_hold or params.friction
	state.inertion = state.inertion * friction_koef

	-- Inertion apply
	if not input_state.is_drag then
		local inertion_koef = const.FPS * dt * params.inertion_koef
		target.x = target.x + state.inertion.x * inertion_koef
		target.y = target.y + state.inertion.y * inertion_koef
	end

	-- Hard border
	luax.math.clamp_box(target, state.border_hard, state.camera_box * state.zoom, true)

	-- Lerp position
	pos.x = luax.math.lerp(pos.x, target.x, params.move_lerp_speed * const.FPS * dt)
	pos.y = luax.math.lerp(pos.y, target.y, params.move_lerp_speed * const.FPS * dt)

	go.set_position(state.pos, state.cam_id)
end


return M
