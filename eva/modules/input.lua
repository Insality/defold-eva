--- Eva input module
-- Can priotirize input, handle drag, pinch and
-- other gestures
-- @submodule eva


local gesture = require("in.gesture")

local app = require("eva.app")
local log = require("eva.log")
local luax = require("eva.luax")
local const = require("eva.const")

local input_touch = require("eva.modules.input.input_touch")

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


--- Register the input to handle user actions
-- @function eva.input.register
-- @tparam string name Name of input system
-- @tparam function callback The input callback
-- @tparam number priority Priority of input. Lower first
function M.register(context, name, callback, priority)
	table.insert(app.input.stack, {
		name = name,
		callback = callback,
		priority = priority,
		context = context
	})

	table.sort(app.input.stack, function(a, b)
		return a.priority < b.priority
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


local function handle_modifiers(action_id, action, state)
	if action_id == const.INPUT.KEY_LALT then
		if action.pressed then
			state.modifiers.lalt = true
		end
		if action.released then
			state.modifiers.lalt = false
		end
	end

	if action_id == const.INPUT.KEY_LCTRL then
		if action.pressed then
			state.modifiers.lctrl = true
		end

		if action.released then
			state.modifiers.lctrl = false
		end
	end
end


function M.on_input(action_id, action)
	if not action_id then
		return
	end

	local g = app.input.gesture.on_input(action_id, action)
	local stack = app.input.stack
	local state = app.input.state

	state.input_type = nil

	input_touch.handle_touch(state, action_id, action)
	-- handle_gesture(state, action_id, action)

	if g then
		state.is_double_tap = luax.toboolean(g.double_tap)
		state.is_swipe = luax.toboolean(g.swipe)
		if state.is_swipe then
			state.swipe = g.swipe

			state.swipe_side = false
			if g.swipe_right then
				state.swipe_side = const.INPUT_SWIPE.RIGHT
			end
			if g.swipe_up then
				state.swipe_side = const.INPUT_SWIPE.UP
			end
			if g.swipe_left then
				state.swipe_side = const.INPUT_SWIPE.LEFT
			end
			if g.swipe_down then
				state.swipe_side = const.INPUT_SWIPE.DOWN
			end
		end
	end

	handle_modifiers(action_id, action, state)

	-- implement list:
	-- START_PINCH
	-- PINCH
	-- PINCH_END
	if luax.table.contains(const.INPUT_KEYS, action_id) then
		state.key_id = nil
		if action.released then
			state.input_type = const.INPUT_TYPE.KEY_RELEASED
		end
		if action.repeated then
			state.input_type = const.INPUT_TYPE.KEY_REPEATED
		end
		if action.pressed then
			state.input_type = const.INPUT_TYPE.KEY_PRESSED
		end

		if state.input_type then
			state.key_id = action_id
		end
	end

	if state.input_type and action_id then
		print(state.input_type)
	end

	if state.is_drag then
		state.input_type = const.INPUT_TYPE.DRAG
	end
	if state.is_pinch then
		state.input_type = const.INPUT_TYPE.PINCH
	end

	state.action_id = action_id
	state.action = action

	for i = 1, #stack do
		local context = stack[i].context
		local callback = stack[i].callback
		local result = callback(context, state.input_type, state)

		if result then
			break
		end
	end

	input_touch.after_input(state, action_id, action)
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
			action_id = nil,
			action = nil,

			input_type = nil,

			is_touch = false,
			is_long_trigger = false,
			is_drag = false,
			is_pinch = false,

			is_double_tap = false,

			is_swipe = false,
			swipe_side = false,
			swipe = nil,

			touch_id = 0,
			touch_start_pos = vmath.vector3(0),
			touch_start_time = 0,

			screen_x = 0,
			screen_y = 0,
			world_x = 0,
			world_y = 0,

			pinch_distance = 0,
			pinch_pos = vmath.vector3(0),
			pinch_info = false,

			dx = 0,
			dy = 0,

			key_id = nil,
			modifiers = {
				lctrl = false,
				rctrl = false,
				lalt = false,
				ralt = false,
				lshift = false,
				rshift = false,
				lcmd = false,
				rcmd = false,
				fn = false,
			}
		}
	}
end


return M
