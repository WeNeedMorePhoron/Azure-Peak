/obj/structure/roguemachine/steward/proc/build_caravan_routes()
	var/list/routes = list()
	for(var/datum/trade_route/route_path as anything in subtypesof(/datum/trade_route))
		var/list/subroutes = list()
		for(var/datum/trade_subroute/subroute_path as anything in subtypesof(/datum/trade_subroute))
			if(initial(subroute_path.route) != route_path)
				continue
			var/list/region_ids = list()
			for(var/datum/economic_region/region as anything in get_subroute_regions(subroute_path))
				region_ids += region.region_id
			subroutes += list(list(
				"name" = initial(subroute_path.name),
				"region_ids" = region_ids,
			))
		routes += list(list(
			"id" = "[route_path]",
			"name" = initial(route_path.name),
			"trip_minutes" = round(initial(route_path.trip_time) / (1 MINUTES)),
			"subroutes" = subroutes,
		))
	return routes

/obj/structure/roguemachine/steward/proc/caravan_order_data(list/order)
	if(!order)
		return null
	return list(
		"route" = "[order["route"]]",
		"buys" = order["buys"],
		"sells" = order["sells"],
		"tribute" = order["tribute"],
	)

/obj/structure/roguemachine/steward/proc/build_caravan_rows()
	var/list/rows = list()
	for(var/datum/crown_caravan/caravan as anything in SSeconomy.crown_caravans)
		var/datum/caravan_trip/trip = caravan.trip
		var/list/row = list(
			"ref" = REF(caravan),
			"name" = caravan.name,
			"on_road" = trip ? TRUE : FALSE,
			"last_order" = caravan_order_data(caravan.last_order),
		)
		if(trip)
			var/datum/trade_good/tribute_tg = trip.tribute_good ? GLOB.trade_goods[trip.tribute_good] : null
			row["route_name"] = get_route_name(trip.route)
			row["booked_by"] = trip.booked_by || ""
			row["returns_in"] = max(0, round((trip.returns_at - world.time) / 10))
			row["buy_units"] = trip.buy_units
			row["sell_units"] = trip.sell_units
			row["buy_cost"] = trip.get_departure_cost()
			row["sell_revenue"] = trip.sell_revenue
			row["market_estimate"] = SSeconomy.estimate_market_revenue(trip)
			row["tribute_name"] = tribute_tg ? tribute_tg.name : ""
			row["tribute_units"] = trip.tribute_units
		rows += list(row)
	return rows

/obj/structure/roguemachine/steward/proc/build_caravan_quote(list/params)
	var/datum/caravan_trip/trip = SSeconomy.plan_caravan_trip(SSeconomy.sanitize_caravan_order(params["order"]))
	return list(
		"stamp" = text2num("[params["stamp"]]") || 0,
		"ok" = trip.error ? FALSE : TRUE,
		"error" = trip.error || "",
		"buy_cost" = trip.buy_cost,
		"market_cost" = trip.market_cost,
		"sell_revenue" = trip.sell_revenue,
		"market_estimate" = trip.error ? 0 : SSeconomy.estimate_market_revenue(trip),
		"tribute_units" = trip.tribute_units,
		"royal_deliveries" = trip.royal_deliveries,
		"market_deliveries" = trip.market_deliveries,
		"royal_sales" = trip.royal_sales,
		"market_purchases" = trip.market_purchases,
	)
