local eva = require("eva.eva")

return function()
	describe("Eva rating", function()
		before(function()
			eva.init("/resources/tests/eva_tests.json")
		end)

		it("Should correct calc elo", function()
			-- Diff: 60. Easy threshold: 2000, easy reduce koef: 3
			-- Min-Max: 100 - 8000

			assert(eva.rating.elo(1000, 3000, 1) == 1060)
			-- Cause of easy mode. Lose in 3 times smaller
			assert(eva.rating.elo(1800, 500, 0) == 1780)
			assert(eva.rating.elo(5000, 3000, 0) == 4940)

			assert(eva.rating.elo(4000, 4000, 0.5) == 4000)
			assert(eva.rating.elo(8000, 8000, 1) == 8000)
			assert(eva.rating.elo(100, 100, 0) == 100)
			assert(eva.rating.elo(150, 150, 0) == 140)
			assert(eva.rating.elo(4000, 4000, 0) == 3970)
		end)
	end)
end