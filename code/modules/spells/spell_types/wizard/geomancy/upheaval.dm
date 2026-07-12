/datum/action/cooldown/spell/telegraphed_strike/upheaval
	button_icon = 'icons/mob/actions/mage_geomancy.dmi'
	name = "Upheaval"
	desc = "Slam the earth with your feet, sending a shockwave in the ground ahead of you. \
	Everything loose is thrown forward, and a stone pillar emerges at the center of the far end. \
	Deals double damage to structures. The blow can be parried by guard. Deals blunt physical damage."
	button_icon_state = "upheaval"
	sound = 'sound/combat/hits/onstone/stonedeath.ogg'
	spell_color = GLOW_COLOR_EARTHEN
	glow_intensity = GLOW_INTENSITY_MEDIUM
	attunement_school = ASPECT_NAME_GEOMANCY

	invocation_type = INVOCATION_SHOUT
	invocations = list("Frange Terram!")

	primary_resource_type = SPELL_COST_STAMINA
	primary_resource_cost = SPELLCOST_MAJOR_AOE

	cooldown_time = 20 SECONDS
	associated_skill = /datum/skill/magic/arcane
	spell_tier = 2
	spell_impact_intensity = SPELL_IMPACT_MEDIUM
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC | SPELL_REQUIRES_HUMAN

	damage = 60
	strike_damage_type = BRUTE
	blade_class = BCLASS_BLUNT
	npc_simple_damage_mult = 1.5
	committed_strike = TRUE
	interruptible = FALSE
	charging_slowdown = CHARGING_SLOWDOWN_SMALL
	windup_time = TELEGRAPH_AREA_DENIAL
	sweep_step = 0
	damage_structures = TRUE
	telegraph_type = /obj/effect/temp_visual/trap/geomancy
	strike_sound = 'sound/combat/hits/onstone/wallhit.ogg'
	detonate_sound = 'sound/combat/hits/onstone/stonedeath.ogg'

	var/item_launch_dist = 5
	var/turf/pending_boulder_turf

/datum/action/cooldown/spell/telegraphed_strike/upheaval/get_pattern_offsets()
	var/list/offsets = list()
	for(var/x in -1 to 1)
		for(var/y in 1 to 4)
			offsets += list(list(x, y))
	return offsets

/datum/action/cooldown/spell/telegraphed_strike/upheaval/get_sweep_bands()
	return list(get_pattern_offsets())

/datum/action/cooldown/spell/telegraphed_strike/upheaval/on_impact(mob/living/carbon/human/H, facing, atom/movable/visual)
	var/turf/origin = get_turf(H)
	if(!origin)
		return

	var/list/launch_turfs = list(origin)
	for(var/list/off in get_pattern_offsets())
		var/list/r = rotate_offset(off[1], off[2], facing)
		var/turf/T = locate(origin.x + r[1], origin.y + r[2], origin.z)
		if(T)
			launch_turfs |= T
	for(var/turf/T in launch_turfs)
		for(var/obj/item/I in T)
			if(I.anchored)
				continue
			var/turf/tgt = get_ranged_target_turf(I, facing, item_launch_dist)
			I.throw_at(tgt, item_launch_dist, 2, H, spin = TRUE)

	var/list/end_r = rotate_offset(0, 4, facing)
	pending_boulder_turf = locate(origin.x + end_r[1], origin.y + end_r[2], origin.z)

/datum/action/cooldown/spell/telegraphed_strike/upheaval/on_strike_complete(mob/living/carbon/human/H, hit_count, deflected)
	var/turf/end_turf = pending_boulder_turf
	pending_boulder_turf = null
	if(!end_turf || end_turf.density)
		return
	if(locate(/mob/living) in end_turf)
		return
	for(var/obj/structure/S in end_turf)
		if(S.density)
			return
	var/obj/structure/earthen_pillar/pillar = new(end_turf)
	pillar.caster_ref = WEAKREF(H)
	QDEL_IN(pillar, cooldown_time)

/datum/action/cooldown/spell/telegraphed_strike/upheaval/damage_obstacles(turf/T)
	if(!T || (T in struck_obstacles))
		return
	struck_obstacles += T
	var/hit_any = FALSE
	for(var/obj/structure/S in T)
		S.take_damage(damage, BRUTE, "blunt", object_damage_multiplier = 2)
		hit_any = TRUE
	if(hit_any)
		new /obj/effect/temp_visual/spell_impact(T, spell_color, spell_impact_intensity)
		if(detonate_sound)
			playsound(T, detonate_sound, 65, TRUE)

/obj/effect/temp_visual/trap/geomancy
	color = GLOW_COLOR_EARTHEN
	light_color = GLOW_COLOR_EARTHEN
	duration = 2 SECONDS
