/datum/crown_caravan
	var/name
	var/datum/caravan_trip/trip
	var/list/last_order

/datum/crown_caravan/New(caravan_name)
	. = ..()
	name = caravan_name

/datum/caravan_trip
	var/route
	var/list/buys = list()
	var/list/sells = list()
	var/tribute_good
	var/tribute_units = 0
	var/buy_units = 0
	var/sell_units = 0
	var/buy_cost = 0
	var/sell_revenue = 0
	var/market_cost = 0
	var/list/market_purchases = list()
	var/list/royal_sales = list()
	var/list/royal_deliveries = list()
	var/list/market_deliveries = list()
	var/error
	var/booked_by
	var/departed_at = 0
	var/returns_at = 0

/datum/caravan_trip/proc/get_departure_cost()
	return buy_cost + market_cost

/datum/caravan_trip/proc/get_deliveries()
	var/list/deliveries = buys.Copy()
	if(tribute_good)
		deliveries[tribute_good] += tribute_units
	return deliveries
