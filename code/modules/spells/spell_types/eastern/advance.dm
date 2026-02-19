/*
 * Advance - Phalangite subclass 3-step charge attack
 *
 * The polar opposite of Azurean Phalanx. Where Phalanx pushes enemies back
 * to create space, Advance closes distance — 3 rapid steps forward in the
 * user's facing direction, ending with a spear thrust on anything in front.
 * Very short cooldown, no slowdown, but the charge is visible and can be
 * interrupted (stun, knockdown, etc.).
 *
 * References:
 *   Azurean Phalanx (code/modules/spells/spell_types/eastern/azurean_phalanx.dm) - mirror ability
 *   Shukuchi (code/modules/spells/spell_types/eastern/shukuchi.dm) - execute_strike pattern
 */

/obj/effect/proc_holder/spell/self/advance
	name = "Advance"
	desc = "Charge forward 3 paces and deliver a spear thrust. The opposite of Azurean Phalanx — close distance instead of creating it."
	clothes_req = FALSE
	overlay_state = "blade_burst"
	releasedrain = 15
	chargedrain = 0
	chargetime = 2
	recharge_time = 8 SECONDS
	warnie = "spellwarning"
	no_early_release = TRUE
	movement_interrupt = FALSE
	charging_slowdown = 0
	chargedloop = /datum/looping_sound/invokegen
	invocations = list("Procedo!")
	invocation_type = "shout"
	gesture_required = TRUE
	xp_gain = FALSE
	var/charge_steps = 3
	var/strike_damage = 40
	var/step_delay = 2 // deciseconds between steps (0.2s each = 0.6s total)

/obj/effect/proc_holder/spell/self/advance/cast(list/targets, mob/user = usr)
	var/mob/living/carbon/human/H = user
	if(!istype(H))
		revert_cast()
		return

	// Require a weapon in hand
	var/obj/item/held_weapon = H.get_active_held_item()
	if(!held_weapon)
		held_weapon = H.get_inactive_held_item()
	if(!held_weapon)
		to_chat(H, span_warning("I need a weapon in hand!"))
		revert_cast()
		return

	var/facing = H.dir
	var/turf/start = get_turf(H)

	// Validate path — check that at least 1 tile ahead is open
	var/turf/first_step = get_step(start, facing)
	if(!first_step || first_step.density)
		to_chat(H, span_warning("There's no room to charge!"))
		revert_cast()
		return

	// Unbuckle if needed
	if(H.buckled)
		H.buckled.unbuckle_mob(H, TRUE)

	H.visible_message(
		span_warning("[H] surges forward!"),
		span_notice("I advance!"))
	playsound(start, pick('sound/combat/wooshes/bladed/wooshsmall (1).ogg', 'sound/combat/wooshes/bladed/wooshsmall (2).ogg'), 60, TRUE)

	// --- 3 rapid steps forward ---
	var/steps_taken = 0
	for(var/i in 1 to charge_steps)
		// Interrupted check — stun, knockdown, incapacitated
		if(H.stat != CONSCIOUS || H.IsParalyzed() || H.IsStun() || QDELETED(H))
			break

		var/turf/next = get_step(get_turf(H), facing)
		if(!next || next.density)
			break

		// Check for blocking structures (doors, gates, bars)
		var/blocked = FALSE
		for(var/obj/structure/S in next.contents)
			if(S.density)
				blocked = TRUE
				break
		if(blocked)
			break

		step(H, facing)
		steps_taken++

		// Brief kinetic effect at each step
		new /obj/effect/temp_visual/kinetic_blast(get_turf(H))

		if(i < charge_steps)
			sleep(step_delay)

	if(steps_taken == 0)
		to_chat(H, span_warning("My charge is blocked!"))
		return

	// --- Thrust attack on arrival ---
	// Hit the first living mob on our tile or 1 tile ahead
	var/mob/living/victim = null

	// Check current tile first
	for(var/mob/living/M in get_turf(H))
		if(M != H && M.stat != DEAD)
			victim = M
			break

	// Then check the tile in front
	if(!victim)
		var/turf/ahead = get_step(get_turf(H), facing)
		if(ahead)
			for(var/mob/living/M in ahead)
				if(M != H && M.stat != DEAD)
					victim = M
					break

	if(!victim)
		H.visible_message(span_notice("[H] finishes the charge with a thrust at the air."))
		return

	// Deliver spear thrust
	var/armor_block = victim.run_armor_check(BODY_ZONE_CHEST, "stab", blade_dulling = BCLASS_STAB, damage = strike_damage)
	victim.apply_damage(strike_damage, BRUTE, BODY_ZONE_CHEST, armor_block)

	// Crit/wound roll
	var/effective_damage = strike_damage * ((100 - armor_block) / 100)
	if(effective_damage > 0 && iscarbon(victim))
		var/mob/living/carbon/C = victim
		var/obj/item/bodypart/affecting = C.get_bodypart(check_zone(BODY_ZONE_CHEST))
		if(affecting)
			affecting.bodypart_attacked_by(BCLASS_STAB, effective_damage, H, BODY_ZONE_CHEST, crit_message = TRUE, weapon = held_weapon)

	// Attack animation — forward thrust
	H.do_attack_animation(victim, ATTACK_EFFECT_SLASH, held_weapon, item_animation_override = ATTACK_ANIMATION_THRUST)
	playsound(get_turf(victim), pick('sound/combat/hits/bladed/genthrust (1).ogg', 'sound/combat/hits/bladed/genthrust (2).ogg'), 80, TRUE)

	H.visible_message(
		span_danger("[H] drives [held_weapon.name] forward into [victim]!"),
		span_notice("I drive my [held_weapon.name] into [victim]!"))

	log_combat(H, victim, "advance-thrust", held_weapon, "(DMG: [strike_damage]) (STEPS: [steps_taken])")

	return TRUE
