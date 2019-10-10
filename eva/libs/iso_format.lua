--- ISO format time parser
-- format: yyyy-mm-ddThh:mm:ss.ffffff
-- example: 2008-09-15T15:53:00
-- 			2008-09-15T15:53:00+05:00

local M = {}


local function parse_date(str)
	local Y, MM, D = str:match("^(%d%d%d%d)-?(%d%d)-?(%d%d)")
	return tonumber(Y), tonumber(MM), tonumber(D)
end


local function parse_time(str)
	local h, m, s = str:match("T(%d%d):?(%d%d):?(%d%d)")
	return tonumber(h) or 0, tonumber(m) or 0, tonumber(s) or 0
end


local function parse_offset(str)
	if str:sub(-1)=="Z" then return 0,0 end -- ends with Z, Zulu time

	-- matches ±hh:mm, ±hhmm or ±hh; else returns nils
	local sign, oh, om = str:match("([-+])(%d%d):?(%d?%d?)$")
	sign, oh, om = sign or "+", oh or "00", om or "00"

	return tonumber(sign .. oh) or 0, tonumber(sign .. om) or 0
end


function M.parse(str)
	local Y, MM, D = parse_date(str)
	local h, m, s = parse_time(str)
	local oh, om = parse_offset(str)
	return os.time({year=Y, month=MM, day=D, hour=(h+oh), min=(m+om), sec=s})
end


function M.get_time(seconds)
	return os.date("%Y-%m-%dT%TZ", seconds)
end


--- Get the table with delta times
-- @tparam string str In format: "1Y 10M 2W 1D 12h 30m". Can pass part of time
local function get_delta_time(str)
	local year = tonumber(str:match("(%d?)Y")) or 0
	local month = tonumber(str:match("(%d?%d?)M")) or 0
	local week = tonumber(str:match("(%d?)W")) or 0
	local day = tonumber(str:match("(%d?%d?)D")) or 0
	local hour = tonumber(str:match("(%d?%d?)h")) or 0
	local min = tonumber(str:match("(%d?%d?)m")) or 0

	return {
		year = year,
		month = month,
		day = week*7 + day,
		hour = hour,
		min = min
	}
end


--- Return next time in seconds on event
-- @tparam string start_date date in ISO format
-- @tparam string delta_time delta in next format: "1Y 10M 2W 1D 12h 30m". Can pass part of time
-- @tparam[opt] string cur_time_str date in ISO format. local time by default
function M.get_time_to_next(start_date, delta_time, cur_time_str)
	local start_time = M.parse(start_date)

	local cur_time = socket.gettime()
	if cur_time_str then
		cur_time = M.parse(cur_time_str)
	end

	local cur_table = os.date("*t", start_time)
	local time = os.time(cur_table)
	local delta = get_delta_time(delta_time)

	while time < cur_time do
		cur_table.year = cur_table.year + delta.year
		cur_table.month = cur_table.month + delta.month
		cur_table.day = cur_table.day + delta.day
		cur_table.hour = cur_table.hour + delta.hour
		cur_table.min = cur_table.min + delta.min
		time = os.time(cur_table)
	end

	return time
end


function M.get_delta_seconds(delta_str)
	local time_table = get_delta_time(delta_str)
	local seconds = 0
	seconds = seconds + time_table.min * 60
	seconds = seconds + time_table.hour * 60 * 60
	seconds = seconds + time_table.day * 60 * 60 * 24
	seconds = seconds + time_table.month * 60 * 60 * 24 * 30
	seconds = seconds + time_table.year * 60 * 60 * 24 * 365
	return seconds
end


return M