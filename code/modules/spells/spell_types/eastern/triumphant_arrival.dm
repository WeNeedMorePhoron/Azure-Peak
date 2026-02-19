/*
 * Triumphant Arrival - Phalanx subclass leap attack
 *
 * Fade away, then leap to a target. Strike them in the HEAD zone with a
 * downward spear plunge. Knock back everyone on the tile EXCEPT the target
 * (isolation pick). 30-second cooldown.
 *
 * References:
 *   Blink (code/modules/spells/spell_types/wizard/misc/blink.dm) - teleport validation
 *   Shukuchi (code/modules/spells/spell_types/eastern/shukuchi.dm) - afterimage + execute_strike
 *   Repulse (code/modules/spells/spell_types/wizard/invoked_aoe/repulse.dm) - selective knockback
 */

/obj/effect/proc_holder/spell/invoked/triumphant_arrival
	name = "Triumphant Arrival"
	desc = "Leap to a target, striking them from above with a devastating downward plunge. Knocks back everyone else nearby."
	clothes_req = FALSE
	range = 6
	overlay_state = "jump"
	releasedrain = 40
	chargedrain = 1
	chargetime = 5
	recharge_time = 30 SECONDS
	warnie = "spellwarning"
	no_early_release = TRUE
	movement_interrupt = FALSE
	charging_slowdown = 2
	chargedloop = /datum/looping_sound/invokegen
	invocations = list("Adventus Triumphans!")
	invocation_type = "shout"
	gesture_required = TRUE
	xp_gain = FALSE
	var/strike_damage_min = 35
	var/strike_damage_max = 50
	var/knockback_range = 2

/obj/effect/proc_holder/spell/invoked/triumphant_arrival/cast(list/targets, mob/user = usr)
	var/mob/living/carbon/human/H = user
	if(!istype(H))
		revert_cast()
		return

	// Require a weapon in hand
	var/obj/item/held_weapon = H.get_active_held_item()
	if(!held_weapon)
		held_weapon = H.get_inactive_held_item()
	if(!held_weapon)
		to_chat(H, span_warning("I need a weapon in hand for this technique!"))
		revert_cast()
		return

	var/atom/target = targets[1]
	var/turf/start = get_turf(H)
	var/turf/dest

	// Resolve destination
	if(isliving(target))
		dest = get_turf(target)
	else
		dest = get_turf(target)

	if(!dest)
		to_chat(H, span_warning("Invalid target!"))
		revert_cast()
		return

	// --- Validation (adapted from Blink) ---

	if(dest.z != start.z)
		to_chat(H, span_warning("I can only leap on the same plane!"))
		revert_cast()
		return

	if(dest.teleport_restricted)
		to_chat(H, span_warning("Something prevents me from leaping here!"))
		revert_cast()
		return

	if(istransparentturf(dest))
		to_chat(H, span_warning("I cannot leap into the open air!"))
		revert_cast()
		return

	var/distance = get_dist(start, dest)
	if(distance > range)
		to_chat(H, span_warning("Too far! Maximum range is [range] tiles."))
		revert_cast()
		return

	if(distance < 2)
		to_chat(H, span_warning("I need more distance to leap!"))
		revert_cast()
		return

	// --- Telegraph: warning at target + interruptible channel ---

	// Show ! warning at the target location
	var/obj/effect/warning_marker = new(dest)
	warning_marker.icon = 'icons/effects/effects.dmi'
	warning_marker.icon_state = "spellwarning"
	warning_marker.pixel_y = 16

	H.visible_message(
		span_warning("[H] crouches and focuses, preparing to leap!"),
		span_notice("I focus my strength..."))
	playsound(start, 'sound/magic/charged.ogg', 30, TRUE)

	// Interruptible channel — can be broken by movement/damage
	if(!do_after(H, 1 SECONDS, target = H))
		to_chat(H, span_warning("My concentration breaks!"))
		qdel(warning_marker)
		revert_cast()
		return

	qdel(warning_marker)

	// --- Execute the leap ---

	// Fade out — afterimage at start position
	playsound(start, 'sound/magic/blink.ogg', 40, TRUE)
	H.visible_message(
		span_warning("[H] fades from view!"),
		span_notice("I focus my strength and leap!"))

	// Brief afterimage at start
	var/obj/effect/after_image/fade = new(start, 0, 0, 0, 0, 0.5 SECONDS, 2 SECONDS, 0)
	fade.appearance = H.appearance
	fade.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	fade.alpha = 120
	QDEL_IN(fade, 2 SECONDS)

	// Unbuckle if needed
	if(H.buckled)
		H.buckled.unbuckle_mob(H, TRUE)

	// Teleport to destination
	do_teleport(H, dest, channel = TELEPORT_CHANNEL_MAGIC)
	playsound(dest, 'sound/magic/blink.ogg', 50, TRUE)

	log_combat(H, target, "used Triumphant Arrival on", addition="(DIST: [distance])")

	// --- Landing strike on the primary target ---

	if(isliving(target))
		var/mob/living/primary = target
		if(!QDELETED(primary) && primary.stat != DEAD)
			// Delayed strike for drama (0.3s)
			addtimer(CALLBACK(src, PROC_REF(execute_landing), H, primary, held_weapon, dest), 3)

	return TRUE

/// Delayed landing — strike primary target in the head, knockback everyone else
/obj/effect/proc_holder/spell/invoked/triumphant_arrival/proc/execute_landing(mob/living/carbon/human/user, mob/living/primary_target, obj/item/weapon, turf/landing_turf)
	if(!user || QDELETED(user))
		return
	if(!primary_target || QDELETED(primary_target) || primary_target.stat == DEAD)
		return

	var/damage = rand(strike_damage_min, strike_damage_max)

	// Strike the primary target in the HEAD
	var/armor_block = primary_target.run_armor_check(BODY_ZONE_HEAD, "stab", blade_dulling = BCLASS_STAB, damage = damage)
	primary_target.apply_damage(damage, BRUTE, BODY_ZONE_HEAD, armor_block)

	// Crit/wound roll on head
	var/effective_damage = damage * ((100 - armor_block) / 100)
	if(effective_damage > 0 && iscarbon(primary_target))
		var/mob/living/carbon/C = primary_target
		var/obj/item/bodypart/affecting = C.get_bodypart(check_zone(BODY_ZONE_HEAD))
		if(affecting)
			affecting.bodypart_attacked_by(BCLASS_STAB, effective_damage, user, BODY_ZONE_HEAD, crit_message = TRUE, weapon = weapon)

	// Attack animation — downward thrust
	user.do_attack_animation(primary_target, ATTACK_EFFECT_SLASH, weapon, item_animation_override = ATTACK_ANIMATION_THRUST)
	playsound(get_turf(primary_target), pick('sound/combat/hits/bladed/genthrust (1).ogg', 'sound/combat/hits/bladed/genthrust (2).ogg'), 100, TRUE)

	user.visible_message(
		span_danger("[user] plunges [weapon.name] down onto [primary_target] from above!"),
		span_notice("I strike [primary_target] from above!"))

	log_combat(user, primary_target, "arrival-struck", weapon, "(DMG: [damage]) (ZONE: head)")

	// --- Knockback everyone else on and adjacent to the landing tile ---
	for(var/mob/living/bystander in landing_turf)
		if(bystander == user || bystander == primary_target || bystander.stat == DEAD)
			continue
		var/atom/push_target = get_edge_target_turf(user, get_dir(user, get_step_away(bystander, user)))
		bystander.safe_throw_at(push_target, knockback_range, 1, user, force = MOVE_FORCE_EXTREMELY_STRONG)
		bystander.set_resting(TRUE, TRUE)
		to_chat(bystander, span_danger("The force of [user]'s landing sends you flying!"))
