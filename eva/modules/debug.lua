--- Eva debug module
-- Make some debug stuff with eva module.
-- @submodule eva


local app = require("eva.app")
local const = require("eva.const")

local festivals = require("eva.modules.festivals")
local game = require("eva.modules.game")
local saver = require("eva.modules.saver")

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


function M.on_eva_init()
	app.debug_data = {}
end


function M.on_input(action_id, action)
	if not game.is_debug() then
		return
	end

	if action_id == const.INPUT.KEY_LALT then
		if action.pressed then
			app.debug_data.is_lalt = true
		end
		if action.released then
			app.debug_data.is_lalt = nil
		end
	end

	if action_id == const.INPUT.KEY_LCTRL then
		if action.pressed then
			app.debug_data.is_lctrl = true
		end
		if action.released then
			app.debug_data.is_lctrl = nil
		end
	end


	if action_id == const.INPUT.KEY_Q and action.released then
		app.debug_data.quit_counter = (app.debug_data.quit_counter or 0) + 1
		if app.debug_data.quit_counter == 3 then
			M.exit_game()
		end
	end

	if action_id == const.INPUT.KEY_R and action.released then
		app.debug_data.restart_counter = (app.debug_data.restart_counter or 0) + 1
		if app.debug_data.restart_counter == 3 then
			M.restart_game()
		end
	end

	if action_id == const.INPUT.KEY_1 and action.released then
		if app.debug_data.is_lalt then
			M.load_profile("eva_test_1")
		end
		if app.debug_data.is_lctrl then
			M.save_profile("eva_test_1")
		end
	end

	if action_id == const.INPUT.KEY_2 and action.released then
		if app.debug_data.is_lalt then
			M.load_profile("eva_test_2")
		end
		if app.debug_data.is_lctrl then
			M.save_profile("eva_test_2")
		end
	end

	if action_id == const.INPUT.KEY_3 and action.released then
		if app.debug_data.is_lalt then
			M.load_profile("eva_test_3")
		end
		if app.debug_data.is_lctrl then
			M.save_profile("eva_test_3")
		end
	end
end


return M
