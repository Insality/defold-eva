--- Eva advertisement module
-- This module provide API to ads with different adapters
-- @submodule eva


local app = require("eva.app")
local log = require("eva.log")
local const = require("eva.const")

local db = require("eva.modules.db")
local game = require("eva.modules.game")
local proto = require("eva.modules.proto")
local saver = require("eva.modules.saver")
local device = require("eva.modules.device")
local events = require("eva.modules.events")
local wallet = require("eva.modules.wallet")

local logger = log.get_logger("eva.ads")

local M = {}

-- EVA_SETUP
-- Uncomment adapters you wanna use
M.ADAPTERS = {
	["unity"] = require("eva.modules.ads.ads_unity"),
	-- ["yandex"] = require("eva.modules.ads.ads_yandex")
}


local function get_ad_data(ad_id)
	local config_name = app.settings.ads.config
	return db.get(config_name).ads[ad_id]
end


local function get_adapter()
	return M.ADAPTERS[app._eva_ads_data.adapter]
end


local function on_ads_finished(ad_id)
	logger:debug("Ads finished", { id = ad_id, time = game.get_time() })

	local data = app[const.EVA.ADS]

	data.daily_watched[ad_id] = (data.daily_watched[ad_id] or 0) + 1
	data.total_watched[ad_id] = (data.total_watched[ad_id] or 0) + 1
	data.last_watched_time[ad_id] = game.get_time()
end


local function on_ads_error(ad_id)
	local ad_config = get_ad_data(ad_id)
	local is_rewarded = ad_config.type == const.AD.REWARDED
	events.event(const.EVENT.ADS_ERROR, {
		id = ad_id,
		time = game.get_time(),
		is_rewarded = is_rewarded
	})
end


local function on_ads_success(ad_id)
	logger:debug("Ads success", { id = ad_id })

	local ad_config = get_ad_data(ad_id)
	local is_rewarded = ad_config.type == const.AD.REWARDED
	events.event(const.EVENT.ADS_SUCCESS, { id = ad_id, is_rewarded = is_rewarded })
	if is_rewarded then
		events.event(const.EVENT.ADS_SUCCESS_REWARDED, { id = ad_id })
	end
end


local function on_ads_loaded(ad_id, placement_id)
	local data = app[const.EVA.ADS]
	data.ads_loaded = data.ads_loaded + 1
	events.event(const.EVENT.ADS_READY, { ad_id = ad_id, placement = placement_id })
end


local function is_network_ok(ad_id, ad_config)
	return get_adapter().is_ready(ad_id, ad_config)
end


local function is_time_between_ok(ad_id, ad_config)
	local data = app[const.EVA.ADS]
	local last_play_time = data.last_watched_time[ad_id] or 0
	return (game.get_time() - last_play_time) >= ad_config.time_between_shows
end


local function is_time_between_all_ok(ad_id, ad_config)
	local data = app[const.EVA.ADS]
	local last_play_time = 0
	for _, ad_last_play_time in pairs(data.last_watched_time) do
		last_play_time = math.max(last_play_time, ad_last_play_time)
	end
	return (game.get_time() - last_play_time) >= ad_config.time_between_shows_all
end


local function is_from_session_start_ok(ad_id, ad_config)
	local game_data = app[const.EVA.GAME]
	return (game.get_time() - game_data.session_start_time) >= ad_config.time_from_game_start
end


local function is_tokens_ok(ad_id, ad_config)
	local token_group_id = ad_config.required_token_group
	if not token_group_id or token_group_id == "" then
		return true
	end

	return wallet.is_enough_group(token_group_id)
end


local function is_daily_limit_ok(ad_id, ad_config)
	local data = app[const.EVA.ADS]

	return (data.daily_watched[ad_id] or 0) < ad_config.daily_limit
end


local function is_total_limit_ok(ad_id, ad_config)
	local data = app[const.EVA.ADS]

	local count = 0
	for id, amount in pairs(data.daily_watched) do
		count = count + data.daily_watched[id]
	end

	return count < ad_config.all_ads_daily_limit
end


--- Check is ads are ready to show now
-- @function eva.ads.is_ready
-- @tparam string ad_id The Ad placement id
function M.is_ready(ad_id)
	local ad_config = get_ad_data(ad_id)
	assert(ad_id, "You should provide ad id")
	assert(ad_config, "Ad config should exists")

	return is_network_ok(ad_id, ad_config) and
			is_from_session_start_ok(ad_id, ad_config) and
			is_time_between_ok(ad_id, ad_config) and
			is_time_between_all_ok(ad_id, ad_config) and
			is_daily_limit_ok(ad_id, ad_config) and
			is_tokens_ok(ad_id, ad_config) and
			is_total_limit_ok(ad_id, ad_config)
end


--- Check is ads are blocked with network or tokens for player
-- @function eva.ads.is_blocked
-- @tparam string ad_id The Ad placement id
function M.is_blocked(ad_id)
	local ad_config = get_ad_data(ad_id)
	assert(ad_id, "You should provide ad id")
	assert(ad_config, "Ad config should exists")

	return not (is_network_ok(ad_id, ad_config) and
			is_tokens_ok(ad_id, ad_config))
end


--- Return seconds when placement will be ready
-- @function eva.ads.get_time_to_ready
-- @tparam string ad_id The Ad placement id
-- @tparam number The amount in seconds
-- @treturn number The seconds amount until ads available
function M.get_time_to_ready(ad_id)
	local game_data = app[const.EVA.GAME]
	local ads_data = app[const.EVA.ADS]

	local ad_config = get_ad_data(ad_id)
	local time = game.get_time()

	local until_from_game_start = math.max(0, ad_config.time_from_game_start - (time - game_data.session_start_time))

	local last_play_time = ads_data.last_watched_time[ad_id] or 0
	local until_between_shows = math.max(0, ad_config.time_between_shows - (time - last_play_time))

	local all_last_play_time = 0
	for _, ad_last_play_time in pairs(ads_data.last_watched_time) do
		all_last_play_time = math.max(all_last_play_time, ad_last_play_time)
	end
	local until_between_shows_all = math.max(0, ad_config.time_between_shows_all - (time - all_last_play_time))

	local until_daily_limit_reset = 0
	local is_daily_limit_ok = is_daily_limit_ok(ad_id, ad_config) and is_total_limit_ok(ad_id, ad_config)
	if not is_daily_limit_ok then
		until_daily_limit_reset = game.get_seconds_until_new_day()
	end

	return math.max(until_from_game_start, until_between_shows, until_between_shows_all, until_daily_limit_reset)
end


--- Show ad by placement id
-- @function eva.ads.show
-- @tparam string ad_id The Ad placement id
-- @tparam function success_callback The success callback
-- @tparam function finish_callback The ads finish callback
function M.show(ad_id, success_callback, finish_callback)
	if not M.is_ready(ad_id) then
		logger:info("The ads is not ready, skip show", { ad_id = ad_id })
		return
	end

	local ad_config = get_ad_data(ad_id)
	events.event(const.EVENT.ADS_SHOW, { id = ad_id, type = ad_config.type })
	app._eva_ads_data.last_ad_id = ad_id

	get_adapter().show(ad_id, ad_config, function(id)
		on_ads_success(app._eva_ads_data.last_ad_id)
		if success_callback then
			success_callback(ad_id)
		end
	end, function(id)
		on_ads_finished(app._eva_ads_data.last_ad_id)
		if finish_callback then
			finish_callback(ad_id)
		end
	end, function(id)
		on_ads_error(app._eva_ads_data.last_ad_id)
	end)
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


--- Return current ads adapter name
-- @function eva.ads.get_adapter_name
-- @treturn string The adapter name
function M.get_adapter_name()
	return app._eva_ads_data.adapter
end


function M.on_new_day()
	local data = app[const.EVA.ADS]

	for id, amount in pairs(data.daily_watched) do
		data.daily_watched[id] = 0
	end
end


function M.on_eva_init()
	app[const.EVA.ADS] = proto.get(const.EVA.ADS)
	saver.add_save_part(const.EVA.ADS, app[const.EVA.ADS])

	app._eva_ads_data = {
		adapter = app.settings.ads.adapter or "unity",
		last_ad_id = nil
	}

	events.subscribe(const.EVENT.NEW_DAY, M.on_new_day)
end


function M.after_eva_init()
	if not M.is_enabled() then
		return
	end

	local settings = app.settings.ads
	local ads_id = nil

	if device.is_ios() then
		ads_id = settings.ads_id_ios
	end
	if device.is_android() then
		ads_id = settings.ads_id_android
	end

	get_adapter().initialize(ads_id, on_ads_loaded)
end


return M
