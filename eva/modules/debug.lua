--- Eva debug module
-- Make some debug stuff with eva module.
-- ALT + 1/2/3 - load save from slot 1/2/3
-- CTRL + 1/2/3 - save game to slot 1/2/3
-- Q - quit game
-- R(3) - restart game
-- N(5) - reset profile
-- D - toggle profiler
-- O - toggle Profi profiler
-- @submodule eva


local app = require("eva.app")
local log = require("eva.log")
local const = require("eva.const")

local festivals = require("eva.modules.festivals")
local game = require("eva.modules.game")
local lang = require("eva.modules.lang")
local saver = require("eva.modules.saver")
local input = require("eva.modules.input")
local ProFi = require("eva.system.profi")

local logger = log.get_logger("eva.debug")

local M = {}


function M.save_profile(filename)
	saver.save(filename)
end


function M.load_profile(filename)
	game.reboot(0, "--config=eva.load_filename=" .. filename)
end


function M.reset_no_consumables()

end


function M.complete_all_timers()

end


function M.toogle_profiler()
	msg.post("@system:", "toggle_profile")
end


function M.restart_game()
	game.reboot()
end


function M.exit_game()
	game.exit()
end


function M.start_festival(festival_id)
	festivals.debug_start_festival(festival_id)
end


function M.end_festival(festival_id)
	festivals.debug_end_festival(festival_id)

end


function M.complete_quest()

end


local function on_eva_input(_, input_type, input_state)
	if input_type ~= const.INPUT_TYPE.KEY_RELEASED then
		return
	end

	local key = input_state.key_id

	if key == const.INPUT.KEY_Q then
		app.debug_data.quit_counter = (app.debug_data.quit_counter or 0) + 1
		if app.debug_data.quit_counter == 1 then
			M.exit_game()
		end
	end

	if key == const.INPUT.KEY_P then
		M.toogle_profiler()
	end

	if key == const.INPUT.KEY_O then
		if not app.debug_data.is_profiling_now then
			app.debug_data.is_profiling_now = true
			ProFi:reset()
			ProFi:start()
			logger:info("Start ProFi profiling...")
		else
			app.debug_data.is_profiling_now = false
			ProFi:stop()
			ProFi:writeReport('MyProfilingReport.txt')
			logger:info("Finish ProFi profiling")
		end
	end

	if key == const.INPUT.KEY_R then
		M.restart_game()
	end

	if key == const.INPUT.KEY_N then
		app.debug_data.new_game_counter = (app.debug_data.new_game_counter or 0) + 1
		if app.debug_data.new_game_counter == 5 then
			saver.delete()
			M.restart_game()
		end
	end

	if key == const.INPUT.KEY_1 then
		if input_state.modifiers.lalt then
			M.load_profile("eva_test_1.json")
		end
		if input_state.modifiers.lctrl then
			M.save_profile("eva_test_1.json")
			logger:info("Debug save to slot 1")
		end
	end

	if key == const.INPUT.KEY_2 then
		if input_state.modifiers.lalt then
			M.load_profile("eva_test_2.json")
		end
		if input_state.modifiers.lctrl then
			M.save_profile("eva_test_2.json")
			logger:info("Debug save to slot 2")
		end
	end

	if key == const.INPUT.KEY_3 then
		if input_state.modifiers.lalt then
			M.load_profile("eva_test_3.json")
		end
		if input_state.modifiers.lctrl then
			M.save_profile("eva_test_3.json")
			logger:info("Debug save to slot 3")
		end
	end

	if key == const.INPUT.KEY_L then
		lang.set_next_lang()
	end
end


--@function eva.debug.set_value
--@tparam string key
--@tparam any value
function M.set_value(key, value)
	app.debug_data.values = app.debug_data.values or {}
	app.debug_data.values[key] = value
end


--@function eva.debug.get_value
--@tparam string key
--@treturn any
function M.get_value(key)
	app.debug_data.values = app.debug_data.values or {}
	return app.debug_data.values[key]
end


function M.on_eva_init()
	app.debug_data = {}
end


function M.after_eva_init()
	if game.is_debug() then
		local settings = app.settings.debug
		input.register(nil, "eva.debug", on_eva_input, settings.input_priority)
	end
end


return M
