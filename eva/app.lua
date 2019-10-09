--- Eva app instance module
-- contains all runtime data of every module
-- @local


local M = {}


--- Clear the app state
function M.clear()
	for key in pairs(M) do
		if key ~= "clear" then
			M[key] = nil
		end
	end
end


return M
