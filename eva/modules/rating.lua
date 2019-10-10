--- Eva rating module
-- Can carry for calculate ratings for different
-- game systems. Elo for example
-- @submodule eva


local luax = require("eva.luax")


local MIN_RATING = 100
local MAX_RATING = 8000
local FREE_RATING_MAX = 2000
local DIFF_CONSTANT = 600
local FREE_REDUCE_KOEF = 3

local M = {}


local function diff(rating_a, rating_b)
	local value = (rating_b - rating_a) / DIFF_CONSTANT
	return 1 / (1 + math.pow(10, value))
end


-- @tparam number game_koef 1 is win, 0 on loose, 0.5 is draw
function M.elo(rating_a, rating_b, game_koef, K)
	if not game_koef then
		print("No game_koef in args")
		game_koef = 0.5
	end

	K = K or 60

	local rating_diff = K * (game_koef - diff(rating_a, rating_b))

	if (rating_diff < 0 and rating_a < FREE_RATING_MAX) then
		-- On loose and low rating, decrease elo in FREE_REDUCE_KOEF times less
		rating_diff = rating_diff / FREE_REDUCE_KOEF
	end

	local new_rating = luax.math.round(rating_a + rating_diff)
	return luax.math.clamp(new_rating, MIN_RATING, MAX_RATING)
end

return M