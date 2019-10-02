--- Defold-Eva window module
-- @submodule eva

local luax = require("eva.luax")
local const = require("eva.const")
local monarch = require("monarch.monarch")
local log = require("eva.log")

local logger = log.get_logger("eva.window")


local M = {}


local function get_settings(window_id)
	local data = M._eva.app.window_settings
	assert(data, "Window settings is not setup")

	local settings = {}
	luax.table.extend(settings, data.default)
	luax.table.extend(settings, data[window_id])
	return settings
end


--- Load the game scene
-- @function eva.window.show_scene
function M.show_scene(scene_id, data)
	logger:debug("Show scene", { scene_id = scene_id })
	local settings = get_settings(scene_id)

	-- Praise the pyramids!
	settings.before_show_scene(function()
		monarch.show(scene_id, nil, data, function()
			settings.after_show_scene()

			local window_data = M._eva.app.window
			window_data.last_scene = scene_id
			M._eva.events.screen(window_data.last_scene, window_data.last_window)
		end)
	end)
end


--- Show the game window
-- It will close current window and open new, if any opened
-- It can be popup on popup, so don't close prev. window
-- Can add window in queue to open it after current one is closed
-- Window callbacks will be separated module? Calling with ID
-- @function eva.window.show
function M.show(window_id, data, in_queue)
	logger:debug("Show window", { window_id = window_id })
	local settings = get_settings(window_id)

	-- Hello, Pyramids again!
	settings.before_show_window(function()
		monarch.show(window_id, nil, data, function()
			settings.after_show_window()

			local window_data = M._eva.app.window
			window_data.last_window = window_id
			M._eva.events.screen(window_data.last_scene, window_data.last_window)
		end)
	end)
end


--- Check is window is opened now
-- @function eva.window.is_open
function M.is_open(window_id)
	return monarch.top() == hash(window_id)
end


--- Close window by id or last window
-- @function eva.window.close
function M.close(window_id)
	-- window_id = window_id or M._eva.app.last_window
end


--- Close all windows
-- @function eva.window.close_all
function M.close_all()

end


-- TODO
-- Keep context to return from window to window
-- Make window queue, to open one window after already opened


--- Appear functions for all windows
-- Need to call inside window
-- @function eva.window.appear
function M.appear(window_id, cb)
	local data = M._eva.app.window
	local settings = get_settings(window_id)
	gui.set_render_order(settings.render_order)

	table.insert(data.queue, {
		url = msg.url(),
		window_id = window_id
	})

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
	local data = M._eva.app.window
	local settings = get_settings(window_id)

	settings.disappear_func(settings, function()
		monarch.back(nil, function()
			-- TODO: If it was popup on popup??
			table.remove(data.queue)
			M._eva.app.window.last_window = nil

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
end

--- Set game windows settings
-- @function eva.window.set_settings
function M.set_settings(window_settings)
	M._eva.app.window_settings = window_settings
end


function M.before_game_start()
	M._eva.app.window = {
		last_window = nil,
		last_scene = "loader", -- TODO: To const or auto-calc?
		queue = {},
		next_queue = {},
		close_all_callback = nil,
	}
end


return M
