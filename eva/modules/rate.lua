--- Eva rate module
-- Can promt to user rate the game
-- Can store rate settings and handle basic
-- logic to when need to show rate or enough
-- @submodule eva


local app = require("eva.app")
local const = require("eva.const")

local M = {}


--- Set never promt rate again
-- @function eva.rate.set_never_show
function M.set_never_show(state)
	app[const.EVA.RATE].is_never_show = state
end


--- Set rate as accepted. It will no show more
-- @function eva.rate.set_accepted
function M.set_accepted(state)
	app[const.EVA.RATE].is_accepted = state
end


--- Try to promt rate game to the player
-- @function eva.rate.promt_rate
function M.promt_rate(on_can_promt)
	if not M._eva.device.is_mobile() then
		return
	end

	local settings = app.settings.rate
	if app[const.EVA.RATE].is_never_show or app[const.EVA.RATE].is_accepted then
		return
	end

	if app[const.EVA.RATE].promt_count > settings.max_promt_count then
		return
	end

	app[const.EVA.RATE].promt_count = app[const.EVA.RATE].promt_count + 1
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


function M.on_eva_init()
	app[const.EVA.RATE] = M._eva.proto.get(const.EVA.RATE)
	M._eva.saver.add_save_part(const.EVA.RATE, app[const.EVA.RATE])
end


return M
