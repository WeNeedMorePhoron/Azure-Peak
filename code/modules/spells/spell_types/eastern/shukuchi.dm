/*
 * Shukuchi - Eastern Warrior Shadow Step Strike
 *
 * A martial technique that dashes the user forward at incredible speed,
 * leaving afterimages in their wake and delivering an instant weapon strike.
 *
 * References:
 *   Blink (code/modules/spells/spell_types/wizard/misc/blink.dm) - teleportation & validation
 *   after_image (code/datums/components/after_image.dm) - afterimage visual objects
 *   Air Blade (code/modules/spells/spell_types/wizard/projectiles_single/air_blade.dm) - weapon intent mapping
 *   Fae Wrath (code/modules/vampire_neu/covens/coven_powers/fae_trickery.dm) - standalone afterimage trail
 */

/obj/effect/proc_holder/spell/invoked/shukuchi
	name = "Shukuchi"
	desc = "Focus your ki and dash forward at blinding speed, leaving afterimages in your wake. \
		Cuts through every enemy in your path. \
		Damage type is determined by your weapon's current intent."
	clothes_req = FALSE
	range = 7
	overlay_state = "rune6"
	releasedrain = 25
	chargedrain = 1
	chargetime = 1
	recharge_time = 2 SECONDS
	warnie = "spellwarning"
	no_early_release = TRUE
	movement_interrupt = FALSE
	gesture_required = TRUE
	charging_slowdown = 2
	chargedloop = /datum/looping_sound/invokegen
	invocations = list("ISSEN!")
	invocation_type = "shout"
	xp_gain = FALSE
	var/max_range = 7
	var/strike_damage_min = 40
	var/strike_damage_max = 60

/obj/effect/proc_holder/spell/invoked/shukuchi/cast(list/targets, mob/user = usr)
	var/mob/living/carbon/human/H = user
	if(!istype(H))
		revert_cast()
		return

	// Require a weapon in hand
	var/obj/item/held_weapon = H.get_active_held_item()
	if(!held_weapon)
		held_weapon = H.get_inactive_held_item()
	if(!held_weapon)
		to_chat(H, span_warning("I need a weapon in hand to perform this technique!"))
		revert_cast()
		return

	var/atom/target = targets[1]
	var/turf/start = get_turf(H)
	var/turf/dest

	// Resolve destination turf
	if(isliving(target))
		dest = find_landing_turf(H, target)
	else
		dest = get_turf(target)

	if(!dest)
		to_chat(H, span_warning("Invalid target!"))
		revert_cast()
		return

	// --- Destination validation (adapted from Blink) ---

	if(dest.z != start.z)
		to_chat(H, span_warning("I can only dash on the same plane!"))
		revert_cast()
		return

	if(dest.teleport_restricted)
		to_chat(H, span_warning("Something prevents me from dashing here!"))
		revert_cast()
		return

	if(istransparentturf(dest))
		to_chat(H, span_warning("I cannot dash into the open air!"))
		revert_cast()
		return

	if(dest.density)
		to_chat(H, span_warning("I cannot dash into a wall!"))
		revert_cast()
		return

	var/distance = get_dist(start, dest)
	if(distance > max_range)
		to_chat(H, span_warning("Too far! Maximum range is [max_range] tiles."))
		revert_cast()
		return

	if(distance < 1)
		to_chat(H, span_warning("I need somewhere to dash to!"))
		revert_cast()
		return

	// --- Path obstruction check (adapted from Blink) ---

	var/list/turf_list = getline(start, dest)
	if(length(turf_list) > 0)
		turf_list.len-- // Exclude destination (already validated above)

	for(var/turf/check_turf in turf_list)
		if(check_turf == start)
			continue
		if(check_turf.density)
			to_chat(H, span_warning("I cannot dash through walls!"))
			revert_cast()
			return
		for(var/obj/structure/mineral_door/door in check_turf.contents)
			if(door.density)
				to_chat(H, span_warning("I cannot dash through doors!"))
				revert_cast()
				return
		for(var/obj/structure/roguewindow/window in check_turf.contents)
			if(window.density && !window.climbable)
				to_chat(H, span_warning("I cannot dash through windows!"))
				revert_cast()
				return
		for(var/obj/structure/bars/B in check_turf.contents)
			if(B.density)
				to_chat(H, span_warning("I cannot dash through bars!"))
				revert_cast()
				return
		for(var/obj/structure/gate/G in check_turf.contents)
			if(G.density)
				to_chat(H, span_warning("I cannot dash through gates!"))
				revert_cast()
				return

	// --- Execute the dash ---

	var/list/full_path = getline(start, dest)

	// Collect every living mob along the path (excluding self)
	var/list/mobs_in_path = list()
	for(var/turf/path_turf in full_path)
		if(path_turf == start)
			continue
		for(var/mob/living/M in path_turf)
			if(M != H && M.stat != DEAD)
				mobs_in_path += M

	// Afterimage trail (async so it doesn't block the teleport)
	INVOKE_ASYNC(src, PROC_REF(create_afterimage_trail), H, full_path)

	playsound(start, 'sound/magic/blink.ogg', 40, TRUE)
	H.visible_message(
		span_warning("[H] vanishes in a blur of motion!"),
		span_notice("I focus my ki and dash!"))

	if(H.buckled)
		H.buckled.unbuckle_mob(H, TRUE)
	do_teleport(H, dest, channel = TELEPORT_CHANNEL_MAGIC)
	playsound(dest, 'sound/magic/blink.ogg', 25, TRUE)

	// --- Strike every mob that was in the path ---

	for(var/mob/living/victim in mobs_in_path)
		if(victim.stat != DEAD)
			execute_strike(H, victim, held_weapon)

	return TRUE

/// Finds a valid adjacent turf to land on when targeting a mob.
/// Tries to land on the far side (dash past the target), falls back to their turf.
/obj/effect/proc_holder/spell/invoked/shukuchi/proc/find_landing_turf(mob/living/user, mob/living/target_mob)
	var/approach_dir = get_dir(user, target_mob)
	var/turf/far_side = get_step(target_mob, approach_dir)
	if(far_side && !far_side.density && !istransparentturf(far_side) && isfloorturf(far_side))
		return far_side
	// Fallback to the mob's own turf
	return get_turf(target_mob)

/// Spawns paired afterimages offset to the left and right edges of the path, like shadow flanks.
/// Uses /obj/effect/after_image with zero pixel offsets (no wobble). Pattern from Fae Wrath.
/obj/effect/proc_holder/spell/invoked/shukuchi/proc/create_afterimage_trail(mob/living/carbon/human/user, list/path_turfs)
	set waitfor = FALSE
	var/list/images = list()
	var/path_len = length(path_turfs)
	if(path_len < 2)
		return
	var/travel_dir = get_dir(path_turfs[1], path_turfs[path_len])

	// Parallel pixel offsets along the travel direction (front image, back image)
	var/front_px = 0
	var/front_py = 0
	var/back_px = 0
	var/back_py = 0
	switch(travel_dir)
		if(NORTH)
			front_py = 10
			back_py = -10
		if(SOUTH)
			front_py = -10
			back_py = 10
		if(EAST)
			front_px = 10
			back_px = -10
		if(WEST)
			front_px = -10
			back_px = 10
		if(NORTHEAST)
			front_px = 8
			front_py = 8
			back_px = -8
			back_py = -8
		if(NORTHWEST)
			front_px = -8
			front_py = 8
			back_px = 8
			back_py = -8
		if(SOUTHEAST)
			front_px = 8
			front_py = -8
			back_px = -8
			back_py = 8
		if(SOUTHWEST)
			front_px = -8
			front_py = -8
			back_px = 8
			back_py = 8

	// Spawn two afterimages per tile - one on each side of the path
	for(var/i in 1 to path_len)
		var/turf/T = path_turfs[i]
		var/base_alpha = round(40 + 80 * (i - 1) / max(path_len - 1, 1)) // 40 -> 120, semi-transparent shadow
		for(var/side in 1 to 2)
			var/obj/effect/after_image/img = new(T, 0, 0, 0, 0, 0.5 SECONDS, 3 SECONDS, 0)
			images += img
			img.name = user.name
			img.appearance = user.appearance
			img.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
			img.dir = travel_dir
			img.alpha = base_alpha
			if(side == 1)
				img.pixel_x = front_px
				img.pixel_y = front_py
			else
				img.pixel_x = back_px
				img.pixel_y = back_py
	QDEL_LIST_IN(images, 2 SECONDS)

/// Delivers a weapon-aware strike with armor interaction and crit rolls.
/// Applies damage via apply_damage, then calls bodypart_attacked_by for wound/crit chance.
/// Mirrors the species.dm attack flow (lines 1819-1839) without going through the click pipeline.
/obj/effect/proc_holder/spell/invoked/shukuchi/proc/execute_strike(mob/living/carbon/human/user, mob/living/target, obj/item/weapon)
	// Determine damage type from current weapon intent (adapted from Air Blade)
	var/blade_class = BCLASS_CUT
	var/attack_flag = "slash"
	var/datum/intent/current_intent = user.a_intent
	if(current_intent)
		switch(current_intent.blade_class)
			if(BCLASS_BLUNT, BCLASS_SMASH)
				blade_class = BCLASS_BLUNT
				attack_flag = "blunt"
			if(BCLASS_STAB, BCLASS_PICK)
				blade_class = BCLASS_STAB
				attack_flag = "stab"

	// Body zone: user's aim or chest
	var/def_zone = user.zone_selected || BODY_ZONE_CHEST

	// Damage and armor
	var/damage = rand(strike_damage_min, strike_damage_max)
	var/armor_block = target.run_armor_check(def_zone, attack_flag, blade_dulling = blade_class, damage = damage)
	target.apply_damage(damage, BRUTE, def_zone, armor_block)

	// Crit/wound roll on the bodypart (mirrors species.dm line 1839)
	var/effective_damage = damage * ((100 - armor_block) / 100)
	if(effective_damage > 0 && iscarbon(target))
		var/mob/living/carbon/C = target
		var/obj/item/bodypart/affecting = C.get_bodypart(check_zone(def_zone))
		if(affecting)
			affecting.bodypart_attacked_by(blade_class, effective_damage, user, def_zone, crit_message = TRUE, weapon = weapon)
	else if(effective_damage > 0 && !iscarbon(target))
		// Simple mobs without bodyparts
		target.simple_woundcritroll(blade_class, effective_damage, user, def_zone, crit_message = TRUE)

	// Feedback
	var/attack_verb = "strikes"
	var/hit_sound = 'sound/combat/hits/bladed/smallslash (1).ogg'
	switch(blade_class)
		if(BCLASS_CUT)
			attack_verb = "slashes"
			hit_sound = 'sound/combat/hits/bladed/smallslash (1).ogg'
		if(BCLASS_BLUNT)
			attack_verb = "smashes"
			hit_sound = 'sound/combat/hits/blunt/shovel_hit2.ogg'
		if(BCLASS_STAB)
			attack_verb = "stabs"
			hit_sound = 'sound/combat/hits/bladed/genstab (3).ogg'

	playsound(get_turf(target), hit_sound, 100, TRUE)
	user.visible_message(
		span_danger("[user] [attack_verb] [target] with [weapon]!"),
		span_notice("I [attack_verb] [target] with my [weapon]!"))
