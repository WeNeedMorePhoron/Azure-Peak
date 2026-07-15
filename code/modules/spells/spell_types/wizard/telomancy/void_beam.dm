#define VOID_BEAM_SLOWDOWN_ID "void_beam_windup"

/datum/action/cooldown/spell/void_beam
	button_icon = 'icons/mob/actions/mage_telomancy.dmi'
	name = "Void Beam"
	desc = "Fire a lance of raw arcyne force that exposes your foe. It is well telegraphed and does a decent amount of damaage."
	button_icon_state = "seeker_volley"
	sound = 'sound/magic/soulshot.ogg'
	spell_color = GLOW_COLOR_ARCANE
	glow_intensity = GLOW_INTENSITY_HIGH
	attunement_school = ASPECT_NAME_TELOMANCY

	click_to_activate = TRUE
	cast_range = 8

	primary_resource_type = SPELL_COST_STAMINA
	primary_resource_cost = SPELLCOST_MAJOR_AOE

	invocations = list("Scintilla Magistra!")
	invocation_type = INVOCATION_SHOUT

	charge_required = TRUE
	weapon_cast_penalized = TRUE
	charge_time = CHARGETIME_POKE
	charge_swingdelay_type = SWINGDELAY_PENALTY
	hold_drain = 1
	charge_slowdown = CHARGING_SLOWDOWN_SMALL
	charge_sound = 'sound/magic/charging.ogg'
	cooldown_time = 20 SECONDS

	associated_skill = /datum/skill/magic/arcane
	spell_tier = 3
	spell_impact_intensity = SPELL_IMPACT_MEDIUM
	displayed_damage = 100

	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC | SPELL_REQUIRES_HUMAN | SPELL_REQUIRES_SAME_Z

	var/beam_range = 8
	var/beam_delay = 1.5 SECONDS
	var/beam_damage = 100
	var/push_dist = 1
	var/expose_duration = 6 SECONDS
	var/beam_slowdown = 2

/datum/action/cooldown/spell/void_beam/get_spell_statistics(mob/living/user)
	var/list/stats = ..()
	stats += span_info("Riders: pushes back [push_dist], leaves the target Exposed for [expose_duration / 10]s (no lockdown).")
	return stats

/datum/action/cooldown/spell/void_beam/cast(atom/cast_on)
	. = ..()
	var/mob/living/carbon/human/H = owner
	if(!istype(H))
		return FALSE

	var/turf/origin = get_turf(H)
	if(!origin)
		return FALSE

	var/turf/clicked = get_turf(cast_on)
	var/beam_dir = (clicked && clicked != origin) ? get_dir(origin, clicked) : H.dir

	var/list/turf/line = list()
	var/turf/current = origin
	for(var/i in 1 to beam_range)
		var/turf/next = get_step(current, beam_dir)
		if(!next || next.density)
			break
		line += next
		new /obj/effect/temp_visual/pillar_warning/fadein(next, beam_delay)
		current = next

	if(!length(line))
		return FALSE

	H.add_movespeed_modifier(VOID_BEAM_SLOWDOWN_ID, update = TRUE, priority = 100, multiplicative_slowdown = beam_slowdown, movetypes = GROUND)
	playsound(origin, 'sound/magic/charging.ogg', 60, TRUE)
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(void_beam_detonate), line, H, origin, beam_dir, beam_damage, push_dist, expose_duration, src, name), beam_delay)

	return TRUE

/proc/void_beam_detonate(list/turf/line, mob/living/carbon/human/caster, turf/origin, beam_dir, damage = 35, push_dist = 1, expose_dur = 6 SECONDS, datum/action/cooldown/spell/guard_source, spell_name = "Void Beam")
	if(caster)
		caster.remove_movespeed_modifier(VOID_BEAM_SLOWDOWN_ID)
	if(!length(line))
		return

	playsound(origin, 'sound/magic/soulshot.ogg', 90, TRUE, 4)
	var/static/list/random_zones = list(BODY_ZONE_HEAD, BODY_ZONE_CHEST, BODY_ZONE_L_ARM, BODY_ZONE_R_ARM)
	var/index = 0
	var/last_index = length(line)

	for(var/turf/T in line)
		index++
		var/obj/effect/temp_visual/void_beam/seg = new(T)
		seg.setDir(beam_dir)
		if(index == 1)
			seg.icon_state = "obeliskbeam_start"
		else if(index == last_index)
			seg.icon_state = "obeliskbeam_end"

		for(var/mob/living/L in T.contents)
			if(L.anti_magic_check())
				L.visible_message(span_warning("The beam splinters against [L]!"))
				playsound(T, 'sound/magic/magic_nulled.ogg', 100)
				continue
			if(guard_source && !QDELETED(guard_source) && guard_source.spell_guard_check(L, TRUE))
				L.visible_message(span_warning("[L] turns the beam aside!"))
				continue
			if(istype(caster) && !QDELETED(caster) && ishuman(L))
				arcyne_strike(caster, L, null, damage, pick(random_zones), \
					BCLASS_BLUNT, spell_name = spell_name, \
					damage_type = BRUTE, npc_simple_damage_mult = 1, \
					skip_animation = TRUE)
			else
				L.adjustBruteLoss(damage)
			L.apply_status_effect(/datum/status_effect/debuff/exposed, expose_dur)
			var/push_dir = get_dir(origin, L) || beam_dir
			L.safe_throw_at(get_ranged_target_turf(L, push_dir, push_dist), push_dist, 1, caster, force = MOVE_FORCE_STRONG)
			new /obj/effect/temp_visual/spell_impact(get_turf(L), GLOW_COLOR_ARCANE, SPELL_IMPACT_MEDIUM)

/obj/effect/temp_visual/void_beam
	name = "void beam"
	icon = 'icons/effects/effects.dmi'
	icon_state = "obeliskbeam_mid"
	layer = ABOVE_MOB_LAYER
	plane = GAME_PLANE_UPPER
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	light_color = "#9400D3"
	light_power = 4
	light_outer_range = 3
	duration = 6

#undef VOID_BEAM_SLOWDOWN_ID
