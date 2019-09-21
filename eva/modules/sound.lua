local settings = require("eva.settings.default")

local M = {}

local props = { gain = 1 }
local sound_times = {}


function M.play(sound_id, gain)
	gain = gain or 1

	if M._sound_prefs.sound_gain == 0 then
		return
	end

	local threshold = settings.sound.repeat_threshold
	if sound_times[sound_id] and (socket.gettime() - sound_times[sound_id]) < threshold then
		return
	end

	props.gain = gain
	sound.play(settings.sound.sound_path .. sound_id, props)

	sound_times[sound_id] = socket.gettime()
end


function M.play_music(music_id)
	if M._sound_prefs.music_gain == 0 then
		return
	end

	M.stop_music()
	sound.set_group_gain("music", 1)
	M.current_music = settings.sound.sound_path .. music_id
	sound.play(M.current_music)
end


function M.stop_music()
	if M.current_music then
		sound.stop(M.current_music)
		M.current_music = nil
	end
end


function M.fade_music(from, to)
	-- TODO: Implement me
end


function M.stop_all()
	-- TODO: Implement me
end


function M.on_game_start()
	local is_debug = not M._eva.game.is_debug()
	M._sound_prefs = M._eva.proto.get("eva.Sound")
	M._sound_prefs.sound_gain = is_debug and 0 or 1
	M._sound_prefs.music_gain = is_debug and 0 or 1

	M._eva.saver.add_save_part("eva.Sound", M._sound_prefs)
end


return M
