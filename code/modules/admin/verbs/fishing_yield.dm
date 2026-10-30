#define FISHING_YIELD_CASTS_PER_HOUR 120
#define FISHING_YIELD_HOURS 1
#define FISHING_YIELD_RODLESS_ROLLS 1000
#define FISHING_YIELD_SUMMARY_PATH "data/fishing_yield_summary.csv"
#define FISHING_YIELD_CATCHES_PATH "data/fishing_yield_catches.csv"

/client/proc/fishing_yield_report()
	set category = "Debug"
	set name = "Fishing Yield Report"
	if(!check_rights(R_DEBUG))
		return

	var/list/baits = list(
		"none" = null,
		"basic" = /obj/item/natural/worms,
		"good" = /obj/item/natural/worms/grubs,
		"great" = /obj/item/reagent_containers/food/snacks/eoran_aril/cerulean,
		"red" = /obj/item/fishing/lure/meat,
		"dough" = /obj/item/fishing/lure/dough,
		"gray" = /obj/item/fishing/lure/gray,
		"speckled" = /obj/item/fishing/lure/speckled,
		"enchanted" = /obj/item/fishing/lure/deluxe,
	)
	var/mob/fisherman = mob
	var/turf/location = get_turf(fisherman)
	var/casts = FISHING_YIELD_CASTS_PER_HOUR * FISHING_YIELD_HOURS
	var/interval = (3600 / FISHING_YIELD_CASTS_PER_HOUR) SECONDS

	var/list/sources = list()
	for(var/path in GLOB.preset_fish_sources)
		if(path == /datum/fish_source/cage)
			continue
		var/datum/fish_source/source = GLOB.preset_fish_sources[path]
		if(length(source.fish_table))
			sources += source

	var/list/summary_csv = list("source,bait,fish_pct,dud_pct,junk_pct,mob_pct,fish_out_pct,mammon_per_hour,mammon_per_catch")
	var/list/catches_csv = list("source,bait,catch,count")
	var/html = "<style>table{border-collapse:collapse;font-size:12px}th,td{border:1px solid #666;padding:3px 6px;text-align:right}td:first-child,th:first-child,td.l{text-align:left}tr.src td{background:#333;color:#fff;font-weight:bold}</style>"
	html += "<p>[casts] casts over [FISHING_YIELD_HOURS] h per bait, every catch landed, no fisher trait, no region change. Live bait tiers first, then the five rolled baits. Prices are base sellprice; the rarity roll adds about 18% on average.</p>"
	html += "<table><tr><th>Bait</th><th>Fish</th><th>Dud</th><th>Junk</th><th>Mobs</th><th>Casts with a fish out</th><th>Mammon/h</th><th>Mammon/catch</th><th class='l'>Catches</th></tr>"

	for(var/datum/fish_source/source in sources)
		var/source_name = source.catalog_description || "[source.type]"
		html += "<tr class='src'><td colspan=9>[source_name]</td></tr>"
		for(var/bait_name in baits)
			var/obj/item/fishingrod/fisher/rod = new
			var/bait_path = baits[bait_name]
			if(bait_path)
				rod.baited = new bait_path(rod)
			var/list/stats = fishing_yield_simulate(source, rod, fisherman, location, casts, interval)
			qdel(rod)
			var/pct = 100 / casts
			var/caught = stats["fish"] + stats["junk"] + stats["mobs"]
			var/mammon_h = round(stats["mammon"] / FISHING_YIELD_HOURS, 0.1)
			var/mammon_c = caught ? round(stats["mammon"] / caught, 0.1) : 0
			var/list/tally = stats["tally"]
			var/list/catch_lines = list()
			for(var/path in tally)
				catch_lines += "[fishing_yield_name(path)] [tally[path]]"
				catches_csv += "[source_name],[bait_name],[fishing_yield_name(path)],[tally[path]]"
			html += "<tr><td>[bait_name]</td><td>[round(stats["fish"] * pct)]%</td><td>[round(stats["duds"] * pct)]%</td><td>[round(stats["junk"] * pct)]%</td><td>[round(stats["mobs"] * pct)]%</td><td>[round(stats["fish_out"] * pct)]%</td><td>[mammon_h]</td><td>[mammon_c]</td><td class='l'>[catch_lines.Join(", ")]</td></tr>"
			summary_csv += "[source_name],[bait_name],[round(stats["fish"] * pct)],[round(stats["duds"] * pct)],[round(stats["junk"] * pct)],[round(stats["mobs"] * pct)],[round(stats["fish_out"] * pct)],[mammon_h],[mammon_c]"
	html += "</table>"

	html += "<h3>Rodless rolls ([FISHING_YIELD_RODLESS_ROLLS] per source, no depletion)</h3>"
	html += "<table><tr><th>Source</th><th colspan=3>Spear</th><th colspan=3>Compulsion</th></tr><tr><th></th><th>Fish</th><th>Mobs</th><th>Mammon/hit</th><th>Fish</th><th>Mobs</th><th>Mammon/pull</th></tr>"
	for(var/datum/fish_source/source in sources)
		var/source_name = source.catalog_description || "[source.type]"
		var/list/spear = fishing_yield_rodless(source, location, TRUE)
		var/list/compel = fishing_yield_rodless(source, location, FALSE)
		html += "<tr><td>[source_name]</td><td>[spear["fish"]]%</td><td>[spear["mobs"]]%</td><td>[spear["mammon"]]</td><td>[compel["fish"]]%</td><td>[compel["mobs"]]%</td><td>[compel["mammon"]]</td></tr>"
		summary_csv += "[source_name],spear,[spear["fish"]],,,[spear["mobs"]],,,[spear["mammon"]]"
		summary_csv += "[source_name],compulsion,[compel["fish"]],,,[compel["mobs"]],,,[compel["mammon"]]"
	html += "</table>"

	var/datum/fish_source/cage = GLOB.preset_fish_sources[/datum/fish_source/cage]
	var/cage_value = fishing_yield_table_value(cage.fish_table)
	var/cage_slow = round(cage_value * 3600 / FISHING_CAGE_CATCH_TIME_SLOWEST, 0.1)
	var/cage_fast = round(cage_value * 3600 / FISHING_CAGE_CATCH_TIME_FASTEST, 0.1)
	html += "<p>Cage: [cage_value] mammon per catch, [cage_slow]/h unskilled to [cage_fast]/h legendary, one bait resilience per catch.</p>"
	summary_csv += "cage,unskilled,,,,,,[cage_slow],[cage_value]"
	summary_csv += "cage,legendary,,,,,,[cage_fast],[cage_value]"

	var/datum/browser/popup = new(mob, "fishing_yield", "Fishing Yield", 1200, 800)
	popup.set_content(html)
	popup.open()

	rustg_file_write(summary_csv.Join("\n"), FISHING_YIELD_SUMMARY_PATH)
	rustg_file_write(catches_csv.Join("\n"), FISHING_YIELD_CATCHES_PATH)
	src << ftp(file(FISHING_YIELD_SUMMARY_PATH), "fishing_yield_summary.csv")
	src << ftp(file(FISHING_YIELD_CATCHES_PATH), "fishing_yield_catches.csv")

/proc/fishing_yield_price(path)
	if(!ispath(path, /obj/item))
		return 0
	var/obj/item/item = path
	return initial(item.sellprice)

/proc/fishing_yield_name(path)
	if(path == FISHING_DUD)
		return "dud"
	var/atom/atom = path
	return initial(atom.name)

/// Expected mammon of one flat pick from a table.
/proc/fishing_yield_table_value(list/table)
	var/total = 0
	var/value = 0
	for(var/result in table)
		total += table[result]
		value += table[result] * fishing_yield_price(result)
	return total ? round(value / total, 0.1) : 0

/// Walks a session of casts against a throwaway copy of the source, with counts and chained regen on a virtual clock.
/proc/fishing_yield_simulate(datum/fish_source/preset, obj/item/fishingrod/rod, mob/fisherman, atom/location, casts, interval)
	var/source_type = preset.type
	var/datum/fish_source/sim = new source_type
	var/list/regen_due = list()
	var/list/tally = list()
	var/list/stats = list("fish" = 0, "duds" = 0, "junk" = 0, "mobs" = 0, "fish_out" = 0, "mammon" = 0)
	var/now = 0

	for(var/i in 1 to casts)
		now += interval
		for(var/path in regen_due)
			var/list/due = regen_due[path]
			while(length(due) && due[1] <= now)
				sim.fish_counts[path] += 1
				due.Cut(1, 2)
		for(var/path in sim.fish_counts)
			if(sim.is_exhausted(path) && ispath(path, /obj/item/reagent_containers/food/snacks/fish))
				stats["fish_out"] += 1
				break

		var/result = pickweight(sim.get_modified_fish_table(rod, fisherman, location)) || FISHING_DUD
		var/path = sim.get_fish_path(result)
		if(path == FISHING_DUD)
			stats["duds"] += 1
			continue
		if(sim.is_limited(path))
			sim.fish_counts[path] -= 1
			var/list/due = regen_due[path]
			if(!due)
				due = list()
				regen_due[path] = due
			var/start = length(due) ? due[length(due)] : now
			due += start + sim.fish_count_regen[path]
		if(ispath(path, /obj/item/reagent_containers/food/snacks/fish))
			stats["fish"] += 1
		else if(ispath(path, /mob/living))
			stats["mobs"] += 1
		else
			stats["junk"] += 1
		tally[path] += 1
		stats["mammon"] += fishing_yield_price(path)

	sim.cleanup_generated_fish()
	qdel(sim)
	sortTim(tally, GLOBAL_PROC_REF(cmp_numeric_dsc), associative = TRUE)
	stats["tally"] = tally
	return stats

/proc/fishing_yield_rodless(datum/fish_source/source, atom/location, spear)
	var/fish = 0
	var/mobs = 0
	var/mammon = 0
	for(var/i in 1 to FISHING_YIELD_RODLESS_ROLLS)
		var/result = spear ? source.roll_simple_reward(location) : source.roll_compelled_reward(location)
		if(ispath(result, /obj/item/reagent_containers/food/snacks/fish))
			fish++
		else if(ispath(result, /mob/living))
			mobs++
		mammon += fishing_yield_price(result)
	var/pct = 100 / FISHING_YIELD_RODLESS_ROLLS
	return list("fish" = round(fish * pct), "mobs" = round(mobs * pct), "mammon" = round(mammon / FISHING_YIELD_RODLESS_ROLLS, 0.1))

#undef FISHING_YIELD_CASTS_PER_HOUR
#undef FISHING_YIELD_HOURS
#undef FISHING_YIELD_RODLESS_ROLLS
#undef FISHING_YIELD_SUMMARY_PATH
#undef FISHING_YIELD_CATCHES_PATH
