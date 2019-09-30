--- Defold-Eva window module
-- @submodule eva

local luax = require("eva.luax")
local monarch = require("monarch.monarch")
local log = require("eva.log")

local logger = log.get_logger("eva.window")


local M = {}


--- Load the game scene
-- @function eva.window.show_scene
function M.show_scene(scene_id, data)
	monarch.show(scene_id, nil, data, function()
		local window_data = M._eva.app.window
		window_data.last_scene = scene_id
		M._eva.events.screen(window_data.last_scene, window_data.last_window)
	end)
end


--- Show the game window
-- @function eva.window.show
function M.show(window_id, data)
	monarch.show(window_id, nil, data)

	local window_data = M._eva.app.window
	window_data.last_window = window_id
	M._eva.events.screen(window_data.last_scene, window_data.last_window)
end


--- Check is window is opened now
-- @function eva.window.is_opened
function M.is_opened(window_id)

end


--- Close window by id or last window
-- @function eva.window.close
function M.close(window_id)

end


--- Close all windows
-- @function eva.window.close_all
function M.close_all()

end


local function get_settings(window_name)
	local data = M._eva.app.window_settings
	assert(data, "Window settings is not setup")

	local settings = {}
	luax.table.extend(settings, data.default)
	luax.table.extend(settings, data[window_name])
	return settings
end


--- Appear functions for all windows
-- @function eva.window.appear
function M.appear(window_name, cb)
	local data = M._eva.app.window
	if data.transitions ~= 0 then
		return
	end

	local settings = get_settings(window_name)
	gui.set_render_order(settings.render_order)

	data.transitions = data.transitions + 1

	settings.appear_func(settings, function()
		data.transitions = data.transitions -1

		if cb then
			cb()
		end
	end)
end


--- Disappear functions for all windows
-- @function eva.window.disappear
function M.disappear(window_name, cb)
	local data = M._eva.app.window
	if data.transitions ~= 0 then
		return
	end

	local settings = get_settings(window_name)

	data.transitions = data.transitions + 1

	settings.disappear_func(settings, function()
		monarch.back(nil, function()
			data.transitions = data.transitions - 1
			-- TODO: If it was popup on popup??
			M._eva.app.last_window = nil
		end)
	end)
end


--- Set game windows settings
-- @function eva.window.set_settings
function M.set_settings(window_settings)
	M._eva.app.window_settings = window_settings
end


function M.before_game_start()
	M._eva.app.window = {
		last_window = nil,
		last_scene = "loader",
		transitions = 0,
	}
end


return M
