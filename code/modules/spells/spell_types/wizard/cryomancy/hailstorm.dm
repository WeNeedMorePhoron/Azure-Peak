// Hail Storm - Cryomancy ultimate channeled AOE
// Caster stands still and lobs arcing frost bolts at a target area.
// Each wave fires 5 arcing projectiles at random turfs in a 7x7 zone.
// On impact each bolt deals 30 burn arcyne_strike (head) + frost stack in a 3x3 AOE.
// Caster must stand still (do_after) and maintain LOS between each wave.

/datum/action/cooldown/spell/hailstorm
	button_icon = 'icons/mob/actions/mage_cryomancy.dmi'
	name = "Hail Storm"
	desc = "Channel a devastating barrage of arcing frost bolts onto a distant area. \
	Each wave lobs 5 bolts that arc over obstacles and explode on impact, burning and freezing all caught within. \
	The caster must remain still and maintain line of sight — any interruption ends the barrage."
	button_icon_state = "hailstorm"
	sound = 'sound/spellbooks/crystal.ogg'
	spell_color = GLOW_COLOR_ICE
	glow_intensity = GLOW_INTENSITY_VERY_HIGH

	click_to_activate = TRUE
	cast_range = 14
	self_cast_possible = FALSE

	primary_resource_type = SPELL_COST_STAMINA
	primary_resource_cost = 50
	secondary_resource_type = SPELL_COST_ENERGY
	secondary_resource_cost = 200

	invocations = list("Tempestas Glacialis!")
	invocation_type = INVOCATION_SHOUT

	charge_required = TRUE
	charge_time = CHARGETIME_HEAVY
	charge_drain = 1
	charge_slowdown = CHARGING_SLOWDOWN_HEAVY
	charge_sound = 'sound/magic/charging.ogg'
	cooldown_time = 60 SECONDS

	associated_skill = /datum/skill/magic/arcane
	spell_tier = 4
	point_cost = 6
	spell_impact_intensity = SPELL_IMPACT_HIGH

	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC | SPELL_REQUIRES_HUMAN

	var/bombardments = 10
	var/bolts_per_wave = 5
	var/bolt_damage = 30
	var/storm_radius = 3 // 7x7 area (range 3 from center)
	var/wave_delay = 1.5 SECONDS

/// Charge cost upfront so the player pays before channeling, not after
/datum/action/cooldown/spell/hailstorm/before_cast(atom/cast_on)
	. = ..()
	. |= SPELL_NO_IMMEDIATE_COST
	invoke_cost()

/datum/action/cooldown/spell/hailstorm/cast(atom/cast_on)
	. = ..()
	var/mob/living/carbon/human/H = owner
	if(!istype(H))
		return FALSE

	// Cryomancy countersynergy: reduce fire stacks on caster
	if(H.fire_stacks > 0)
		H.adjust_fire_stacks(-1)
		to_chat(H, span_notice("The frost becalms the flame on me."))

	var/turf/centerpoint = get_turf(cast_on)
	if(!centerpoint)
		return FALSE

	var/turf/source_turf = get_turf(H)
	if(centerpoint.z > H.z)
		source_turf = get_step_multiz(source_turf, UP)
	if(centerpoint.z < H.z)
		source_turf = get_step_multiz(source_turf, DOWN)

	if(!(centerpoint in get_hear(cast_range, source_turf)))
		to_chat(H, span_warning("I can't cast where I can't see!"))
		return FALSE

	// Gather valid turfs in the storm area
	var/list/storm_turfs = list()
	for(var/turf/T in range(storm_radius, centerpoint))
		if(T.density)
			continue
		storm_turfs += T

	if(!length(storm_turfs))
		return FALSE

	H.visible_message(span_danger("[H] begins lobbing a barrage of frost bolts!"))

	// Channel bombardments — caster must stand still between each wave
	for(var/wave in 1 to bombardments)
		if(QDELETED(H) || QDELETED(src) || H.stat != CONSCIOUS)
			break

		// LOS check each wave
		if(!(centerpoint in get_hear(cast_range, get_turf(H))))
			to_chat(H, span_warning("I can no longer see the target area!"))
			break

		hail_wave(H, storm_turfs)
		if(wave < bombardments)
			if(!do_after(H, wave_delay, needhand = FALSE))
				to_chat(H, span_warning("My concentration breaks!"))
				break

	return TRUE

/datum/action/cooldown/spell/hailstorm/proc/hail_wave(mob/living/carbon/human/caster, list/storm_turfs)
	playsound(caster, 'sound/spellbooks/icicle.ogg', 60, TRUE, 6)

	for(var/bolt in 1 to bolts_per_wave)
		var/turf/impact = pick(storm_turfs)
		// Fire an arcing frost bolt from the caster toward the target turf
		var/obj/projectile/magic/hailstorm_bolt/P = new(get_turf(caster))
		P.firer = caster
		P.fired_from = get_turf(caster)
		P.bolt_damage = bolt_damage
		P.hailstorm_source = src
		P.preparePixelProjectile(impact, caster)
		P.fire()

/// Arcing frost bolt projectile for hailstorm — AOE on impact
/obj/projectile/magic/hailstorm_bolt
	name = "hailstorm bolt"
	icon_state = "ice_2"
	arcshot = TRUE
	damage = 0 // Damage handled in on_hit AOE
	nodamage = TRUE // Don't do base projectile damage
	damage_type = BURN
	flag = "magic"
	range = 20
	speed = 1.5
	/// Actual damage dealt by the AOE on impact
	var/bolt_damage = 50
	/// Reference to the spell for guard checks
	var/datum/action/cooldown/spell/hailstorm/hailstorm_source

/obj/projectile/magic/hailstorm_bolt/on_hit(target)
	. = ..()
	var/turf/impact = get_turf(target)
	if(!impact)
		qdel(src)
		return

	playsound(impact, pick('sound/combat/fracture/fracturedry (1).ogg', 'sound/combat/fracture/fracturedry (2).ogg', 'sound/combat/fracture/fracturedry (3).ogg'), 60, TRUE)

	for(var/turf/aoe_turf in range(1, impact))
		new /obj/effect/temp_visual/snap_freeze(aoe_turf)
		for(var/mob/living/L in aoe_turf.contents)
			if(L == firer || L.stat == DEAD)
				continue
			if(L.anti_magic_check())
				L.visible_message(span_warning("The ice fades away around [L]!"))
				continue
			if(hailstorm_source?.spell_guard_check(L, TRUE))
				L.visible_message(span_warning("[L] endures the hail!"))
				continue
			if(ishuman(firer) && ishuman(L))
				var/mob/living/carbon/human/H = firer
				arcyne_strike(firer, L, null, bolt_damage, H.zone_selected || BODY_ZONE_CHEST, \
					BCLASS_BURN, spell_name = "Hail Storm", \
					damage_type = BURN, npc_simple_damage_mult = 1, \
					skip_animation = TRUE)
			else
				L.adjustFireLoss(bolt_damage)
			apply_frost_stack(L)
			new /obj/effect/temp_visual/spell_impact(get_turf(L), GLOW_COLOR_ICE, SPELL_IMPACT_HIGH)
	qdel(src)
