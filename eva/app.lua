--- Eva app instance module
-- contains all runtime data of every module
-- @local

local luax = require("eva.luax")

local app = {}
local M = {}


--- Clear the app state
function M.clear()
	app = {}
end


M = setmetatable(M, {
	__newindex = function(self, key, value)
		if type(value) ~= "table" then
			error("You can add to eva.app only tables value. Key: " .. key)
		end

		if app[key] and luax.table.length(app[key]) > 0 then
			error("Trying to override not empty eva.app data. Key: " .. key)
		end

		app[key] = value
	end,

	__index = function(self, key)
		return app[key]
	end
})


return M
