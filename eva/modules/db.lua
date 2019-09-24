local M = {}


function M.before_game_start(settings)
	local paths = settings.paths

	for name, path in pairs(paths) do
		local config = M._eva.utils.load_json(path)
		-- TODO
	end
end


return M
