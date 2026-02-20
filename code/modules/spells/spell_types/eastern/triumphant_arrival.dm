/*
 * Triumphant Arrival - Phalangite subclass leap attack
 *
 * Leap to a target with a visible jump-up animation, then plunge down onto
 * them striking the HEAD zone. Knocks back everyone on the tile EXCEPT the
 * primary target (isolation pick). Supports cross-Z-level travel on connected
 * planes (2 second channel) vs same-Z (1 second channel).
 *
 * References:
 *   Blink (code/modules/spells/spell_types/wizard/misc/blink.dm) - teleport validation
 *   Shukuchi (code/modules/spells/spell_types/eastern/shukuchi.dm) - afterimage + execute_strike
 *   Repulse (code/modules/spells/spell_types/wizard/invoked_aoe/repulse.dm) - selective knockback
 *   is_in_zweb (code/modules/mapping/space_management/multiz_helpers.dm) - Z-level connectivity
 *   jump.dm (code/game/objects/items/rogueweapons/mmb/jump.dm) - pixel_z animation pattern
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
	invocations = list("DESCENDO!")
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

	// --- Validation ---

	var/cross_z = (dest.z != start.z)

	if(cross_z && !is_in_zweb(start.z, dest.z))
		to_chat(H, span_warning("I can only leap to connected planes!"))
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
	if(!cross_z) // Same Z-level: enforce range and minimum distance
		if(distance > range)
			to_chat(H, span_warning("Too far! Maximum range is [range] tiles."))
			revert_cast()
			return
		if(distance < 2)
			to_chat(H, span_warning("I need more distance to leap!"))
			revert_cast()
			return

	// --- Telegraph: warning at target + interruptible channel ---

	// Channel duration: 2 seconds for cross-Z leap, 1 second for same-Z
	var/channel_time = cross_z ? 2 SECONDS : 1 SECONDS

	// Show ! warning at the target location
	var/obj/effect/warning_marker = new(dest)
	warning_marker.icon = 'icons/effects/effects.dmi'
	warning_marker.icon_state = "spellwarning"
	warning_marker.pixel_y = 16

	// ADVENTUS shout at channel start — announces the leap is coming
	H.say("ADVENTUS!")
	H.visible_message(
		span_warning("[H] crouches and focuses, preparing to leap!"),
		span_notice("I focus my strength..."))
	playsound(start, 'sound/magic/charged.ogg', 30, TRUE)

	// Interruptible channel on the ground — enemies can still hit/stun to interrupt
	if(!do_after(H, channel_time, target = H))
		to_chat(H, span_warning("My concentration breaks!"))
		qdel(warning_marker)
		revert_cast()
		return

	qdel(warning_marker)

	// --- Channel succeeded — now committed, go airborne ---

	var/prev_pixel_z = H.pixel_z
	var/rise_height = cross_z ? 144 : 96

	// Unbuckle if needed
	if(H.buckled)
		H.buckled.unbuckle_mob(H, TRUE)

	// Leave an afterimage that rises at the start position
	var/obj/effect/after_image/fade = new(start, 0, 0, 0, 0, 0.5 SECONDS, 2 SECONDS, 0)
	fade.appearance = H.appearance
	fade.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	fade.alpha = 120
	animate(fade, pixel_z = rise_height, alpha = 0, time = 4, easing = SINE_EASING)
	QDEL_IN(fade, 2 SECONDS)

	// Hide the actual mob — they're in the air now
	H.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	H.alpha = 0
	playsound(start, 'sound/magic/blink.ogg', 40, TRUE)
	H.visible_message(
		span_warning("[H] launches skyward and vanishes!"),
		span_notice("I soar!"))

	// Leyline rift at origin — the gap they ascend through
	new /obj/effect/temp_visual/lycan(start)
	playsound(start, 'sound/misc/portalactivate.ogg', 80, TRUE)

	// Leyline rift at destination — offset to where the drop animation begins
	var/obj/effect/temp_visual/lycan/dest_rift = new(dest)
	dest_rift.pixel_z = rise_height
	playsound(dest, 'sound/misc/portalactivate.ogg', 80, TRUE)

	// Teleport to destination — arrive high up, still invisible
	H.pixel_z = prev_pixel_z + rise_height
	do_teleport(H, dest, channel = TELEPORT_CHANNEL_MAGIC)

	// Restore visibility and slam down through the rift
	H.mouse_opacity = initial(H.mouse_opacity)
	H.alpha = 255
	animate(H, pixel_z = prev_pixel_z, time = 5, easing = BOUNCE_EASING) // fast slam down from height

	log_combat(H, target, "used Triumphant Arrival on", addition="(DIST: [distance], CROSS_Z: [cross_z])")

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

	// Landing impact sound
	playsound(landing_turf, pick('sound/combat/ground_smash1.ogg', 'sound/combat/ground_smash2.ogg', 'sound/combat/ground_smash3.ogg'), 100, TRUE)

	// --- 1-tile repulse on landing — push everyone surrounding away, no throw ---
	for(var/turf/T in get_hear(1, user))
		new /obj/effect/temp_visual/kinetic_blast(T)
		for(var/mob/living/bystander in T)
			if(bystander == user || bystander.stat == DEAD)
				continue
			var/push_dir = get_dir(user, bystander)
			if(!push_dir)
				push_dir = pick(GLOB.cardinals)
			step(bystander, push_dir)
			to_chat(bystander, span_danger("The shockwave of [user]'s landing pushes you back!"))
