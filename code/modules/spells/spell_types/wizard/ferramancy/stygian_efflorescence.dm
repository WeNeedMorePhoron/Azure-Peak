#define MT_STYGIAN "stygian"
#define STYGIAN_DR_DURATION 1 SECONDS

/datum/action/cooldown/spell/projectile/stygian_efflorescence
	button_icon = 'icons/mob/actions/mage_ferramancy.dmi'
	name = "Stygian Efflorescence"
	desc = "Burst forth a volley of five sharpened obsidian shards in a wide spread. Additional shards striking the same target deal reduced damage. Projectile\ effectiveness decreases after 4 tiles."
	fluff_desc = "Before the first men learned to refine metal, men fought with sharpened stones - particularly obsidian from the foot of volcanos. \
	It is said that Mount Golgotha had the best obsidian in all the world, sharp enough to cut flesh with ease. \
	Malice, energy, and the imagination of the Magi cutting someone apart with Obsidian. \
	Thus was born the first spell that would lead to Ferramancy, when men could imagine themselves smelting metal and forging tools - and after it, using magyck to replicate the very same thing."
	button_icon_state = "stygian"
	sound = 'sound/magic/scrapeblade.ogg'
	spell_color = GLOW_COLOR_METAL
	glow_intensity = GLOW_INTENSITY_LOW

	projectile_type = /obj/projectile/energy/stygian
	cast_range = SPELL_RANGE_PROJECTILE
	projectiles_per_fire = 3
	point_cost = 3

	primary_resource_type = SPELL_COST_STAMINA
	primary_resource_cost = SPELLCOST_MAJOR_PROJECTILE // It is a big ass shotgun now

	invocations = list("Golgothae Acies!")
	invocation_type = INVOCATION_SHOUT

	charge_required = TRUE
	weapon_cast_penalized = TRUE // Use it with an arcyne armament noob 
	charge_time = CHARGETIME_MINOR
	charge_drain = 1
	charge_slowdown = CHARGING_SLOWDOWN_NONE
	charge_sound = 'sound/magic/charging.ogg'
	cooldown_time = 20 SECONDS // Not meant to be the thing you relies on for damage or a staple poke spell, it is something to be mixed in in melee
	attunement_school = ASPECT_NAME_FERRAMANCY

	associated_skill = /datum/skill/magic/arcane
	spell_tier = 2
	spell_impact_intensity = SPELL_IMPACT_MEDIUM

	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC | SPELL_REQUIRES_HUMAN

	var/spread_step = 18

/datum/action/cooldown/spell/projectile/stygian_efflorescence/ready_projectile(obj/projectile/to_fire, atom/target, mob/user, iteration)
	. = ..()
	var/base_angle = to_fire.Angle
	if(isnull(base_angle))
		base_angle = Get_Angle(user, target)
	var/center_index = (projectiles_per_fire + 1) / 2
	to_fire.Angle = base_angle + ((iteration - center_index) * spread_step)
	// It used to be only center shard crits, but now that it is on much higher cooldown :) everything can crit

// --- Stygian projectile ---

/obj/projectile/energy/stygian
	name = "stygian harpe"
	guard_deflectable = TRUE
	range = 5
	icon = 'icons/obj/magic_projectiles.dmi'
	icon_state = "stygian"
	max_range = 4 // Effective range is lower than its maximal range
	damage = 34
	damage_type = BRUTE
	woundclass = BCLASS_STAB
	armor_penetration = PEN_LIGHT
	npc_simple_damage_mult = 1.5
	speed = MAGE_PROJ_SLOW
	flag = "stab"
	hitsound = 'sound/combat/hits/bladed/genstab (1).ogg'
	var/reduced_damage = 18

/obj/projectile/energy/stygian/prehit(atom/target)
	if(ismob(target))
		var/mob/living/M = target
		if(M.mob_timers[MT_STYGIAN] && world.time < M.mob_timers[MT_STYGIAN] + STYGIAN_DR_DURATION)
			damage = reduced_damage
		else
			M.mob_timers[MT_STYGIAN] = world.time
	return ..()

/obj/projectile/energy/stygian/on_hit(target)
	if(ismob(target))
		var/mob/living/M = target
		if(M.anti_magic_check())
			visible_message(span_warning("[src] shatters harmlessly against [target]!"))
			playsound(get_turf(target), 'sound/magic/magic_nulled.ogg', 100)
			qdel(src)
			return BULLET_ACT_BLOCK
	. = ..()

#undef MT_STYGIAN
#undef STYGIAN_DR_DURATION
