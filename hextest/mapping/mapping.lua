local M = {}

local function make_hex(image_name)
	return function(position)
		local object = factory.create("/spawner#hexes", position)
		sprite.play_flipbook(object, image_name)
		return object
	end
end

local function make_decals(image_name)
	return function(position)
		local object = factory.create("/spawner#decals", position)
		sprite.play_flipbook(object, image_name)
		return object
	end
end

local function make_resource(image_name)
	return function(position)
		local object = factory.create("/spawner#resources", position)
		sprite.play_flipbook(object, image_name)
		return object
	end
end

M.hexes = {
	[0] = make_hex("tileAutumn_tile"),
	[1] = make_hex("tileDirt_tile"),
	[2] = make_hex("tileGrass_tile"),
	[3] = make_hex("tileLava_tile"),
	[4] = make_hex("tileMagic_tile"),
	[5] = make_hex("tileRock_tile"),
	[6] = make_hex("tileSand_tile"),
	[7] = make_hex("tileWater_tile"),
}

M.decals = {
	[0] = make_decals("bushDirt"),
	[1] = make_decals("bushGrass"),
	[2] = make_decals("flowerGreen"),
	[3] = make_decals("flowerRed"),
	[4] = make_decals("flowerWhite"),
	[5] = make_decals("flowerYellow"),
	[6] = make_decals("treeCactus_1"),
	[7] = make_decals("treeCactus_2"),
	[8] = make_decals("treeCactus_3"),
}

M.resources = {
	[0] = make_resource("pineAutumn_high"),
	[1] = make_resource("pineAutumn_low"),
	[2] = make_resource("pineAutumn_mid"),
	[3] = make_resource("pineBlue_high"),
	[4] = make_resource("pineBlue_low"),
	[5] = make_resource("pineBlue_mid"),
	[6] = make_resource("pineGreen_high"),
	[7] = make_resource("pineGreen_low"),
	[8] = make_resource("pineGreen_mid"),
	[9] = make_resource("rockDirt_moss1"),
	[10] = make_resource("rockDirt_moss2"),
	[11] = make_resource("rockDirt_moss3"),
	[12] = make_resource("rockDirt"),
	[13] = make_resource("rockStone_moss1"),
	[14] = make_resource("rockStone_moss2"),
	[15] = make_resource("rockStone_moss3"),
	[16] = make_resource("rockStone"),
	[17] = make_resource("smallRockDirt"),
	[18] = make_resource("smallRockGrass"),
	[19] = make_resource("smallRockStone"),
	[20] = make_resource("treeAutumn_high"),
	[21] = make_resource("treeAutumn_low"),
	[22] = make_resource("treeAutumn_mid"),
	[23] = make_resource("treeBlue_high"),
	[24] = make_resource("treeBlue_low"),
	[25] = make_resource("treeBlue_mid"),
	[26] = make_resource("treeGreen_high"),
	[27] = make_resource("treeGreen_low"),
	[28] = make_resource("treeGreen_mid"),
}

return M