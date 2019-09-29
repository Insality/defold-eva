--- Defold-eva simply daily bonus module
-- daily types: reset, skip, wait
-- (what we do at end of prize timer)
-- @submodule eva

local const = require("eva.const")

local M = {}


function M.pick_current()

end


function M.is_can_pick()

end


function M.get_state()

end


function M.get_time()

end


function M.on_game_start()
	M._eva.app[const.EVA.DAILY] = M._eva.proto.get(const.EVA.DAILY)
	M._eva.saver.add_save_part(const.EVA.DAILY, M._eva.app[const.EVA.DAILY])
end


return M
