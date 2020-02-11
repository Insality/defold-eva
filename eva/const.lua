--- Defold-Eva const module.
-- Specify all eva constant.

local M = {}


--- Unknown region for eva.device.get_region()
M.UNKNOWN_REGION = "UN"
M.WALLET_CONTAINER = "eva.wallet"
M.WALLET_TYPE = "wallet"
M.DEFAULT_SETTINGS_PATH = "/eva/resources/eva_settings.json"


M.FPS = 60


M.OS = {
	ANDROID = "Android",
	IOS = "iPhone OS",
	MAC = "Darwin",
	LINUX = "Linux",
	WINDOWS = "Windows",
	BROWSER = "HTML5",
}


M.TYPE = {
	STRING = "string",
	NUMBER = "number",
	BOOLEAN = "boolean",
	TABLE = "table"
}


M.AD = {
	REWARDED = "rewardedVideo",
	PAGE = "video",
}


M.INPUT = {
	MULTITOUCH = hash("touch_multi"),
	TOUCH = hash("touch"),
	CLOSE = hash("close"),
	CALLBACK = hash("callback"),
	SCROLL_UP = hash("mouse_wheel_up"),
	SCROLL_DOWN = hash("mouse_wheel_down"),
	KEY_Q = hash("key_q"),
	KEY_R = hash("key_r"),
	KEY_N = hash("key_n"),
	KEY_D = hash("key_d"),
	KEY_1 = hash("key_1"),
	KEY_2 = hash("key_2"),
	KEY_3 = hash("key_3"),
	KEY_LALT = hash("key_lalt"),
	KEY_LCTRL = hash("key_lctrl"),
}


M.INPUT_TYPE = {
	TOUCH_START = hash("touch_start"),
	TOUCH = hash("touch"),
	TOUCH_END = hash("touch_end"),
	LONG_TOUCH = hash("long_touch"),
	DOUBLE_TAP = hash("double_tap"),
	DRAG_START = hash("drag_start"),
	DRAG = hash("drag"),
	DRAG_END = hash("drag_end"),
	START_PINCH = hash("start_pinch"),
	PINCH = hash("pinch"),
	PINCH_END = hash("pinch_end"),
	SWIPE = hash("swipe")
}


M.EVENT = {
	EVENT = "eva.events.event",
	GAME_START = "eva.game.start",
	GAME_FOCUS = "eva.game.focus",
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
	TOKEN_CHANGE = "eva.token.change",
	SERVER_LOGIN = "eva.server.login",
	TIMER_TRIGGER = "eva.timers.trigger",
	LANG_UPDATE = "eva.lang.update",
	OFFERS_START = "eva.offers.start",
	OFFERS_CLEAR = "eva.offers.clear",
	DAILY_REWARD = "eva.daily.reward",
	DAILY_RESET = "eva.daily.reset",
	DAILY_LOST = "eva.daily.lost",
	DAILY_NEW_CYCLE = "eva.daily.new_cycle",
	FESTIVAL_START = "eva.festivals.start",
	FESTIVAL_END = "eva.festivals.end",
	FESTIVAL_CLOSE_TO_END = "eva.festivals.close_to_end",
	QUEST_REGISTER = "eva.quests.register",
	QUEST_START = "eva.quests.start",
	QUEST_PROGRESS = "eva.quests.progress",
	QUEST_TASK_COMPLETE = "eva.quests.task_complete",
	QUEST_END = "eva.quests.end",
	WINDOW_SHOW = "eva.window.window_show",
	WINDOW_CLOSE = "eva.window.window_close",
	SCENE_SHOW = "eva.window.scene_show",
	SCENE_CLOSE = "eva.window.scene_close",
	PUSH_SCHEDULED = "eva.push.scheduled",
	PUSH_CANCEL = "eva.push.cancel",
	INVOICE_ADD = "eva.invoices.add",
	INVOICE_EXPIRE = "eva.invoices.expire",
	INVOICE_CONSUME = "eva.invoices.consume",
	TRUCK_ARRIVE = "eva.truck.arrive",
	TRUCK_LEAVE = "eva.truck.leave",
	TRUCK_CLOSE_TO_LEAVE = "eva.truck.close_to_leave",
}


M.REASON = {
	IAP = "eva.reason.inapp",
	QUESTS = "eva.reason.quests",
}


M.IAP = {
	STATE = {
		PURCHASING = 0,
		PURCHASED = 1,
		FAILED = 2,
		RESTORED = 3,
		UNVERIFIED = 4,
	},
	REASON = {
		UNKNOWN = 0,
		CANCELED = 1,
	}
}


M.EVA = {
	-- Modules, equals to proto name
	ADS = "eva.Ads",
	SOUND = "eva.Sound",
	LANG = "eva.Lang",
	DEVICE = "eva.Device",
	RATE = "eva.Rate",
	SAVER = "eva.Saver",
	GAME = "eva.Game",
	TOKEN_RESTORE_CONFIG = "eva.TokenRestoreConfig",
	CONTAINER = "eva.Container",
	CONTAINERS = "eva.Containers",
	GDPR = "eva.Gdpr",
	IAPS = "eva.Iaps",
	TIMERS = "eva.Timers",
	STORAGE = "eva.Storage",
	OFFERS = "eva.Offers",
	DAILY = "eva.Daily",
	FESTIVALS = "eva.Festivals",
	QUESTS = "eva.Quests",
	PUSH = "eva.Push",
	INVOICES = "eva.Invoices",
	TRUCKS = "eva.Trucks",

	-- Part of data
	TOKEN = "eva.Token",
	OFFER = "eva.Offer",
	STORAGE_VALUE = "eva.StorageValue",
	TIMER = "eva.Timer",
	IAP_INFO = "eva.IapInfo",
	PUSH_INFO = "eva.PushInfo",
	INVOICE_INFO = "eva.InvoiceInfo",

	TOKENS_DATA = "evadata.Tokens",
}


M.DAILY = {
	SKIP = "skip",
	WAIT = "wait",
	RESET = "reset",
}


M.STORE_URL = {
	ANDROID_MARKET = "market://details?id=%s&referrer=utm_source%%3D%s",
	ANDROID_URL = "https://play.google.com/store/apps/details?id=%s&referrer=utm_source%%3D%s",
	IOS_MARKET = "https://itunes.apple.com/app/apple-store/id%s?pt=119008561&ct=%s&mt=8",
}


M.ASTAR = {
	ISO = {
		NEIGHBORS = {
			{{-1, -1}, {0, -1}, {-1, 1}, {0, 1}}, -- Even rows
			{{0, -1}, {1, -1}, {0, 1}, {1, 1}} -- Odd rows
		},
		NEIGHBORS_DIAGONAL = {
			{{-1, -1}, {0, -1}, {-1, 1}, {0, 1}, {-1, 0}, {1, 0}, {0, 2}, {0, -2}}, -- Even rows
			{{0, -1}, {1, -1}, {0, 1}, {1, 1}, {-1, 0}, {1, 0}, {0, 2}, {0, -2}}, -- Odd rows
		},
	},
	GRID = {
		NEIGHBORS = {{-1, 0}, {0, -1}, {1, 0}, {0, 1}},
		NEIGHBORS_DIAGONAL = {{-1, 0}, {0, -1}, {1, 0}, {0, 1}, {-1, -1}, {1, -1}, {1, 1}, {-1, 1}}
	},
	HEX = {
		NEIGHBORS = {
			{{1, 0}, {0,-1}, {-1, -1}, {-1, 0}, {-1, 1}, {0, 1}}, -- Even rows
			{{1, 0}, {1, -1}, {0, -1}, {-1, 0}, {0, 1}, {1, 1}}, -- Odd rows
		}
	}
}


return M
