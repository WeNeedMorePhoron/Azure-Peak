#define MT_ROCKSHOT "rockshot"
#define ROCKSHOT_DR_DURATION 1 SECONDS

/datum/action/cooldown/spell/projectile/gravel_blast
	button_icon = 'icons/mob/actions/mage_geomancy.dmi'
	name = "Gravel Blast"
	desc = "Spray a volley of stone shards at a target. Shards ricochet off walls and become deadlier with each bounce. Subsequent hits on the same target deal reduced damage."
	fluff_desc = "TODO"
	button_icon_state = "gravel_blast"
	sound = 'sound/combat/hits/onstone/wallhit.ogg'
	spell_color = GLOW_COLOR_METAL
	glow_intensity = GLOW_INTENSITY_LOW

	projectile_type = /obj/projectile/magic/gravel_blast
	cast_range = 7
	projectiles_per_fire = 5

	primary_resource_type = SPELL_COST_STAMINA
	primary_resource_cost = SPELLCOST_MINOR_PROJECTILE

	invocations = list("Saxum Iaci!")
	invocation_type = INVOCATION_SHOUT

	charge_required = TRUE
	weapon_cast_penalized = TRUE
	charge_time = CHARGETIME_POKE
	charge_drain = 1
	charge_slowdown = CHARGING_SLOWDOWN_SMALL
	charge_sound = 'sound/magic/charging_fire.ogg'
	cooldown_time = 4.5 SECONDS
	is_implement_scaled_spell = TRUE
	implement_aspect_name = ASPECT_NAME_GEOMANCY
	var/spread_step = 8

	associated_skill = /datum/skill/magic/arcane
	spell_impact_intensity = SPELL_IMPACT_LOW

/datum/action/cooldown/spell/projectile/gravel_blast/ready_projectile(obj/projectile/to_fire, atom/target, mob/user, iteration)
	. = ..()
	var/base_angle = to_fire.Angle
	if(isnull(base_angle))
		base_angle = Get_Angle(user, target)
	var/center_index = (projectiles_per_fire + 1) / 2
	to_fire.Angle = base_angle + ((iteration - center_index) * spread_step)

/obj/projectile/magic/gravel_blast
	name = "gravel shot"
	icon = 'icons/obj/magic_projectiles.dmi'
	icon_state = "stone"
	damage = 25
	nodamage = FALSE
	damage_type = BRUTE
	woundclass = BCLASS_BLUNT
	flag = "magic"
	range = 10
	speed = 2.5 // Stones slow AF boi
	accuracy = 50
	guard_deflectable = TRUE
	npc_simple_damage_mult = 1.5
	hitsound = 'sound/combat/hits/onstone/wallhit.ogg'
	ricochets_max = 2
	ricochet_chance = 80
	ricochet_auto_aim_angle = 40
	ricochet_auto_aim_range = 5
	ricochet_incidence_leeway = 40
	ricochet_decay_chance = 1
	ricochet_decay_damage = 1.5
	var/reduced_damage = 12

/obj/projectile/magic/gravel_blast/on_hit(target)
	if(ismob(target))
		var/mob/living/M = target
		if(M.anti_magic_check())
			visible_message(span_warning("[src] shatters harmlessly against [target]!"))
			playsound(get_turf(target), 'sound/magic/magic_nulled.ogg', 100)
			qdel(src)
			return BULLET_ACT_BLOCK
		if(M.mob_timers[MT_ROCKSHOT] && world.time < M.mob_timers[MT_ROCKSHOT] + ROCKSHOT_DR_DURATION)
			damage = reduced_damage
		else
			M.mob_timers[MT_ROCKSHOT] = world.time
	. = ..()
