/*
 * Excalibur - Blade subclass beam attack (placeholder name)
 *
 * Devastating arcyne beam projectile that pierces through structures
 * and up to 3 living targets. Damage scales with momentum consumed:
 *   0-5 stacks:  80 damage
 *   6-9 stacks:  120 damage
 *   10+ stacks:  160 damage
 * Negative AP (-30) — armor is MORE effective against this beam.
 * Overrides Bump() to pierce structures and track living hit count.
 *
 * References:
 *   Projectile piercing (code/modules/projectiles/projectile.dm) - Bump, permutated, UNSTOPPABLE
 *   Arcyne Momentum (code/modules/spells/spell_types/eastern/arcyne_momentum.dm) - stack system
 */

/obj/effect/proc_holder/spell/invoked/projectile/excalibur
	name = "Excalibur"
	desc = "Release a devastating arcyne beam. Pierces through structures and up to 3 targets. Power scales with momentum."
	clothes_req = FALSE
	range = 14
	projectile_type = /obj/projectile/energy/excalibur_beam
	sound = list('sound/magic/whiteflame.ogg')
	active = FALSE
	overlay_state = "blade_burst"
	releasedrain = 50
	chargedrain = 1
	chargetime = 30
	recharge_time = 45 SECONDS
	warnie = "spellwarning"
	no_early_release = TRUE
	movement_interrupt = FALSE
	charging_slowdown = 3
	chargedloop = /datum/looping_sound/invokegen
	invocations = list("EXCALIBUR!")
	invocation_type = "shout"
	gesture_required = TRUE
	xp_gain = FALSE

/// Momentum-scaled damage: swap projectile type based on stacks consumed
/obj/effect/proc_holder/spell/invoked/projectile/excalibur/cast(list/targets, mob/user = usr)
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

	// Check and consume momentum
	var/stacks = 0
	var/datum/status_effect/buff/arcyne_momentum/M = H.has_status_effect(/datum/status_effect/buff/arcyne_momentum)
	if(M && M.stacks > 0)
		stacks = M.stacks
		M.consume_all_stacks()

	if(stacks >= 10)
		projectile_type = /obj/projectile/energy/excalibur_beam/maximum
		to_chat(H, span_notice("All [stacks] momentum released — maximum power!"))
	else if(stacks >= 6)
		projectile_type = /obj/projectile/energy/excalibur_beam/empowered
		to_chat(H, span_notice("[stacks] momentum released — empowered!"))
	else
		projectile_type = /obj/projectile/energy/excalibur_beam
		if(stacks > 0)
			to_chat(H, span_notice("[stacks] momentum released."))
	. = ..()

// ─── Beam projectile: pierces structures, stops after 3 living mob hits ───

/obj/projectile/energy/excalibur_beam
	name = "Excalibur Beam"
	icon_state = "air_blade"
	damage = 80
	flag = "slash"
	woundclass = BCLASS_CUT
	nodamage = FALSE
	speed = 0.4
	range = 14
	armor_penetration = -30
	hitsound = 'sound/combat/hits/bladed/largeslash (1).ogg'
	var/living_hits = 0
	var/max_living_hits = 3

/// Empowered tier (6-9 momentum stacks)
/obj/projectile/energy/excalibur_beam/empowered
	damage = 120

/// Maximum tier (10+ momentum stacks)
/obj/projectile/energy/excalibur_beam/maximum
	damage = 160

/// Override Bump to pierce through structures and control living hit count
/obj/projectile/energy/excalibur_beam/Bump(atom/A)
	if(QDELETED(src))
		return
	var/turf/T = get_turf(A)
	if(!T)
		return

	if(isliving(A))
		var/mob/living/L = A
		// Skip dead mobs and mobs we already hit
		if(L.stat == DEAD || (L in permutated))
			temporary_unstoppable_movement = TRUE
			ENABLE_BITFIELD(movement_type, UNSTOPPABLE)
			return

		// Hit this living mob — bullet_act handles armor, damage, wounds
		permutated |= L
		L.bullet_act(src, def_zone)
		living_hits++

		if(firer)
			log_combat(firer, L, "excalibur-beamed", src, "(DMG: [damage]) (HITS: [living_hits]/[max_living_hits])")

		// Stop after max hits
		if(living_hits >= max_living_hits)
			qdel(src)
			return

		// Keep going through to next target
		temporary_unstoppable_movement = TRUE
		ENABLE_BITFIELD(movement_type, UNSTOPPABLE)
		return

	// Non-living atoms (structures, objects, turfs): pass through everything
	temporary_unstoppable_movement = TRUE
	ENABLE_BITFIELD(movement_type, UNSTOPPABLE)

/// Beam-specific hit feedback
/obj/projectile/energy/excalibur_beam/on_hit(atom/target, blocked = FALSE)
	. = ..()
	if(isliving(target))
		to_chat(target, span_userdanger("A searing beam of arcyne light cuts through!"))
