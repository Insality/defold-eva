local settings = require("eva.settings.default")

local M = {}

local props = { gain = 1 }
local sound_times = {}

local sound_prefs = {
	sound_gain = 0,
	music_gain = 0
}

function M.play(sound_id, gain)
	gain = gain or 1

	-- if not save.data.settings.sound then
	-- 	return
	-- end
	local threshold = settings.sound.repeat_threshold
	if sound_times[sound_id] and (socket.gettime() - sound_times[sound_id]) < threshold then
		return
	end

	props.gain = gain
	sound.play(settings.sound.sound_path .. sound_id, props)

	sound_times[sound_id] = socket.gettime()
end


function M.play_music(music_id)

end


function M.stop_music()

end


function M.fade_music(from, to)

end


function M.on_game_start()
	M._eva.saver.add_save_part("eva.sound", sound_prefs)
end

return M
