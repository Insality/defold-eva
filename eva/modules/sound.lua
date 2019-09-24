--- Defold-Eva sound module
-- @submodule eva

local const = require("eva.const")

local M = {}

local props = { gain = 1 }
local sound_times = {}


--- Play the sound in the game
-- @function eva.sound.play
function M.play(sound_id, gain)
	gain = gain or 1

	if M._sound_prefs.sound_gain == 0 then
		return
	end

	local threshold = M.settings.repeat_threshold
	if sound_times[sound_id] and (socket.gettime() - sound_times[sound_id]) < threshold then
		return
	end

	props.gain = gain
	sound.play(M.settings.sound_path .. sound_id, props)

	sound_times[sound_id] = socket.gettime()
end


--- Start playing music
-- @function eva.sound.play_music
function M.play_music(music_id)
	if M._sound_prefs.music_gain == 0 then
		return
	end

	M.stop_music()
	sound.set_group_gain("music", 1)
	M.current_music = M.settings.sound_path .. music_id
	sound.play(M.current_music)
end


--- Stop any music in the game
-- @function eva.sound.stop_music
function M.stop_music()
	if M.current_music then
		sound.stop(M.current_music)
		M.current_music = nil
	end
end


--- Slowly fade music to another one or empty
-- @function eva.sound.fade_music
function M.fade_music(from, to)
	-- TODO: Implement me
end


--- Stop all sounds in the game
-- @function eva.sound.stop_all
function M.stop_all()
	M.stop_music()
	-- TODO: Implement sounds
end


--- Set music gain
-- @function eva.sound.set_music_gain
function M.set_music_gain(value)
	M._sound_prefs.music_gain = value or 0
end


--- Set sound gain
-- @function eva.sound.set_sound_gain
function M.set_sound_gain(value)
	M._sound_prefs.sound_gain = value or 0
end


function M.before_game_start(settings)
	M.settings = settings
end


function M.on_game_start()
	local is_debug = not M._eva.game.is_debug()
	M._sound_prefs = M._eva.proto.get(const.EVA.SOUND)
	M._sound_prefs.sound_gain = is_debug and 0 or 1
	M._sound_prefs.music_gain = is_debug and 0 or 1

	M._eva.saver.add_save_part(const.EVA.SOUND, M._sound_prefs)
end


return M
