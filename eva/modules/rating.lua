--- Eva rating module
-- Can carry for calculate ratings for different
-- game systems. Elo for example
-- @submodule eva


local app = require("eva.app")
local luax = require("eva.luax")


local M = {}


local function diff(rating_a, rating_b)
	local value = (rating_b - rating_a) / app.settings.rating.diff_constant
	return 1 / (1 + math.pow(10, value))
end


-- @tparam number game_koef 1 is win, 0 on loose, 0.5 is draw
function M.elo(rating_a, rating_b, game_koef, K)
	assert(game_koef, "You should provide game_koef status")
	local settings = app.settings.rating

	K = K or settings.rating_diff

	local rating_diff = K * (game_koef - diff(rating_a, rating_b))

	if (rating_diff < 0 and rating_a < settings.easy_max) then
		-- On loose and low rating, decrease elo in FREE_REDUCE_KOEF times less
		rating_diff = rating_diff / settings.easy_reduce_koef
	end

	local new_rating = luax.math.round(rating_a + rating_diff)
	return luax.math.clamp(new_rating, settings.min, settings.max)
end


return M
