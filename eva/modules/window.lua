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
	return app.window.queue[#app.window.queue]
end


local function add_to_next_queue(window_id, window_data)
	local data = app.window
	local last = data.next_queue[#data.next_queue]
	if last and last.window_id == window_id then
		logger:warn("Try to duplicate windows in next_queue", { window_id = window_id })
		return
	end

	table.insert(data.next_queue, {
		window_id = window_id,
		data = window_data
	})
end


local function handle_callbacks(data)
	if not data.callbacks then
		return
	end

	local callbacks = {}
	local stored_url = msg.url()

	for name, callback in pairs(data.callbacks) do
		callbacks[name] = function(...)
			local index = M._eva.callbacks.create(callback)
			msg.post(stored_url, const.INPUT.CALLBACK, { index = index, args = ...})
		end
	end

	data.callbacks = callbacks
end


function M.get_data(window_id)
	return monarch.data(window_id)
end


--- Load the game scene
-- @function eva.window.show_scene
function M.show_scene(scene_id, data)
	assert(monarch.screen_exists(scene_id), "Provide the correct scene_id")
	local settings = get_settings(scene_id)
	logger:debug("Show scene", { scene_id = scene_id })

	-- Praise the pyramids!
	settings.before_show_scene(function()
		monarch.show(scene_id, nil, data, function()
			settings.after_show_scene()

			app.window.last_scene = scene_id
			M._eva.events.screen(app.window.last_scene, get_current())
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
			-- Close by hard all and open new window
			M.close_all()
		end
		return true
	end

	-- Handle return context
	if window_data.is_return then
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
	logger:debug("Show window", { window_id = window_id })

	-- Hello, Pyramids again!
	settings.before_show_window(function()
		monarch.show(window_id, nil, window_data, function()
			settings.after_show_window()

			M._eva.events.screen(data.last_scene, get_current())
		end)
	end)
end


--- Check is window is opened now
-- @function eva.window.is_open
function M.is_open(window_id)
	if window_id then
		return window_id == get_current()
	else
		return get_current()
	end
end


--- Close window by id or last window
-- @function eva.window.close
function M.close(window_id)
	window_id = window_id or get_current()

	for _, id in ipairs(app.window.queue) do
		if id == window_id then
			monarch.post(window_id, const.INPUT.CLOSE, luax.table.empty)
			return
		end
	end
end


--- Close all windows
-- @function eva.window.close_all
function M.close_all()
	M.close()
end


function M.on_close_window(prev_window_id)
	logger:debug("Close window", { window_id = prev_window_id })
	local data = app.window

	if #data.next_queue > 0 and #data.queue == 0 then
		local next_window = table.remove(data.next_queue, 1)
		M.show(next_window.window_id, next_window.data)
	end
end


--- Appear functions for all windows
-- Need to call inside window
-- @function eva.window.appear
function M.appear(window_id, cb)
	local settings = get_settings(window_id)
	gui.set_render_order(settings.render_order)

	table.insert(app.window.queue, window_id)

	settings.appear_func(settings, function()
		if cb then
			cb()
		end
	end)
end


--- Disappear functions for all windows
-- Need to call inside window
-- @function eva.window.disappear
function M.disappear(window_id, cb)
	local settings = get_settings(window_id)
	msg.post(".", "release_input_focus")

	settings.disappear_func(settings, function()
		monarch.back(nil, function()
			-- TODO: If it was popup on popup??
			table.remove(app.window.queue)

			if cb then
				cb()
			end

			M.on_close_window(window_id)
		end)
	end)
end


function M.on_message(window_id, message_id, message, sender)
	if message_id == const.INPUT.CLOSE then
		M.disappear(window_id)
	end
	if message_id == const.INPUT.CALLBACK then
		M._eva.callbacks.call(message.index, message.args)
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
		queue = {},
		next_queue = {},
		close_all_callback = nil,
		prev_context = nil,
		last_data = nil,
	}
end


return M
