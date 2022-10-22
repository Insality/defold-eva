#!/usr/bin/lua
local M = {}
M.Version = 'VERSION'
M.VersionDate = 'DATESTAMP'

---------------------------- private -----------------------------

local previous_warning = '' -- 5.4
local previous_times = 0    -- 5.4
local function clean_up_warnings() -- 5.4
	-- Call this before returning from any publicly callable function
	-- whenever there's a possibility that a warning might have been printed
	-- by the function, or by any private functions it might have called.
	if previous_times > 1 then
		io.stderr:write('  previous message repeated '
		 ..previous_times..' times\n')
	elseif previous_times > 0 then
		io.stderr:write('  previous message repeated\n')
	end
	previous_times = 0
	previous_warning = ''
end
local function warn(str)
	if str == previous_warning then -- 5.4
		previous_times = previous_times + 1
	else
		clean_up_warnings()
		io.stderr:write(str,'\n')
		previous_warning = str
	end
end
local function die(str)
	clean_up_warnings()
	io.stderr:write(str,'\n')
	os.exit(1)
end

local function readOnly(t)  -- Programming in Lua, page 127
	local proxy = {}
	local mt = {
		__index = t,
		__newindex = function (t, k, v)
			die("attempt to update a read-only table")
		end
	}
	setmetatable(proxy, mt)
	return proxy
end

local function sorted_keys(t)
	local a = {}
	for k,v in pairs(t) do a[#a+1] = k end
	table.sort(a)
	return  a
end

local function twobytes2int(s)
	return 256*string.byte(string.sub(s,1)) + string.byte(string.sub(s,2))
end

local function fourbytes2int(s)
	return 16777216*string.byte(string.sub(s,1)) +
	 65536 * string.byte(string.sub(s,2)) +
	 256*string.byte(string.sub(s,3)) + string.byte(string.sub(s,4))
end

local function read_14_bit(byte_a)
	-- decode a 14 bit quantity from two bytes,
	return string.byte(byte_a,1) + 128 * string.byte(byte_a,2)
end

local function str2ber_int(s, start)
--[[Given (a string, and a position within it), returns
(the ber_integer at that position, and the position after the ber_integer).
]]
	local i = start
	local integer = 0
	while true do
		local byte = string.byte(s, i)
		integer = integer + (byte%128)
		if byte < 127.5 then
			return integer, i+1
		end
		if i >= #s then
			warn('str2ber_int: no end-of-integer found')
			return 0, start
		end
		i = i + 1
		integer = integer * 128
	end
end


local function copy(t)
	local new_table = {}
	for k, v in pairs(t) do new_table[k] = v end
	return new_table
end

local function _decode(trackdata, exclude, include, event_callback, exclusive_event_callback, no_eot_magic)
--[[Decodes MIDI track data into an opus-style list of events.
The options:
  'exclude' is a dictionary-table of event types which will be ignored
  'include' (and no exclude), makes exclude an array of all
      possible events, /minus/ what include specifies
  'event_callback' is a function
  'exclusive_event_callback' is a function
]]

	if not trackdata then trackdata= '' end
	if not exclude then exclude = {} end
	if not include then include = {} end
	if include and not exclude then exclude = M.All_events end  -- 4.6

	local event_code = -1 -- used for running status
	local event_count = 0
	local events = {}

	local i = 1     -- in Lua, i is the pointer to within the trackdata
	while i < #trackdata do   -- loop while there's anything to analyze
		local eot = false -- when True event registrar aborts this loop 4.6,4.7
   		event_count = event_count + 1

		local E = {} -- event; feed it to the event registrar at the end. 4.7

		-- Slice off the delta time code, and analyze it
		local time
		time, i = str2ber_int(trackdata, i)

		-- Now let's see what we can make of the command
		local first_byte = string.byte(trackdata,i); i = i+1

		if first_byte < 240 then  -- It's a MIDI event
			if first_byte % 256 > 127 then
				event_code = first_byte
			else
				-- It wants running status; use last event_code value
				i = i-1
				if event_code == -1 then
					warn("Running status not set; Aborting track.")
					return {}
				end
			end

			local command = math.floor(event_code / 16) * 16
			local channel = event_code % 16
			local parameter
			local param1
			local param2

			if command == 246 then  --  0-byte argument
				--pass
			elseif command == 192 or command == 208 then  --  1-byte arg
				parameter = string.byte(trackdata, i); i = i+1
			else -- 2-byte argument could be BB or 14-bit
				param1 = string.byte(trackdata, i); i = i+1
				param2 = string.byte(trackdata, i); i = i+1
			end

			----------------- MIDI events -----------------------

			local continue = false
			if command      == 128 then
				if exclude['note_off'] then
					continue = true
				else
					E = {'note_off', time, channel, param1, param2}
				end
			elseif command == 144 then
				if exclude['note_on'] then
					continue = true
				else
					E = {'note_on', time, channel, param1, param2}
				end
			elseif command == 160 then
				if exclude['key_after_touch'] then
					continue = true
				else
					E = {'key_after_touch',time,channel,param1,param2}
				end
			elseif command == 176 then
				if exclude['control_change'] then
					continue = true
				else
					E = {'control_change',time,channel,param1,param2}
				end
			elseif command == 192 then
				if exclude['patch_change'] then
					continue = true
				else
					E = {'patch_change', time, channel, parameter}
				end
			elseif command == 208 then
				if exclude['channel_after_touch'] then
					continue = true
				else
					E = {'channel_after_touch', time, channel, parameter}
				end
			elseif command == 224 then
				if exclude['pitch_wheel_change'] then
					continue = true
				else -- the 2 param bytes are a 14-bit int
					E = {'pitch_wheel_change', time, channel,
					 128*param2+param1-8192}
				end
			else
				warn("Shouldn't get here; command="..tostring(command))
			end

		elseif first_byte == 255 then  -- It's a Meta-Event!
			local command = string.byte(trackdata, i); i = i+1
			local length
			length, i = str2ber_int(trackdata, i)
			if (command      == 0) then
				if length == 2 then  -- 3.9
					E = {'set_sequence_number', time,
					 twobytes2int(string.sub(trackdata,i,i+1)) }
				else
					warn('set_sequence_number: length must be 2, not '
					 .. tostring(length))
					E = {'set_sequence_number', time, 0}
				end

			-- Defined text events ------
			elseif command == 1 then
				E = {'text_event', time, string.sub(trackdata,i,i+length-1)}
			elseif command == 2 then  -- 4.9
				E = {'copyright_text_event', time, string.sub(trackdata,i,i+length-1)}
			elseif command == 3 then
				E = {'track_name',time, string.sub(trackdata,i,i+length-1)}
			elseif command == 4 then
				E = {'instrument_name',time, string.sub(trackdata,i,i+length-1)}
			elseif command == 5 then
				E = {'lyric',time, string.sub(trackdata,i,i+length-1)}
			elseif command == 6 then
				E = {'marker',time, string.sub(trackdata,i,i+length-1)}
			elseif command == 7 then
				E = {'cue_point',time, string.sub(trackdata,i,i+length-1)}

			-- Reserved but apparently unassigned text events -------------
			elseif command == 8 then
				E = {'text_event_08',time, string.sub(trackdata,i,i+length-1)}
			elseif command == 9 then
				E = {'text_event_09',time, string.sub(trackdata,i,i+length-1)}
			elseif command == 10 then
				E = {'text_event_0a',time, string.sub(trackdata,i,i+length-1)}
			elseif command == 11 then
				E = {'text_event_0b',time, string.sub(trackdata,i,i+length-1)}
			elseif command == 12 then
				E = {'text_event_0c',time, string.sub(trackdata,i,i+length-1)}
			elseif command == 13 then
				E = {'text_event_0d',time, string.sub(trackdata,i,i+length-1)}
			elseif command == 14 then
				E = {'text_event_0e',time, string.sub(trackdata,i,i+length-1)}
			elseif command == 15 then
				E = {'text_event_0f',time, string.sub(trackdata,i,i+length-1)}

			-- Now the sticky events -------------------------------------
			elseif command == 47 then
				E = {'end_track', time}
				-- The code for handling this, oddly, comes LATER,
				-- in the event registrar.
			elseif command == 81 then -- DTime, Microseconds/Crochet
				if length ~= 3 then
					warn('set_tempo event, but length='..length)
				end
				E = {'set_tempo', time,
					string.byte(trackdata,i) * 65536
					+ string.byte(trackdata,i+1) * 256
					+ string.byte(trackdata,i+2)
				}
			elseif command == 84 then
				if length ~= 5 then   -- DTime, HR, MN, SE, FR, FF
					warn('smpte_offset event, but length='..length)
				end
				E = {'smpte_offset', time,
					string.byte(trackdata,i),
					string.byte(trackdata,i+1),
					string.byte(trackdata,i+2),
					string.byte(trackdata,i+3),
					string.byte(trackdata,i+4)
				}
			elseif command == 88 then
				if length ~= 4 then   -- DTime, NN, DD, CC, BB
					warn('time_signature event, but length='..length)
				end
				E = {'time_signature', time,
					string.byte(trackdata,i),
					string.byte(trackdata,i+1),
					string.byte(trackdata,i+2),
					string.byte(trackdata,i+3)
				}
			elseif command == 89 then
				if length ~= 2 then   -- DTime, SF(signed), MI
					warn('key_signature event, but length='..length)
				end
				local b1 = string.byte(trackdata,i)
				if b1 > 127 then b1 = b1 - 256 end   -- signed byte :-(
				local b2 = string.byte(trackdata,i+1)
				-- list(struct.unpack(">bB",trackdata[0:2]))}
				E = {'key_signature', time, b1, b2 }
			elseif (command == 127) then
				E = {'sequencer_specific',time,
					string.sub(trackdata,i,i+length-1)}
			else
				E = {'raw_meta_event', time, command,
					string.sub(trackdata,i,i+length-1)}
				--"[uninterpretable meta-event command of length length]"
				-- DTime, Command, Binary Data
				-- It's uninterpretable; record it as raw_data.
			end

			-- Pointer += length; --  Now move Pointer
			i = i + length
			-- Hmm... in lua, we should be using Pointer again....
			-- trackdata =  string.sub(trackdata, length+1)

		--#####################################################################
		elseif first_byte == 240 or first_byte == 247 then
			-- Note that sysexes in MIDI /files/ are different than sysexes
			-- in MIDI transmissions!! The vast majority of system exclusive
			-- messages will just use the F0 format. For instance, the
			-- transmitted message F0 43 12 00 07 F7 would be stored in a
			-- MIDI file as F0 05 43 12 00 07 F7. As mentioned above, it is
			-- required to include the F7 at the end so that the reader of the
			-- MIDI file knows that it has read the entire message. (But the F7
			-- is omitted if this is a non-final block in a multiblock sysex;
			-- but the F7 (if there) is counted in the message's declared
			-- length, so we don't have to think about it anyway.)
			--command = trackdata.pop(0)
			local length
			length, i = str2ber_int(trackdata, i)
			if first_byte == 240 then
				-- 20091008 added ISO-8859-1 to get an 8-bit str
				E = {'sysex_f0', time, string.sub(trackdata,i,i+length-1)}
			else
				E = {'sysex_f7', time, string.sub(trackdata,i,i+length-1)}
			end
			i = i + length
			-- trackdata =  string.sub(trackdata, length+1)

		--#####################################################################
		-- Now, the MIDI file spec says:
		--  <track data> = <MTrk event>+
		--  <MTrk event> = <delta-time> <event>
		--  <event> = <MIDI event> | <sysex event> | <meta-event>
		-- I know that, on the wire, <MIDI event> can include note_on,
		-- note_off, and all the other 8x to Ex events, AND Fx events
		-- other than F0, F7, and FF -- namely, <song position msg>,
		-- <song select msg>, and <tune request>.
		--
		-- Whether these can occur in MIDI files is not clear specified
		-- from the MIDI file spec.  So, I'm going to assume that
		-- they CAN, in practice, occur.  I don't know whether it's
		-- proper for you to actually emit these into a MIDI file.

		elseif first_byte == 242 then   -- DTime, Beats
			--  <song position msg> ::=     F2 <data pair>
			E = {'song_position', time, read_14_bit(string.sub(trackdata,i))}
			trackdata = string.sub(trackdata,3)

		elseif first_byte == 243 then -- <song select> ::= F3 <data singlet>
			-- E=['song_select', time, struct.unpack('>B',trackdata.pop(0))[0]]
			E = {'song_select', time, string.byte(trackdata,i)}
			-- trackdata = trackdata[1:]
			trackdata = string.sub(trackdata,2)
			-- DTime, Thing (what?! song number?  whatever ...)

		elseif first_byte == 246 then   -- DTime
			E = {'tune_request', time}
			-- What would a tune request be doing in a MIDI /file/?

		--########################################################
		-- ADD MORE META-EVENTS HERE.  TODO:
		-- f1 -- MTC Quarter Frame Message. One data byte follows
		--     the Status; it's the time code value, from 0 to 127.
		-- f8 -- MIDI clock.    no data.
		-- fa -- MIDI start.    no data.
		-- fb -- MIDI continue. no data.
		-- fc -- MIDI stop.     no data.
		-- fe -- Active sense.  no data.
		-- f4 f5 f9 fd -- unallocated

--[[
		elseif (first_byte > 240) { -- Some unknown kinda F-series event ####
			-- Here we only produce a one-byte piece of raw data.
			-- But the encoder for 'raw_data' accepts any length of it.
			E = [ 'raw_data', time, substr(trackdata,Pointer,1) ]
			-- DTime and the Data (in this case, the one Event-byte)
			++Pointer;  -- itself

]]
		elseif first_byte > 240 then  -- Some unknown F-series event
			-- Here we only produce a one-byte piece of raw data.
			E = {'raw_data', time, string.byte(trackdata,i)}  -- 4.6
			trackdata = string.sub(trackdata,2)  -- 4.6
		else  -- Fallthru.
			warn(string.format("Aborting track.  Command-byte first_byte=0x%x",first_byte)) --4.6
			break
		end
		-- End of the big if-group


		--#####################################################################
		--  THE EVENT REGISTRAR...
		-- warn('3: E='+str(E))
		if E and  E[1] == 'end_track' then
			-- This is the code for exceptional handling of the EOT event.
			eot = true
			if not no_eot_magic then
				if E[2] > 0 then  -- a null text-event to carry the delta-time
					E = {'text_event', E[2], ''}  -- 4.4
				else
					E = nil   -- EOT with a delta-time of 0; ignore it.
				end
			end
		end

		if E and not exclude[E[1]] then
			--if ( $exclusive_event_callback ):
			--    &{ $exclusive_event_callback }( @E );
			--else
			--    &{ $event_callback }( @E ) if $event_callback;
			events[#events+1] = E
		end
		if eot then break end
	end
	-- End of the big "Event" while-block

	return events
end


-------------------------- public ------------------------------
M.All_events = readOnly{
	note_off=true, note_on=true, key_after_touch=true, control_change=true,
	patch_change=true, channel_after_touch=true, pitch_wheel_change=true,
	text_event=true, copyright_text_event=true, track_name=true,
	instrument_name=true, lyric=true, marker=true, cue_point=true,
	text_event_08=true, text_event_09=true, text_event_0a=true,
	text_event_0b=true, text_event_0c=true, text_event_0d=true,
	text_event_0e=true, text_event_0f=true,
	end_track=true, set_tempo=true, smpte_offset=true,
	time_signature=true, key_signature=true,
	sequencer_specific=true, raw_meta_event=true,
	sysex_f0=true, sysex_f7=true,
	song_position=true, song_select=true, tune_request=true,
}

function M.midi2ms_score(midi)
	return M.opus2score(M.to_millisecs(M.midi2opus(midi)))
end

function M.midi2opus(s)
	if not s then s = '' end
	--my_midi=bytearray(midi)
	if #s < 4 then return {1000,{},} end
	local i = 1
	local id = string.sub(s, i, i+3); i = i+4
	if id ~= 'MThd' then
		warn("midi2opus: midi starts with "..id.." instead of 'MThd'")
		clean_up_warnings()
		return {1000,{},}
	end
	-- h:short; H:unsigned short; i:int; I:unsigned int;
	-- l:long; L:unsigned long; f:float; d:double.
	-- [length, format, tracks_expected, ticks] = struct.unpack(
	--  '>IHHH', bytes(my_midi[4:14]))  is this 10 bytes or 14 ?
	-- NOT 2+4+4+4 grrr...   'MHhd'+4+2+2+2 !
	local length          = fourbytes2int(string.sub(s,i,i+3)); i = i+4
	i = i+2
	i = i+2
	local ticks           = twobytes2int(string.sub(s,i,i+1)); i = i+2
	if length ~= 6 then
		warn("midi2opus: midi header length was "..tostring(length).." instead of 6")
		clean_up_warnings()
		return {1000,{},}
	end
	local my_opus = {ticks,}
	local track_num = 1   -- 5.1
	while i < #s-8 do
		local track_type   = string.sub(s, i, i+3); i = i+4
		if track_type ~= 'MTrk' then
			warn('midi2opus: Warning: track #'..track_num..' type is '..track_type.." instead of 'MTrk'")
		end
		local track_length = fourbytes2int(string.sub(s,i,i+3)); i = i+4
		if track_length > #s then
			warn('midi2opus: track #'..track_num..' length '..track_length..' is too large')
			clean_up_warnings()
			return my_opus  -- 4.9
		end
		local my_midi_track = string.sub(s, i, i+track_length-1) -- 4.7
		i = i+track_length
		local my_track = _decode(my_midi_track) -- 4.7
		my_opus[#my_opus+1] = my_track
		track_num = track_num + 1   -- 5.1
	end
	clean_up_warnings()
	return my_opus
end

function M.midi2score(midi)
	return M.opus2score(M.midi2opus(midi))
end

function M.opus2score(opus)
	if opus == nil or #opus < 2 then return {1000,{},} end
	local ticks = opus[1]
	local score = {ticks,}
	local itrack = 2; while itrack <= #opus do
		local opus_track = opus[itrack]
		local ticks_so_far = 0
		local score_track = {}
		local chapitch2note_on_events = {}   -- 4.0
		local k; for k,opus_event in ipairs(opus_track) do
			ticks_so_far = ticks_so_far + opus_event[2]
			if opus_event[1] == 'note_off' or
			 (opus_event[1] == 'note_on' and opus_event[5] == 0) then -- 4.8
				local cha = opus_event[3]  -- 4.0
				local pitch = opus_event[4]
				local key = cha*128 + pitch  -- 4.0
				local pending_notes = chapitch2note_on_events[key] -- 5.3
				if pending_notes and #pending_notes > 0 then
					local new_e = table.remove(pending_notes, 1)
					new_e[3] = ticks_so_far - new_e[2]
					score_track[#score_track+1] = new_e
				elseif pitch > 127 then
					warn('opus2score: note_off with no note_on, bad pitch='
					 ..tostring(pitch))
				else
					warn('opus2score: note_off with no note_on cha='
					 ..tostring(cha)..' pitch='..tostring(pitch))
				end
			elseif opus_event[1] == 'note_on' then
				local cha = opus_event[3]  -- 4.0
				local pitch = opus_event[4]
				local new_e = {'note',ticks_so_far,0,cha,pitch,opus_event[5]}
				local key = cha*128 + pitch  -- 4.0
				if chapitch2note_on_events[key] then
					table.insert(chapitch2note_on_events[key], new_e)
				else
					chapitch2note_on_events[key] = {new_e,}
				end
			else
				local new_e = copy(opus_event)
				new_e[2] = ticks_so_far
				score_track[#score_track+1] = new_e
			end
		end
		-- check for unterminated notes (Oisín) -- 5.2
		for chapitch,note_on_events in pairs(chapitch2note_on_events) do
			for k,new_e in ipairs(note_on_events) do
				new_e[3] = ticks_so_far - new_e[2]
				score_track[#score_track+1] = new_e
				--warn("adding unterminated note: {'"..new_e[1].."', "..new_e[2]
				-- ..', '..new_e[3]..', '..new_e[4]..', '..new_e[5]..'}')
				warn("opus2score: note_on with no note_off cha="..new_e[4]
				 ..' pitch='..new_e[5]..'; adding note_off at end')
			end
		end
		score[#score+1] = score_track
		itrack = itrack + 1
	end
	clean_up_warnings()
	return score
end

function M.to_millisecs(old_opus)   -- 6.7
	if old_opus == nil then return {1000,{},}; end
	local old_tpq  = old_opus[1]
	local new_opus = {1000,}
	-- 6.7 first go through building a dict of set_tempos by absolute-tick
	local ticks2tempo = {}
	local itrack = 2
	while itrack <= #old_opus do
		local ticks_so_far = 0
		local k; for k,old_event in ipairs(old_opus[itrack]) do
			if old_event[1] == 'note' then
				warn('to_millisecs needs an opus, not a score')
				clean_up_warnings()
				return {1000,{},}
			end
			ticks_so_far = ticks_so_far + old_event[2]
			if old_event[1] == 'set_tempo' then
				ticks2tempo[ticks_so_far] = old_event[3]
			end
		end
		itrack = itrack + 1
	end
	--  then get the sorted-array of their keys
	local tempo_ticks = sorted_keys(ticks2tempo)
	--  then go through converting to millisec, testing if the next
	--  set_tempo lies before the next track-event, and using it if so.
	local itrack = 2
	while itrack <= #old_opus do
		local ms_per_old_tick = 500.0 / old_tpq -- will be rounded later 6.3
		local i_tempo_ticks = 1
		local ticks_so_far = 0
		local ms_so_far = 0.0
		local previous_ms_so_far = 0.0
		local new_track = {{'set_tempo',0,1000000},}  -- new "crochet" is 1 sec
		local k; for k,old_event in ipairs(old_opus[itrack]) do
			-- detect if ticks2tempo has something before this event
			-- If ticks2tempo is at the same time, don't handle it yet.
			local event_delta_ticks = old_event[2]
			if i_tempo_ticks <= #tempo_ticks and
			  tempo_ticks[i_tempo_ticks] < (ticks_so_far + old_event[2]) then
				local delta_ticks = tempo_ticks[i_tempo_ticks] - ticks_so_far
				ms_so_far = ms_so_far + (ms_per_old_tick * delta_ticks)
				ticks_so_far = tempo_ticks[i_tempo_ticks]
				ms_per_old_tick = ticks2tempo[ticks_so_far] / (1000.0*old_tpq)
				i_tempo_ticks = i_tempo_ticks + 1
				event_delta_ticks = event_delta_ticks - delta_ticks
			end  -- now handle the new event
			local new_event = copy(old_event) -- 4.7
			ms_so_far = ms_so_far + (ms_per_old_tick * old_event[2])  -- NO!
			new_event[2] = math.floor(0.5 + ms_so_far - previous_ms_so_far)
			if old_event[1] ~= 'set_tempo' then -- set_tempos are already known
				previous_ms_so_far = ms_so_far
				new_track[#new_track+1] = new_event
			end
			ticks_so_far = ticks_so_far + event_delta_ticks
		end
		new_opus[#new_opus+1] = new_track
		itrack = itrack + 1
	end
	clean_up_warnings()
	return new_opus
end

return M
