-- Eva yandex ads plugin
-- @local

local yagames = require("yagames.yagames")
local game = require("eva.modules.game")
local device = require("eva.modules.device")
local sound = require("eva.modules.sound")
local app = require("eva.app")
local log = require("eva.log")

local logger = log.get_logger("ads.yandex")

local Ads = {}
Ads._on_ready_callback = nil
Ads._sound_gain = nil
Ads._music_gain = nil

local function mute_sounds()
	Ads._music_gain = sound.get_music_gain()
	Ads._sound_gain = sound.get_sound_gain()
	sound.set_music_gain(0)
	sound.set_sound_gain(0)
end


local function return_sounds()
	sound.set_music_gain(Ads._music_gain)
	sound.set_sound_gain(Ads._sound_gain)
end


function Ads.initialize(ads_id, on_ready_callback)
	Ads._on_ready_callback = on_ready_callback
	Ads._music_gain = sound.get_music_gain()
	Ads._sound_gain = sound.get_sound_gain()
end


function Ads.is_ready(ad_id, ad_config)
	return true
end


local function show_interstitial(ad_id, success_callback, finish_callback, error_callback)
	yagames.adv_show_fullscreen_adv({
		open = function()
			logger:debug("Open interstitial", { ad_id = ad_id })
			mute_sounds()
		end,
		close = function(self, was_shown)
			logger:debug("Close interstitial", { ad_id = ad_id })
			return_sounds()
			if was_shown then
				finish_callback(ad_id)
				success_callback(ad_id)
			end
		end,
		offline = function()
			error_callback(ad_id)
			logger:debug("Offline interstitial", { ad_id = ad_id })
		end,
		error = function()
			error_callback(ad_id)
			logger:debug("Error interstitial", { ad_id = ad_id })
		end
	})
end


local function show_rewarded(ad_id, success_callback, finish_callback, error_callback)
	yagames.adv_show_rewarded_video({
		open = function()
			logger:debug("Open rewarded", { ad_id = ad_id })
			mute_sounds()
		end,
		close = function()
			logger:debug("Close rewarded", { ad_id = ad_id })
			return_sounds()
		end,
		rewarded = function()
			logger:debug("Success rewarded", { ad_id = ad_id })
			finish_callback(ad_id)
			success_callback(ad_id)
		end,
		error = function()
			error_callback(ad_id)
			logger:debug("Error rewarded", { ad_id = ad_id })
		end
	})
end


function Ads.show(ad_id, ad_config, success_callback, finish_callback, error_callback)
	if (game.is_debug() and device.is_desktop()) or not yagames then
		finish_callback(ad_id)
		success_callback(ad_id)
		return
	end

	if ad_config.type == "rewardedVideo" then
		show_rewarded(ad_id, success_callback, finish_callback, error_callback)
	end
	if ad_config.type == "video" then
		show_interstitial(ad_id, success_callback, finish_callback, error_callback)
	end
end


return Ads
