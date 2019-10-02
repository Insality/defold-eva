--- Window settings example
-- default settings will be extend with windows custom
-- every settings should have next field:
-- 	- render_order - number 0..15 to gui.set_render_order
-- 	- appear_func - function(cb) on window show
-- 	- disappear_func - function(cb) on window close
-- 	- before_show_scene - function before show scene
-- 	- after_show_scene - function after show scene
-- 	- before_show_window - function before show window
-- 	- after_show_window - function after show window
-- callback should be executed always!


local function appear_simple(settings, cb)
	local root = gui.get_node("root")
	gui.set_scale(root, vmath.vector3(0.01))
	gui.animate(root, gui.PROP_SCALE, 1, gui.EASING_OUTSINE, 0.1, 0, cb)
end


local function disappear_simple(settings, cb)
	local root = gui.get_node("root")
	gui.animate(root, gui.PROP_SCALE, 0.01, gui.EASING_OUTSINE, 0.1, 0, cb)
end


local function before_show_scene(cb)
	cb()
end


local function after_show_scene(cb)
	if cb then
		cb()
	end
end


local function before_show_window(cb)
	cb()
end


local function after_show_window(cb)
	if cb then
		cb()
	end
end


local M = {
	["default"] = {
		render_order = 10,
		appear_func = appear_simple,
		disappear_func = disappear_simple,
		before_show_scene = before_show_scene,
		after_show_scene = after_show_scene,
		before_show_window = before_show_window,
		after_show_window = after_show_window,

		test_value = "test",
	},

	["window_test"] = {
		render_order = 11
	},

	["window_popup"] = {
		render_order = 13
	}
}

return M
