/datum/region_type
	var/name
	var/description = ""
	var/list/produces = list()
	var/list/demands = list()
	var/list/seasonal_produces = list()
	var/list/seasonal_demands = list()
	var/list/rotating_demands = list()
	var/rotating_picks = 0

/datum/region_type/proc/season_multiplier(list/seasonal, good_id, season)
	var/entry = seasonal[season]
	if(isnull(entry))
		return 1
	if(islist(entry))
		var/list/per_good = entry
		return isnull(per_good[good_id]) ? 1 : per_good[good_id]
	return entry
