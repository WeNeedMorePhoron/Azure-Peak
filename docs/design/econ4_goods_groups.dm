// Goods groups sheet (G-0). Not compiled. Move members, rename, split or merge groups in place; the layout maps straight to G-1 datums.
// A group is stocked and priced in value. Each member trades at the group's price step times its own price, so a salmon draws more than a carp.
// A group never holds a good together with its own input or output, directly or down a chain. One exception for sanity: sausage and salumoi (user 2026-11-11).
// Metals are never pooled (user 2026-11-10, confirmed 2026-11-11).
// Prices are today's reference prices. The pricing engine's derived price matches the base price for every Market good right now.
// 103 Market goods become 18 groups (81 members) and 22 single goods: 40 Market lines.

// Farm and forage

/datum/goods_group/grains
	name = "Grains"
	members = list(
		TRADE_GOOD_GRAIN, // 3
		TRADE_GOOD_OATS, // 3
		TRADE_GOOD_RICE, // 3
		TRADE_GOOD_MAIZE, // 3
	)

/datum/goods_group/vegetables
	name = "Vegetables"
	members = list(
		TRADE_GOOD_MUSHROOM, // 2
		TRADE_GOOD_POTATO, // 3
		TRADE_GOOD_TURNIP, // 3
		TRADE_GOOD_CARROT, // 3
		TRADE_GOOD_CABBAGE, // 3
		TRADE_GOOD_ONION, // 3
		TRADE_GOOD_GARLICK, // 3
		TRADE_GOOD_CUCUMBER, // 3
		TRADE_GOOD_EGGPLANT, // 3
		TRADE_GOOD_TOMATO, // 3
		TRADE_GOOD_PUMPKIN, // 3
		TRADE_GOOD_BEANS, // 4
		TRADE_GOOD_LENTILS, // 4
	)

/datum/goods_group/fruit_and_nuts
	name = "Fruit and Nuts"
	members = list(
		TRADE_GOOD_APPLE, // 3
		TRADE_GOOD_PEAR, // 3
		TRADE_GOOD_JACKSBERRY, // 3
		TRADE_GOOD_BLACKBERRY, // 4
		TRADE_GOOD_RASPBERRY, // 4
		TRADE_GOOD_STRAWBERRY, // 4
		TRADE_GOOD_PLUM, // 4
		TRADE_GOOD_LEMON, // 4
		TRADE_GOOD_LIME, // 4
		TRADE_GOOD_TANGERINE, // 4
		TRADE_GOOD_ROCKNUT, // 4
	)

/datum/goods_group/herbs
	name = "Herbs"
	members = list(
		TRADE_GOOD_POPPY, // 3
		TRADE_GOOD_CALENDULA, // 4
	)

/datum/goods_group/luxuries
	name = "Luxuries"
	members = list(
		TRADE_GOOD_HONEY, // 5
		TRADE_GOOD_SUGAR, // 5
		TRADE_GOOD_COFFEE, // 5
		TRADE_GOOD_TEA, // 5
	)

// Fish

/datum/goods_group/common_fish
	name = "Common Fish"
	members = list(
		TRADE_GOOD_CARP, // 5
		TRADE_GOOD_SOLE, // 5
		TRADE_GOOD_FLOUNDER, // 5
		TRADE_GOOD_MACKEREL, // 5
		TRADE_GOOD_EEL, // 5
		TRADE_GOOD_BLACK_BASS, // 8
		TRADE_GOOD_COD, // 10
		TRADE_GOOD_BASS, // 10
	)

/datum/goods_group/luxury_fish
	name = "Luxury Fish"
	members = list(
		TRADE_GOOD_SALMON, // 15
		TRADE_GOOD_PLAICE, // 15
	)

/datum/goods_group/shellfish
	name = "Shellfish"
	members = list(
		TRADE_GOOD_SHRIMP, // 8
		TRADE_GOOD_CRAB, // 10
		TRADE_GOOD_CLAM, // 15
		TRADE_GOOD_LOBSTER, // 15
	)

/datum/goods_group/swamp_fish
	name = "Swamp Fish"
	members = list(
		TRADE_GOOD_MUDSKIPPER, // 5
		TRADE_GOOD_SWAMP_SHRIMP, // 5
		TRADE_GOOD_SWAMP_MOTHER, // 15
	)

/datum/goods_group/fish_cuts
	name = "Fish Cuts"
	members = list(
		TRADE_GOOD_FISH_FILET, // 3
		TRADE_GOOD_CRAB_MEAT, // 4
	)

/datum/goods_group/prepared_fish
	name = "Prepared Fish"
	members = list(
		TRADE_GOOD_FISH_MINCE, // 2
		TRADE_GOOD_DRIED_FISH, // 7
	)

// Meat and animal goods

/datum/goods_group/staple_meats
	name = "Staple Meats"
	members = list(
		TRADE_GOOD_FAT, // 3
		TRADE_GOOD_RABBIT, // 3
		TRADE_GOOD_MEAT, // 4
		TRADE_GOOD_PORK, // 4
		TRADE_GOOD_POULTRY, // 4
		TRADE_GOOD_PORK_BELLY, // 5
		TRADE_GOOD_HAM, // 6
	)

/datum/goods_group/game_meats
	name = "Game Meats"
	members = list(
		TRADE_GOOD_LESSER_MEAT, // 1
		TRADE_GOOD_BOGMEAT, // 2
		TRADE_GOOD_BUSHMEAT, // 4
		TRADE_GOOD_GREATER_BUSHMEAT, // 9
		TRADE_GOOD_VENISON, // 16
		TRADE_GOOD_VENISON_RIBS, // 16
		TRADE_GOOD_BOAR_HAM, // 16
	)

/datum/goods_group/preserved_meats
	name = "Preserved Meats"
	members = list(
		TRADE_GOOD_SAUSAGE, // 7
		TRADE_GOOD_SALUMOI, // 9
	)

/datum/goods_group/dairy
	name = "Dairy"
	members = list(
		TRADE_GOOD_CHEESE, // 3
		TRADE_GOOD_BUTTER, // 7
	)

/datum/goods_group/animal_parts
	name = "Animal Parts"
	members = list(
		TRADE_GOOD_SINEW, // 2
		TRADE_GOOD_TALLOW, // 2
		TRADE_GOOD_BONES, // 3
		TRADE_GOOD_VISCERA, // 3
	)

/datum/goods_group/hides_and_furs
	name = "Hides and Furs"
	members = list(
		TRADE_GOOD_HIDE, // 8
		TRADE_GOOD_FUR, // 10
	)

// Materials

/datum/goods_group/cloth_and_silk
	name = "Cloth and Silk"
	members = list(
		TRADE_GOOD_CLOTH, // 3
		TRADE_GOOD_SILK, // 4
	)

// Single goods: a group of one each.

// Input or output of a grouped good
// TRADE_GOOD_FIBERS 1 (weaves into cloth)
// TRADE_GOOD_CURED_LEATHER 3 (from hide)
// TRADE_GOOD_WOOD 3 (burns into charcoal, which counts as coal)
// TRADE_GOOD_GLASS_BATCH 4

// Not a substitute for anything else
// TRADE_GOOD_EGG 2
// TRADE_GOOD_STONE 1, TRADE_GOOD_COAL 4, TRADE_GOOD_SALT 4, TRADE_GOOD_CINNABAR 10 (separate for now, user 2026-11-11)
// TRADE_GOOD_DENDOR_ESSENCE 20 (rare, target preset 10; grouping it with herbs would let common herbs buy it)

// Metals, never pooled
// TRADE_GOOD_IRON_ORE 8, TRADE_GOOD_COPPER_ORE 6, TRADE_GOOD_TIN_ORE 7
// TRADE_GOOD_IRON_INGOT 10, TRADE_GOOD_COPPER_INGOT 7, TRADE_GOOD_TIN_INGOT 8
// TRADE_GOOD_STEEL_INGOT 14, TRADE_GOOD_BRONZE_INGOT 10
// TRADE_GOOD_GOLD_ORE 50, TRADE_GOOD_SILVER_ORE 80, TRADE_GOOD_GOLD_INGOT 60, TRADE_GOOD_SILVER_INGOT 80

// Changes from the 3-1f demand groups, which these replace
// Iron Ingots, Bronze Ingots, Precious Metals and Textiles are split up: each pairs a good with its own input, or is never pooled.
// Preserved Meats stays a group (user 2026-11-11, for sanity, though salumoi is dried sausage).
// Herbs stays a group (user 2026-11-11, overriding never pooled).
// Staple Meats loses tallow to Animal Parts (fat renders into it) and gains meat and rabbit.
// Game Meats gains lesser meat and bogmeat.
// Fine Fish splits into Common Fish, Luxury Fish and Shellfish. Swamp Fish, Fish Cuts and Prepared Fish are new.
// Orchard Fruit and Exotic Fruit merge into Fruit and Nuts, with the berries and rocknut.
// Root Vegetables and Pulses merge into Vegetables, with the garden produce and mushroom.
// Dairy is unchanged. Grains, Animal Parts and Cloth and Silk are new.

// Outside the Market
// The other 112 trade goods (equipment, potions, gems, reagents, trophies) are order only and stay single.
// Tribute and gift only items (oyster, sturgeon, swordfish) are not Market goods. If one ever joins a group it is deposit only.
