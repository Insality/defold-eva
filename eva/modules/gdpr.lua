--- Eva GDPR module.
-- Can process stuff with GDPR
-- @submodule eva


local log = require("eva.log")
local app = require("eva.app")
local const = require("eva.const")

local game = require("eva.modules.game")
local proto = require("eva.modules.proto")
local saver = require("eva.modules.saver")

local logger = log.get_logger("eva.gdpr")

local M = {}


--- Apply the GDPR to the game profile
-- @function eva.gdpr.apply_gdpr
function M.apply_gdpr()
	app[const.EVA.GDPR].is_accepted = true
	app[const.EVA.GDPR].accept_date = game.get_current_time_string()

	logger:info("Apply GDPR", { date = app[const.EVA.GDPR].accept_date })
end


--- Return if GDPR is accepted
-- @function eva.gdpr.is_accepted
function M.is_accepted()
	return app[const.EVA.GDPR].is_accepted
end


--- Open the policy URL
-- @function eva.gdpr.open_policy_url
function M.open_policy_url()
	local settings = app.settings.gdpr
	sys.open_url(settings.policy_url)
end


function M.on_eva_init()
	app[const.EVA.GDPR] = proto.get(const.EVA.GDPR)
	saver.add_save_part(const.EVA.GDPR, app[const.EVA.GDPR])
end


return M
