/datum/action/cooldown/spell/ramstam
	button_icon = 'icons/mob/actions/mage_geomancy.dmi'
	name = "Ramstam"
	desc = "Mark out a path, then transforms into a rolling mass of stone and hurtle toward your destination. Pushes everyone out of the way, and deal minor damage. If you are stopped by a wall, a burst of gravel will explode outward and you will deal significant damage to structures. Can be stopped by a Riposte that will leave you exposed."
	button_icon_state = "ramstam"
	sound = 'sound/foley/stone_scrape.ogg'
	spell_color = GLOW_COLOR_EARTHEN
	glow_intensity = GLOW_INTENSITY_LOW
	attunement_school = ASPECT_NAME_GEOMANCY

	click_to_activate = TRUE
	cast_range = SPELL_RANGE_GROUND
	self_cast_possible = FALSE

	primary_resource_type = SPELL_COST_STAMINA
	primary_resource_cost = SPELLCOST_MAJOR_AOE

	invocations = list("Volve!")
	invocation_type = INVOCATION_SHOUT

	charge_required = FALSE
	charge_swingdelay_type = SWINGDELAY_PENALTY
	cooldown_time = 25 SECONDS

	associated_skill = /datum/skill/magic/arcane
	spell_tier = 2
	spell_impact_intensity = SPELL_IMPACT_LOW

	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC | SPELL_REQUIRES_HUMAN | SPELL_REQUIRES_SAME_Z

	var/telegraph_length = 7
	var/max_tiles = 7
	var/telegraph_time = 6
	var/roll_speed = 1
	var/barrel_damage = 15
	var/knock_dist = 1
	var/expose_duration = 5 SECONDS
	var/fragment_count = 8
	var/fragment_damage = 12
	var/crash_structure_damage = 100
	var/rolling = FALSE

/datum/action/cooldown/spell/ramstam/cast(atom/cast_on)
	. = ..()
	var/mob/living/carbon/human/H = owner
	if(!istype(H))
		return FALSE
	if(rolling)
		return FALSE
	var/turf/target = get_turf(cast_on)
	if(!target)
		return FALSE
	var/dir = get_dir(H, target)
	if(!dir)
		return FALSE
	INVOKE_ASYNC(src, PROC_REF(do_ramstam), H, dir)
	return TRUE

/datum/action/cooldown/spell/ramstam/proc/do_ramstam(mob/living/carbon/human/H, dir)
	rolling = TRUE
	H.setDir(dir)
	var/commit_time = telegraph_time + max_tiles * roll_speed + 2
	H.changeNext_move(commit_time)
	H.apply_status_effect(/datum/status_effect/swingdelay/penalty/committed, commit_time, TRUE)
	H.tempfixeye = TRUE
	H.nodirchange = TRUE
	H.notransform = TRUE
	ADD_TRAIT(H, TRAIT_SPELLCOCKBLOCK, "ramstam_roll")

	var/list/indicators = list()
	var/turf/cur = get_turf(H)
	for(var/i in 1 to telegraph_length)
		cur = get_step(cur, dir)
		if(!cur || cur.density)
			break
		indicators += new /obj/effect/temp_visual/trap/geomancy(cur)
	playsound(H, 'sound/foley/stone_scrape.ogg', 60, TRUE)
	sleep(telegraph_time)
	for(var/obj/effect/E in indicators)
		qdel(E)

	if(QDELETED(H) || H.stat != CONSCIOUS)
		end_ramstam(H, null, initial(H.alpha))
		return

	var/saved_alpha = H.alpha
	H.alpha = 0
	var/obj/effect/ramstam_boulder/B = new(get_turf(H))
	B.setDir(dir)

	var/list/struck = list()
	for(var/i in 1 to max_tiles)
		if(QDELETED(H) || H.stat != CONSCIOUS)
			break
		var/turf/next = get_step(H, dir)
		if(!next || next.density)
			roll_crash(H, next)
			break
		var/blocked = FALSE
		for(var/obj/structure/S in next)
			if(S.density && !S.climbable)
				blocked = TRUE
				break
		if(blocked)
			roll_crash(H, next)
			break
		var/countered = FALSE
		for(var/mob/living/L in next)
			if(L == H)
				continue
			if(is_riposting(L))
				riposte_counter(H, L)
				countered = TRUE
				break
		if(countered)
			break
		H.forceMove(next)
		H.setDir(dir)
		B.forceMove(next)
		playsound(next, 'sound/foley/stone_scrape.ogg', 45, TRUE)
		new /obj/effect/temp_visual/kinetic_blast(next)
		for(var/mob/living/L in next)
			if(L == H || (L in struck))
				continue
			struck += L
			roll_hit(H, L, dir)
		sleep(roll_speed)

	end_ramstam(H, B, saved_alpha)

/datum/action/cooldown/spell/ramstam/proc/end_ramstam(mob/living/carbon/human/H, obj/effect/ramstam_boulder/B, restore_alpha)
	if(!QDELETED(B))
		qdel(B)
	if(!QDELETED(H))
		H.alpha = restore_alpha
		H.tempfixeye = FALSE
		H.nodirchange = FALSE
		H.notransform = FALSE
		REMOVE_TRAIT(H, TRAIT_SPELLCOCKBLOCK, "ramstam_roll")
	rolling = FALSE

/datum/action/cooldown/spell/ramstam/proc/roll_hit(mob/living/carbon/human/H, mob/living/L, dir)
	if(L.anti_magic_check())
		return
	if(ishuman(L))
		arcyne_strike(H, L, null, barrel_damage, H.zone_selected || BODY_ZONE_CHEST, BCLASS_BLUNT, \
			spell_name = name, damage_type = BRUTE, npc_simple_damage_mult = 1.5, skip_animation = TRUE)
	else
		L.adjustBruteLoss(barrel_damage * (L.mind ? 1 : 1.5))
	new /obj/effect/temp_visual/spell_impact(get_turf(L), spell_color, spell_impact_intensity)
	var/knockdir = pick(turn(dir, 90), turn(dir, -90))
	L.safe_throw_at(get_ranged_target_turf(L, knockdir, knock_dist), knock_dist, 1, H, force = MOVE_FORCE_STRONG)

/datum/action/cooldown/spell/ramstam/proc/roll_crash(mob/living/carbon/human/H, turf/obstacle)
	var/turf/from = get_turf(H)
	playsound(from, 'sound/combat/hits/onstone/stonedeath.ogg', 80, TRUE)
	if(obstacle)
		new /obj/effect/temp_visual/kinetic_blast(obstacle)
		if(obstacle.density)
			obstacle.take_damage(crash_structure_damage, BRUTE, "blunt")
		for(var/obj/structure/S in obstacle)
			if(S.density)
				S.take_damage(crash_structure_damage, BRUTE, "blunt")
	if(!from)
		return
	new /obj/effect/temp_visual/spell_impact(from, spell_color, SPELL_IMPACT_MEDIUM)
	var/static/list/burst_dirs = list(NORTH, SOUTH, EAST, WEST, NORTHEAST, NORTHWEST, SOUTHEAST, SOUTHWEST)
	for(var/i in 1 to fragment_count)
		var/fdir = pick(burst_dirs)
		var/turf/ftarget = get_ranged_target_turf(from, fdir, 4)
		var/obj/projectile/magic/gravel_blast/frag = new(from)
		frag.damage = fragment_damage
		frag.range = 4
		frag.firer = H
		frag.preparePixelProjectile(ftarget, from)
		frag.fire()

/datum/action/cooldown/spell/ramstam/proc/is_riposting(mob/living/L)
	if(!ishuman(L))
		return FALSE
	var/mob/living/carbon/human/HL = L
	return istype(HL.rmb_intent, /datum/rmb_intent/riposte)

/datum/action/cooldown/spell/ramstam/proc/riposte_counter(mob/living/carbon/human/H, mob/living/L)
	H.apply_status_effect(/datum/status_effect/debuff/exposed, expose_duration)
	H.visible_message(span_warning("[L] braces and turns [H]'s charge aside - [H] sprawls, exposed!"), span_userdanger("[L] catches my charge - I am thrown off and left exposed!"))
	playsound(get_turf(H), 'sound/combat/parry/parrygen.ogg', 70, TRUE)

/obj/effect/ramstam_boulder
	icon = 'icons/obj/magic_projectiles.dmi'
	icon_state = "boulder"
	anchored = TRUE
	density = FALSE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	layer = MOB_LAYER

/obj/effect/ramstam_boulder/Initialize(mapload)
	. = ..()
	SpinAnimation(15, -1)
