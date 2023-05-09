--- Eva feature can control which feature is enabled now and can
-- be changed in runtime due different conditions.
-- @submodule eva


local app = require("eva.app")
local log = require("eva.log")
local const = require("eva.const")

local proto = require("eva.modules.proto")
local saver = require("eva.modules.saver")
local utils = require("eva.modules.utils")

local logger = log.get_logger("eva.feature")

local M = {}


--- Toggle manually feature
-- @function set_enabled
function M.set_enabled(feature_name, state)

end


--- Start eva feature system.
-- Need to call, when game is prepared for features
-- @function eva.feature.start
function M.start()
	app.feature_status.is_started = true
end


function M.before_eva_init()

end

function M.on_eva_init()
	app[const.EVA.FEATURE] = proto.get(const.EVA.FEATURE)
	saver.add_save_part(const.EVA.FEATURE, app[const.EVA.FEATURE])
end


function M.after_eva_init()
	app.feature_status = {
		is_started = false,
	}
end




return M
