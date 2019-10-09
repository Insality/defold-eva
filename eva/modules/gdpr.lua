--- Eva GDPR module.
-- Can process stuff with GDPR
-- @submodule eva


local app = require("eva.app")
local const = require("eva.const")


local M = {}


--- Apply the GDPR to the game profile
-- @function eva.gdpr.apply_gdpr
function M.apply_gdpr()
	app[const.EVA.GDPR].is_accepted = true
	app[const.EVA.GDPR].accept_date = M._eva.game.get_current_time_string()
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


function M.on_game_start()
	app[const.EVA.GDPR] = M._eva.proto.get(const.EVA.GDPR)
	M._eva.saver.add_save_part(const.EVA.GDPR, app[const.EVA.GDPR])
end


return M
