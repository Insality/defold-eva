--- Defold-Eva ads module
-- This module provide API to unityads
-- @submodule eva

local log = require("eva.log")
local const = require("eva.const")

local logger = log.get_logger("eva.ads")

local M = {}


local function on_rewarded_success()
	M._eva.events.event(const.EVENT.ADS_SUCCESS_REWARDED)
end


local function ads_callback(self, message_id, message)
	if message_id == unityads.TYPE_IS_READY then
		logger:debug("Ads ready", message)

		M._ads_prefs.ads_loaded = M._ads_prefs.ads_loaded + 1

		M._eva.events.event(const.EVENT.ADS_READY, { placement = message.placementId })
	end

	if message_id == unityads.TYPE_DID_FINISH then
		if message.state == unityads.FINISH_STATE_COMPLETED then
			logger:debug("Ads finished", message)

			if message.placementId == const.AD.REWARDED then
				M._ads_prefs.rewarded_watched = M._ads_prefs.rewarded_watched + 1
				on_rewarded_success()
			end

			if message.placementId == const.AD.PAGE then
				M._ads_prefs.page_watched = M._ads_prefs.page_watched + 1
			end
		end
	end
end


local function is_ready(ads_type)
	if not unityads then
		return true
	end

	return unityads.isReady(ads_type)
end


--- Check is page ads ready.
-- @function eva.ads.is_page_ready
-- @treturn bool is page ads ready
function M.is_page_ready()
	return is_ready(const.AD.PAGE)
end


--- Check is rewarded ads ready.
-- @function eva.ads.is_rewarded_ready
-- @treturn bool is rewarded ads ready
function M.is_rewarded_ready()
	return is_ready(const.AD.REWARDED)
end


--- Start show rewarded ads
-- On success it will throw const.MSG.ADS_SUCCESS_REWARDED event
-- @function eva.ads.show_rewarded
function M.show_rewarded()
	if not M.is_rewarded_ready() then
		return
	end

	M._eva.events.event(const.EVENT.ADS_SHOW_REWARDED)
	logger:debug("Ads rewarded show")

	if not unityads then
		on_rewarded_success()
		return
	end

	unityads.show(const.AD.REWARDED)
end


--- Start show page ads
-- @function eva.ads.show_page
function M.show_page()
	if not M.is_page_ready() then
		return
	end

	M._eva.events.event(const.EVENT.ADS_SHOW_PAGE)
	logger:debug("Ads page show")

	if not unityads then
		return
	end

	unityads.show()
end


function M.on_game_start(settings)
	M._ads_prefs = M._eva.proto.get(const.EVA.ADS)
	M._eva.saver.add_save_part(const.EVA.ADS, M._ads_prefs)
end


function M.after_game_start(settings)
	local is_debug = M._eva.game.is_debug()
	local ads_id = nil
	if M._eva.device.is_ios() then
		ads_id = settings.ads_id_ios
	end
	if M._eva.device.is_android() then
		ads_id = settings.ads_id_android
	end

	if unityads and ads_id then
		unityads.initialize(ads_id, ads_callback, is_debug)
	end
end


return M
