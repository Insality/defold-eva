local settings = require("eva.settings.default")

local M = {}

local android_id = sys.get_config("android.package")
local ios_id = sys.get_config("ios.id")
local url_source = settings.rate.url_source


local android_market =
	"market://details?id=" .. android_id .. "&referrer=utm_source%3D" .. url_source

local android_url =
	"https://play.google.com/store/apps/details?id=" .. android_id .. "&referrer=utm_source%3D" .. url_source

local ios_market =
	"https://itunes.apple.com/app/apple-store/id" .. ios_id .. "?pt=119008561&ct=" .. url_source .. "&mt=8"


function M.promt_rate()
	local is_ios = M._eva.device.is_ios()
	local is_android = M._eva.device.is_android()

	if not is_ios or not is_android then
		return
	end

	if defreview and defreview.isSupported() then
		defreview.requestReview()
	else
		local market_url = is_ios and ios_market or android_market
		local direct_url = is_ios and ios_market or android_url
		local success = sys.open_url(market_url)
			if not success then
			sys.open_url(direct_url)
		end
	end
end

return M
