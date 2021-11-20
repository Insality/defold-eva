--- Eva input module
-- Register you callbacks with priority
-- other gestures
-- @submodule eva

local gesture = require("in.gesture")

local app = require("eva.app")
local log = require("eva.log")
local luax = require("eva.luax")
local const = require("eva.const")

local input_touch = require("eva.modules.input.input_touch")
local input_pinch = require("eva.modules.input.input_pinch")

local logger = log.get_logger("eva.input")

local M = {}


--- Register the input to handle user actions
-- If callback return true it will stop handle next input
-- @function eva.input.register
-- @tparam string name Name of input system
-- @tparam function callback The input callback
-- @tparam number priority Priority of input. Lower first
function M.register(context, name, callback, priority)
	-- TODO: Check name is no exist
	table.insert(app.input.stack, {
		name = name,
		callback = callback,
		script_context = lua_script_instance.Get(),
		priority = priority,
		context = context
	})

	table.sort(app.input.stack, function(a, b)
		return a.priority < b.priority
	end)

	logger:debug("Input register", { name = name, priority = priority })
end


--- Unregister prev. registered input
-- @function eva.input.unregister
-- @tparam string name Name of input system
function M.unregister(name)
	local result = luax.table.remove_by_dict(app.input.stack, {
		name = name
	})

	if result then
		logger:debug("Input unregister", { name = name })
	end
end


local function handle_modifiers(state, action_id, action)
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


local function handle_gestures(state, action_id, action)
	local g = app.input.gesture.on_input(action_id, action)
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
end


function M.on_input(action_id, action)
	if not action_id then
		return
	end

	local stack = app.input.stack
	local state = app.input.state

	state.input_type = nil

	handle_modifiers(state, action_id, action)
	input_touch.handle_touch(state, action_id, action)
	input_pinch.handle_pinch(state, action_id, action)
	handle_gestures(state, action_id, action)

	if luax.table.contains(const.INPUT_KEYS, action_id) then
		state.key_id = nil
		if action.value > 0 then
			state.input_type = const.INPUT_TYPE.KEY_HOLD
		end
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

	if state.is_drag and state.input_type ~= const.INPUT_TYPE.DRAG_START then
		state.input_type = const.INPUT_TYPE.DRAG
	end
	if state.is_pinch then
		state.input_type = const.INPUT_TYPE.PINCH
	end

	state.action_id = action_id
	state.action = action

	local current_context = lua_script_instance.Get()
	for i = 1, #stack do
		local context = stack[i].context
		local callback = stack[i].callback
		local script_context = stack[i].script_context
		lua_script_instance.Set(script_context)

		local ok, result = pcall(callback, context, state.input_type, state)

		if ok and result then
			break
		end
		if not ok then
			pprint("Input errors:", result)
		end
	end
	lua_script_instance.Set(current_context)

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

			-- Will be true at INPUT_TYPE.TOUCH_END, if double tap
			is_double_tap = false,

			-- Will be true at TOUCH_END/DRAG_END, if was swipe
			is_swipe = false,
			swipe_side = false,
			swipe = nil,

			touch_id = 0,
			touch_start_pos = vmath.vector3(0),
			touch_start_time = 0,

			dx = 0,
			dy = 0,
			screen_x = 0,
			screen_y = 0,
			world_x = 0,
			world_y = 0,

			pinch_distance = 0,
			pinch_delta = 0,
			pinch_pos = vmath.vector3(0),

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
