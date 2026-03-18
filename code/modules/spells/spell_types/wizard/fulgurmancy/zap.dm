// Zap - Fulgurmancy staple poke
// Hitscan, lowest burn efficiency of the 3 burn schools, but instant hit
// No CC effects. Highest cooldown among staple pokes (5.5s vs 4s)
// 0.5s charge time — standardized across all poke spells

/datum/action/cooldown/spell/projectile/zap
	name = "Zap"
	desc = "Fire a quick jolt of lightning at a target. Deals less damage than most other minor offensive spells, but strikes instantly. \
	Damage is increased by 100% versus simple-minded creechurs."
	button_icon_state = "dvine_strike"
	sound = 'sound/magic/lightning.ogg'
	spell_color = GLOW_COLOR_LIGHTNING
	glow_intensity = GLOW_INTENSITY_LOW

	projectile_type = /obj/projectile/magic/zap
	cast_range = 8

	primary_resource_type = SPELL_COST_STAMINA
	primary_resource_cost = SPELLCOST_MINOR_PROJECTILE

	invocations = list("Fulgur!")
	invocation_type = INVOCATION_SHOUT

	charge_required = TRUE
	charge_time = CHARGETIME_POKE
	charge_drain = 1
	charge_slowdown = CHARGING_SLOWDOWN_SMALL
	charge_sound = 'sound/magic/charging.ogg'
	cooldown_time = 5.5 SECONDS

	associated_skill = /datum/skill/magic/arcane

/obj/projectile/magic/zap
	name = "zap"
	tracer_type = /obj/effect/projectile/tracer/wormhole
	muzzle_type = null
	impact_type = null
	hitscan = TRUE
	movement_type = UNSTOPPABLE
	light_color = LIGHT_COLOR_WHITE
	damage = 25
	npc_simple_damage_mult = 2
	damage_type = BURN
	accuracy = 40
	nodamage = FALSE
	guard_deflectable = TRUE
	speed = 0.3
	flag = "magic"
	light_outer_range = 5

/obj/projectile/magic/zap/on_hit(target)
	. = ..()
	if(ismob(target))
		var/mob/M = target
		if(M.anti_magic_check())
			visible_message(span_warning("[src] fizzles on contact with [target]!"))
			playsound(get_turf(target), 'sound/magic/magic_nulled.ogg', 100)
			qdel(src)
			return BULLET_ACT_BLOCK
		if(isliving(target))
			var/mob/living/L = target
			L.electrocute_act(1, src, 1, SHOCK_NOSTUN)
	qdel(src)
