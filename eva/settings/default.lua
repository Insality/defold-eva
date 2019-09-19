local M = {}

M.settings = {
	server = {
		game_id = "xxx"
	}
}

function M.get_time()
	return socket.gettime()
end

return M
