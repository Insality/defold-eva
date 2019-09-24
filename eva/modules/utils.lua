local luax = require("eva.luax")

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


function M.load_json(filename)
	return cjson.decode(sys.load_resource(filename))
end


--- Compare two project version.
-- Version format should be in semver("x.y.z")
-- @tparam string version_a project version
-- @tparam string version_b project version
-- @treturn int -1 if version_a higher, 1 if version_b higher, 0 if they are equal
function M.compare_versions(version_a, version_b)
	local split_a = luax.string.split(version_a, ".")
	local split_b = luax.string.split(version_b, ".")

	for i = 1, #split_a do
		if tonumber(split_a[i]) < tonumber((split_b[i] or "0")) then
			return 1
		end
		if tonumber(split_a[i]) > tonumber((split_b[i] or "0")) then
			return -1
		end
	end

	return 0
end


return M
