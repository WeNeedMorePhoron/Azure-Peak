/*
 * Azurean Phalanx - Phalanx subclass 3x1 line attack with pushback
 *
 * Short cooldown spacing tool. Hits everyone in a 3-tile line in front
 * of the caster and pushes them back 1 tile. No armor piercing — purely
 * for controlling space and keeping enemies at spear range.
 *
 * References:
 *   Repulse (code/modules/spells/spell_types/wizard/invoked_aoe/repulse.dm) - push via safe_throw_at
 *   Shukuchi (code/modules/spells/spell_types/eastern/shukuchi.dm) - line collection
 */

/obj/effect/proc_holder/spell/invoked/azurean_phalanx
	name = "Azurean Phalanx"
	desc = "Thrust forward with arcyne-infused reach, striking everything in a 3-tile line and pushing them back."
	clothes_req = FALSE
	range = 3
	overlay_state = "repulse"
	releasedrain = 20
	chargedrain = 0
	chargetime = 3
	recharge_time = 8 SECONDS
	warnie = "spellwarning"
	no_early_release = TRUE
	movement_interrupt = FALSE
	charging_slowdown = 1
	chargedloop = /datum/looping_sound/invokegen
	invocations = list("Phalanx Azurea!")
	invocation_type = "shout"
	gesture_required = TRUE
	xp_gain = FALSE
	var/line_length = 3
	var/damage = 15
	var/push_distance = 1

/obj/effect/proc_holder/spell/invoked/azurean_phalanx/cast(list/targets, mob/user = usr)
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

	var/turf/start = get_turf(H)
	var/facing = H.dir

	// Build 3-tile line in facing direction
	var/list/line_turfs = list()
	var/turf/current = start
	for(var/i in 1 to line_length)
		current = get_step(current, facing)
		if(!current || current.density)
			break
		line_turfs += current

	if(!length(line_turfs))
		to_chat(H, span_warning("There's no room to thrust!"))
		revert_cast()
		return

	// Visual effects along the line
	for(var/turf/T in line_turfs)
		new /obj/effect/temp_visual/kinetic_blast(T)

	playsound(start, pick('sound/combat/wooshes/bladed/wooshsmall (1).ogg', 'sound/combat/wooshes/bladed/wooshsmall (2).ogg'), 80, TRUE)

	// Hit and push mobs in the line
	var/hit_count = 0
	for(var/turf/T in line_turfs)
		for(var/mob/living/victim in T)
			if(victim == H || victim.stat == DEAD)
				continue

			// Apply damage (no AP — just stab damage)
			var/armor_block = victim.run_armor_check(BODY_ZONE_CHEST, "stab", blade_dulling = BCLASS_STAB, damage = damage)
			victim.apply_damage(damage, BRUTE, BODY_ZONE_CHEST, armor_block)
			hit_count++

			// Push back
			var/atom/push_target = get_edge_target_turf(H, get_dir(H, get_step_away(victim, H)))
			victim.safe_throw_at(push_target, push_distance, 1, H, force = MOVE_FORCE_STRONG)
			to_chat(victim, span_danger("[H] shoves you back with a powerful thrust!"))

			// Animation
			H.do_attack_animation(victim, ATTACK_EFFECT_SLASH, held_weapon, item_animation_override = ATTACK_ANIMATION_THRUST)
			playsound(get_turf(victim), pick('sound/combat/hits/bladed/genthrust (1).ogg', 'sound/combat/hits/bladed/genthrust (2).ogg'), 80, TRUE)
			log_combat(H, victim, "phalanx-thrust", held_weapon, "(DMG: [damage])")

	if(hit_count)
		H.visible_message(span_danger("[H] thrusts [held_weapon.name] forward in a powerful line!"))
	else
		H.visible_message(span_notice("[H] thrusts [held_weapon.name] forward!"))

	return TRUE
