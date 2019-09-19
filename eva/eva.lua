local M = {}


M.ads = require("eva.modules.ads")
M.devices = require("eva.modules.devices")
M.errors = require("eva.modules.errors")
M.events = require("eva.modules.events")
M.game = require("eva.modules.game")
M.iaps = require("eva.modules.iaps")
M.input = require("eva.modules.input")
M.lang = require("eva.modules.lang")
M.notifications = require("eva.modules.notifications")
M.saver = require("eva.modules.saver")
M.server = require("eva.modules.server")
M.sound = require("eva.modules.sound")
M.stats = require("eva.modules.stats")
M.tokens = require("eva.modules.tokens")
M.utils = require("eva.modules.utils")
M.window = require("eva.modules.window")


function M.on_game_start()
	-- Setup some stuff?
	M.game.on_game_start()
	M.stats.on_game_start()
	M.errors.apply_error_handler()
end


function M.on_game_update(dt)
	M.stats.on_game_update(dt)
end

return M
