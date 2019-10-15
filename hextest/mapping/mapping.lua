local M = {}

local function make_object(spawner, image_name)
	return function(position)
		local object = factory.create("/spawner#" .. spawner, position)
		sprite.play_flipbook(object, image_name)
		return object
	end
end

M.hexes = {
	[0] = make_object("hex", "tileAutumn_tile"),
	[1] = make_object("hex", "tileDirt_tile"),
	[2] = make_object("hex", "tileGrass_tile"),
	[3] = make_object("hex", "tileLava_tile"),
	[4] = make_object("hex", "tileMagic_tile"),
	[5] = make_object("hex", "tileRock_tile"),
	[6] = make_object("hex", "tileSand_tile"),
	[7] = make_object("hex", "tileWater_tile"),
}

M.decals = {
	[0] = make_object("bush", "bushDirt"),
	[1] = make_object("bush", "bushGrass"),
	[2] = make_object("flower", "flowerGreen"),
	[3] = make_object("flower", "flowerRed"),
	[4] = make_object("flower", "flowerWhite"),
	[5] = make_object("flower", "flowerYellow"),
	[6] = make_object("cactus", "treeCactus_1"),
	[7] = make_object("cactus", "treeCactus_2"),
	[8] = make_object("cactus", "treeCactus_3"),
}

M.resources = {
	[0] = make_object("tree_pine_high", "pineAutumn_high"),
	[1] = make_object("tree_pine_low", "pineAutumn_low"),
	[2] = make_object("tree_pine_medium", "pineAutumn_mid"),
	[3] = make_object("tree_pine_high", "pineBlue_high"),
	[4] = make_object("tree_pine_low", "pineBlue_low"),
	[5] = make_object("tree_pine_medium", "pineBlue_mid"),
	[6] = make_object("tree_pine_high", "pineGreen_high"),
	[7] = make_object("tree_pine_low", "pineGreen_low"),
	[8] = make_object("tree_pine_medium", "pineGreen_mid"),
	[9] = make_object("rock_big", "rockDirt_moss1"),
	[10] = make_object("rock_big", "rockDirt_moss2"),
	[11] = make_object("rock_big", "rockDirt_moss3"),
	[12] = make_object("rock_big", "rockDirt"),
	[13] = make_object("rock_big", "rockStone_moss1"),
	[14] = make_object("rock_big", "rockStone_moss2"),
	[15] = make_object("rock_big", "rockStone_moss3"),
	[16] = make_object("rock_big", "rockStone"),
	[17] = make_object("rock_small", "smallRockDirt"),
	[18] = make_object("rock_small", "smallRockGrass"),
	[19] = make_object("rock_small", "smallRockStone"),
	[20] = make_object("tree_round_high", "treeAutumn_high"),
	[21] = make_object("tree_round_low", "treeAutumn_low"),
	[22] = make_object("tree_round_high", "treeAutumn_mid"),
	[23] = make_object("tree_round_high", "treeBlue_high"),
	[24] = make_object("tree_round_low", "treeBlue_low"),
	[25] = make_object("tree_round_high", "treeBlue_mid"),
	[26] = make_object("tree_round_high", "treeGreen_high"),
	[27] = make_object("tree_round_low", "treeGreen_low"),
	[28] = make_object("tree_round_high", "treeGreen_mid"),
}

return M