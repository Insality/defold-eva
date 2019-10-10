--- Eva utils module
-- Contains simple helpers functions to
-- make your life easier
-- @submodule eva


local luax = require("eva.luax")

local M = {}


--- Make after closure
-- @function eva.utils.after
function M.after(count, callback)
	local closure = function()
		count = count - 1
		if count <= 0 then
			callback()
		end
	end
	return closure
end


--- Load json from bundled resource
-- @function eva.utils.load_json
function M.load_json(filename)
	return cjson.decode(sys.load_resource(filename))
end


--- Compare two project version.
-- Version format should be in semver("x.y.z")
-- @function eva.utils.compare_versions
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
