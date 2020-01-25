--- Eva offers module
-- Make logic about offer time, price and reward
-- Price of offers can be iap or token group
-- Reward of offer is token group
-- @submodule eva


local app = require("eva.app")
local log = require("eva.log")
local const = require("eva.const")

local db = require("eva.modules.db")
local iaps = require("eva.modules.iaps")
local saver = require("eva.modules.saver")
local proto = require("eva.modules.proto")
local token = require("eva.modules.token")
local timers = require("eva.modules.timers")
local events = require("eva.modules.events")

local logger = log.get_logger("eva.offers")

local M = {}


local function get_offer_data(offer_id)
	local config_name = app.settings.offers.config
	return db.get(config_name).offers[offer_id]
end


local function get_offers()
	return app[const.EVA.OFFERS].offers
end


--- Start new offer
-- Every offer is unique. You got error, if offer_id
-- is already started. Data pickups from Offers DB.
-- @function eva.offers.add
-- @tparam string offer_id offer id from db
-- @treturn eva.Offer new offer
function M.add(offer_id)
	-- Check offer_id is valid
	local offer = get_offer_data(offer_id)
	if not offer then
		logger:error("Incorrect offer id. No offer in data", { offer_id = offer_id })
		return
	end

	-- Create offer data
	local offer_save = proto.get(const.EVA.OFFER)
	local timer_id = "eva.offers." .. offer_id
	offer_save.timer_id = timer_id

	-- Check offer is unique
	local offers = get_offers()
	local is_offer_exist = offers[offer_id]
	local is_timer_exist = timers.get(offer_save.timer_id)
	if is_offer_exist or is_timer_exist then
		logger:error("The offer is already exist", { offer_id = offer_id, timer_id = timer_id })
		return
	end

	-- Add offer data to save
	events.event(const.EVENT.OFFERS_START, { offer_id = offer_id })
	offers[offer_id] = offer_save
	timers.add(offer_save.timer_id, offer_id, offer.time)

	return offer_save
end


--- Remove offers from active list
-- @function eva.offers.remove
-- @tparam string offer_id offer id from db
function M.remove(offer_id)
	local offers = get_offers()

	local offer = offers[offer_id]
	if offer then
		events.event(const.EVENT.OFFERS_CLEAR, { offer_id = offer_id })
		offers[offer_id] = nil
		timers.clear(offer.timer_id)
	else
		logger:error("No offer with id on remove", { offer_id = offer_id })
	end
end


--- Return time till offer end.
-- If offer is no exist now, print the error
-- @function eva.offers.get_time
-- @tparam string offer_id offer id from db
-- @treturn number time in seconds
function M.get_time(offer_id)
	local offer = get_offers()[offer_id]

	if not offer then
		logger:error("No offer to get time", { offer_id = offer_id })
		return
	end

	return timers.get_time(offer.timer_id)
end


--- Check is offer active not
-- @function eva.offers.is_active
-- @tparam string offer_id offer id from db
-- @treturn bool is offer active
function M.is_active(offer_id)
	return get_offers()[offer_id]
end


--- Get token group of offer reward.
-- @function eva.offers.get_reward
-- @tparam string offer_id offer id from db
-- @treturn evadata.Tokens token list
function M.get_reward(offer_id)
	local offer = get_offer_data(offer_id)

	local is_iap = M.is_iap(offer_id)

	if is_iap then
		return iaps.get_reward(offer.iap_id)
	else
		return token.get_lot_reward(offer.lot_id)
	end
end


--- Get token group of offer price.
-- @function eva.offers.get_price
-- @tparam string offer_id offer id from db
-- @treturn evadata.Tokens token list
function M.get_price(offer_id)
	local offer = get_offer_data(offer_id)

	local is_iap = M.is_iap(offer_id)

	if is_iap then
		return iaps.get_price(offer.iap_id)
	else
		return token.get_lot_price(offer.lot_id)
	end
end


--- Check is offer for inapp
-- @function eva.offers.is_iap
-- @tparam string offer_id offer id from db
-- @treturn bool is offer inapp
function M.is_iap(offer_id)
	local offer = get_offer_data(offer_id)
	if offer.iap_id and offer.iap_id ~= "" then
		return true
	end

	return false
end


function M.on_eva_init()
	app[const.EVA.OFFERS] = proto.get(const.EVA.OFFERS)
	saver.add_save_part(const.EVA.OFFERS, app[const.EVA.OFFERS])
end


function M.on_eva_second()
	local offers = get_offers()

	for offer_id, offer in pairs(offers) do
		if timers.is_end(offer.timer_id) then
			M.remove(offer_id)
		end
	end
end


return M
