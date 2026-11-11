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

/obj/structure/roguemachine/steward/proc/build_caravan_rows()
	var/list/rows = list()
	for(var/datum/crown_caravan/caravan as anything in SSeconomy.crown_caravans)
		var/datum/caravan_trip/trip = caravan.trip
		var/list/row = list(
			"ref" = REF(caravan),
			"name" = caravan.name,
			"on_road" = trip ? TRUE : FALSE,
			"last_trip" = caravan.last_route ? list("route" = "[caravan.last_route]", "stops" = caravan.last_orders) : null,
		)
		if(trip)
			row["route_name"] = trip.get_route_name()
			row["region_names"] = trip.get_region_names()
			row["booked_by"] = trip.booked_by || ""
			row["returns_in"] = max(0, round((trip.returns_at - world.time) / 10))
			row["buy_units"] = trip.buy_units
			row["sell_units"] = trip.sell_units
			row["buy_cost"] = trip.get_buy_cost()
			row["sell_revenue"] = trip.get_sell_revenue()
			row["has_tribute"] = trip.has_tribute() ? TRUE : FALSE
		rows += list(row)
	return rows

/obj/structure/roguemachine/steward/proc/build_caravan_quote(list/params)
	var/datum/caravan_trip/trip = SSeconomy.plan_caravan_trip(text2path("[params["route"]]"), SSeconomy.sanitize_caravan_orders(params["orders"]))
	var/list/stops = list()
	for(var/datum/caravan_stop/stop as anything in trip.stops)
		stops += list(list(
			"region_id" = stop.region_id,
			"buy_cost" = stop.buy_cost,
			"sell_revenue" = stop.sell_revenue,
		))
	return list(
		"stamp" = text2num("[params["stamp"]]") || 0,
		"ok" = trip.error ? FALSE : TRUE,
		"error" = trip.error || "",
		"buy_cost" = trip.get_buy_cost(),
		"sell_revenue" = trip.get_sell_revenue(),
		"stops" = stops,
	)
