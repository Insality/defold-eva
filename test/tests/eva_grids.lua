local eva = require("eva.eva")

return function()
	describe("Eva grid, Eva hexgrid, Eva isogrid", function()
		before(function()
			eva.init("/resources/tests/eva_tests.json")
		end)

		it("Eva grid", function()
			local params = eva.grid.get_map_params({
				tilewidth = 32,
				tileheight = 64,
				invert_y = true,
				width = 50,
				height = 40,
			})
			for i = -3, 3 do
				for j = -3, 3 do
					local x, y = eva.grid.cell_to_pos(i, j, params)
					local new_i, new_j = eva.grid.pos_to_cell(x + i, y + j, params)
					assert(new_i == i and new_j == j)
				end
			end
		end)

		it("Eva isogrid", function()
			local params = eva.isogrid.get_map_params({
				tilewidth = 32,
				tileheight = 64,
				invert_y = true,
				width = 50,
				height = 40,
			})
			for i = -3, 3 do
				for j = -3, 3 do
					local x, y = eva.isogrid.cell_to_pos(i, j, params)
					local new_i, new_j = eva.isogrid.pos_to_cell(x + i, y + j, params)
					assert(new_i == i and new_j == j)
				end
			end
		end)

		it("Eva hexgrid", function()
			local params = eva.hexgrid.get_map_params({
				tilewidth = 32,
				tileheight = 64,
				tileside = 24,
				invert_y = true,
				width = 50,
				height = 40,
			})
			for i = -3, 3 do
				for j = -3, 3 do
					local x, y = eva.hexgrid.cell_to_pos(i, j, params)
					local new_i, new_j = eva.hexgrid.pos_to_cell(x + i, y + j, params)
					assert(new_i == i and new_j == j)
				end
			end
		end)
	end)
end