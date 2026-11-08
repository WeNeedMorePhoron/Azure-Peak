/datum/region_type/mining/iron_steel
	name = "Minerals (Iron and Steel)"
	produces = list(
		TRADE_GOOD_IRON_ORE = TG_SUPPLY_IRON,
		TRADE_GOOD_COAL = TG_SUPPLY_IRON,
		TRADE_GOOD_CINNABAR = TG_SUPPLY_PRECIOUS_METAL,
		TRADE_GOOD_GOLD_ORE = TG_SUPPLY_PRECIOUS_METAL,
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

/datum/region_type/mining/quarry
	name = "Quarry"
	produces = list(
		TRADE_GOOD_STONE = TG_SUPPLY_CHEAP_RAW_MAT,
		TRADE_GOOD_SALT = TG_SUPPLY_SALT,
		TRADE_GOOD_GLASS_BATCH = TG_SUPPLY_GLASS,
	)
