/datum/goods_group
	var/name
	var/list/members = list()
	var/list/stocks = list()
	var/market_stock = 0
	var/market_target = 0

/datum/goods_group/proc/add_stock(datum/roguestock/D)
	stocks += D
	D.group = src

/datum/goods_group/proc/seed_market()
	market_target = 0
	for(var/datum/roguestock/D as anything in stocks)
		market_target += D.market_target * D.market_weight()
	market_stock = market_target

/datum/goods_group/proc/market_step(stock)
	var/ratio = stock * 100 / market_target
	if(ratio >= MARKET_RATIO_OVERSTOCKED)
		return market_zone_step(MARKET_STEP_OVERSTOCKED)
	if(ratio >= MARKET_RATIO_ABUNDANT)
		return MARKET_STEP_ABUNDANT
	if(ratio >= MARKET_RATIO_PLENTIFUL)
		return MARKET_STEP_PLENTIFUL
	if(ratio >= MARKET_RATIO_STEADY)
		return MARKET_STEP_STEADY
	if(ratio >= MARKET_RATIO_LOW)
		return MARKET_STEP_LOW
	if(ratio >= MARKET_RATIO_SCARCE)
		return MARKET_STEP_SCARCE
	return market_zone_step(MARKET_STEP_VERY_SCARCE)

/datum/goods_group/proc/current_step()
	return market_step(market_stock)

/datum/goods_group/proc/market_zone_step(step)
	var/event = get_event_label()
	if(step == MARKET_STEP_OVERSTOCKED && event == "GLUT")
		return MARKET_STEP_GLUT
	if(step == MARKET_STEP_VERY_SCARCE && event == "SHORTAGE")
		return MARKET_STEP_SHORTAGE
	return step

/datum/goods_group/proc/market_step_min_stock(step)
	return market_step_ratio(step) * market_target / 100

/datum/goods_group/proc/is_overstocked()
	return market_stock * 100 / market_target >= MARKET_RATIO_OVERSTOCKED

/datum/goods_group/proc/get_event_label()
	for(var/datum/roguestock/D as anything in stocks)
		var/label = D.get_event_label()
		if(label)
			return label
	return ""

/datum/goods_group/proc/market_has_supply()
	for(var/datum/roguestock/D as anything in stocks)
		if(!D.market_never_supplies && D.has_open_producer())
			return TRUE
	return FALSE

/datum/goods_group/proc/market_day_step(rate)
	if(!market_target || get_event_label())
		return
	var/gap = market_target - market_stock
	if(!gap)
		return
	var/open_share = market_open_supply_share()
	if(isnull(open_share))
		if(gap > 0)
			return
		open_share = 1
	var/step = max(abs(gap) * rate / 100, market_target * MARKET_DAY_FLOOR / 100) * open_share
	step = min(round(step, STOCKPILE_PRICE_STEP), abs(gap))
	market_stock += gap > 0 ? step : -step

/datum/goods_group/proc/market_open_supply_share()
	var/producers = 0
	var/open = 0
	for(var/datum/roguestock/D as anything in stocks)
		if(!D.trade_good_id || D.market_never_supplies)
			continue
		var/datum/trade_good/tg = GLOB.trade_goods[D.trade_good_id]
		if(!tg?.importable)
			continue
		for(var/region_id in GLOB.economic_regions)
			var/datum/economic_region/region = GLOB.economic_regions[region_id]
			if(!region.produces[D.trade_good_id])
				continue
			producers++
			if(!region.is_region_blockaded)
				open++
	if(!producers)
		return null
	return open / producers

/datum/controller/subsystem/treasury/proc/build_goods_groups()
	for(var/path in subtypesof(/datum/goods_group))
		var/datum/goods_group/G = new path
		for(var/good_id in G.members)
			var/datum/roguestock/D = stockpile_by_trade_good[good_id]
			if(D && !D.group)
				G.add_stock(D)
		if(length(G.stocks))
			goods_groups += G
	for(var/datum/roguestock/D as anything in stockpile_datums)
		if(D.group)
			continue
		var/datum/goods_group/G = new
		G.name = D.name
		G.add_stock(D)
		goods_groups += G
	for(var/datum/goods_group/G as anything in goods_groups)
		G.seed_market()

/datum/goods_group/grains
	name = "Grains"
	members = list(
		TRADE_GOOD_GRAIN,
		TRADE_GOOD_OATS,
		TRADE_GOOD_RICE,
		TRADE_GOOD_MAIZE,
	)

/datum/goods_group/vegetables
	name = "Vegetables"
	members = list(
		TRADE_GOOD_MUSHROOM,
		TRADE_GOOD_POTATO,
		TRADE_GOOD_TURNIP,
		TRADE_GOOD_CARROT,
		TRADE_GOOD_CABBAGE,
		TRADE_GOOD_ONION,
		TRADE_GOOD_GARLICK,
		TRADE_GOOD_CUCUMBER,
		TRADE_GOOD_EGGPLANT,
		TRADE_GOOD_TOMATO,
		TRADE_GOOD_PUMPKIN,
		TRADE_GOOD_BEANS,
		TRADE_GOOD_LENTILS,
	)

/datum/goods_group/fruit_and_nuts
	name = "Fruit and Nuts"
	members = list(
		TRADE_GOOD_APPLE,
		TRADE_GOOD_PEAR,
		TRADE_GOOD_JACKSBERRY,
		TRADE_GOOD_BLACKBERRY,
		TRADE_GOOD_RASPBERRY,
		TRADE_GOOD_STRAWBERRY,
		TRADE_GOOD_PLUM,
		TRADE_GOOD_LEMON,
		TRADE_GOOD_LIME,
		TRADE_GOOD_TANGERINE,
		TRADE_GOOD_ROCKNUT,
	)

/datum/goods_group/herbs
	name = "Herbs"
	members = list(
		TRADE_GOOD_POPPY,
		TRADE_GOOD_CALENDULA,
	)

/datum/goods_group/luxuries
	name = "Luxuries"
	members = list(
		TRADE_GOOD_HONEY,
		TRADE_GOOD_SUGAR,
		TRADE_GOOD_COFFEE,
		TRADE_GOOD_TEA,
	)

/datum/goods_group/common_fish
	name = "Common Fish"
	members = list(
		TRADE_GOOD_CARP,
		TRADE_GOOD_SOLE,
		TRADE_GOOD_FLOUNDER,
		TRADE_GOOD_MACKEREL,
		TRADE_GOOD_EEL,
		TRADE_GOOD_BLACK_BASS,
		TRADE_GOOD_COD,
		TRADE_GOOD_BASS,
	)

/datum/goods_group/luxury_fish
	name = "Luxury Fish"
	members = list(
		TRADE_GOOD_SALMON,
		TRADE_GOOD_PLAICE,
	)

/datum/goods_group/shellfish
	name = "Shellfish"
	members = list(
		TRADE_GOOD_SHRIMP,
		TRADE_GOOD_CRAB,
		TRADE_GOOD_CLAM,
		TRADE_GOOD_LOBSTER,
	)

/datum/goods_group/swamp_fish
	name = "Swamp Fish"
	members = list(
		TRADE_GOOD_MUDSKIPPER,
		TRADE_GOOD_SWAMP_SHRIMP,
		TRADE_GOOD_SWAMP_MOTHER,
	)

/datum/goods_group/fish_cuts
	name = "Fish Cuts"
	members = list(
		TRADE_GOOD_FISH_FILET,
		TRADE_GOOD_CRAB_MEAT,
	)

/datum/goods_group/prepared_fish
	name = "Prepared Fish"
	members = list(
		TRADE_GOOD_FISH_MINCE,
		TRADE_GOOD_DRIED_FISH,
	)

/datum/goods_group/staple_meats
	name = "Staple Meats"
	members = list(
		TRADE_GOOD_FAT,
		TRADE_GOOD_RABBIT,
		TRADE_GOOD_MEAT,
		TRADE_GOOD_PORK,
		TRADE_GOOD_POULTRY,
		TRADE_GOOD_PORK_BELLY,
		TRADE_GOOD_HAM,
	)

/datum/goods_group/game_meats
	name = "Game Meats"
	members = list(
		TRADE_GOOD_LESSER_MEAT,
		TRADE_GOOD_BOGMEAT,
		TRADE_GOOD_BUSHMEAT,
		TRADE_GOOD_GREATER_BUSHMEAT,
		TRADE_GOOD_VENISON,
		TRADE_GOOD_VENISON_RIBS,
		TRADE_GOOD_BOAR_HAM,
	)

/datum/goods_group/preserved_meats
	name = "Preserved Meats"
	members = list(
		TRADE_GOOD_SAUSAGE,
		TRADE_GOOD_SALUMOI,
	)

/datum/goods_group/dairy
	name = "Dairy"
	members = list(
		TRADE_GOOD_CHEESE,
		TRADE_GOOD_BUTTER,
	)

/datum/goods_group/animal_parts
	name = "Animal Parts"
	members = list(
		TRADE_GOOD_SINEW,
		TRADE_GOOD_TALLOW,
		TRADE_GOOD_BONES,
		TRADE_GOOD_VISCERA,
	)

/datum/goods_group/hides_and_furs
	name = "Hides and Furs"
	members = list(
		TRADE_GOOD_HIDE,
		TRADE_GOOD_FUR,
	)

/datum/goods_group/cloth_and_silk
	name = "Cloth and Silk"
	members = list(
		TRADE_GOOD_CLOTH,
		TRADE_GOOD_SILK,
	)
