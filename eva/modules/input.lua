--- Eva input module
-- Can priotirize input, handle drag, pinch and
-- other gestures
-- @submodule eva


local gesture = require("in.gesture")

local app = require("eva.app")
local log = require("eva.log")
local luax = require("eva.luax")
local const = require("eva.const")

local device = require("eva.modules.device")

local logger = log.get_logger("eva.input")

local M = {}


local function get_distance(action)
	if not action.touch then
		return 0
	end

	local t1 = action.touch[1]
	local t2 = action.touch[2]

	return luax.math.distance(t1.screen_x, t1.screen_y, t2.screen_x, t2.screen_y)
end


local function start_drag(state, touch)
	state.is_drag = true
	state.drag_pos.x = touch.screen_x
	state.drag_pos.y = touch.screen_y
end


local function end_drag(state)
	state.is_drag = false
	state.touch_id = 0
end


local function find_touch(action_id, action, touch_id)
	local act = app.input.state.IS_MOBILE and const.INPUT.MULTITOUCH or const.INPUT.TOUCH

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


local function handle_drag(state, action_id, action)
	local touch = find_touch(action_id, action, state.touch_id)
	if not touch then
		return
	end

	if touch.id then
		state.touch_id = touch.id
	end

	if touch.pressed and not state.is_drag then
		-- TODO: drag deadzone
		start_drag(state, touch)
	end

	if touch.released and state.is_drag then
		if action.touch then
			-- Mobile
			touch = on_touch_release(action_id, action, state)

			if not touch then
				end_drag(state)
				return
			end
		else
			-- PC
			end_drag(state)
		end
	end
end


local function handle_pinch(data, state, action)
	-- Zooming start
	if not state.is_pinch then
		state.is_pinch = true
		state.pinch_distance = data.dist
		state.pinch_pos = data.center
	end

	-- Pinch delta
	local delta = (data.dist - state.pinch_distance) / (1000 * M.ZOOM_SPEED)
	local delta_koef = math.sqrt(state.target_zoom)
	delta = delta * delta_koef

	-- Adjust zoom
	state.target_zoom = state.target_zoom - delta
	state.pinch_distance = data.dist

	-- Move to zoom position
	local move_vector = vmath.vector3(data.center.x - M.SCREEN.x, data.center.y - M.SCREEN.y, 0)
	state.target_pos.x = state.target_pos.x + move_vector.x * delta
	state.target_pos.y = state.target_pos.y + move_vector.y * delta

	-- Move by center
	state.target_pos.x = state.target_pos.x + (state.pinch_pos.x - data.center.x) * state.zoom
	state.target_pos.y = state.target_pos.y + (state.pinch_pos.y - data.center.y) * state.zoom

	-- Input module
	state.pinch_pos = data.center
end


local function handle_gesture(state, action_id, action)
	local g = app.input.gesture.on_input(action_id, action)

	-- Handle pinch
	if g and g.two_finger and g.two_finger.pinch then
		g.two_finger.pinch.dist = get_distance(action)
		state.pinch_info = g.two_finger.pinch
		handle_pinch(g.two_finger.pinch, state)
	end

	-- Detect end pinch state
	if action.touch and state.is_pinch then
		local no_touch = #action.touch ~= 2

		local all_released = true
		for i = 1, #action.touch do
			if not action.touch[i].released then
				all_released = false
			end
		end

		if no_touch or all_released then
			state.is_pinch = false
		end
	end
end


local function handle_input(action_id, action)
	local state = app.input.state
	state.dx = 0
	state.dy = 0

	handle_drag(state, action_id, action)
	-- handle_gesture(state, action_id, action)
end


function M.register(name, callback, priority)
	table.insert(app.input.stack, {
		name = name,
		callback = callback,
		priority = priority
	})

	table.sort(app.input.stack, function(a, b)
		return a.priority > b.priority
	end)

	logger:debug("Input register", { name = name, priority = priority })
end


function M.unregister(name)
	local result = luax.table.remove_item(app.input.stack, {
		name = name
	})

	if result then
		logger:debug("Input unregister", { name = name })
	end
end


function M.on_input(action_id, action)
	local g = app.input.gesture.on_input(action_id, action)
	local stack = app.input.stack
	local state = app.input.state

	local touch = find_touch(action_id, action, state.touch_id)

	handle_input(action_id, action)

	if touch and state.is_drag or state.is_pinch then
		state.dx = touch.screen_x - state.drag_pos.x
		state.dy = touch.screen_y - state.drag_pos.y
	end

	-- TODO: Action type
	-- should be:
	-- touch_start
	-- touch_cancel
	-- [long_press_start]
	-- [long_press_end] /
	-- touch_end (usuall touch)

	-- or drag:
	-- touch_cancel
	-- drag_start
	-- drag
	-- drag_end

	-- with pinch:
	-- touch_start
	-- touch_cancel
	-- pinch_start
	-- pinch
	-- pinch_end

	-- double_tap:
	-- touch_start
	-- touch_end
	-- double_touch?
	local input_action
	if state.is_drag then
		input_action = const.INPUT_TYPE.DRAG
	end
	if state.is_pinch then
		input_action = const.INPUT_TYPE.PINCH
	end

	if input_action then
		print("Input type:", input_action)
		if g then
			pprint(g)
		end
		if g then
			for k, v in pairs(g) do
				if v and k ~= "two_finger" then
					pprint(k, v)
				end
			end
		end
	end

	for i = 1, #stack do
		local callback = stack[i].callback
		local result = callback(touch, state, action_id, action)

		if result then
			break
		end
	end

	if touch then
		state.drag_pos.x = touch.screen_x
		state.drag_pos.y = touch.screen_y
	end
end


function M.before_eva_init()
	local settings = app.settings.input

	app.input = {
		stack = {},
		gesture = gesture.create({
			action_id = hash("touch"),
			multi_touch = settings.multi_touch
		}),
		state = {
			IS_MOBILE = device.is_mobile(),
			is_drag = false,
			is_pinch = false,

			touch_id = 0,
			drag_pos = vmath.vector3(0),
			pinch_distance = 0,
			pinch_pos = vmath.vector3(0),
			pinch_info = false,

			dx = 0,
			dy = 0,
		}
	}
end


return M
