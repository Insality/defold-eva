local M = {}

local modules = {
	ads = require("eva.modules.ads"),
	devices = require("eva.modules.devices"),
	errors = require("eva.modules.errors"),
	events = require("eva.modules.events"),
	game = require("eva.modules.game"),
	iaps = require("eva.modules.iaps"),
	input = require("eva.modules.input"),
	lang = require("eva.modules.lang"),
	notifications = require("eva.modules.notifications"),
	saver = require("eva.modules.saver"),
	server = require("eva.modules.server"),
	sound = require("eva.modules.sound"),
	stats = require("eva.modules.stats"),
	tokens = require("eva.modules.tokens"),
	utils = require("eva.modules.utils"),
	window = require("eva.modules.window"),
}


function M.on_game_start()
	for name, component do
		M[name] = component
		component._eva = M

		if M.on_game_start then
			M.on_game_start()
		end
	end
end


function M.on_game_update(dt)
	M.stats.on_game_update(dt)
end

return M
