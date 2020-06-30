--- Eva sound module
-- Carry on any sound and music in the game
-- @submodule eva


local app = require("eva.app")
local const = require("eva.const")

local proto = require("eva.modules.proto")
local saver = require("eva.modules.saver")

local M = {}


--- Play the sound in the game
-- @function eva.sound.play
function M.play(sound_id, gain)
	gain = gain or 1

	if app[const.EVA.SOUND].sound_gain == 0 then
		return
	end

	local sound_times = app.sound_times
	local settings = app.settings.sound
	local threshold = settings.repeat_threshold

	if sound_times[sound_id] and (socket.gettime() - sound_times[sound_id]) < threshold then
		return
	end

	app.sound_props.gain = gain
	sound.play(settings.sound_path .. sound_id, app.sound_props)

	sound_times[sound_id] = socket.gettime()
end


--- Start playing music
-- @function eva.sound.play_music
function M.play_music(music_id)
	if app[const.EVA.SOUND].music_gain == 0 then
		return
	end

	M.stop_music()
	sound.set_group_gain("music", 1)
	local settings = app.settings.sound
	M.current_music = settings.sound_path .. music_id
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
	app[const.EVA.SOUND].music_gain = value or 0
end


--- Set sound gain
-- @function eva.sound.set_sound_gain
function M.set_sound_gain(value)
	app[const.EVA.SOUND].sound_gain = value or 0
end


--- Check music gain
-- @function eva.sound.is_music_enabled
function M.is_music_enabled(value)
	return app[const.EVA.SOUND].music_gain > 0
end


--- Check sound gain
-- @function eva.sound.is_sound_enabled
function M.is_sound_enabled(value)
	return app[const.EVA.SOUND].sound_gain > 0
end


function M.on_eva_init()
	local is_debug = sys.get_engine_info().is_debug

	app[const.EVA.SOUND] = proto.get(const.EVA.SOUND)
	app[const.EVA.SOUND].sound_gain = is_debug and 0 or 1
	app[const.EVA.SOUND].music_gain = is_debug and 0 or 1
	saver.add_save_part(const.EVA.SOUND, app[const.EVA.SOUND])

	app.sound_props = { gain = 1 }
	app.sound_times = {}
end


return M
