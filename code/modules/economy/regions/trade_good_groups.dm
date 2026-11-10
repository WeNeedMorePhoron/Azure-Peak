/datum/trade_good_group
	var/name
	var/list/goods = list()

/datum/trade_good_group/base_ingots
	name = "Ingots"
	goods = list(
		TRADE_GOOD_IRON_INGOT,
		TRADE_GOOD_STEEL_INGOT,
		TRADE_GOOD_COPPER_INGOT,
		TRADE_GOOD_TIN_INGOT,
		TRADE_GOOD_BRONZE_INGOT,
	)

/datum/trade_good_group/precious_metals
	name = "Precious Metals"
	goods = list(
		TRADE_GOOD_SILVER_INGOT,
		TRADE_GOOD_GOLD_INGOT,
		TRADE_GOOD_GOLD_ORE,
	)

/datum/trade_good_group/leathers
	name = "Leathers"
	goods = list(
		TRADE_GOOD_HIDE,
		TRADE_GOOD_FUR,
		TRADE_GOOD_CURED_LEATHER,
	)

/datum/trade_good_group/staple_meats
	name = "Staple Meats"
	goods = list(
		TRADE_GOOD_PORK,
		TRADE_GOOD_HAM,
		TRADE_GOOD_PORK_BELLY,
		TRADE_GOOD_POULTRY,
		TRADE_GOOD_FAT,
		TRADE_GOOD_TALLOW,
	)

/datum/trade_good_group/dairy
	name = "Dairy"
	goods = list(
		TRADE_GOOD_BUTTER,
		TRADE_GOOD_CHEESE,
	)

/datum/trade_good_group/root_vegetables
	name = "Root Vegetables"
	goods = list(
		TRADE_GOOD_POTATO,
		TRADE_GOOD_TURNIP,
		TRADE_GOOD_CARROT,
		TRADE_GOOD_CABBAGE,
		TRADE_GOOD_ONION,
	)

/datum/trade_good_group/preserved_foods
	name = "Preserved Foods"
	goods = list(
		TRADE_GOOD_DRIED_FISH,
		TRADE_GOOD_SAUSAGE,
		TRADE_GOOD_SALUMOI,
	)

/datum/trade_good_group/fine_fish
	name = "Fine Fish"
	goods = list(
		TRADE_GOOD_SALMON,
		TRADE_GOOD_COD,
		TRADE_GOOD_CRAB,
		TRADE_GOOD_BASS,
		TRADE_GOOD_CARP,
		TRADE_GOOD_SOLE,
		TRADE_GOOD_CLAM,
		TRADE_GOOD_LOBSTER,
		TRADE_GOOD_SHRIMP,
		TRADE_GOOD_BLACK_BASS,
		TRADE_GOOD_PLAICE,
	)

/datum/trade_good_group/orchard_fruit
	name = "Orchard Fruit"
	goods = list(
		TRADE_GOOD_APPLE,
		TRADE_GOOD_PEAR,
		TRADE_GOOD_JACKSBERRY,
	)

/datum/trade_good_group/exotic_fruit
	name = "Exotic Fruit"
	goods = list(
		TRADE_GOOD_PLUM,
		TRADE_GOOD_LEMON,
		TRADE_GOOD_LIME,
		TRADE_GOOD_TANGERINE,
	)

/datum/trade_good_group/luxuries
	name = "Luxuries"
	goods = list(
		TRADE_GOOD_HONEY,
		TRADE_GOOD_SUGAR,
		TRADE_GOOD_COFFEE,
		TRADE_GOOD_TEA,
	)

/datum/trade_good_group/herbs
	name = "Herbs"
	goods = list(
		TRADE_GOOD_CALENDULA,
		TRADE_GOOD_POPPY,
	)
