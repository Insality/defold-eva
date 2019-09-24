local const = require("eva.const")


local M = {}


function M.apply_gdpr()
	M._gdpr_prefs.is_accepted = true
	M._gdpr_prefs.accept_date = M._eva.game.get_current_time_string()
end


function M.is_accepted()
	return M._gdpr_prefs.is_accepted
end


function M.open_policy_url()
	sys.open_url(M.settings.policy_url)
end


function M.before_game_start(settings)
	M.settings = settings
end


function M.on_game_start(settings)
	M._gdpr_prefs = M._eva.proto.get(const.EVA.GDPR)
	M._eva.saver.add_save_part(const.EVA.GDPR, M._gdpr_prefs)
end


return M
