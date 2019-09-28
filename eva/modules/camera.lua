--- Defold-eva camera module
local luax = require("eva.luax")
local gesture = require("in.gesture")
local rendercam = require("rendercam.rendercam")

local MULTITOUCH = hash("touch_multi")
local TOUCH = hash("touch")

local params = {
	zoom_speed = 0.65,
	center = vmath.vector3(450, 800, 0),
}

local M = {}
M.ZOOM_SPEED = 0.65
M.CENTER = vmath.vector3(450, 800, 0)

M.state = {
	target_pos = vmath.vector3(0, 0, 0),
	target_zoom = 1,
	is_drag = false,
	drag_info = {
		x = 0,
		y = 0,
	},
	cam_id = nil,
	pinch_zoom_start = 1,
	zoom = 1,
	touch_id = 0,
	is_pinch = false
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
		rendercam.pan(-x, -y)

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


return M
