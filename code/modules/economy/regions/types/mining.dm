/datum/region_type/mining/iron_steel
	name = "Minerals (Iron and Steel)"
	produces = list(
		TRADE_GOOD_IRON_ORE = TG_SUPPLY_IRON,
		TRADE_GOOD_COAL = TG_SUPPLY_IRON,
	)
	demands = list(
		TRADE_GOOD_MEAT = TG_DEMAND_MEAT_BULK,
	)

/datum/region_type/mining/copper_tin
	name = "Minerals (Copper and Tin)"
	produces = list(
		TRADE_GOOD_COPPER_ORE = TG_SUPPLY_TIN_BRONZE,
		TRADE_GOOD_TIN_ORE = TG_SUPPLY_TIN_BRONZE,
	)
	demands = list(
		TRADE_GOOD_MEAT = TG_DEMAND_MEAT_BULK,
	)

/datum/region_type/mining/precious_veins
	name = "Precious Veins"
	produces = list(
		TRADE_GOOD_GOLD_ORE = TG_SUPPLY_PRECIOUS_METAL,
		TRADE_GOOD_CINNABAR = TG_SUPPLY_PRECIOUS_METAL,
	)
	demands = list(
		TRADE_GOOD_IRON_INGOT = TG_DEMAND_REFINED_INGOTS,
	)

/datum/region_type/mining/stone_quarry
	name = "Stone Quarry"
	produces = list(
		TRADE_GOOD_STONE = TG_SUPPLY_CHEAP_RAW_MAT,
	)
	demands = list(
		TRADE_GOOD_IRON_INGOT = TG_DEMAND_REFINED_INGOTS,
	)

/datum/region_type/mining/glass_quarry
	name = "Glass Quarry"
	produces = list(
		TRADE_GOOD_GLASS_BATCH = TG_SUPPLY_GLASS,
	)
	demands = list(
		TRADE_GOOD_WOOD = TG_DEMAND_WOOD,
		TRADE_GOOD_IRON_INGOT = TG_DEMAND_REFINED_INGOTS,
	)

/datum/region_type/mining/clay_pits
	name = "Clay Pits"
	produces = list(
		TRADE_GOOD_CLAY = TG_SUPPLY_CHEAP_RAW_MAT,
	)

/datum/region_type/mining/salt_mines
	name = "Salt Mines"
	produces = list(
		TRADE_GOOD_SALT = TG_SUPPLY_SALT,
	)
	demands = list(
		TRADE_GOOD_IRON_INGOT = TG_DEMAND_REFINED_INGOTS,
	)

/datum/region_type/mining/salt_flats
	name = "Salt Flats"
	produces = list(
		TRADE_GOOD_SALT = TG_SUPPLY_SALT,
	)
	seasonal_produces = list(
		SEASON_AUTUMN = REGION_SEASON_PEAK,
	)
