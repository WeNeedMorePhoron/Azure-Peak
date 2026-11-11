/datum/crown_caravan
	var/name
	var/datum/caravan_trip/trip

/datum/crown_caravan/New(caravan_name)
	. = ..()
	name = caravan_name

/datum/caravan_trip
	var/route
	var/list/stops = list()
	var/buy_units = 0
	var/sell_units = 0
	var/error
	var/booked_by
	var/departed_at = 0
	var/returns_at = 0

/datum/caravan_trip/proc/find_stop(region_id)
	for(var/datum/caravan_stop/stop as anything in stops)
		if(stop.region_id == region_id)
			return stop
	return null

/datum/caravan_trip/proc/get_route_name()
	var/datum/trade_route/route_path = route
	return initial(route_path.name)

/datum/caravan_trip/proc/get_region_names()
	var/list/names = list()
	for(var/datum/caravan_stop/stop as anything in stops)
		var/datum/economic_region/region = GLOB.economic_regions[stop.region_id]
		names += region.name
	return english_list(names)

/datum/caravan_trip/proc/get_buy_cost()
	. = 0
	for(var/datum/caravan_stop/stop as anything in stops)
		. += stop.buy_cost

/datum/caravan_trip/proc/get_sell_revenue()
	. = 0
	for(var/datum/caravan_stop/stop as anything in stops)
		. += stop.sell_revenue

/datum/caravan_trip/proc/has_tribute()
	for(var/datum/caravan_stop/stop as anything in stops)
		if(length(stop.tribute))
			return TRUE
	return FALSE

/datum/caravan_stop
	var/region_id
	var/list/buys = list()
	var/list/sells = list()
	var/list/tribute = list()
	var/buy_cost = 0
	var/sell_revenue = 0
