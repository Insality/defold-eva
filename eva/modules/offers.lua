--- Defolf-eva offers module
-- Make logic about offer time, prica and reward
-- Can be iap or for tokens
-- @submodule eva

local log = require("eva.log")
local const = require("eva.const")

local logger = log.get_logger("eva.offers")

local M = {}


local function get_offers()
	return M._eva.app[const.EVA.OFFERS].offers
end


function M.add(offer_id, category, time, lot, iap_id)
	local offers = get_offers()
	local offer = M._eva.proto.get(const.EVA.OFFER)

	local timer_id = "eva.offers." .. offer_id
	offer.timer_id = timer_id
	offer.lot = lot
	offer.category = category
	if iap_id then
		offer.is_iap = true
		offer.iap_id = iap_id
	end

	local is_offer_exist = offers[offer_id]
	local is_timer_exist = M._eva.timers.get(offer.timer_id)

	if is_offer_exist or is_timer_exist then
		logger:error("The offer is already exist", { offer_id = offer_id, timer_id = timer_id })
		return
	end

	offers[offer_id] = offer
	M._eva.timers.add(offer.timer_id, offer_id, time)

	return offer
end


function M.remove(offer_id)
	local offers = get_offers()

	local offer = offers[offer_id]
	if offer then
		offers[offer_id] = nil
		M._eva.timers.clear(offer.timer_id)
	else
		logger:error("No offer with id on remove", { offer_id = offer_id })
	end
end


function M.get_time(offer_id)
	local offer = get_offers()[offer_id]

	if offer then
		return M._eva.timers.get_time(offer.timer_id)
	end

	logger:error("No offer to get time", { offer_id = offer_id })
	return -1
end


function M.is_active(offer_id)
	return get_offers()[offer_id]
end


function M.get_reward(offer_id)

end


function M.get_price(offer_id)

end


function M.is_iap(offer_id)
	local offer = get_offers()[offer_id]
	if offer then
		return offer.is_iap
	else
		logger:error("No offer with id", { offer_id = offer_id })
	end
end


function M.on_game_start()
	M._eva.app[const.EVA.OFFERS] = M._eva.proto.get(const.EVA.OFFERS)
	M._eva.saver.add_save_part(const.EVA.OFFERS, M._eva.app[const.EVA.OFFERS])
end


function M.on_game_second()
	local offers = get_offers()

	for offer_id, offer in pairs(offers) do
		if M._eva.timers.is_end(offer.timer_id) then
			M.remove(offer_id)
		end
	end
end


return M
