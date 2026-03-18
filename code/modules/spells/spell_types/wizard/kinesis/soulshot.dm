// Soulshot - Kinesis hitscan beam
// High-damage brute beam with eldritch visuals

/datum/action/cooldown/spell/projectile/soulshot
	name = "Soulshot"
	desc = "Fire a devastating beam of kinetic force that tears through a target."
	button_icon_state = "yourewizardharry"
	sound = 'sound/magic/cosmic_expansion.ogg'
	spell_color = GLOW_COLOR_DISPLACEMENT
	glow_intensity = GLOW_INTENSITY_MEDIUM

	projectile_type = /obj/projectile/magic/soulshot
	cast_range = 8
	point_cost = 3

	primary_resource_type = SPELL_COST_STAMINA
	primary_resource_cost = SPELLCOST_MAJOR_PROJECTILE

	invocations = list("Animus Ictus!")
	invocation_type = INVOCATION_SHOUT

	charge_required = TRUE
	charge_time = CHARGETIME_MAJOR
	charge_drain = 1
	charge_slowdown = CHARGING_SLOWDOWN_MEDIUM
	charge_sound = 'sound/magic/charging.ogg'
	cooldown_time = 10 SECONDS

	associated_skill = /datum/skill/magic/arcane
	spell_tier = 2

/obj/projectile/magic/soulshot
	name = "soulshot"
	tracer_type = /obj/effect/projectile/tracer/bloodsteal
	muzzle_type = null
	impact_type = null
	hitscan = TRUE
	movement_type = UNSTOPPABLE
	guard_deflectable = TRUE
	damage = 80
	damage_type = BRUTE
	npc_simple_damage_mult = 1.5
	accuracy = 40
	nodamage = FALSE
	speed = 0.3
	flag = "magic"
	hitsound = 'sound/magic/obeliskbeam.ogg'
	light_color = "#9400D3"
	light_outer_range = 7

/obj/projectile/magic/soulshot/on_hit(target)
	. = ..()
	if(ismob(target))
		var/mob/M = target
		if(M.anti_magic_check())
			visible_message(span_warning("[src] fizzles on contact with [target]!"))
			playsound(get_turf(target), 'sound/magic/magic_nulled.ogg', 100)
			qdel(src)
			return BULLET_ACT_BLOCK
	qdel(src)
