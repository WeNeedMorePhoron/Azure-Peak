#define BARRAGE_MIN_SWORDS 7
#define BARRAGE_MAX_SWORDS 9
#define BARRAGE_FORM_DELAY 10 // 1 second for swords to form and rotate
#define BARRAGE_MAX_PIERCE 3

/datum/action/cooldown/spell/steel_barrage
	button_icon = 'icons/mob/actions/mage_ferramancy.dmi'
	name = "Steel Barrage"
	desc = "Conjure a volley of greatswords behind you. After a moment they rotate to face \
	your target and launch simultaneously, piercing through up to three targets each. \
	Always strikes the chest. Repeated hits on the same target deal halved damage."
	button_icon_state = "iron_tempest"
	sound = 'sound/magic/scrapeblade.ogg'
	spell_color = GLOW_COLOR_METAL
	glow_intensity = GLOW_INTENSITY_VERY_HIGH

	click_to_activate = TRUE
	cast_range = 7
	self_cast_possible = FALSE

	primary_resource_type = SPELL_COST_STAMINA
	primary_resource_cost = SPELLCOST_ULTIMATE

	invocations = list("Porta Ferri Aperta!")
	invocation_type = INVOCATION_SHOUT

	charge_required = TRUE
	weapon_cast_penalized = TRUE
	charge_time = CHARGETIME_HEAVY
	charge_drain = 1
	charge_slowdown = CHARGING_SLOWDOWN_HEAVY
	charge_sound = 'sound/magic/charging.ogg'
	cooldown_time = 60 SECONDS

	associated_skill = /datum/skill/magic/arcane
	spell_impact_intensity = SPELL_IMPACT_HIGH

	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC | SPELL_REQUIRES_HUMAN

	var/sword_damage = 50
	var/sword_count_min = BARRAGE_MIN_SWORDS
	var/sword_count_max = BARRAGE_MAX_SWORDS
	var/list/hit_targets = list()

/datum/action/cooldown/spell/steel_barrage/cast(atom/cast_on)
	. = ..()
	var/mob/living/carbon/human/H = owner
	if(!istype(H))
		return FALSE

	var/turf/target_turf = get_turf(cast_on)
	if(!target_turf)
		return FALSE

	var/turf/source_turf = get_turf(H)
	if(target_turf.z > H.z)
		source_turf = get_step_multiz(source_turf, UP)
	if(target_turf.z < H.z)
		source_turf = get_step_multiz(source_turf, DOWN)
	if(!(target_turf in get_hear(cast_range, source_turf)))
		to_chat(H, span_warning("I can't cast where I can't see!"))
		return FALSE

	hit_targets = list()

	// Telegraph on target tile
	new /obj/effect/temp_visual/trap/thunderstrike(target_turf, TELEGRAPH_HIGH_IMPACT + BARRAGE_FORM_DELAY)

	// Spawn swords behind caster
	var/sword_count = rand(sword_count_min, sword_count_max)
	var/behind_dir = REVERSE_DIR(H.dir)
	var/turf/behind = get_step(source_turf, behind_dir)
	if(!behind || behind.density)
		behind = source_turf

	var/list/sword_visuals = list()
	var/base_angle = Get_Angle(behind, target_turf)

	for(var/i in 1 to sword_count)
		// Spread swords in a line behind caster with slight vertical offset
		var/offset_x = rand(-12, 12)
		var/offset_y = rand(-8, 8)
		var/obj/effect/temp_visual/barrage_sword/S = new(behind)
		S.pixel_x = offset_x
		S.pixel_y = offset_y
		S.target_angle = base_angle
		sword_visuals += S

	H.visible_message(span_boldwarning("[H] conjures a wall of greatswords!"))
	playsound(source_turf, 'sound/magic/scrapeblade.ogg', 80, TRUE, 6)

	// After forming, rotate swords to face target then launch
	addtimer(CALLBACK(src, PROC_REF(rotate_swords), sword_visuals, base_angle), 5)
	addtimer(CALLBACK(src, PROC_REF(launch_all), target_turf, sword_count, behind), BARRAGE_FORM_DELAY)
	return TRUE

/datum/action/cooldown/spell/steel_barrage/proc/rotate_swords(list/visuals, angle)
	for(var/obj/effect/temp_visual/barrage_sword/S in visuals)
		if(!QDELETED(S))
			var/matrix/M = matrix()
			M.Turn(angle)
			animate(S, transform = M, time = 4)

/datum/action/cooldown/spell/steel_barrage/proc/launch_all(turf/target_turf, sword_count, turf/origin)
	if(QDELETED(src) || QDELETED(owner))
		return
	var/mob/living/carbon/human/H = owner
	if(!istype(H) || H.stat != CONSCIOUS)
		return

	playsound(origin, 'sound/magic/scrapeblade.ogg', 100, TRUE, 8)

	var/base_angle = Get_Angle(origin, target_turf)
	var/spread = 30
	var/angle_step = spread / max(sword_count - 1, 1)
	var/start_angle = base_angle - (spread / 2)

	for(var/i in 1 to sword_count)
		var/launch_angle = start_angle + (angle_step * (i - 1))
		var/obj/projectile/magic/arcyne_sword/P = new(origin)
		P.firer = owner
		P.fired_from = origin
		P.damage = sword_damage
		P.barrage_ref = src
		P.def_zone = BODY_ZONE_CHEST
		// Rotate sprite to match travel direction
		var/matrix/M = matrix()
		M.Turn(launch_angle)
		P.transform = M
		P.fire(launch_angle)
	playsound(origin, 'sound/combat/wooshes/flail_swing.ogg', 60, TRUE)

// Sword visual that forms behind caster before launching
/obj/effect/temp_visual/barrage_sword
	icon = 'icons/obj/projectiles/magic_projectiles64.dmi'
	icon_state = "greatsword"
	layer = ABOVE_MOB_LAYER
	duration = 2 SECONDS
	var/target_angle = 0

/obj/effect/temp_visual/barrage_sword/Initialize(mapload)
	. = ..()
	// Fade in
	alpha = 0
	animate(src, alpha = 255, time = 3)

// Projectile - pierces 3 targets like Arcyne Lance, always hits chest
/obj/projectile/magic/arcyne_sword
	name = "conjured greatsword"
	icon = 'icons/obj/projectiles/magic_projectiles64.dmi'
	icon_state = "greatsword"
	damage = 50
	nodamage = FALSE
	damage_type = BRUTE
	woundclass = BCLASS_CUT
	flag = "magic"
	range = 9
	speed = 2
	def_zone = BODY_ZONE_CHEST
	hitsound = 'sound/combat/hits/onmetal/metalimpact (1).ogg'
	movement_type = UNSTOPPABLE
	var/hits = 0
	var/max_hits = BARRAGE_MAX_PIERCE
	var/datum/action/cooldown/spell/steel_barrage/barrage_ref

/obj/projectile/magic/arcyne_sword/on_hit(target)
	if(ismob(target))
		var/mob/living/M = target
		if(M.anti_magic_check())
			visible_message(span_warning("[src] shatters harmlessly against [M]!"))
			playsound(get_turf(M), 'sound/magic/magic_nulled.ogg', 100)
			qdel(src)
			return BULLET_ACT_BLOCK
		// Halve damage for repeated hits on same target
		if(barrage_ref)
			if(target in barrage_ref.hit_targets)
				damage = max(round(damage * 0.5), 1)
			else
				barrage_ref.hit_targets += target
		playsound(get_turf(target), pick('sound/combat/hits/onmetal/metalimpact (1).ogg', 'sound/combat/hits/onmetal/metalimpact (2).ogg'), 60, TRUE)
	. = ..()
	new /obj/effect/temp_visual/spell_impact(get_turf(target), GLOW_COLOR_METAL, SPELL_IMPACT_HIGH)
	if(!ismob(target))
		qdel(src)
		return . || BULLET_ACT_HIT
	hits++
	if(hits >= max_hits)
		qdel(src)
		return . || BULLET_ACT_HIT
	return BULLET_ACT_FORCE_PIERCE

#undef BARRAGE_MIN_SWORDS
#undef BARRAGE_MAX_SWORDS
#undef BARRAGE_FORM_DELAY
#undef BARRAGE_MAX_PIERCE
