--- Defold-Eva const module.
-- Specify all eva constant.

local M = {}

--- Unknown region for eva.device.get_region()
M.UNKNOWN_REGION = "UN"

--- Constant for messages inside eva module
M.MSG = {
	EVENT = hash("eva.event"), -- General game event message
	SMART_VISUAL_UPDATE = hash("eva.smartvalue.update_visual"),
	LANG_UPDATE = hash("eva.lang.update"), -- Message, when language of the game is changed
	ADS_READY = hash("eva.ads.ready"),
	ADS_SUCCESS_REWARDED = hash("eva.ads.rewarded_success"),
}


M.OS = {
	ANDROID = "Android",
	IOS = "iPhone OS",
	MAC = "Darwin",
	LINUX = "Linux",
	WINDOWS = "Windows",
	BROWSER = "HTML5",
}


M.OS.MOBILE_PLATFORMS = {
	M.OS.ANDROID,
	M.OS.IOS,
}


M.OS.PC_PLATFORMS = {
	M.OS.MAC,
	M.OS.LINUX,
	M.OS.WINDOWS,
	M.OS.BROWSER,
}

M.AD = {
	REWARDED = "rewardedVideo",
	PAGE = "video",
}


M.EVENT = {
	GAME_START = "game_start",
	IAP_UPDATE = "iap_update",
	IAP_START = "iap_start",
	IAP_CANCEL = "iap_cancel",
	IAP_PURCHASE = "iap_purchase",
	IAP_VALID = "iap_valid",
	IAP_INVALID = "iap_invalid",
	ADS_READY = "ads_ready",
	ADS_SHOW_REWARDED = "ads_show_rewarded",
	ADS_SHOW_PAGE = "ads_show_page",
	ADS_SUCCESS_REWARDED = "ads_success_rewarded",
	ADS_SUCCESS_PAGE = "ads_success_page",
	SERVER_LOGIN = "server_login"
}


M.EVA = {
	-- Modules
	ADS = "eva.Ads",
	SOUND = "eva.Sound",
	LANG = "eva.Lang",
	DEVICE = "eva.Device",
	RATE = "eva.Rate",
	SAVER = "eva.Saver",
	STATS = "eva.Stats",
	TOKENS = "eva.Tokens",
	GDPR = "eva.Gdpr",
	IAPS = "eva.Iaps",

	-- Part of data
	TOKEN = "eva.Token",
	IAP_INFO = "eva.IapInfo"
}


M.STORE_URL = {
	ANDROID_MARKET =	"market://details?id=%s&referrer=utm_source%%3D%s",
	ANDROID_URL =	"https://play.google.com/store/apps/details?id=%s&referrer=utm_source%%3D%s",
	IOS_MARKET =	"https://itunes.apple.com/app/apple-store/id%s?pt=119008561&ct=%s&mt=8",
}

return M