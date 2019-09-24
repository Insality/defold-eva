--- Defold-Eva rate module
-- @submodule eva

local const = require("eva.const")

local M = {}


--- Set never promt rate again
-- @function eva.rate.set_never_show
function M.set_never_show(state)
	M._rate_prefs.is_never_show = state
end


--- Set rate as accepted. It will no show more
-- @function eva.rate.set_accepted
function M.set_accepted(state)
	M._rate_prefs.is_accepted = state
end


--- Try to promt rate game to the player
-- @function eva.rate.promt_rate
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


--- Open store or native rating on iOS
-- @function eva.rate.open_rate
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
