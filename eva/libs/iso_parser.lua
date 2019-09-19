local M = {}


local function parse_date(str)
	local Y, MM, D = str:match("^(%d%d%d%d)-?(%d%d)-?(%d%d)")
	return tonumber(Y), tonumber(MM), tonumber(D)
end


local function parse_time(str)
	local h, m, s = str:match("T(%d%d):?(%d%d):?(%d%d)")
	return tonumber(h), tonumber(m), tonumber(s)
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


return M