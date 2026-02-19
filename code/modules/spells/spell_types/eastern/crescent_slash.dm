/*
 * Crescent Slash - Blade subclass arc attack with pull
 *
 * Always usable: at 0 stacks it's a weak arc with no pull.
 * At 3+ stacks: consumes 3 momentum for full arc + 2-tile pull + bonus damage.
 * Ensures the Blade always has SOMETHING to press even without momentum.
 *
 * References:
 *   Repulse (code/modules/spells/spell_types/wizard/invoked_aoe/repulse.dm) - AoE collection
 *   Fetch (code/modules/spells/spell_types/wizard/projectiles_single/fetch.dm) - pull mechanic
 *   Arcyne Momentum (code/modules/spells/spell_types/eastern/arcyne_momentum.dm) - stack system
 */

/obj/effect/proc_holder/spell/invoked/crescent_slash
	name = "Crescent Slash"
	desc = "Sweep your blade in an arcyne arc. At 3+ momentum: consumes 3 stacks for a powerful arc that pulls targets toward you."
	clothes_req = FALSE
	range = 3
	overlay_state = "blade_burst"
	releasedrain = 20
	chargedrain = 0
	chargetime = 3
	recharge_time = 6 SECONDS
	warnie = "spellwarning"
	no_early_release = TRUE
	movement_interrupt = FALSE
	charging_slowdown = 1
	chargedloop = /datum/looping_sound/invokegen
	invocations = list("Falx Azurea!")
	invocation_type = "shout"
	gesture_required = TRUE
	xp_gain = FALSE
	var/base_damage = 15
	var/empowered_damage = 30
	var/momentum_cost = 3
	var/pull_distance = 2

/obj/effect/proc_holder/spell/invoked/crescent_slash/cast(list/targets, mob/user = usr)
	var/mob/living/carbon/human/H = user
	if(!istype(H))
		revert_cast()
		return

	// Check if empowered (3+ momentum)
	var/empowered = FALSE
	var/datum/status_effect/buff/arcyne_momentum/M = H.has_status_effect(/datum/status_effect/buff/arcyne_momentum)
	if(M && M.stacks >= momentum_cost)
		M.consume_stacks(momentum_cost)
		empowered = TRUE
		to_chat(H, span_notice("[momentum_cost] momentum released — empowered crescent!"))

	var/damage = empowered ? empowered_damage : base_damage

	// Require a weapon in hand
	var/obj/item/held_weapon = H.get_active_held_item()
	if(!held_weapon)
		held_weapon = H.get_inactive_held_item()
	if(!held_weapon)
		to_chat(H, span_warning("I need a weapon in hand!"))
		revert_cast()
		return

	// Collect targets in a cone/arc in front of the caster (2-tile range, 3-wide)
	var/turf/center = get_turf(H)
	var/list/affected_turfs = list()
	var/facing = H.dir

	// Row 1: 3 tiles wide at 1 step away
	var/turf/front1 = get_step(center, facing)
	if(front1)
		affected_turfs += front1
		if(facing == NORTH || facing == SOUTH)
			var/turf/left1 = get_step(front1, WEST)
			var/turf/right1 = get_step(front1, EAST)
			if(left1) affected_turfs += left1
			if(right1) affected_turfs += right1
		else
			var/turf/left1 = get_step(front1, NORTH)
			var/turf/right1 = get_step(front1, SOUTH)
			if(left1) affected_turfs += left1
			if(right1) affected_turfs += right1

	// Row 2: 3 tiles wide at 2 steps away (empowered only)
	if(empowered)
		var/turf/front2 = get_step(front1, facing)
		if(front2)
			affected_turfs += front2
			if(facing == NORTH || facing == SOUTH)
				var/turf/left2 = get_step(front2, WEST)
				var/turf/right2 = get_step(front2, EAST)
				if(left2) affected_turfs += left2
				if(right2) affected_turfs += right2
			else
				var/turf/left2 = get_step(front2, NORTH)
				var/turf/right2 = get_step(front2, SOUTH)
				if(left2) affected_turfs += left2
				if(right2) affected_turfs += right2

	// Visual effect on affected tiles
	for(var/turf/T in affected_turfs)
		new /obj/effect/temp_visual/kinetic_blast(T)

	// Sound
	playsound(center, pick('sound/combat/wooshes/bladed/wooshsmall (1).ogg', 'sound/combat/wooshes/bladed/wooshsmall (2).ogg'), 80, TRUE)

	// Hit mobs in the arc
	var/hit_count = 0
	for(var/turf/T in affected_turfs)
		for(var/mob/living/victim in T)
			if(victim == H || victim.stat == DEAD)
				continue
			// Apply damage
			var/armor_block = victim.run_armor_check(BODY_ZONE_CHEST, "slash", blade_dulling = BCLASS_CUT, damage = damage)
			victim.apply_damage(damage, BRUTE, BODY_ZONE_CHEST, armor_block)
			hit_count++

			// Pull toward caster (empowered only)
			if(empowered)
				var/atom/pull_target = get_step(H, get_dir(H, victim))
				victim.throw_at(pull_target, pull_distance, 3, H)
				to_chat(victim, span_danger("[H] drags you toward them with arcyne force!"))

			// Attack animation
			H.do_attack_animation(victim, ATTACK_EFFECT_SLASH, held_weapon)
			playsound(get_turf(victim), pick('sound/combat/hits/bladed/largeslash (1).ogg', 'sound/combat/hits/bladed/largeslash (2).ogg'), 80, TRUE)
			log_combat(H, victim, "crescent-slashed", held_weapon, "(EMPOWERED: [empowered]) (DMG: [damage])")

	if(hit_count)
		H.visible_message(span_danger("[H] sweeps [held_weapon.name] in a wide arcyne arc!"))
	else
		H.visible_message(span_notice("[H] sweeps [held_weapon.name] through the air!"))

	return TRUE
