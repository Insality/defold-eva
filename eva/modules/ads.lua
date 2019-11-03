--- Eva ads module
-- This module provide API to unityads
-- @submodule eva


local app = require("eva.app")
local log = require("eva.log")
local const = require("eva.const")

local saver = require("eva.modules.saver")
local proto = require("eva.modules.proto")
local events = require("eva.modules.events")
local device = require("eva.modules.device")
local game = require("eva.modules.game")

local logger = log.get_logger("eva.ads")

local M = {}


local function on_rewarded_success()
	events.event(const.EVENT.ADS_SUCCESS_REWARDED)
end


local function ads_callback(self, message_id, message)
	local data = app[const.EVA.ADS]

	if message_id == unityads.TYPE_IS_READY then
		logger:debug("Ads ready", message)

		data.ads_loaded = data.ads_loaded + 1

		events.event(const.EVENT.ADS_READY, { placement = message.placementId })
	end

	if message_id == unityads.TYPE_DID_FINISH then
		if message.state == unityads.FINISH_STATE_COMPLETED then
			logger:debug("Ads finished", message)

			if message.placementId == const.AD.REWARDED then
				data.rewarded_watched = data.rewarded_watched + 1
				on_rewarded_success()
			end

			if message.placementId == const.AD.PAGE then
				data.page_watched = data.page_watched + 1
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
-- On success it will throw ADS_SUCCESS_REWARDED event
-- @function eva.ads.show_rewarded
function M.show_rewarded()
	if not M.is_rewarded_ready() then
		return
	end

	events.event(const.EVENT.ADS_SHOW_REWARDED)

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

	events.event(const.EVENT.ADS_SHOW_PAGE)

	if not unityads then
		return
	end

	unityads.show()
end


--- Set enabled ads state
-- @function eva.ads.set_enabled
-- @tparam bool state ads state
function M.set_enabled(state)
	app[const.EVA.ADS].ads_disabled = not state
end


--- Check ads is enabled
-- @function eva.ads.is_enabled
-- @treturn bool is ads enabled
function M.is_enabled()
	return not app[const.EVA.ADS].ads_disabled
end


function M.on_eva_init()
	app[const.EVA.ADS] = proto.get(const.EVA.ADS)
	saver.add_save_part(const.EVA.ADS, app[const.EVA.ADS])
end


function M.after_eva_init()
	if M.is_enabled() then
		return
	end

	local settings = app.settings.ads
	local is_debug = game.is_debug()
	local ads_id = nil

	if device.is_ios() then
		ads_id = settings.ads_id_ios
	end
	if device.is_android() then
		ads_id = settings.ads_id_android
	end

	if unityads and ads_id then
		unityads.initialize(ads_id, ads_callback, is_debug)
	end
end


return M
