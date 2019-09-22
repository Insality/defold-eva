local M = {}

local android_id = sys.get_config("android.package") or ""
local ios_id = sys.get_config("ios.id") or ""


local android_market =
	"market://details?id=%s&referrer=utm_source%%3D%s"

local android_url =
	"https://play.google.com/store/apps/details?id=%s&referrer=utm_source%%3D%s"

local ios_market =
	"https://itunes.apple.com/app/apple-store/id%s?pt=119008561&ct=%s&mt=8"


local function select_url(url_ios, url_android)
	local is_ios = M._eva.device.is_ios()
	local url_source = M.settings.url_source
	local market_url = is_ios and url_ios or url_android

	return string.format(market_url, is_ios and ios_id or android_id, url_source)
end


function M.promt_rate()
	if not (M._eva.device.is_mobile()) then
		return
	end

	if defreview and defreview.isSupported() then
		defreview.requestReview()
	else
		local market_url = select_url(ios_market, android_market)
		local success = sys.open_url(market_url)
			if not success then
			local direct_url = select_url(ios_market, android_url)
			sys.open_url(direct_url)
		end
	end
end


function M.before_game_start(settings)
	M.settings = settings
end


return M
