--- Eva festival module
-- It carry on some time events, like halloween,
-- new year, foodtracks in some games.
-- It can start and end events by date with some logic
-- It can be repeatable every day, week, year etc
-- It have deadzone at end, to not start before festival end
-- It throws events on start/end festival
-- @submodule eva


local app = require("eva.app")
local const = require("eva.const")

local proto = require("eva.modules.proto")
local saver = require("eva.modules.saver")


local M = {}


function M.on_eva_init()
	app[const.EVA.FESTIVAL] = proto.get(const.EVA.FESTIVAL)
	saver.add_save_part(const.EVA.FESTIVAL, app[const.EVA.FESTIVAL])
end


return M
