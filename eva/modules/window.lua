--- Eva window module
-- Carry on game window system
-- All windows are setup via separate window_config
-- You can see example at eva/resource/window_settings_template.lua
-- All windows should be described in this settings
-- @submodule eva


local app = require("eva.app")
local luax = require("eva.luax")
local const = require("eva.const")
local monarch = require("monarch.monarch")
local log = require("eva.log")

local events = require("eva.modules.events")

local logger = log.get_logger("eva.window")


local M = {}


local function get_settings(window_id)
	local data = app.window_settings
	assert(data, "Window settings is not setup")

	local settings = {}
	luax.table.extend(settings, data.default)
	luax.table.extend(settings, data[window_id])
	return settings
end


local function get_current()
	local current = app.window.queue[#app.window.queue]
	return current and current.window_id
end


local function add_to_next_queue(window_id, window_data)
	local data = app.window
	local last = data.next_queue[#data.next_queue]
	if last and last.window_id == window_id then
		logger:warn("Try to duplicate windows in next_queue", { window_id = window_id })
		return
	end

	logger:debug("Add window to next queue", { window_id = window_id })
	table.insert(data.next_queue, {
		window_id = window_id,
		data = window_data
	})
end


local function handle_callbacks(data)
	if not data.callbacks then
		return
	end

	local callbacks_wrapped = {}

	for name, callback in pairs(data.callbacks) do
		local callback_context = lua_script_instance.Get()
		callbacks_wrapped[name] = function(...)
			local current_context = lua_script_instance.Get()
			lua_script_instance.Set(callback_context)
			local ok, result = pcall(callback, callback_context, ...)
			lua_script_instance.Set(current_context)

			if not ok then
				error(result)
			end
		end
	end

	data.callbacks = callbacks_wrapped
end


--- Return passed data to scene/window
-- @function eva.window.get_data
function M.get_data(window_id)
	return monarch.data(window_id) or {}
end


--- Load the game scene
-- @function eva.window.show_scene
function M.show_scene(scene_id, data)
	assert(monarch.screen_exists(scene_id), "Provide the correct scene_id")
	local settings = get_settings(scene_id)
	events.event(const.EVENT.SCENE_SHOW, { scene_id = scene_id })

	-- TODO: If want to use live update, here we can check resources
	-- https://defold.com/manuals/live-update/
	-- To sure, resources is excluded, need to clean build folder?
	-- Or distclean, dunno

	-- Praise the pyramids!
	settings.before_show_scene(function()
		if app.window.last_scene then
			monarch.back()
		end

		monarch.show(scene_id, nil, data, function()
			settings.after_show_scene()

			app.window.last_scene = scene_id
			events.screen(app.window.last_scene, get_current())
		end)
	end)
end


--- Show the game window
-- It will close current window and open new, if any opened
-- It can be popup on popup, so don't close prev. window
-- Can add window in queue to open it after current one is closed
-- Window callbacks will be separated module? Calling with ID
-- @function eva.window.show
function M.show(window_id, window_data, in_queue)
	assert(monarch.screen_exists(window_id), "Provide the correct window_id")
	window_data = window_data or luax.table.empty
	local settings = get_settings(window_id)
	local data = app.window

	-- Handle window queue
	if #data.queue > 0 and not settings.is_popup_on_popup then
		add_to_next_queue(window_id, window_data)

		if not in_queue then
			logger:debug("Close all to open new window", { window_id = window_id })
			M.close_all()
		end

		return true
	end

	-- Handle return context
	if window_data.is_return then
		logger:debug("Set prev context", data.last_data)
		data.prev_context = data.last_data
		window_data.is_return = nil
	end

	if not settings.is_popup_on_popup then
		data.last_data = {
			window_id = window_id,
			window_data = window_data,
		}
	end

	handle_callbacks(window_data)

	-- Handle window show
	events.event(const.EVENT.WINDOW_SHOW, { window_id = window_id })

	-- Hello, Pyramids again!
	settings.before_show_window(function()
		monarch.show(window_id, nil, window_data, function()
			settings.after_show_window()

			events.screen(data.last_scene, get_current())
		end)
	end)
end


--- Preload window via monarch
-- @function eva.window.preload
-- @tparam string window_id The window id
-- @tparam[opt] function callback The callback function
function M.preload(window_id, callback)
	monarch.preload(window_id, callback)
end


--- Check is window is opened now
-- @function eva.window.is_open
-- @tparam string window_id The window id
function M.is_open(window_id)
	if window_id then
		return window_id == get_current()
	else
		return get_current()
	end
end


--- Close window by id or last window
-- @function eva.window.close
-- @tparam string window_id The window id
function M.close(window_id)
	window_id = window_id or get_current()

	logger:debug("Call close window", { window_id = window_id })
	for _, queue_data in ipairs(app.window.queue) do
		if queue_data.window_id == window_id then
			msg.post(queue_data.window_url, const.INPUT.CLOSE)
			return
		end
	end
end



--- Send message to the last open window
-- @function eva.window.msg_post
-- @tparam hash message_id
-- @tparam table message
function M.msg_post(message_id, message)
	monarch.post(get_current(), message_id, message)
end


--- Close all windows
-- @function eva.window.close_all
function M.close_all()
	app.window.closing_all = true
	M.close()
end


function M.on_close_window(prev_window_id)
	local data = app.window

	-- Remove this from queue
	for i = #data.queue, 1, -1 do
		if data.queue[i].window_id == prev_window_id then
			table.remove(data.queue, i)
		end
	end

	events.event(const.EVENT.WINDOW_CLOSE, { window_id = prev_window_id, queue = #data.queue })

	if #data.queue == 0 then
		app.window.closing_all = nil

		if data.prev_context then
			local context = data.prev_context
			data.prev_context = nil
			M.show(context.window_id, context.window_data)
		elseif #data.next_queue > 0 then
			local next_window = table.remove(data.next_queue, 1)
			M.show(next_window.window_id, next_window.data)
		end
	end

	if app.window.closing_all and #data.queue > 0 then
		M.close_all()
	end
end


--- Appear functions for all windows
-- Need to call inside window
-- @function eva.window.appear
-- @tparam string window_id The window id
-- @tparam func callback Callback after window open
function M.appear(window_id, callback)
	local settings = get_settings(window_id)
	gui.set_render_order(settings.render_order)

	table.insert(app.window.queue, {
		window_id = window_id,
		window_url = msg.url()
	})

	settings.appear_func(settings, function()
		if callback then
			callback()
		end
	end)
end


--- Disappear functions for all windows
-- Need to call inside window
-- @function eva.window.disappear
-- @tparam string window_id The window id
-- @tparam func callback Callback after window close
function M.disappear(window_id, callback)
	local settings = get_settings(window_id)
	msg.post(".", "release_input_focus")

	settings.disappear_func(settings, function()
		monarch.back(nil, function()
			-- TODO: If it was popup on popup??
			M.on_close_window(window_id)

			if callback then
				callback()
			end
		end)
	end)
end


--- On message function to manage windows
-- @function eva.window.on_message
-- @tparam string window_id
-- @tparam hash message_id
-- @tparam table message
-- @tparam url sender
function M.on_message(window_id, message_id, message, sender)
	if message_id == const.INPUT.CLOSE then
		M.disappear(window_id)
	end
end


--- Set game windows settings
-- @function eva.window.set_settings
function M.set_settings(window_settings)
	app.window_settings = window_settings
end


function M.before_eva_init()
	app.window = {
		last_scene = "loader", -- TODO: To const or auto-calc?
		queue = {}, -- Current windows, {id: "", url: ""}
		next_queue = {},
		close_all_callback = nil,
		prev_context = nil,
		last_data = nil,
		closing_all = nil
	}
end


return M
