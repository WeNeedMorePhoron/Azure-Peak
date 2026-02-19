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
	overlay_state = "shadowstep"
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

	// Admin log the dash
	log_combat(H, target, "used Shukuchi on", addition="(DIST: [distance], MOBS_HIT: [length(mobs_in_path)])")

	// Consume all arcyne momentum stacks (Issen releases tension)
	var/datum/status_effect/buff/arcyne_momentum/momentum = H.has_status_effect(/datum/status_effect/buff/arcyne_momentum)
	if(momentum && momentum.stacks > 0)
		var/consumed = momentum.consume_all_stacks()
		to_chat(H, span_notice("[consumed] momentum released!"))

	// --- Strike every mob that was in the path (delayed 0.5s for drama) ---

	// Capture body zone NOW — it may change by the time the delayed strike fires
	var/locked_zone = H.zone_selected || BODY_ZONE_CHEST

	if(length(mobs_in_path))
		addtimer(CALLBACK(src, PROC_REF(execute_path_strikes), H, mobs_in_path, held_weapon, locked_zone), 5) // 5 deciseconds = 0.5s

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

/// Delayed strike callback — fires 0.5s after the dash so shadows appear first.
/obj/effect/proc_holder/spell/invoked/shukuchi/proc/execute_path_strikes(mob/living/carbon/human/user, list/victims, obj/item/weapon, def_zone)
	if(!user || QDELETED(user))
		return
	for(var/mob/living/victim in victims)
		if(QDELETED(victim) || victim.stat == DEAD)
			continue
		execute_strike(user, victim, weapon, rand(strike_damage_min, strike_damage_max), def_zone)

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

/// Delivers a weapon-aware strike with armor interaction, crit/wound rolls, attack animation, and admin logging.
/// Mirrors the species.dm attack flow (armor check -> apply_damage -> bodypart_attacked_by)
/// without going through the click pipeline.
/obj/effect/proc_holder/spell/invoked/shukuchi/proc/execute_strike(mob/living/carbon/human/user, mob/living/target, obj/item/weapon, damage, def_zone, blade_class_override)
	// Determine damage type from weapon intent unless overridden
	var/blade_class = BCLASS_CUT
	var/attack_flag = "slash"
	if(blade_class_override)
		blade_class = blade_class_override
	else
		var/datum/intent/current_intent = user.a_intent
		if(current_intent)
			blade_class = current_intent.blade_class

	// Map blade class to armor flag and normalized class for armor/sounds
	switch(blade_class)
		if(BCLASS_BLUNT, BCLASS_SMASH)
			blade_class = BCLASS_BLUNT
			attack_flag = "blunt"
		if(BCLASS_STAB, BCLASS_PICK)
			blade_class = BCLASS_STAB
			attack_flag = "stab"
		else
			blade_class = BCLASS_CUT
			attack_flag = "slash"

	// Body zone: explicit, or user's aim, or chest
	if(!def_zone)
		def_zone = user.zone_selected || BODY_ZONE_CHEST

	// Attack animation (visual weapon swing on the target)
	var/visual_effect = ATTACK_EFFECT_SLASH
	var/anim_type = ATTACK_ANIMATION_SWIPE
	switch(blade_class)
		if(BCLASS_BLUNT)
			visual_effect = ATTACK_EFFECT_SMASH
			anim_type = ATTACK_ANIMATION_BONK
		if(BCLASS_STAB)
			anim_type = ATTACK_ANIMATION_THRUST
	user.do_attack_animation(target, visual_effect, weapon, item_animation_override = anim_type)

	// Armor check and damage application
	var/armor_block = target.run_armor_check(def_zone, attack_flag, blade_dulling = blade_class, damage = damage)
	target.apply_damage(damage, BRUTE, def_zone, armor_block)

	// Crit/wound roll on bodypart (mirrors species.dm line 1839)
	var/effective_damage = damage * ((100 - armor_block) / 100)
	if(effective_damage > 0)
		if(iscarbon(target))
			var/mob/living/carbon/C = target
			var/obj/item/bodypart/affecting = C.get_bodypart(check_zone(def_zone))
			if(affecting)
				affecting.bodypart_attacked_by(blade_class, effective_damage, user, def_zone, crit_message = TRUE, weapon = weapon)
		else
			target.simple_woundcritroll(blade_class, effective_damage, user, def_zone, crit_message = TRUE)

	// Hit sound and message
	var/attack_verb = "strikes"
	var/hit_sound
	switch(blade_class)
		if(BCLASS_CUT)
			attack_verb = "slashes"
			hit_sound = pick('sound/combat/hits/bladed/largeslash (1).ogg', 'sound/combat/hits/bladed/largeslash (2).ogg', 'sound/combat/hits/bladed/largeslash (3).ogg')
		if(BCLASS_BLUNT)
			attack_verb = "smashes"
			hit_sound = pick('sound/combat/hits/blunt/genblunt (1).ogg', 'sound/combat/hits/blunt/genblunt (2).ogg', 'sound/combat/hits/blunt/genblunt (3).ogg')
		if(BCLASS_STAB)
			attack_verb = "stabs"
			hit_sound = pick('sound/combat/hits/bladed/genthrust (1).ogg', 'sound/combat/hits/bladed/genthrust (2).ogg')

	playsound(get_turf(target), hit_sound, 100, TRUE)
	user.visible_message(
		span_danger("[user] [attack_verb] [target] with [weapon.name]!"),
		span_notice("I [attack_verb] [target] with my [weapon.name]!"))

	// Admin logging
	log_combat(user, target, "spell-struck", weapon, "(SPELL: Shukuchi) (BCLASS: [attack_flag]) (DMG: [damage]) (ZONE: [def_zone])")
