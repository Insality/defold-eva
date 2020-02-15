--- Input touch handling


local rendercam = require("rendercam.rendercam")

local app = require("eva.app")
local luax = require("eva.luax")
local const = require("eva.const")

local device = require("eva.modules.device")

local M = {}


local function start_touch(state, touch)
	state.input_type = const.INPUT_TYPE.TOUCH_START

	state.is_touch = true
	state.is_long_trigger = false
	state.is_drag = false

	state.touch_start_pos.x = touch.screen_x
	state.touch_start_pos.y = touch.screen_y
	state.touch_start_time = socket.gettime()

	state.screen_x = touch.screen_x
	state.screen_y = touch.screen_y
end


local function end_touch(state)
	if state.is_drag then
		state.input_type = const.INPUT_TYPE.DRAG_END
	else
		state.input_type = const.INPUT_TYPE.TOUCH_END
	end

	state.is_drag = false
	state.is_touch = false
	state.touch_id = 0
end


local function process_touch(state, touch)
	local settings = app.settings.input

	if not state.input_type then
		if state.is_drag then
			state.input_type = const.INPUT_TYPE.DRAG
		else
			state.input_type = const.INPUT_TYPE.TOUCH
		end
	end

	local distance = luax.math.distance(touch.screen_x, touch.screen_y, state.touch_start_pos.x, state.touch_start_pos.y)
	if not state.is_drag and distance >= settings.drag_deadzone then
		state.is_drag = true
		state.input_type = const.INPUT_TYPE.DRAG_START
	end

	local touch_time = socket.gettime() - state.touch_start_time
	if not state.is_drag and not state.is_long_trigger and touch_time > settings.long_touch_threshold then
		state.is_long_trigger = true
		state.input_type = const.INPUT_TYPE.LONG_TOUCH
	end
end


local function find_touch(action_id, action, touch_id)
	local act = device.is_mobile() and const.INPUT.MULTITOUCH or const.INPUT.TOUCH

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
			state.screen_x = next_touch.screen_x
			state.screen_y = next_touch.screen_y
			state.touch_id = next_touch.id
		else
			end_touch(state)
		end
	elseif #action.touch == 1 then
		end_touch(state)
	end
end


function M.handle_touch(state, action_id, action)
	state.dx = 0
	state.dy = 0

	local touch = find_touch(action_id, action, state.touch_id)
	if not touch then
		return
	end

	if touch.id then
		state.touch_id = touch.id
	end

	if touch.pressed and not state.is_touch then
		start_touch(state, touch)
	end

	if touch.released and state.is_touch then
		if action.touch then
			-- Mobile
			on_touch_release(action_id, action, state)
		else
			-- PC
			end_touch(state)
		end
	end

	if state.is_touch then
		process_touch(state, touch)
	end

	local touch_end = find_touch(action_id, action, state.touch_id)
	if touch_end and state.is_drag or state.is_pinch then
		state.dx = touch_end.screen_x - state.screen_x
		state.dy = touch_end.screen_y - state.screen_y
	end
end


function M.after_input(state, action_id, action)
	local touch = find_touch(action_id, action, state.touch_id)
	if touch then
		state.screen_x = touch.screen_x
		state.screen_y = touch.screen_y
		state.world_x, state.world_y = rendercam.screen_to_world_2d(touch.screen_x, touch.screen_y, nil, nil, true)
	end
end


return M
