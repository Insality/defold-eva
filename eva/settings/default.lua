local M = {
	server = {
		game_id = "xxx"
	},
	sound = {
		repeat_threshold = 0.08, -- don't play sounds too fast. In second
		sound_path = "loader:/sound#"
	},
	stats = {
		game_stated_time_count = 5, -- how many records keep last game runs
	},
	saver = {
		autosave = 4,
	},
	errors = {
		error_server_url = "https://8.8.8.8" -- place to send errors
	},
	lang = {
		default = "en",
		lang_paths = {
			ru = "/resources/locales/ru.json",
			en = "/resources/locales/en.json",
		}
	},
	tokens = {
		token_config = nil,
	},
	log = {
		format = "[%levelname]<%function:%lineno>: %message %context"
	},
	window = {
		window_path = "",
	},
	iaps = {
		product_list = {
		},
	},
	rate = {
		url_source = "game",
	},
	proto = {
		proto_paths = {
			["/eva/proto/"] = {
				"eva",
				"evadata"
			}
		}
	},
	funcs = {}
}


function M.funcs.get_time()
	return socket.gettime()
end


return M
