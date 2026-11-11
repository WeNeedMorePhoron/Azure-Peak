/datum/controller/subsystem/economy/proc/grant_crown_caravans()
	var/due = min(CARAVAN_START_MAX, CARAVAN_START_BASE + round(get_effective_player_count() / CARAVAN_START_POP_STEP))
	while(caravans_granted < due)
		if(!add_crown_caravan())
			return
		caravans_granted++

/datum/controller/subsystem/economy/proc/add_crown_caravan()
	if(length(crown_caravans) >= CARAVAN_MAX)
		return null
	var/datum/crown_caravan/caravan = new("Caravan [length(crown_caravans) + 1]")
	crown_caravans += caravan
	return caravan

/datum/controller/subsystem/economy/proc/route_open_regions(route)
	. = list()
	for(var/datum/economic_region/region as anything in get_route_regions(route))
		if(!region.is_region_blockaded)
			. += region

/datum/controller/subsystem/economy/proc/route_capacity(list/regions, good_id, importing)
	. = 0
	for(var/datum/economic_region/region as anything in regions)
		. += region.get_day_capacity(good_id, importing)

/datum/controller/subsystem/economy/proc/spend_route_capacity(list/regions, good_id, units, importing)
	for(var/datum/economic_region/region as anything in regions)
		if(units <= 0)
			return
		var/take = min(units, region.get_day_capacity(good_id, importing))
		if(take <= 0)
			continue
		var/list/today = importing ? region.produces_today : region.demands_today
		today[good_id] -= take
		units -= take

/datum/controller/subsystem/economy/proc/royal_order_need(good_id)
	. = 0
	if(get_good_route(good_id) == "warehouse")
		return
	for(var/datum/standing_order/O as anything in GLOB.standing_order_pool)
		if(!O.is_fulfilled)
			. += O.required_items[good_id] || 0

/datum/controller/subsystem/economy/proc/royal_spare(datum/roguestock/D)
	return max(0, D.royal_stock - royal_order_need(D.trade_good_id))

/datum/controller/subsystem/economy/proc/royal_delivery_share(datum/roguestock/D, units)
	return clamp(royal_order_need(D.trade_good_id) - D.royal_stock, 0, units)

/datum/controller/subsystem/economy/proc/plan_caravan_landing(datum/caravan_trip/trip)
	trip.royal_deliveries = list()
	trip.market_deliveries = list()
	var/list/deliveries = trip.get_deliveries()
	for(var/good_id in deliveries)
		var/datum/roguestock/D = find_stockpile_by_trade_good(good_id)
		var/units = deliveries[good_id]
		var/to_royal = royal_delivery_share(D, units)
		if(to_royal > 0)
			trip.royal_deliveries[good_id] = to_royal
		if(units > to_royal)
			trip.market_deliveries[good_id] = units - to_royal

/datum/controller/subsystem/economy/proc/plan_caravan_trip(list/order)
	var/datum/caravan_trip/trip = new()
	var/route = order["route"]
	trip.route = route
	if(!ispath(route, /datum/trade_route))
		trip.error = "Pick a route."
		return trip
	var/route_name = get_route_name(route)
	var/list/regions = route_open_regions(route)
	if(!length(regions))
		trip.error = "Raiders block all of [route_name]."
		return trip
	var/list/buys = order["buys"]
	for(var/good_id in buys)
		var/units = buys[good_id]
		var/datum/trade_good/tg = GLOB.trade_goods[good_id]
		if(!tg.importable || !find_stockpile_by_trade_good(good_id))
			trip.error = "[route_name] doesn't sell [tg.name]."
			return trip
		var/left = route_capacity(regions, good_id, TRUE)
		if(units > left)
			trip.error = left ? "[route_name] has only [left] [tg.name] left today." : "[route_name] has no [tg.name] today."
			return trip
		trip.buys[good_id] = units
		trip.buy_units += units
		trip.buy_cost += mammon_round(tg.producer_price() * units)
	var/list/sells = order["sells"]
	for(var/good_id in sells)
		var/units = sells[good_id]
		var/datum/trade_good/tg = GLOB.trade_goods[good_id]
		var/datum/roguestock/D = find_stockpile_by_trade_good(good_id)
		if(!D)
			trip.error = "[route_name] doesn't buy [tg.name]."
			return trip
		var/wanted = route_capacity(regions, good_id, FALSE)
		if(units > wanted)
			trip.error = wanted ? "[route_name] wants only [wanted] more [tg.name] today." : "[route_name] wants no [tg.name] today."
			return trip
		var/from_royal = min(units, royal_spare(D))
		var/from_market = units - from_royal
		if(from_market > 0)
			if(D.market_never_supplies || (D.market_stock < from_market && !D.market_has_supply()))
				trip.error = "Not enough [tg.name] to sell. Royal stock has [from_royal] and the Market has [D.market_never_supplies ? 0 : max(0, D.market_stock)]."
				return trip
			trip.market_purchases[good_id] = from_market
			trip.market_cost += D.market_ask(from_market)
		if(from_royal > 0)
			trip.royal_sales[good_id] = from_royal
		trip.sells[good_id] = units
		trip.sell_units += units
		trip.sell_revenue += mammon_round(tg.demander_price() * units)
	var/datum/economic_region/tribute_region = GLOB.economic_regions[order["tribute"]]
	if(tribute_region)
		if(!(tribute_region in regions) || !tribute_region.tribute_good || !find_stockpile_by_trade_good(tribute_region.tribute_good))
			trip.error = "[tribute_region.name] can't give tribute to a caravan on [route_name] today."
			return trip
		if(tribute_region.tribute_claimed)
			trip.error = "[tribute_region.name] has already given its tribute today."
			return trip
		var/datum/trade_good/tg = GLOB.trade_goods[tribute_region.tribute_good]
		var/units = round(tribute_value / tg.producer_price())
		if(units <= 0)
			trip.error = "[tribute_region.name]'s tribute can't cover a single [tg.name]."
			return trip
		trip.tribute_region = tribute_region.region_id
		trip.tribute_good = tribute_region.tribute_good
		trip.tribute_units = units
	if(trip.sell_units > CARAVAN_CAPACITY)
		trip.error = "A caravan carries at most [CARAVAN_CAPACITY] goods out."
		return trip
	if(trip.buy_units > CARAVAN_CAPACITY)
		trip.error = "A caravan carries at most [CARAVAN_CAPACITY] goods home."
		return trip
	if(!trip.buy_units && !trip.sell_units && !trip.tribute_units)
		trip.error = "Give the caravan something to buy, sell or collect."
		return trip
	var/cost = trip.get_departure_cost()
	if(cost > SStreasury.discretionary_fund.balance)
		trip.error = "The Treasury can't afford this trip. It has [format_mammon(SStreasury.discretionary_fund.balance)]m and needs [format_mammon(cost)]m."
		return trip
	plan_caravan_landing(trip)
	return trip

/datum/controller/subsystem/economy/proc/pending_market_deliveries(good_id, datum/caravan_trip/except)
	. = 0
	for(var/datum/crown_caravan/caravan as anything in crown_caravans)
		var/datum/caravan_trip/trip = caravan.trip
		if(trip && trip != except)
			. += trip.market_deliveries[good_id] || 0

/datum/controller/subsystem/economy/proc/estimate_market_revenue(datum/caravan_trip/trip)
	. = 0
	for(var/good_id in trip.market_deliveries)
		var/datum/roguestock/D = find_stockpile_by_trade_good(good_id)
		. += D.market_bid(trip.market_deliveries[good_id], D.market_stock + pending_market_deliveries(good_id, trip))

/datum/controller/subsystem/economy/proc/sanitize_caravan_order(list/raw)
	var/list/order = list("route" = null, "buys" = list(), "sells" = list(), "tribute" = null)
	if(!islist(raw))
		return order
	var/route = text2path("[raw["route"]]")
	if(ispath(route, /datum/trade_route))
		order["route"] = route
	order["buys"] = sanitize_caravan_lines(raw["buys"])
	order["sells"] = sanitize_caravan_lines(raw["sells"])
	var/tribute = raw["tribute"]
	if(istext(tribute) && GLOB.economic_regions[tribute])
		order["tribute"] = tribute
	return order

/datum/controller/subsystem/economy/proc/sanitize_caravan_lines(list/raw)
	var/list/lines = list()
	if(!islist(raw))
		return lines
	for(var/good_id in raw)
		if(!istext(good_id) || !GLOB.trade_goods[good_id])
			continue
		var/units = round(text2num("[raw[good_id]]"))
		if(units > 0)
			lines[good_id] = min(units, CARAVAN_CAPACITY)
	return lines

/datum/controller/subsystem/economy/proc/book_caravan_trip(mob/user, datum/crown_caravan/caravan, list/order)
	if(!caravan)
		return null
	if(caravan.trip)
		to_chat(user, span_warning("That caravan is already on the road."))
		return null
	var/datum/caravan_trip/trip = plan_caravan_trip(order)
	if(trip.error)
		to_chat(user, span_warning(trip.error))
		return null
	var/route_name = get_route_name(trip.route)
	if(trip.buy_cost > 0)
		SStreasury.burn(SStreasury.discretionary_fund, trip.buy_cost, "Caravan Purchase: [caravan.name] on [route_name]", LEDGER_CROWN_EXP_IMPORTS)
		SStreasury.total_import += trip.buy_cost
		SStreasury.economic_output += trip.buy_cost
		record_round_statistic(STATS_STOCKPILE_IMPORTS_VALUE, trip.buy_cost)
	if(trip.market_cost > 0)
		SStreasury.burn(SStreasury.discretionary_fund, trip.market_cost, "Caravan Market Purchase: [caravan.name] on [route_name]", LEDGER_CROWN_EXP_STOCKPILE)
	for(var/good_id in trip.market_purchases)
		var/datum/roguestock/D = find_stockpile_by_trade_good(good_id)
		D.market_stock = max(0, D.market_stock - trip.market_purchases[good_id])
		D.check_glut_relief()
	for(var/good_id in trip.royal_sales)
		var/datum/roguestock/D = find_stockpile_by_trade_good(good_id)
		D.royal_stock -= trip.royal_sales[good_id]
	var/list/regions = route_open_regions(trip.route)
	for(var/good_id in trip.buys)
		spend_route_capacity(regions, good_id, trip.buys[good_id], TRUE)
	for(var/good_id in trip.sells)
		spend_route_capacity(regions, good_id, trip.sells[good_id], FALSE)
	if(trip.tribute_region)
		var/datum/economic_region/tribute_region = GLOB.economic_regions[trip.tribute_region]
		tribute_region.tribute_claimed = TRUE
		last_tribute_picks[trip.route] = trip.tribute_region
	var/datum/trade_route/route_path = trip.route
	var/trip_time = initial(route_path.trip_time)
	trip.booked_by = user?.real_name
	trip.departed_at = world.time
	trip.returns_at = world.time + trip_time
	caravan.trip = trip
	caravan.last_order = order
	addtimer(CALLBACK(src, PROC_REF(finish_caravan_trip), caravan), trip_time)
	SStreasury.dirty_market_view()
	SStreasury.steward_machine?.say("[caravan.name] sets out on [route_name].")
	log_game("CARAVAN TRIP by [user ? user.ckey : "nobody"]: [caravan.name] on [route_name] (cost [trip.buy_cost]m, Market purchases [trip.market_cost]m, expected revenue [trip.sell_revenue]m, tribute [trip.tribute_units] [trip.tribute_good])")
	return trip

/datum/controller/subsystem/economy/proc/finish_caravan_trip(datum/crown_caravan/caravan)
	var/datum/caravan_trip/trip = caravan?.trip
	if(!trip)
		return
	var/route_name = get_route_name(trip.route)
	plan_caravan_landing(trip)
	for(var/good_id in trip.royal_deliveries)
		var/datum/roguestock/D = find_stockpile_by_trade_good(good_id)
		D.royal_stock += trip.royal_deliveries[good_id]
	var/market_revenue = 0
	for(var/good_id in trip.market_deliveries)
		var/datum/roguestock/D = find_stockpile_by_trade_good(good_id)
		var/units = trip.market_deliveries[good_id]
		market_revenue += D.market_bid(units)
		D.market_stock += units
		credit_economic_event_saturation(good_id, units)
	if(market_revenue > 0)
		SStreasury.mint(SStreasury.discretionary_fund, market_revenue, "Caravan Market Sale: [caravan.name] from [route_name]", null, LEDGER_CROWN_REV_STOCKPILE_SALES)
	if(trip.sell_revenue > 0)
		SStreasury.mint(SStreasury.discretionary_fund, trip.sell_revenue, "Caravan Sale: [caravan.name] on [route_name]", null, LEDGER_CROWN_REV_EXPORT_SALES)
		SStreasury.total_export += trip.sell_revenue
		SStreasury.economic_output += trip.sell_revenue
		record_round_statistic(STATS_STOCKPILE_EXPORTS_VALUE, trip.sell_revenue)
	caravan.trip = null
	SStreasury.dirty_market_view()
	SStreasury.steward_machine?.say("[caravan.name] returns from [route_name].")
	log_game("CARAVAN RETURN: [caravan.name] from [route_name] (revenue [trip.sell_revenue]m, Market sales [market_revenue]m)")
	qdel(trip)
