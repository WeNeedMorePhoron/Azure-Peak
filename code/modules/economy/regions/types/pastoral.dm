/datum/region_type/pastoral/mixed
	name = "Pastoral (Mixed)"
	produces = list(
		TRADE_GOOD_MEAT = TG_SUPPLY_MEAT_BULK,
		TRADE_GOOD_POULTRY = TG_SUPPLY_MEAT_STAPLE,
		TRADE_GOOD_EGG = TG_SUPPLY_MEAT_BULK,
		TRADE_GOOD_BUTTER = TG_SUPPLY_MEAT_STAPLE,
		TRADE_GOOD_CHEESE = TG_SUPPLY_MEAT_STAPLE,
		TRADE_GOOD_FAT = TG_SUPPLY_MEAT_STAPLE,
		TRADE_GOOD_TALLOW = TG_SUPPLY_MEAT_STAPLE,
	)
	demands = list(
		TRADE_GOOD_SALT = TG_DEMAND_SALT,
	)
	seasonal_produces = list(
		SEASON_AUTUMN = REGION_SEASON_PEAK,
	)
	seasonal_demands = list(
		SEASON_AUTUMN = list(
			TRADE_GOOD_SALT = REGION_SEASON_PEAK,
		),
	)

/datum/region_type/pastoral/saiga
	name = "Pastoral (Saigas)"
	produces = list(
		TRADE_GOOD_MEAT = TG_SUPPLY_MEAT_BULK,
		TRADE_GOOD_HIDE = TG_SUPPLY_LEATHER,
		TRADE_GOOD_TALLOW = TG_SUPPLY_MEAT_STAPLE,
	)
	demands = list(
		TRADE_GOOD_OATS = TG_DEMAND_LOCAL_GRAIN,
	)

/datum/region_type/pastoral/mountain
	name = "Pastoral (Goats and Saigas)"
	produces = list(
		TRADE_GOOD_CHEESE = TG_SUPPLY_MEAT_STAPLE,
		TRADE_GOOD_BUTTER = TG_SUPPLY_MEAT_STAPLE,
		TRADE_GOOD_MEAT = TG_SUPPLY_MEAT_BULK,
		TRADE_GOOD_FUR = TG_SUPPLY_LEATHER,
		TRADE_GOOD_HIDE = TG_SUPPLY_LEATHER,
	)

/datum/region_type/pastoral/swine
	name = "Swine Herd"
	produces = list(
		TRADE_GOOD_PORK = TG_SUPPLY_MEAT_STAPLE,
		TRADE_GOOD_HAM = TG_SUPPLY_MEAT_STAPLE,
		TRADE_GOOD_PORK_BELLY = TG_SUPPLY_MEAT_STAPLE,
		TRADE_GOOD_FAT = TG_SUPPLY_MEAT_STAPLE,
	)
	demands = list(
		TRADE_GOOD_ROCKNUT = TG_DEMAND_FORAGE,
	)
	seasonal_produces = list(
		SEASON_AUTUMN = REGION_SEASON_PEAK,
	)
