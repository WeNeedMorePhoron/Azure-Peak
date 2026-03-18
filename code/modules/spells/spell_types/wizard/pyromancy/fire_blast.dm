/datum/action/cooldown/spell/fire_blast
	name = "Fire Blast"
	desc = "Channel a blast of flame in a line toward your target, repelling those struck back 2 paces and leaving the ground ablaze."
	button_icon_state = "hellish_rebuke"
	sound = 'sound/misc/explode/incendiary (1).ogg'
	spell_color = GLOW_COLOR_FIRE
	glow_intensity = GLOW_INTENSITY_MEDIUM

	click_to_activate = TRUE
	cast_range = 7
	self_cast_possible = FALSE

	primary_resource_type = SPELL_COST_STAMINA
	primary_resource_cost = SPELLCOST_MAJOR_PROJECTILE

	invocations = list("Ignis Irae!")
	invocation_type = INVOCATION_SHOUT

	charge_required = TRUE
	charge_time = 1 SECONDS
	charge_drain = 1
	charge_slowdown = CHARGING_SLOWDOWN_SMALL
	charge_sound = 'sound/magic/charging_fire.ogg'
	cooldown_time = 10 SECONDS

	associated_skill = /datum/skill/magic/arcane

	var/line_length = 4
	var/blast_damage = 30
	var/push_dist = 2
	var/fire_stacks_applied = 1
	var/hotspot_life = 4

/datum/action/cooldown/spell/fire_blast/cast(atom/cast_on)
	. = ..()
	var/mob/living/carbon/human/H = owner
	if(!istype(H))
		return FALSE

	var/turf/start = get_turf(H)
	var/turf/target_turf = get_turf(cast_on)

	var/list/full_line = get_line(start, target_turf)
	// get_line includes the starting turf — skip it, cap to line_length
	var/list/line_turfs = list()
	for(var/i in 2 to min(length(full_line), line_length + 1))
		var/turf/T = full_line[i]
		if(!T || T.density)
			break
		line_turfs += T
	var/facing = length(line_turfs) ? get_dir(start, line_turfs[1]) : H.dir

	if(!length(line_turfs))
		return FALSE

	for(var/turf/T in line_turfs)
		new /obj/effect/temp_visual/fire(T)
		new /obj/effect/hotspot(T, null, null, hotspot_life)

	playsound(start, pick('sound/misc/explode/incendiary (1).ogg', 'sound/misc/explode/incendiary (2).ogg'), 100, TRUE, 4)

	var/list/already_hit = list()
	for(var/turf/T in line_turfs)
		for(var/mob/living/victim in T)
			if(victim == H || victim.stat == DEAD || (victim in already_hit))
				continue
			if(victim.anti_magic_check())
				victim.visible_message(span_warning("The flames fizzle on contact with [victim]!"))
				continue
			if(spell_guard_check(victim, FALSE, H))
				continue
			arcyne_strike(H, victim, null, blast_damage, BODY_ZONE_CHEST, \
				BCLASS_BURN, spell_name = "Fire Blast", \
				allow_shield_check = TRUE, damage_type = BURN, \
				skip_animation = TRUE)
			victim.adjust_fire_stacks(fire_stacks_applied)
			victim.ignite_mob()
			already_hit += victim
			var/push_dir = get_dir(H, victim)
			if(!push_dir)
				push_dir = facing
			victim.safe_throw_at(get_ranged_target_turf(victim, push_dir, push_dist), push_dist, 2, H, force = MOVE_FORCE_STRONG)

	if(length(already_hit))
		H.visible_message(span_danger("[H] unleashes a blast of flame, sending [english_list(already_hit)] flying!"))
	else
		H.visible_message(span_danger("[H] unleashes a blast of flame!"))

	return TRUE
