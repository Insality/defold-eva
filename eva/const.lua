local M = {}

M.UNKNOWN_REGION = "UN"

M.MSG = {
	EVENT = hash("eva.event"),
	SMART_VISUAL_UPDATE = hash("eva.smartvalue.update_visual"),
	LANG_UPDATE = hash("eva.lang.update"),
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


M.EVENT = {
	GAME_START = "game_start",
	IAP_UPDATE = "iap_update",
	IAP_START = "iap_start",
	IAP_CANCEL = "iap_cancel",
	IAP_PURCHASE = "iap_purchase",
	IAP_VALID = "iap_valid",
	IAP_INVALID = "iap_invalid",
	ADS_LOADED = "ads_loaded",
	ADS_SHOW_REWARDED = "ads_show_rewarded",
	ADS_ShOW_PAGE = "ads_show_page",
	SERVER_LOGIN = "server_login"
}


M.EVA = {
	-- Modules
	SOUND = "eva.Sound",
	LANG = "eva.Lang",
	SAVER = "eva.Saver",
	STATS = "eva.Stats",
	TOKENS = "eva.Tokens",
	GDPR = "eva.Gdpr",
	IAPS = "eva.Iaps",

	-- Part of data
	TOKEN = "eva.Token",
}

return M