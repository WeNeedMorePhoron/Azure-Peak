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

/datum/controller/subsystem/economy/proc/quote_region_import(good_id, datum/economic_region/region, units)
	var/starting_index = max(0, (region.produces[good_id] || 0) - (region.produces_today[good_id] || 0))
	var/total = 0
	for(var/i in 1 to units)
		total += compute_import_unit_price(good_id, region, starting_index + i)
	return round(total, STOCKPILE_PRICE_STEP)

/datum/controller/subsystem/economy/proc/quote_region_export(good_id, datum/economic_region/region, units)
	var/starting_index = max(0, (region.demands[good_id] || 0) - (region.demands_today[good_id] || 0))
	var/total = 0
	for(var/i in 1 to units)
		total += compute_export_unit_price(good_id, region, starting_index + i)
	return round(total, STOCKPILE_PRICE_STEP)

/datum/controller/subsystem/economy/proc/plan_caravan_trip(route, list/orders)
	var/datum/caravan_trip/trip = new()
	trip.route = route
	if(!ispath(route, /datum/trade_route))
		trip.error = "Pick a route."
		return trip
	if(!length(orders) || length(orders) > CARAVAN_STOPS_MAX)
		trip.error = "A caravan trades with one or two regions on its route."
		return trip
	var/list/sold = list()
	for(var/list/order as anything in orders)
		var/datum/economic_region/region = GLOB.economic_regions[order["region_id"]]
		if(!region || get_subroute_route(region.subroute) != route)
			trip.error = "That region isn't on this route."
			return trip
		if(trip.find_stop(region.region_id))
			trip.error = "[region.name] is listed twice."
			return trip
		if(region.is_region_blockaded)
			trip.error = "Raiders are blocking the road to [region.name]."
			return trip
		var/datum/caravan_stop/stop = new()
		stop.region_id = region.region_id
		trip.stops += stop
		var/list/buys = order["buys"]
		for(var/good_id in buys)
			var/units = round(buys[good_id])
			if(units <= 0)
				continue
			var/datum/trade_good/tg = GLOB.trade_goods[good_id]
			if(!tg?.importable || !region.produces[good_id] || !find_stockpile_by_trade_good(good_id))
				trip.error = "[region.name] doesn't sell [tg ? tg.name : good_id]."
				return trip
			stop.buys[good_id] = units
			stop.buy_cost += quote_region_import(good_id, region, units)
			trip.buy_units += units
		var/list/sells = order["sells"]
		for(var/good_id in sells)
			var/units = round(sells[good_id])
			if(units <= 0)
				continue
			var/datum/trade_good/tg = GLOB.trade_goods[good_id]
			if(!tg || !region.demands[good_id])
				trip.error = "[region.name] doesn't buy [tg ? tg.name : good_id]."
				return trip
			stop.sells[good_id] = units
			stop.sell_revenue += quote_region_export(good_id, region, units)
			trip.sell_units += units
			sold[good_id] += units
		var/list/tribute = order["tribute"]
		var/tribute_spent = 0
		for(var/good_id in tribute)
			var/units = round(tribute[good_id])
			if(units <= 0)
				continue
			var/datum/trade_good/tg = GLOB.trade_goods[good_id]
			var/price = region.tribute_unit_price(good_id)
			if(!price || !find_stockpile_by_trade_good(good_id))
				trip.error = "[region.name] can't give [tg ? tg.name : good_id] as tribute today."
				return trip
			stop.tribute[good_id] = units
			tribute_spent += price * units
		if(length(stop.tribute))
			if(region.tribute_claimed)
				trip.error = "[region.name] has already given its tribute today."
				return trip
			if(tribute_spent > region.tribute_value)
				trip.error = "That is more than [region.name]'s tribute today."
				return trip
	if(trip.sell_units > CARAVAN_CAPACITY)
		trip.error = "A caravan carries at most [CARAVAN_CAPACITY] goods out."
		return trip
	if(trip.buy_units > CARAVAN_CAPACITY)
		trip.error = "A caravan carries at most [CARAVAN_CAPACITY] goods home."
		return trip
	for(var/good_id in sold)
		var/datum/roguestock/D = find_stockpile_by_trade_good(good_id)
		if(!D || D.royal_stock < sold[good_id])
			trip.error = "Not enough [D ? D.name : good_id] in the royal stockpile. You have [D?.royal_stock || 0] and need [sold[good_id]]."
			return trip
	if(!trip.buy_units && !trip.sell_units && !trip.has_tribute())
		trip.error = "Give the caravan something to buy, sell or collect."
		return trip
	var/cost = trip.get_buy_cost()
	if(cost > SStreasury.discretionary_fund.balance)
		trip.error = "The Treasury can't afford this trip. It has [format_mammon(SStreasury.discretionary_fund.balance)]m and needs [format_mammon(cost)]m."
	return trip

/datum/controller/subsystem/economy/proc/sanitize_caravan_orders(list/raw)
	var/list/orders = list()
	if(!islist(raw))
		return orders
	for(var/entry in raw)
		if(!islist(entry))
			continue
		var/list/order = entry
		orders += list(list(
			"region_id" = "[order["region_id"]]",
			"buys" = sanitize_caravan_lines(order["buys"], CARAVAN_CAPACITY),
			"sells" = sanitize_caravan_lines(order["sells"], CARAVAN_CAPACITY),
			"tribute" = sanitize_caravan_lines(order["tribute"]),
		))
		if(length(orders) > CARAVAN_STOPS_MAX)
			break
	return orders

/datum/controller/subsystem/economy/proc/sanitize_caravan_lines(list/raw, cap)
	var/list/lines = list()
	if(!islist(raw))
		return lines
	for(var/good_id in raw)
		if(!istext(good_id) || !GLOB.trade_goods[good_id])
			continue
		var/units = round(text2num("[raw[good_id]]"))
		if(units > 0)
			lines[good_id] = cap ? min(units, cap) : units
	return lines

/datum/controller/subsystem/economy/proc/book_caravan_trip(mob/user, datum/crown_caravan/caravan, route, list/orders)
	if(!caravan)
		return null
	if(caravan.trip)
		to_chat(user, span_warning("That caravan is already on the road."))
		return null
	var/datum/caravan_trip/trip = plan_caravan_trip(route, orders)
	if(trip.error)
		to_chat(user, span_warning(trip.error))
		return null
	var/cost = trip.get_buy_cost()
	if(cost > 0 && !SStreasury.burn(SStreasury.discretionary_fund, cost, "Caravan Purchase: [caravan.name] to [trip.get_region_names()]", LEDGER_CROWN_EXP_IMPORTS))
		to_chat(user, span_warning("The Treasury can't afford this trip."))
		return null
	for(var/datum/caravan_stop/stop as anything in trip.stops)
		var/datum/economic_region/region = GLOB.economic_regions[stop.region_id]
		for(var/good_id in stop.buys)
			region.produces_today[good_id] = (region.produces_today[good_id] || 0) - stop.buys[good_id]
		for(var/good_id in stop.sells)
			region.demands_today[good_id] = (region.demands_today[good_id] || 0) - stop.sells[good_id]
			var/datum/roguestock/D = find_stockpile_by_trade_good(good_id)
			D.royal_stock -= stop.sells[good_id]
		if(length(stop.tribute))
			region.tribute_claimed = TRUE
			last_tribute_picks[stop.region_id] = stop.tribute.Copy()
	if(cost > 0)
		SStreasury.total_import += cost
		SStreasury.economic_output += cost
		record_round_statistic(STATS_STOCKPILE_IMPORTS_VALUE, cost)
	var/datum/trade_route/route_path = route
	var/trip_time = initial(route_path.trip_time)
	trip.booked_by = user?.real_name
	trip.departed_at = world.time
	trip.returns_at = world.time + trip_time
	caravan.trip = trip
	caravan.last_route = route
	caravan.last_orders = orders
	addtimer(CALLBACK(src, PROC_REF(finish_caravan_trip), caravan), trip_time)
	SStreasury.dirty_market_view()
	SStreasury.steward_machine?.say("[caravan.name] sets out for [trip.get_region_names()].")
	log_game("CARAVAN TRIP by [user ? user.ckey : "nobody"]: [caravan.name] to [trip.get_region_names()] on [trip.get_route_name()] (cost [cost]m, expected revenue [trip.get_sell_revenue()]m)")
	return trip

/datum/controller/subsystem/economy/proc/finish_caravan_trip(datum/crown_caravan/caravan)
	var/datum/caravan_trip/trip = caravan?.trip
	if(!trip)
		return
	for(var/datum/caravan_stop/stop as anything in trip.stops)
		for(var/good_id in stop.buys)
			var/datum/roguestock/D = find_stockpile_by_trade_good(good_id)
			D.royal_stock += stop.buys[good_id]
		for(var/good_id in stop.tribute)
			var/datum/roguestock/D = find_stockpile_by_trade_good(good_id)
			D.royal_stock += stop.tribute[good_id]
	var/revenue = trip.get_sell_revenue()
	if(revenue > 0)
		SStreasury.mint(SStreasury.discretionary_fund, revenue, "Caravan Sale: [caravan.name] to [trip.get_region_names()]", null, LEDGER_CROWN_REV_EXPORT_SALES)
		SStreasury.total_export += revenue
		SStreasury.economic_output += revenue
		record_round_statistic(STATS_STOCKPILE_EXPORTS_VALUE, revenue)
	caravan.trip = null
	SStreasury.dirty_market_view()
	SStreasury.steward_machine?.say("[caravan.name] is back from [trip.get_region_names()].")
	log_game("CARAVAN RETURN: [caravan.name] from [trip.get_region_names()] (revenue [revenue]m)")
	qdel(trip)
