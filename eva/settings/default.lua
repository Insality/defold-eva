local M = {}

M.settings = {
	server = {
		game_id = "xxx"
	},
	sound = {
		repeat_threshold = 0.08, -- don't play sounds too fast. In second
		sound_path = "loader:/sound#"
	},
	saver = {
		autosave = 4,
	},
	errors = {
		error_server_url = "https://8.8.8.8" -- place to send errors
	},
	lang = {
		default = "en",
		langs_path = "/locales/"
	}
}

function M.get_time()
	return socket.gettime()
end

return M
