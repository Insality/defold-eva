local M = {}


local function get_time_data(seconds)
	local minutes = math.max(0, math.floor(seconds / 60))
	seconds = math.max(0, math.floor(seconds % 60))
	local hours = math.max(0, math.floor(minutes / 60))
	minutes = math.max(0, math.floor(minutes % 60))
	local days = math.max(0, math.floor(hours / 24))
	hours = math.max(0, math.floor(hours % 24))

	return days, hours, minutes, seconds
end


function M.time_format(seconds)
	local lang = M._eva.lang
	local days, hours, minutes, secs = get_time_data(seconds)
	if days > 0 then
		return lang.txp("time_format_d", days, hours, minutes, secs)
	elseif hours > 0 then
		return lang.txp("time_format_h", hours, minutes, secs)
	else
		return lang.txp("time_format_m", minutes, secs)
	end
end


function M.after(count, callback)
	local closure = function()
		count = count - 1
		if count <= 0 then
			callback()
		end
	end
	return closure
end


return M
