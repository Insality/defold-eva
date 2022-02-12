-- Eva unity ads plugin
-- @local

local game = require("eva.modules.game")
local app = require("eva.app")
local log = require("eva.log")

local logger = log.get_logger("ads.unity")

local Ads = {}
Ads._on_ready_callback = nil
Ads._on_ads_finished_callback = nil
Ads._on_ads_success_callback = nil
Ads._on_ads_error_callback = nil


local function unity_ads_callback(self, message_id, message)
	if message_id == unityads.TYPE_IS_READY then
		logger:debug("Ads ready", { placement_id = message_id.placementId })
		if Ads._on_ready_callback then
			Ads._on_ready_callback(nil, message_id.placementId)
		end
	end

	if message_id == unityads.TYPE_DID_FINISH then
		logger:debug("Ads finished", { ad_id = app._eva_ads_data.last_ad_id, placement_id = message_id.placementId })
		if Ads._on_ads_finished_callback then
			Ads._on_ads_finished_callback(app._eva_ads_data.last_ad_id, message_id.placementId)
		end
		Ads._on_ads_finished_callback = nil

		if message.state == unityads.FINISH_STATE_COMPLETED then
			logger:debug("Ads success", { ad_id = app._eva_ads_data.last_ad_id, placement_id = message_id.placementId })
			if Ads._on_ads_success_callback then
				Ads._on_ads_success_callback(app._eva_ads_data.last_ad_id, message_id.placementId)
			end
			Ads._on_ads_success_callback = nil
		end
	end
end


--- Init the ads adapter
-- @function adapter.initialize
-- @tparam string ads_id
-- @tparam function on_ready_callback
function Ads.initialize(ads_id, on_ready_callback)
	Ads._on_ready_callback = on_ready_callback
	if unityads and ads_id then
		unityads.initialize(ads_id, unity_ads_callback, game.is_debug())
	end
end


--- Check if ads on adapter is ready
-- @function adapter.is_ready
-- @tparam string ads_id
-- @tparam table ad_config
-- @treturn boolean
function Ads.is_ready(ad_id, ad_config)
	if not unityads then
		return game.is_debug()
	end

	return unityads.isReady(ad_config.type)
end


--- Show ads
-- @function adapter.show
-- @tparam string ad_id
-- @tparam table ad_config
-- @tparam function success_callback The callback on ads success show
-- @tparam function error_callback The callback on ads failure show
function Ads.show(ad_id, ad_config, success_callback, finish_callback, error_callback)
	if not unityads then
		finish_callback(ad_id)
		success_callback(ad_id)
	else
		Ads._on_ads_success_callback = success_callback
		Ads._on_ads_finished_callback = finish_callback
		Ads._on_ads_error_callback = error_callback
		unityads.show(ad_config.type)
	end
end


return Ads
