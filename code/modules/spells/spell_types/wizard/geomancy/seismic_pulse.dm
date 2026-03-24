/datum/action/cooldown/spell/seismic_pulse
	button_icon = 'icons/mob/actions/mage_geomancy.dmi'
	name = "Seismic Pulse"
	desc = "Release a shockwave through the earth, pushing nearby creatures away from you. \
	Deals no damage, but targets slammed into walls are knocked down."
	button_icon_state = "gravity"
	sound = 'sound/magic/repulse.ogg'
	spell_color = GLOW_COLOR_EARTHEN
	glow_intensity = GLOW_INTENSITY_LOW
	attunement_school = ASPECT_NAME_GEOMANCY

	click_to_activate = TRUE
	self_cast_possible = TRUE

	primary_resource_type = SPELL_COST_STAMINA
	primary_resource_cost = SPELLCOST_MINOR_PROJECTILE

	invocations = list("Tremor!")
	invocation_type = INVOCATION_SHOUT

	charge_required = TRUE
	charge_time = CHARGETIME_POKE
	charge_drain = 1
	charge_slowdown = CHARGING_SLOWDOWN_SMALL
	charge_sound = 'sound/magic/charging.ogg'
	cooldown_time = 20 SECONDS

	associated_skill = /datum/skill/magic/arcane
	spell_tier = 2
	spell_impact_intensity = SPELL_IMPACT_LOW

	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC | SPELL_REQUIRES_HUMAN

	var/maxthrow = 3
	var/sparkle_path = /obj/effect/temp_visual/gravpush
	var/seismic_pulse_force = MOVE_FORCE_EXTREMELY_STRONG
	var/push_range = 1

/datum/action/cooldown/spell/seismic_pulse/cast(atom/cast_on)
	. = ..()
	var/mob/living/user = owner
	if(!istype(user))
		return FALSE

	var/list/thrownatoms = list()
	var/atom/throwtarget
	var/distfromcaster
	for(var/turf/T in get_hear(push_range, user))
		new /obj/effect/temp_visual/kinetic_blast(T)
		for(var/atom/movable/AM in T)
			thrownatoms += AM

	for(var/am in thrownatoms)
		var/atom/movable/AM = am
		if(AM == user || AM.anchored)
			continue

		if(ismob(AM))
			var/mob/M = AM
			if(M.anti_magic_check())
				continue
			if(isliving(M) && spell_guard_check(M, TRUE))
				M.visible_message(span_warning("[M] braces against the shockwave!"))
				continue

		throwtarget = get_edge_target_turf(user, get_dir(user, get_step_away(AM, user)))
		distfromcaster = get_dist(user, AM)
		new sparkle_path(get_turf(AM), get_dir(user, AM))
		if(isliving(AM))
			var/mob/living/L = AM
			to_chat(L, span_danger("A shockwave pushes me back!"))
		AM.safe_throw_at(throwtarget, ((CLAMP((maxthrow - (CLAMP(distfromcaster - 2, 0, distfromcaster))), 3, maxthrow))), 1, user, force = seismic_pulse_force)

	user.add_movespeed_modifier("seismic_pulse_boost", update = TRUE, priority = 100, multiplicative_slowdown = -1, movetypes = GROUND)
	addtimer(CALLBACK(user, TYPE_PROC_REF(/mob, remove_movespeed_modifier), "seismic_pulse_boost"), 2 SECONDS)
	return TRUE
