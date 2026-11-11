/datum/trade_route
	var/name
	var/threat_region_id
	var/trip_time

/datum/trade_route/northern_seaway
	name = "Northern Seaway"
	threat_region_id = THREAT_REGION_AZUREAN_COAST
	trip_time = TRADE_ROUTE_TRIP_NORTHERN_SEAWAY

/datum/trade_route/southern_seaway
	name = "Southern Seaway"
	threat_region_id = THREAT_REGION_AZURE_GROVE
	trip_time = TRADE_ROUTE_TRIP_SOUTHERN_SEAWAY

/datum/trade_route/ore_road
	name = "The Ore Road"
	threat_region_id = THREAT_REGION_UNDERDARK
	trip_time = TRADE_ROUTE_TRIP_ORE_ROAD

/datum/trade_route/river_azur
	name = "River Azur"
	threat_region_id = THREAT_REGION_MOUNT_DECAP
	trip_time = TRADE_ROUTE_TRIP_RIVER_AZUR

/datum/trade_subroute
	var/name
	var/route

/proc/get_subroute_threat_region(subroute)
	var/datum/trade_subroute/subroute_path = subroute
	var/datum/trade_route/route_path = initial(subroute_path.route)
	return initial(route_path.threat_region_id)

/proc/get_subroute_regions(subroute)
	. = list()
	for(var/region_id in GLOB.economic_regions)
		var/datum/economic_region/region = GLOB.economic_regions[region_id]
		if(region.subroute == subroute)
			. += region

/datum/trade_subroute/rossan_coast
	name = "Rossan Coast"
	route = /datum/trade_route/northern_seaway

/datum/trade_subroute/eastern_shores
	name = "Eastern Shores"
	route = /datum/trade_route/northern_seaway

/datum/trade_subroute/kingsfield_circuit
	name = "Kingsfield Circuit"
	route = /datum/trade_route/southern_seaway

/datum/trade_subroute/southern_shore
	name = "Southern Shore"
	route = /datum/trade_route/southern_seaway

/datum/trade_subroute/syonic_passes
	name = "Syonic Passes"
	route = /datum/trade_route/ore_road

/datum/trade_subroute/terrorbog_causeway
	name = "Terrorbog Causeway"
	route = /datum/trade_route/ore_road

/datum/trade_subroute/riverine_azuria
	name = "Riverine Azuria"
	route = /datum/trade_route/river_azur

/datum/trade_subroute/east_bank_of_arwin
	name = "East Bank of Arwin"
	route = /datum/trade_route/river_azur
