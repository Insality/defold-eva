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


return M
