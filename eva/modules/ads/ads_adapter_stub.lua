--- The ads adapter stub

local Ads = {}

--- Init the ads adapter
-- @function adapter.initialize
-- @tparam string ads_id
-- @tparam function on_ready_callback
function Ads.initialize(ads_id, on_ready_callback) end


--- Check if ads on adapter is ready
-- @function adapter.is_ready
-- @tparam string ads_id
-- @tparam table ad_config
-- @treturn boolean
function Ads.is_ready(ad_id, ad_config) end


--- Show ads
-- @function adapter.show
-- @tparam string ad_id
-- @tparam table ad_config
-- @tparam function success_callback The callback on ads success show
-- @tparam function error_callback The callback on ads failure show
function Ads.show(ad_id, ad_config, success_callback, finish_callback, error_callback) end


return Ads
