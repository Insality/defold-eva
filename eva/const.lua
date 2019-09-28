--- Defold-Eva const module.
-- Specify all eva constant.

local M = {}


--- Unknown region for eva.device.get_region()
M.UNKNOWN_REGION = "UN"

M.FPS = 60

M.OS = {
	ANDROID = "Android",
	IOS = "iPhone OS",
	MAC = "Darwin",
	LINUX = "Linux",
	WINDOWS = "Windows",
	BROWSER = "HTML5",
}


M.AD = {
	REWARDED = "rewardedVideo",
	PAGE = "video",
}


M.EVENT = {
	EVENT = "eva.events.event",
	GAME_START = "eva.game.start",
	IAP_UPDATE = "eva.iaps.update",
	IAP_START = "eva.iaps.start",
	IAP_CANCEL = "eva.iaps.cancel",
	IAP_PURCHASE = "eva.iaps.purchase",
	IAP_VALID = "eva.iaps.valid",
	IAP_INVALID = "eva.iaps.invalid",
	ADS_READY = "eva.ads.ready",
	ADS_SHOW_REWARDED = "eva.ads.rewarded",
	ADS_SHOW_PAGE = "eva.ads.page",
	ADS_SUCCESS_REWARDED = "eva.ads.rewarded_success",
	ADS_SUCCESS_PAGE = "eva.ads.page_success",
	SERVER_LOGIN = "eva.server.login",
	TIMER_TRIGGER = "eva.timers.trigger",
	LANG_UPDATE = "eva.lang.update",
}


M.EVA = {
	-- Modules, equals to proto name
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
	TIMERS = "eva.Timers",

	-- Part of data
	TOKEN = "eva.Token",
	TIMER = "eva.Timer",
	IAP_INFO = "eva.IapInfo"
}


M.STORE_URL = {
	ANDROID_MARKET =	"market://details?id=%s&referrer=utm_source%%3D%s",
	ANDROID_URL =	"https://play.google.com/store/apps/details?id=%s&referrer=utm_source%%3D%s",
	IOS_MARKET =	"https://itunes.apple.com/app/apple-store/id%s?pt=119008561&ct=%s&mt=8",
}


return M
