GLOBAL_LIST_INIT(economic_regions, init_economic_regions())

/proc/init_economic_regions()
	var/list/result = list()
	for(var/datum/economic_region/er as anything in subtypesof(/datum/economic_region))
		var/datum/economic_region/instance = new er()
		if(!instance.region_id)
			continue
		result[instance.region_id] = instance
	return result

/datum/economic_region
	var/region_id
	var/name
	/// Italicized one-liner shown beneath the region name in the Lore Primer's
	/// AZURIA'S REGIONS section. The steward UI ignores it; only `description` shows there.
	var/subtitle = ""
	var/description = ""
	var/list/region_types = list()
	var/list/produces = list()
	var/list/demands = list()
	var/list/possible_standing_order_types = list()
	var/associated_marker_id
	var/is_region_blockaded = FALSE
	/// Null = this region cannot be blockaded.
	var/threat_region_id
	// Ensure this region won't replenish blockade. Used only for Kingsfield because Kingsfield blockade is devastating and shouldn't repeat mid round.
	var/blockade_replenish_eligible = TRUE

	var/list/produces_today = list()
	var/list/demands_today = list()

	var/list/produces_day_start = list()
	var/list/demands_day_start = list()

	/// -1 = never cleared. Otherwise the cooldown window runs from this day.
	var/day_last_cleared = -1

/datum/economic_region/New()
	. = ..()
	build_trade_lists()
	produces_today = produces.Copy()
	demands_today = demands.Copy()
	produces_day_start = produces.Copy()
	demands_day_start = demands.Copy()
	if(!associated_marker_id)
		associated_marker_id = "[region_id]_blockade"

/datum/economic_region/proc/build_trade_lists()
	var/list/supply = list()
	var/list/demand = list()
	for(var/type_path in region_types)
		var/multiplier = region_types[type_path]
		var/datum/region_type/region_type = new type_path()
		add_type_volumes(supply, region_type.produces, multiplier)
		add_type_volumes(demand, region_type.demands, multiplier)
	for(var/good_id in supply)
		demand -= good_id
	produces = supply
	demands = demand

/datum/economic_region/proc/add_type_volumes(list/into, list/volumes, multiplier)
	for(var/good_id in volumes)
		into[good_id] = max(into[good_id] || 0, max(1, round(volumes[good_id] * multiplier, 1)))

/datum/economic_region/proc/get_day_capacity(good_id, importing)
	var/list/today = importing ? produces_today : demands_today
	return max(0, today[good_id] || 0)

/datum/economic_region/proc/get_day_capacity_total(good_id, importing)
	var/list/day_start = importing ? produces_day_start : demands_day_start
	return max(0, day_start[good_id] || 0)

/datum/economic_region/proc/get_batch_capacity(good_id, importing)
	var/pace = (importing ? produces[good_id] : demands[good_id]) || 0
	if(pace <= 0)
		return 0
	return clamp((importing ? produces_today[good_id] : demands_today[good_id]) || 0, 0, pace)

/// Builds the AZURIA'S REGIONS section of the Lore Primer from the economic_region datums,
/// so steward UI prose and primer prose stay in sync from a single source.
/proc/build_regions_primer_html()
	var/list/parts = list()
	parts += "<details>"
	parts += "<summary><strong><span style='font-size:130%'> REGIONS OF AZURIA </span></strong></summary>"
	parts += "<strong><span style='font-size:115%'> THE INTERNAL VASSALS AND DEMESNES </span></strong>"
	parts += "<br><br>"
	for(var/region_id in GLOB.economic_regions)
		var/datum/economic_region/region = GLOB.economic_regions[region_id]
		if(!region)
			continue
		parts += "<details>"
		parts += "<summary><strong> [uppertext(region.name)] </strong></summary>"
		parts += "<br>"
		if(region.subtitle)
			parts += "<em>[region.subtitle]</em>"
			parts += "<br><br>"
		parts += region.description
		parts += "<br>"
		parts += "</details>"
	parts += "<br><br>"
	parts += "</details>"
	return jointext(parts, "\n")
