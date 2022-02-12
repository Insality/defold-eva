--- Eva sound module
-- Carry on any sound and music in the game
-- @submodule eva


local app = require("eva.app")
local const = require("eva.const")
local luax = require("eva.luax")

local proto = require("eva.modules.proto")
local saver = require("eva.modules.saver")
local events = require("eva.modules.events")

local M = {}



--- Get the sound url by sound id
-- @tparam string sound_id
-- @treturn url
-- @local
local function get_sound_url(sound_id)
	return app.settings.sound.sound_path .. sound_id
end


--- Set gain for sound
-- @tparam string sound_id
-- @tparam number gain
-- @local
local function set_gain(sound_id, gain)
	sound.set_gain(get_sound_url(sound_id), gain)
	app.sound_data.last_gains[sound_id] = gain
end


--- Play the sound in the game
-- @function eva.sound.play
-- @tparam string sound_id
-- @tparam[opt=1] number gain
-- @tparam[opt=1] number speed
function M.play(sound_id, gain, speed)
	gain = gain or app.sound_data.last_gains[sound_id] or 1
	speed = speed or 1

	if app[const.EVA.SOUND].sound_gain == 0 then
		return
	end

	local sound_times = app.sound_data.times
	local settings = app.settings.sound
	local threshold = settings.repeat_threshold

	if sound_times[sound_id] and (socket.gettime() - sound_times[sound_id]) < threshold then
		return
	end

	app.sound_data.props.gain = gain
	app.sound_data.props.speed = speed
	sound.play(get_sound_url(sound_id), app.sound_data.props)

	sound_times[sound_id] = socket.gettime()
end


--- Play the random sound from sound names array
-- @function eva.sound.play_random
-- @tparam string[] sound_ids
-- @tparam[opt=1] number gain
-- @tparam[opt=1] number speed
function M.play_random(sound_ids, gain, speed)
	M.play(luax.table.random(sound_ids), gain, speed)
end


--- Stop sound playing
-- @function eva.sound.stop
-- @tparam string sound_id
function M.stop(sound_id)
	sound.stop(get_sound_url(sound_id))
end


--- Start playing music
-- @function eva.sound.play_music
-- @tparam string music_id
-- @tparam[opt=1] number gain
-- @tparam[opt] function callback
function M.play_music(music_id, gain, on_end_play_callback)
	if app[const.EVA.SOUND].music_gain == 0 then
		return
	end

	local prev_music = M.current_music
	M.stop_music()

	if prev_music then
		gain = gain or app.sound_data.last_gains[prev_music]
	end

	gain = gain or 1
	M.current_music = music_id
	set_gain(M.current_music, gain)
	sound.play(get_sound_url(M.current_music), { gain = gain }, on_end_play_callback)
end


--- Stop any music in the game
-- @function eva.sound.stop_music
function M.stop_music()
	if M.current_music then
		sound.stop(get_sound_url(M.current_music))
		M.current_music = nil
	end
end


--- Fade sound from one gain to another
-- @function eva.sound.fade
-- @tparam string sound_id
-- @tparam number to
-- @tparam[opt=1] number time
-- @tparam[opt] function callback
function M.fade(sound_id, to, time)
	local from = app.sound_data.last_gains[sound_id] or 1
	set_gain(sound_id, from)

	local gain = from
	local delta = math.abs(to - from)
	local step = delta * (1/60) / time

	table.insert(app.sound_data.fades, {
		sound_id = sound_id,
		gain = gain,
		step = step,
		to = to,
	})
end


--- Slowly fade music to another one or empty
-- @function eva.sound.fade_music
-- @tparam number to
-- @tparam[opt=1] number time
-- @tparam function callback
function M.fade_music(to, time, callback)
	if M.current_music then
		M.fade(M.current_music, to, time or 1)
		if callback then
			timer.delay(time, false, callback)
		end
	else
		if callback then
			callback()
		end
	end
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
	events.event(const.EVENT.MUSIC_GAIN_CHANGE, app[const.EVA.SOUND].music_gain)
end


--- Set sound gain
-- @function eva.sound.set_sound_gain
function M.set_sound_gain(value)
	app[const.EVA.SOUND].sound_gain = value or 0
	events.event(const.EVENT.SOUND_GAIN_CHANGE, app[const.EVA.SOUND].sound_gain)
end


--- Get music gain
-- @function eva.sound.get_music_gain
function M.get_music_gain()
	return app[const.EVA.SOUND].music_gain
end


--- Get sound gain
-- @function eva.sound.get_sound_gain
function M.get_sound_gain()
	return app[const.EVA.SOUND].sound_gain
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

	app.sound_data = {
		props = { gain = 1, speed = 1},
		times = {},
		last_gains = {},
		fades = {},
	}
end


function M.on_eva_update(dt)
	local fades = app.sound_data.fades
	for index = #fades, 1, -1 do
		local fade_data = fades[index]

		fade_data.gain = luax.math.step(fade_data.gain, fade_data.to, fade_data.step)
		set_gain(fade_data.sound_id, fade_data.gain)
		if fade_data.gain == fade_data.to then
			table.remove(fades, index)
		end
	end
end


return M
