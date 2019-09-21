local M = {
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
	},
	window = {
		window_path = "",
	},
	rate = {
		url_source = "game",
	},
	proto = {
		proto_sources = {
			["/resources/proto/"] = {
				"ExampleType"
			}
		}
	},
	funcs = {}
}


function M.funcs.get_time()
	return socket.gettime()
end


return M
