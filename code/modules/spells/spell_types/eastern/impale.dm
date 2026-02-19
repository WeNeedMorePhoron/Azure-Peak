/*
 * Impale - Blade subclass foot-targeted ground attack
 *
 * Target a tile with a downward blade strike at the feet. Respects armor —
 * if the target has poor/no foot armor, applies a slowdown. Support spell
 * for chasing runners and punishing cheap armor builds.
 *
 * References:
 *   Blade Burst (code/modules/spells/spell_types/wizard/invoked_aoe/blade_burst.dm) - tile targeting
 *   Arcyne Momentum (code/modules/spells/spell_types/eastern/arcyne_momentum.dm) - stack system
 */

/obj/effect/proc_holder/spell/invoked/impale
	name = "Impale"
	desc = "Drive your blade into the ground at a target's feet. If they lack foot armor, they are slowed. Requires 3 momentum stacks."
	clothes_req = FALSE
	range = 2
	overlay_state = "blade_burst"
	releasedrain = 15
	chargedrain = 0
	chargetime = 3
	recharge_time = 10 SECONDS
	warnie = "spellwarning"
	no_early_release = TRUE
	movement_interrupt = FALSE
	charging_slowdown = 1
	chargedloop = /datum/looping_sound/invokegen
	invocations = list("Transfige!")
	invocation_type = "shout"
	gesture_required = TRUE
	xp_gain = FALSE
	var/momentum_cost = 3
	var/damage = 20
	/// Armor block threshold below which the slow is applied
	var/armor_threshold = 30

/obj/effect/proc_holder/spell/invoked/impale/can_cast(mob/user)
	. = ..()
	if(!.)
		return FALSE
	if(get_arcyne_momentum(user) < momentum_cost)
		return FALSE

/obj/effect/proc_holder/spell/invoked/impale/cast(list/targets, mob/user = usr)
	var/mob/living/carbon/human/H = user
	if(!istype(H))
		revert_cast()
		return

	// Consume momentum
	var/datum/status_effect/buff/arcyne_momentum/M = H.has_status_effect(/datum/status_effect/buff/arcyne_momentum)
	if(!M || M.stacks < momentum_cost)
		to_chat(H, span_warning("Not enough momentum! Need [momentum_cost] stacks."))
		revert_cast()
		return
	M.consume_stacks(momentum_cost)
	to_chat(H, span_notice("[momentum_cost] momentum released!"))

	var/turf/target_turf = get_turf(targets[1])
	if(!target_turf)
		revert_cast()
		return

	// Visual marker
	new /obj/effect/temp_visual/blade_burst(target_turf)
	playsound(target_turf, 'sound/magic/blade_burst.ogg', 60, TRUE)

	// Hit mobs on the tile
	for(var/mob/living/victim in target_turf)
		if(victim == H || victim.stat == DEAD)
			continue

		// Check foot armor specifically
		var/armor_block = victim.run_armor_check(BODY_ZONE_PRECISE_L_FOOT, "slash", blade_dulling = BCLASS_STAB, damage = damage)
		victim.apply_damage(damage, BRUTE, BODY_ZONE_PRECISE_L_FOOT, armor_block)

		// If armor is weak, apply speed debuff
		if(armor_block < armor_threshold)
			victim.apply_status_effect(/datum/status_effect/debuff/arcyne_impale_slow)
			to_chat(victim, span_danger("A blade pins my feet — I can barely move!"))
			to_chat(H, span_notice("[victim] is slowed — weak foot armor!"))
		else
			to_chat(H, span_warning("[victim]'s foot armor deflects the pin!"))

		H.do_attack_animation(victim, ATTACK_EFFECT_SLASH)
		playsound(get_turf(victim), pick('sound/combat/hits/bladed/genthrust (1).ogg', 'sound/combat/hits/bladed/genthrust (2).ogg'), 80, TRUE)
		log_combat(H, victim, "impaled", addition="(ARMOR: [armor_block]) (SLOWED: [armor_block < armor_threshold])")

	H.visible_message(span_danger("[H] drives a blade of arcyne force into the ground!"))
	return TRUE

/// Speed debuff applied by Impale when foot armor is weak
/datum/status_effect/debuff/arcyne_impale_slow
	id = "arcyne_impale_slow"
	duration = 4 SECONDS
	effectedstats = list(STATKEY_SPD = -3)
	alert_type = null
