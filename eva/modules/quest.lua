--- Eva quest module
-- Carry for some quest type data
-- Can be used for different quests, tasks, achievements etc
-- It can be required by another quests
-- It can be required by tokens
-- You can expand the quest data and start/progress/end logic
-- @submodule eva


local app = require("eva.app")
local const = require("eva.const")

local proto = require("eva.modules.proto")
local saver = require("eva.modules.saver")


local M = {}


function M.on_eva_init()
	app[const.EVA.QUEST] = proto.get(const.EVA.QUEST)
	saver.add_save_part(const.EVA.QUEST, app[const.EVA.QUEST])
end


return M
