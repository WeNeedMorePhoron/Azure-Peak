SUBSYSTEM_DEF(regionthreat)
	name = "Regional Threat"
	wait = 30 MINUTES
	flags = SS_KEEP_TIMING | SS_BACKGROUND
	runlevels = RUNLEVEL_GAME
	// SS fires every 30 minutes = 6 ticks per 3-hour round.
	// Highpop tick = THREAT_HIGHPOP_TICK_RATE (20%) of max_ambush. Each tick is a maintenance fight's worth of threat.
	// Lowpop tick = THREAT_LOWPOP_TICK_RATE (10%) of max_ambush.
	// Basin & Grove & Terrorbog are fully tameable (min 0). Coast & Decap stay dangerous (min > 0).
	var/list/threat_regions = list(
		new /datum/threat_region(
			_region_name = THREAT_REGION_AZURE_BASIN, // Solo: 1 mob | 5-party: 3 mobs
			_latent_ambush = 60,
			_min_ambush = 0,
			_max_ambush = 150,
			_fixed_ambush = FALSE,
			_lowpop_tick = 150 * THREAT_LOWPOP_TICK_RATE, // 15
			_highpop_tick = 150 * THREAT_HIGHPOP_TICK_RATE, // 30
			_base_divisor = 5
		),
		new /datum/threat_region(
			_region_name = THREAT_REGION_AZURE_GROVE, // Solo: 2 mobs | 5-party: 6 mobs
			_latent_ambush = 120,
			_min_ambush = 0,
			_max_ambush = 250,
			_fixed_ambush = FALSE,
			_lowpop_tick = 250 * THREAT_LOWPOP_TICK_RATE, // 25
			_highpop_tick = 250 * THREAT_HIGHPOP_TICK_RATE, // 50
			_base_divisor = 5
		),
		new /datum/threat_region(
			_region_name = THREAT_REGION_TERRORBOG, // Solo: 2-3 bogmen | 5-party: 7-10 mobs
			_latent_ambush = 300,
			_min_ambush = 0, // Fully tameable — a warden can engage in a long war to tame the terrorbog.
			_max_ambush = 500,
			_fixed_ambush = FALSE,
			_lowpop_tick = 500 * THREAT_LOWPOP_TICK_RATE, // 50
			_highpop_tick = 500 * THREAT_HIGHPOP_TICK_RATE, // 100
			_base_divisor = 10 // Higher divisor keeps solo fights manageable despite huge pool
		),
		// Coast & Decap stay somewhat dangerous no matter what
		new /datum/threat_region(
			_region_name = THREAT_REGION_AZUREAN_COAST, // Solo: 2 mobs | 5-party: 5-6 mobs
			_latent_ambush = 180,
			_min_ambush = 75,
			_max_ambush = 400,
			_fixed_ambush = FALSE,
			_lowpop_tick = 400 * THREAT_LOWPOP_TICK_RATE, // 40
			_highpop_tick = 400 * THREAT_HIGHPOP_TICK_RATE, // 80
			_base_divisor = 8 // Mid divisor — dangerous but not overwhelming solo
		),
		new /datum/threat_region(
			_region_name = THREAT_REGION_MOUNT_DECAP, // Solo: 1 big mob | 5-party: 2 big + extras
			_latent_ambush = 240,
			_min_ambush = 100,
			_max_ambush = 500,
			_fixed_ambush = FALSE,
			_lowpop_tick = 500 * THREAT_LOWPOP_TICK_RATE, // 50
			_highpop_tick = 500 * THREAT_HIGHPOP_TICK_RATE, // 100
			_base_divisor = 5 // Low divisor — everything here is expensive, needs big budgets
		)
	)

/datum/controller/subsystem/regionthreat/fire(resumed)
	var/player_count = GLOB.player_list.len
	var/ishighpop = player_count >= LOWPOP_THRESHOLD
	for(var/T in threat_regions)
		var/datum/threat_region/TR = T
		if(ishighpop)
			TR.increase_latent_ambush(TR.highpop_tick)
		else
			TR.increase_latent_ambush(TR.lowpop_tick)

/datum/controller/subsystem/regionthreat/proc/get_region(region_name)
	for(var/T in threat_regions)
		var/datum/threat_region/TR = T
		if(TR.region_name == region_name)
			return TR
	return null

/datum/threat_region_display
	var/region_name
	var/danger_level
	var/danger_color

/datum/controller/subsystem/regionthreat/proc/get_threat_regions_for_display()
	var/list/threat_region_displays = list()
	for(var/T in threat_regions)
		var/datum/threat_region/TR = T
		var/datum/threat_region_display/TRS = new /datum/threat_region_display
		TRS.region_name = TR.region_name
		TRS.danger_level = TR.get_danger_level()
		TRS.danger_color = TR.get_danger_color()
		threat_region_displays += TRS
	return threat_region_displays
