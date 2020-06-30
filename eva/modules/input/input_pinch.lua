-- Input pinch logic


local app = require("eva.app")
local luax = require("eva.luax")
local const = require("eva.const")

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
	local settings = app.settings.input
	state.input_type = const.INPUT_TYPE.PINCH

	if not state.is_pinch then
		state.input_type = const.INPUT_TYPE.PINCH_START
		state.is_pinch = true
		state.pinch_distance = data.dist
		state.pinch_pos = data.center
	end

	-- Pinch delta
	state.pinch_delta = (data.dist - state.pinch_distance) / (1000 * settings.zoom_speed)
	state.pinch_distance = data.dist
	state.pinch_pos = data.center
end


function M.handle_pinch(state, action_id, action)
	local g = app.input.gesture.on_input(action_id, action)

	-- Handle pinch
	if g and g.two_finger and g.two_finger.pinch then
		g.two_finger.pinch.dist = get_distance(action)
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
			state.input_type = const.INPUT_TYPE.PINCH_END
		end
	end
end


return M
