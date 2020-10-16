--- Eva ads module
-- This module provide API to unityads
-- @submodule eva


local app = require("eva.app")
local log = require("eva.log")
local const = require("eva.const")

local db = require("eva.modules.db")
local saver = require("eva.modules.saver")
local proto = require("eva.modules.proto")
local events = require("eva.modules.events")
local wallet = require("eva.modules.wallet")
local device = require("eva.modules.device")
local game = require("eva.modules.game")

local logger = log.get_logger("eva.ads")

local M = {}


---@return evadata.Ads.AdSettings
local function get_ad_data(ad_id)
	local config_name = app.settings.ads.config
	return db.get(config_name).ads[ad_id]
end


local function on_ads_success(ad_id)
	logger:debug("Ads success", { id = ad_id })

	---@type eva.Ads
	local data = app[const.EVA.ADS]

	data.daily_watched[ad_id] = (data.daily_watched[ad_id] or 0) + 1
	data.total_watched[ad_id] = (data.total_watched[ad_id] or 0) + 1
	data.last_watched_time[ad_id] = game.get_time()

	local ad_config = get_ad_data(ad_id)
	events.event(const.EVENT.ADS_SUCCESS, { id = ad_id })
	if ad_config.type == const.AD.REWARDED then
		events.event(const.EVENT.ADS_SUCCESS_REWARDED, { id = ad_id })
	end
end


local function unity_ads_callback(self, message_id, message)
	local data = app[const.EVA.ADS]

	if message_id == unityads.TYPE_IS_READY then
		data.ads_loaded = data.ads_loaded + 1

		events.event(const.EVENT.ADS_READY, { placement = message.placementId })
	end

	if message_id == unityads.TYPE_DID_FINISH then
		if message.state == unityads.FINISH_STATE_COMPLETED then
			on_ads_success(app._eva_ads_data.last_ad_id)
		end
	end
end


---@param ad_config evadata.Ads.AdSettings
local function is_network_ok(ad_id, ad_config)
	if not unityads then
		return true
	end

	return unityads.isReady(ad_config.type)
end


---@param ad_config evadata.Ads.AdSettings
local function is_time_between_ok(ad_id, ad_config)
	---@type eva.Ads
	local data = app[const.EVA.ADS]
	local last_play_time = data.last_watched_time[ad_id]
	return (game.get_time() - last_play_time) >= ad_config.time_between_shows
end


---@param ad_config evadata.Ads.AdSettings
local function is_from_session_start_ok(ad_id, ad_config)
	---@type eva.Game
	local game_data = app[const.EVA.GAME]
	return (game.get_time() - game_data.session_start_time) >= ad_config.time_from_game_start
end


---@param ad_config evadata.Ads.AdSettings
local function is_tokens_ok(ad_id, ad_config)
	local token_group_id = ad_config.required_token_group
	if not token_group_id or token_group_id == "" then
		return true
	end

	return wallet.is_enough_group(token_group_id)
end


---@param ad_config evadata.Ads.AdSettings
local function is_daily_limit_ok(ad_id, ad_config)
	---@type eva.Ads
	local data = app[const.EVA.ADS]

	return ad_config.daily_limit <= (data.daily_watched[ad_id] or 0)
end


---@param ad_config evadata.Ads.AdSettings
local function is_total_limit_ok(ad_id, ad_config)
	---@type eva.Ads
	local data = app[const.EVA.ADS]

	local count = 0
	for id, amount in pairs(data.daily_watched) do
		count = count + data.daily_watched[id]
	end

	return ad_config.daily_limit <= count
end


--- Check is ads are available now
-- @function eva.ads.is_ready
-- @tparam string ad_id The Ad placement id
function M.is_ready(ad_id)
	local ad_config = get_ad_data(ad_id)
	assert(ad_id, "You should provide ad id")
	assert(ad_config, "Ad config should exists")

	return is_network_ok(ad_id, ad_config) and
			is_from_session_start_ok(ad_id, ad_config) and
			is_time_between_ok(ad_id, ad_config) and
			is_daily_limit_ok(ad_id, ad_config) and
			is_tokens_ok(ad_id, ad_config) and
			is_total_limit_ok(ad_id, ad_config)
end


--- Show ad by placement id
-- @function eva.ads.show
-- @tparam string ad_id The Ad placement id
function M.show(ad_id)
	if not M.is_ready(ad_id) then
		return
	end

	local ad_config = get_ad_data(get_ad_data)
	events.event(const.EVENT.ADS_SHOW, { id = ad_id, type = ad_config.type })

	app._eva_ads_data.last_ad_id = ad_id

	if not unityads then
		on_ads_success(ad_id)
	else
		unityads.show(ad_config.type)
	end
end


--- Set enabled ads state
-- @function eva.ads.set_enabled
-- @tparam boolean state ads state
function M.set_enabled(state)
	app[const.EVA.ADS].ads_disabled = not state
end


--- Check ads is enabled
-- @function eva.ads.is_enabled
-- @treturn bool is ads enabled
function M.is_enabled()
	return not app[const.EVA.ADS].ads_disabled
end


--- Get total ads watched
-- @function eva.ads.get_watched
-- @tparam number Total watched ads count
function M.get_ads_watched()
	---@type eva.Ads
	local data = app[const.EVA.ADS]
	local count = 0
	if not data then
		return count
	end

	for id, amount in pairs(data.total_watched) do
		count = count + amount
	end

	return count
end


function M.on_new_session()
	---@type eva.Ads
	local data = app[const.EVA.ADS]

	for id, amount in pairs(data.daily_watched) do
		data.daily_watched[id] = 0
	end
end


function M.on_eva_init()
	app[const.EVA.ADS] = proto.get(const.EVA.ADS)
	saver.add_save_part(const.EVA.ADS, app[const.EVA.ADS])

	app._eva_ads_data = {
		last_ad_id = nil
	}

	events.subscribe(const.EVENT.NEW_SESSION, M.on_new_session)
end


function M.after_eva_init()
	if not M.is_enabled() then
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
		unityads.initialize(ads_id, unity_ads_callback, is_debug)
	end
end


return M
