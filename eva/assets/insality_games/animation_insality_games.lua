-- The animation file is generated with Panthera Animation Software (0.8.6)
-- https://insality.github.io/panthera-editor/editor

local M = {}
M.ANIMATION_APPEAR = "appear"

local ALPHA = "color.w"
local POSITION_X = "position.x"
local POSITION_Y = "position.y"
local SCALE_X = "scale.x"
local SCALE_Y = "scale.y"
local SIZE_X = "size.x"

---@param nodes table<string, Node>|nil @If nil, it will try to get options.get_node(id) or gui.get_node(id)
---@param options table|nil @Animation params. Fields: animation_id, callback, is_loop, speed, is_relative, is_skip_init, callback_event, get_node
---@param is_skip_autoplay boolean|nil @If true, will not play animation at create
---@return panthera_animation @The Panthera Animation table to pass it into play/stop functions
function M.create(nodes, options, is_skip_autoplay)
	nodes = nodes or {}
	options = options or {}
	local get_node = options.get_node or gui.get_node
	nodes["heart_left"] = nodes["heart_left"] or get_node("heart_left")
	nodes["insality_stencil"] = nodes["insality_stencil"] or get_node("insality_stencil")
	nodes["insality"] = nodes["insality"] or get_node("insality")
	nodes["games"] = nodes["games"] or get_node("games")
	nodes["heart_root"] = nodes["heart_root"] or get_node("heart_root")
	nodes["heart_right"] = nodes["heart_right"] or get_node("heart_right")

	---@type panthera_animation
	local animation = {
		timers = {},
		nodes = nodes,
		is_playing = false,
		is_loop = options.is_loop or false,
		callback = options.callback or nil,
		speed = math.max(options.speed or 1, 0),
		is_relative = options.is_relative or false,
		is_skip_init = options.is_skip_init or false,
		animation_id = options.animation_id or M.ANIMATION_APPEAR,
		callback_event = options.callback_event or function() end,
		animation_time = { default = 2.5, appear = 3 },
		properties = {}
	}
	animation.properties["heart_left"] = { POSITION_X, SCALE_X, SCALE_Y }
	animation.properties["insality_stencil"] = { SIZE_X }
	animation.properties["insality"] = { ALPHA, SCALE_X, SCALE_Y }
	animation.properties["games"] = { ALPHA, POSITION_Y, SCALE_X, SCALE_Y }
	animation.properties["heart_root"] = { ALPHA, POSITION_Y, SCALE_X, SCALE_Y }
	animation.properties["heart_right"] = { POSITION_X, SCALE_X, SCALE_Y }

	if not is_skip_autoplay then
		M.play(animation)
	end

	return animation
end


---@param animation panthera_animation
function M.stop(animation)
	for node_name, properties in pairs(animation.properties) do
		for index = 1, #properties do
			gui.cancel_animation(animation.nodes[node_name], properties[index])
		end
	end
	for index = #animation.timers, 1, -1 do
		timer.cancel(animation.timers[index])
		table.remove(animation.timers, index)
	end
	animation.is_playing = false
end


---@param animation panthera_animation
---@param options table|nil @Options to override. Fields: animation_id, speed, callback, callback_event, is_relative, is_loop, is_skip_init
function M.play(animation, options)
	options = options or {}
	local animation_id = options.animation_id or animation.animation_id
	local animate_function = M["_play_" .. animation_id]
	if not animate_function then
		error("No Panthera Animation with id: " .. animation_id)
	end

	local speed = options.speed or animation.speed
	local callback = options.callback or animation.callback
	local callback_event = options.callback_event or animation.callback_event
	local is_loop = options.is_loop ~= false and (options.is_loop or animation.is_loop)
	local is_relative = options.is_relative ~= false and (options.is_relative or animation.is_relative)
	local is_skip_init = options.is_skip_init ~= false and (options.is_skip_init or animation.is_skip_init)

	if animation.is_playing then
		M.stop(animation)
	end
	animation.is_playing = true

	animate_function(animation, callback, callback_event, speed, is_loop, is_relative, is_skip_init)
end


---@private
function M._play_default(animation, callback, callback_event, speed, is_loop, is_relative, is_skip_init)
	local nodes = animation.nodes
	local timers = animation.timers

	-- Node: heart_left
	local node_heart_left = nodes["heart_left"]
	local node_heart_left_position = vmath.vector3(0, 0, 0)
	local node_heart_left_scale = vmath.vector3(1, 1, 1)
	if not is_relative and not is_skip_init then
		gui.set_position(node_heart_left, node_heart_left_position)
		gui.set_scale(node_heart_left, node_heart_left_scale)
	end

	-- Node: insality_stencil
	local node_insality_stencil = nodes["insality_stencil"]
	local node_insality_stencil_size = vmath.vector3(100, 300, 0)
	if not is_relative and not is_skip_init then
		gui.set_size(node_insality_stencil, node_insality_stencil_size)
	end

	-- Node: insality
	local node_insality = nodes["insality"]
	local node_insality_scale = vmath.vector3(1, 1, 1)
	local node_insality_color = vmath.vector4(1, 1, 1, 1)
	if not is_relative and not is_skip_init then
		gui.set_scale(node_insality, node_insality_scale)
		gui.set_color(node_insality, node_insality_color)
	end

	-- Node: games
	local node_games = nodes["games"]
	local node_games_position = vmath.vector3(0, -250, 0)
	local node_games_scale = vmath.vector3(1, 1, 1)
	local node_games_color = vmath.vector4(1, 1, 1, 1)
	if not is_relative and not is_skip_init then
		gui.set_position(node_games, node_games_position)
		gui.set_scale(node_games, node_games_scale)
		gui.set_color(node_games, node_games_color)
	end

	-- Node: heart_root
	local node_heart_root = nodes["heart_root"]
	local node_heart_root_position = vmath.vector3(0, 220, 0)
	local node_heart_root_scale = vmath.vector3(1, 1, 1)
	local node_heart_root_color = vmath.vector4(1, 1, 1, 1)
	if not is_relative and not is_skip_init then
		gui.set_position(node_heart_root, node_heart_root_position)
		gui.set_scale(node_heart_root, node_heart_root_scale)
		gui.set_color(node_heart_root, node_heart_root_color)
	end

	-- Node: heart_right
	local node_heart_right = nodes["heart_right"]
	local node_heart_right_position = vmath.vector3(0, 0, 0)
	local node_heart_right_scale = vmath.vector3(1, 1, 1)
	if not is_relative and not is_skip_init then
		gui.set_position(node_heart_right, node_heart_right_position)
		gui.set_scale(node_heart_right, node_heart_right_scale)
	end

	table.insert(timers, timer.delay(animation.animation_time[M.ANIMATION_DEFAULT] / speed, false, function()
		if callback then
			callback(animation, M.ANIMATION_DEFAULT)
		end
		if is_loop then
			M._play_default(animation, callback, callback_event, speed, is_loop, is_relative, is_skip_init)
		end
	end))
end


---@private
function M._play_appear(animation, callback, callback_event, speed, is_loop, is_relative, is_skip_init)
	local nodes = animation.nodes
	local timers = animation.timers

	-- Node: heart_left
	local node_heart_left = nodes["heart_left"]
	local node_heart_left_position = vmath.vector3(0, 0, 0)
	local node_heart_left_scale = vmath.vector3(1, 1, 1)
	if is_relative then
		node_heart_left_position = gui.get_position(node_heart_left)
		node_heart_left_scale = gui.get_scale(node_heart_left)
	elseif not is_skip_init then
		gui.set_position(node_heart_left, node_heart_left_position)
		gui.set_scale(node_heart_left, node_heart_left_scale)
	end
	-- POSITION_X
	gui.animate(node_heart_left, POSITION_X, node_heart_left_position.x - 550, gui.EASING_OUTEXPO, 0.61 / speed, 0.54 / speed, function()
		gui.animate(node_heart_left, POSITION_X, node_heart_left_position.x, gui.EASING_OUTEXPO, 0.36 / speed, 0.24 / speed)
	end)
	-- SCALE_X
	gui.animate(node_heart_left, SCALE_X, node_heart_left_scale.x + 0.2, gui.EASING_OUTSINE, 0.16 / speed, 1.33 / speed, function()
		gui.animate(node_heart_left, SCALE_X, node_heart_left_scale.x, gui.EASING_OUTSINE, 0.31 / speed)
	end)
	-- SCALE_Y
	gui.animate(node_heart_left, SCALE_Y, node_heart_left_scale.y - 0.1, gui.EASING_OUTSINE, 0.13 / speed, 1.33 / speed, function()
		gui.animate(node_heart_left, SCALE_Y, node_heart_left_scale.y, gui.EASING_OUTSINE, 0.31 / speed, 0.03 / speed)
	end)

	-- Node: insality_stencil
	local node_insality_stencil = nodes["insality_stencil"]
	local node_insality_stencil_size = vmath.vector3(1, 300, 0)
	if is_relative then
		node_insality_stencil_size = gui.get_size(node_insality_stencil)
	elseif not is_skip_init then
		gui.set_size(node_insality_stencil, node_insality_stencil_size)
	end
	-- SIZE_X
	gui.animate(node_insality_stencil, SIZE_X, node_insality_stencil_size.x + 1099, gui.EASING_OUTEXPO, 0.61 / speed, 0.54 / speed)

	-- Node: insality
	local node_insality = nodes["insality"]
	local node_insality_scale = vmath.vector3(1, 1, 1)
	local node_insality_color = vmath.vector4(1, 1, 1, 0)
	if is_relative then
		node_insality_scale = gui.get_scale(node_insality)
	elseif not is_skip_init then
		gui.set_scale(node_insality, node_insality_scale)
		gui.set_color(node_insality, node_insality_color)
	end
	-- ALPHA
	gui.animate(node_insality, ALPHA, node_insality_color.w + 1, gui.EASING_OUTSINE, 0.54 / speed, 0.45 / speed, function()
		gui.animate(node_insality, ALPHA, node_insality_color.w, gui.EASING_OUTSINE, 0.08 / speed, 1.71 / speed)
	end)
	-- SCALE_X
	gui.animate(node_insality, SCALE_X, node_insality_scale.x + 0.02, gui.EASING_OUTSINE, 2.06 / speed, 0.64 / speed)
	-- SCALE_Y
	gui.animate(node_insality, SCALE_Y, node_insality_scale.y + 0.03, gui.EASING_OUTSINE, 2.06 / speed, 0.64 / speed)

	-- Node: games
	local node_games = nodes["games"]
	local node_games_position = vmath.vector3(0, -210, 0)
	local node_games_scale = vmath.vector3(1, 1, 1)
	local node_games_color = vmath.vector4(1, 1, 1, 0)
	if is_relative then
		node_games_position = gui.get_position(node_games)
		node_games_scale = gui.get_scale(node_games)
	elseif not is_skip_init then
		gui.set_position(node_games, node_games_position)
		gui.set_scale(node_games, node_games_scale)
		gui.set_color(node_games, node_games_color)
	end
	-- ALPHA
	gui.animate(node_games, ALPHA, node_games_color.w + 1, gui.EASING_OUTSINE, 0.53 / speed, 1.01 / speed, function()
		gui.animate(node_games, ALPHA, node_games_color.w, gui.EASING_OUTSINE, 0.13 / speed, 1.14 / speed)
	end)
	-- POSITION_Y
	gui.animate(node_games, POSITION_Y, node_games_position.y - 40, gui.EASING_OUTSINE, 0.59 / speed, 0.9 / speed)
	-- SCALE_X
	gui.animate(node_games, SCALE_X, node_games_scale.x - 0.03, gui.EASING_OUTSINE, 1.14 / speed, 1.53 / speed)
	-- SCALE_Y
	gui.animate(node_games, SCALE_Y, node_games_scale.y - 0.03, gui.EASING_OUTSINE, 1.14 / speed, 1.53 / speed)

	-- Node: heart_root
	local node_heart_root = nodes["heart_root"]
	local node_heart_root_position = vmath.vector3(0, -50, 0)
	local node_heart_root_scale = vmath.vector3(0, 0, 1)
	local node_heart_root_color = vmath.vector4(1, 1, 1, 0)
	if is_relative then
		node_heart_root_position = gui.get_position(node_heart_root)
		node_heart_root_scale = gui.get_scale(node_heart_root)
	elseif not is_skip_init then
		gui.set_position(node_heart_root, node_heart_root_position)
		gui.set_scale(node_heart_root, node_heart_root_scale)
		gui.set_color(node_heart_root, node_heart_root_color)
	end
	-- ALPHA
	gui.animate(node_heart_root, ALPHA, node_heart_root_color.w + 1, gui.EASING_OUTSINE, 0.34 / speed, 0, function()
		gui.animate(node_heart_root, ALPHA, node_heart_root_color.w, gui.EASING_OUTSINE, 0.29 / speed, 2.37 / speed)
	end)
	-- POSITION_Y
	gui.animate(node_heart_root, POSITION_Y, node_heart_root_position.y + 150, gui.EASING_INSINE, 0.58 / speed, 0.56 / speed, function()
		gui.animate(node_heart_root, POSITION_Y, node_heart_root_position.y + 270, gui.EASING_OUTSINE, 0.6 / speed, 0, function()
			gui.animate(node_heart_root, POSITION_Y, node_heart_root_position.y - 50, gui.EASING_OUTSINE, 0.4 / speed, 0.86 / speed)
		end)
	end)
	-- SCALE_X
	gui.animate(node_heart_root, SCALE_X, node_heart_root_scale.x + 1, gui.EASING_OUTBACK, 0.25 / speed, 0, function()
		gui.animate(node_heart_root, SCALE_X, node_heart_root_scale.x + 0.8, gui.EASING_OUTSINE, 0.09 / speed, 0.17 / speed, function()
			gui.animate(node_heart_root, SCALE_X, node_heart_root_scale.x + 1, gui.EASING_OUTSINE, 0.06 / speed, 0, function()
				gui.animate(node_heart_root, SCALE_X, node_heart_root_scale.x + 0.85, gui.EASING_OUTSINE, 0.06 / speed, 1.19 / speed, function()
					gui.animate(node_heart_root, SCALE_X, node_heart_root_scale.x + 1, gui.EASING_OUTBACK, 0.18 / speed, 0, function()
						gui.animate(node_heart_root, SCALE_X, node_heart_root_scale.x + 8, gui.EASING_OUTSINE, 0.4 / speed, 0.6 / speed)
					end)
				end)
			end)
		end)
	end)
	-- SCALE_Y
	gui.animate(node_heart_root, SCALE_Y, node_heart_root_scale.y + 1, gui.EASING_OUTBACK, 0.32 / speed, 0, function()
		gui.animate(node_heart_root, SCALE_Y, node_heart_root_scale.y + 1.12, gui.EASING_OUTSINE, 0.1 / speed, 1.46 / speed, function()
			gui.animate(node_heart_root, SCALE_Y, node_heart_root_scale.y + 1, gui.EASING_OUTBACK, 0.17 / speed, 0, function()
				gui.animate(node_heart_root, SCALE_Y, node_heart_root_scale.y + 8, gui.EASING_OUTSINE, 0.4 / speed, 0.55 / speed)
			end)
		end)
	end)

	-- Node: heart_right
	local node_heart_right = nodes["heart_right"]
	local node_heart_right_position = vmath.vector3(0, 0, 0)
	local node_heart_right_scale = vmath.vector3(1, 1, 1)
	if is_relative then
		node_heart_right_position = gui.get_position(node_heart_right)
		node_heart_right_scale = gui.get_scale(node_heart_right)
	elseif not is_skip_init then
		gui.set_position(node_heart_right, node_heart_right_position)
		gui.set_scale(node_heart_right, node_heart_right_scale)
	end
	-- POSITION_X
	gui.animate(node_heart_right, POSITION_X, node_heart_right_position.x + 550, gui.EASING_OUTEXPO, 0.61 / speed, 0.54 / speed, function()
		gui.animate(node_heart_right, POSITION_X, node_heart_right_position.x, gui.EASING_OUTEXPO, 0.35 / speed, 0.24 / speed)
	end)
	-- SCALE_X
	gui.animate(node_heart_right, SCALE_X, node_heart_right_scale.x + 0.2, gui.EASING_OUTSINE, 0.16 / speed, 1.33 / speed, function()
		gui.animate(node_heart_right, SCALE_X, node_heart_right_scale.x, gui.EASING_OUTSINE, 0.31 / speed)
	end)
	-- SCALE_Y
	gui.animate(node_heart_right, SCALE_Y, node_heart_right_scale.y - 0.1, gui.EASING_OUTSINE, 0.13 / speed, 1.33 / speed, function()
		gui.animate(node_heart_right, SCALE_Y, node_heart_right_scale.y, gui.EASING_OUTSINE, 0.31 / speed, 0.03 / speed)
	end)

	table.insert(timers, timer.delay(animation.animation_time[M.ANIMATION_APPEAR] / speed, false, function()
		if callback then
			callback(animation, M.ANIMATION_APPEAR)
		end
		if is_loop then
			M._play_appear(animation, callback, callback_event, speed, is_loop, is_relative, is_skip_init)
		end
	end))
end


return M
