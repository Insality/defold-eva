--- Defold-Eva const module.
-- Specify all eva constant
-- @module eva_const

local M = {}

-- Hack for require dynamic libraries (exlude from defold dependencies tree, need to manual pre-require some libraries)
M.require = require

--- Need to check basic config and protofiles
M.EVA_VERSION = 1

--- Unknown region for eva.device.get_region()
M.UNKNOWN_REGION = "UN"

--- Default player container
M.WALLET_CONTAINER = "eva.wallet"

--- Default wallet container type
M.WALLET_TYPE = "wallet"

--- Game FPS constant
M.FPS = 60


--- Available OS values
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
	INTERSTITIAL = "video",
}


--- Eva input events
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
	KEY_P = hash("key_p"),
	KEY_O = hash("key_o"),
	KEY_1 = hash("key_1"),
	KEY_2 = hash("key_2"),
	KEY_3 = hash("key_3"),
	KEY_L = hash("key_l"),
	KEY_LALT = hash("key_lalt"),
	KEY_LCTRL = hash("key_lctrl"),
}


--- Eva built-in input type
M.INPUT_TYPE = {
	KEY_PRESSED = hash("key_pressed"),
	KEY_REPEATED = hash("key_repeated"),
	KEY_HOLD = hash("key_hold"),
	KEY_RELEASED = hash("key_released"),
	TOUCH_START = hash("touch_start"),
	TOUCH = hash("touch"),
	TOUCH_END = hash("touch_end"),
	LONG_TOUCH = hash("long_touch"),
	DRAG_START = hash("drag_start"), -- it mean touch_cancel too
	DRAG = hash("drag"),
	DRAG_END = hash("drag_end"),
	PINCH_START = hash("pinch_start"),
	PINCH = hash("pinch"),
	PINCH_END = hash("pinch_end"),
}


--- Eva built-in game events
M.EVENT = {
	GAME_START = "eva.game.start", --- Game start eva event
	GAME_FOCUS = "eva.game.focus",
	NEW_SESSION = "eva.game.new_session",
	NEW_DAY = "eva.game.new_day",
	IAP_UPDATE = "eva.iaps.update",
	IAP_START = "eva.iaps.start",
	IAP_CANCEL = "eva.iaps.cancel",
	IAP_PURCHASE = "eva.iaps.purchase",
	IAP_VALID = "eva.iaps.valid",
	IAP_INVALID = "eva.iaps.invalid",
	ADS_READY = "eva.ads.ready",
	ADS_SUCCESS_REWARDED = "eva.ads.rewarded_success",
	ADS_SUCCESS = "eva.ads.success",
	ADS_SHOW = "eva.ads.show",
	ADS_ERROR = "eva.ads.error",
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
	LABEL_ADD = "eva.labels.add",
	LABEL_REMOVE = "eva.labels.remove",
	SKILL_USE = "eva.skill.use",
	SKILL_USE_END = "eva.skill.end_use",
	SKILL_COOLDOWN_START = "eva.skill.cooldown",
	SKILL_COOLDOWN_END = "eva.skill.cooldown_end",
	CODE_REDEEM = "eva.promocode.redeem",
	WINDOW_EVENT = "eva.game.window_event",
	RATE_OPEN = "eva.rate.open",
	SOUND_GAIN_CHANGE = "eva.sound.sound_gain_change",
	MUSIC_GAIN_CHANGE = "eva.sound.music_gain_change",
}


M.REASON = {
	IAP = "eva.reason.inapp",
	QUESTS = "eva.reason.quests",
}


--- Iap states
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


--- Inner eva protodata names
M.EVA = {
	ADS = "eva.Ads",
	SOUND = "eva.Sound",
	LANG = "eva.Lang",
	LABELS = "eva.Labels",
	FEATURE = "eva.Feature",
	DEVICE = "eva.Device",
	RATE = "eva.Rate",
	SAVER = "eva.Saver",
	SERVER = "eva.Server",
	GAME = "eva.Game",
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
	CONTAINERS = "eva.Containers",
	SKILLS = "eva.Skills",
	SKILL_CONTAINERS = "eva.SkillContainers",
	STATUSES = "eva.Status",
	PROMOCODES = "eva.Promocodes",

	-- Part of data
	TOKEN = "eva.Token",
	OFFER = "eva.Offer",
	STORAGE_VALUE = "eva.StorageValue",
	TIMER = "eva.Timer",
	IAP_INFO = "eva.IapInfo",
	PUSH_INFO = "eva.PushInfo",
	INVOICE_INFO = "eva.InvoiceInfo",
	TOKEN_RESTORE_CONFIG = "eva.TokenRestoreConfig",
	CONTAINER = "eva.Container",
	SKILL = "eva.Skill",

	TOKENS_DATA = "evadata.Tokens",
}


--- Available daily bonus values
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
			{{0, -1}, {-1, -1}, {-1, 0}, {0, 1}, {1, 0}, {1, -1}}, -- Even rows
			{{0, -1}, {-1, 0}, {-1, 1}, {0, 1}, {1, 1}, {1, 0}}, -- Odd rows
		}
	}
}


M.HEXMAP_TYPE = {
	POINTYTOP = "pointytop",
	FLATTOP = "flattop"
}


--- This is all keys from all.input_binding
M.INPUT_KEYS = {
	hash("key_space"),
	hash("key_exclamationmark"),
	hash("key_doublequote"),
	hash("key_hash"),
	hash("key_dollarsign"),
	hash("key_ampersand"),
	hash("key_singlequote"),
	hash("key_lparen"),
	hash("key_rparen"),
	hash("key_asterisk"),
	hash("key_plus"),
	hash("key_comma"),
	hash("key_minus"),
	hash("key_period"),
	hash("key_slash"),
	hash("key_0"),
	hash("key_1"),
	hash("key_2"),
	hash("key_3"),
	hash("key_4"),
	hash("key_5"),
	hash("key_6"),
	hash("key_7"),
	hash("key_8"),
	hash("key_9"),
	hash("key_colon"),
	hash("key_semicolon"),
	hash("key_lessthan"),
	hash("key_equals"),
	hash("key_greaterthan"),
	hash("key_questionmark"),
	hash("key_at"),
	hash("key_a"),
	hash("key_b"),
	hash("key_c"),
	hash("key_d"),
	hash("key_e"),
	hash("key_f"),
	hash("key_g"),
	hash("key_h"),
	hash("key_i"),
	hash("key_j"),
	hash("key_k"),
	hash("key_l"),
	hash("key_m"),
	hash("key_n"),
	hash("key_o"),
	hash("key_p"),
	hash("key_q"),
	hash("key_r"),
	hash("key_s"),
	hash("key_t"),
	hash("key_u"),
	hash("key_v"),
	hash("key_w"),
	hash("key_x"),
	hash("key_y"),
	hash("key_z"),
	hash("key_lbracket"),
	hash("key_rbracket"),
	hash("key_backslash"),
	hash("key_caret"),
	hash("key_underscore"),
	hash("key_grave"),
	hash("key_lbrace"),
	hash("key_rbrace"),
	hash("key_pipe"),
	hash("key_esc"),
	hash("key_f1"),
	hash("key_f2"),
	hash("key_f3"),
	hash("key_f4"),
	hash("key_f5"),
	hash("key_f6"),
	hash("key_f7"),
	hash("key_f8"),
	hash("key_f9"),
	hash("key_f10"),
	hash("key_f11"),
	hash("key_f12"),
	hash("key_up"),
	hash("key_down"),
	hash("key_left"),
	hash("key_right"),
	hash("key_lshift"),
	hash("key_rshift"),
	hash("key_lctrl"),
	hash("key_rctrl"),
	hash("key_lalt"),
	hash("key_ralt"),
	hash("key_tab"),
	hash("key_enter"),
	hash("key_backspace"),
	hash("key_insert"),
	hash("key_del"),
	hash("key_pageup"),
	hash("key_pagedown"),
	hash("key_home"),
	hash("key_end"),
	hash("key_numpad_0"),
	hash("key_numpad_1"),
	hash("key_numpad_2"),
	hash("key_numpad_3"),
	hash("key_numpad_4"),
	hash("key_numpad_5"),
	hash("key_numpad_6"),
	hash("key_numpad_7"),
	hash("key_numpad_8"),
	hash("key_numpad_9"),
	hash("key_numpad_divide"),
	hash("key_numpad_multiply"),
	hash("key_numpad_subtract"),
	hash("key_numpad_add"),
	hash("key_numpad_decimal"),
	hash("key_numpad_equal"),
	hash("key_numpad_enter"),
	hash("key_numpad_numlock"),
	hash("key_capslock"),
	hash("key_scrolllock"),
	hash("key_pause"),
	hash("key_lsuper"),
	hash("key_rsuper"),
	hash("key_menu"),
	hash("key_back"),

	-- from mouse some triggers
	hash("mouse_wheel_down"),
	hash("mouse_wheel_up"),
}


--- Eva built-in input swipe directions
M.INPUT_SWIPE = {
	UP = "up",
	RIGHT = "right",
	DOWN = "down",
	LEFT = "left"
}


--- Vibrate constants for eva.vibrate
M.VIBRATE = {
	LIGHT = {
		Android = 1, -- in milliseconds
		iOS = 1
	},
	MEDIUM = {
		Android = 50,
		iOS = 2
	},
	HEAVY = {
		Android = 200,
		iOS = 3
	},
}


--- Reserved strings for eva.storage values from other modules
M.STORAGE = {
	VIBRATE_IS_ENABLED = "eva.vibrate.is_enabled"
}


-- List of days in every month
M.DAYS_IN_MONTH = { 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 }

return M
