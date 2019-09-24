local const = require("eva.const")

local M = {}


function M.set_never_show(state)
	M._rate_prefs.is_never_show = state
end


function M.set_accepted(state)
	M._rate_prefs.is_accepted = state
end


function M.promt_rate(on_can_promt)
	if not M._eva.device.is_mobile() then
		return
	end

	if M._rate_prefs.is_never_show or M._rate_prefs.is_accepted then
		return
	end

	if M._rate_prefs.promt_count > M.settings.max_promt_count then
		return
	end

	M._rate_prefs.promt_count = M._rate_prefs.promt_count + 1
	if on_can_promt then
		on_can_promt()
	end
end


function M.open_rate()
	if defreview and defreview.isSupported() then
		defreview.requestReview()
	else
		M._eva.game.open_store_page()
	end
end


function M.on_game_start(settings)
	M.settings = settings

	M._rate_prefs = M._eva.proto.get(const.EVA.RATE)
	M._eva.saver.add_save_part(const.EVA.RATE, M._rate_prefs)
end


return M
