local const = require("eva.const")

local M = {}

M[1] = function(save)
	save[const.EVA.GAME].game_time = 1000
	print("Apply migration")
end

M[2] = function(save)
	save[const.EVA.GAME].prefer_playing_time = 2
	print("Apply migration")
end

M[3] = function(save)
	save[const.EVA.GAME].game_start_count = 666
	print("Apply migration")
end


return M