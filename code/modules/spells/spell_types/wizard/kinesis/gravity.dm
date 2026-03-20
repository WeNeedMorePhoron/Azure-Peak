// Gravity - Kinesis single-target CC
// Crushes a target with gravitational force. STR > 15 resists knockdown (off-balanced instead).
// Consumes Arcane Marks for bonus damage and knockdown duration.

#define GRAVITY_TELEGRAPH 5 // Ticks of warning before the crush lands

/datum/action/cooldown/spell/gravity
	name = "Gravity"
	desc = "Weighten space around someone, crushing them and knocking them to the floor. Stronger opponents will resist and be off-balanced. Consumes <b>Arcane Marks</b> to slightly increase knockdown time and damage."
	button_icon_state = "hierophant"
	sound = 'sound/magic/gravity.ogg'
	spell_color = GLOW_COLOR_DISPLACEMENT
	glow_intensity = GLOW_INTENSITY_MEDIUM

	click_to_activate = TRUE
	cast_range = 7
	self_cast_possible = FALSE

	primary_resource_type = SPELL_COST_STAMINA
	primary_resource_cost = SPELLCOST_SINGLE_CC

	invocations = list("Pondus!")
	invocation_type = INVOCATION_SHOUT

	charge_required = TRUE
	charge_time = CHARGETIME_MAJOR
	charge_drain = 1
	charge_slowdown = CHARGING_SLOWDOWN_MEDIUM
	charge_sound = 'sound/magic/charging.ogg'
	cooldown_time = 20 SECONDS

	associated_skill = /datum/skill/magic/arcane
	spell_tier = 2

	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC | SPELL_REQUIRES_HUMAN

/datum/action/cooldown/spell/gravity/cast(atom/cast_on)
	. = ..()
	var/mob/living/carbon/human/H = owner
	if(!istype(H))
		return FALSE

	var/turf/T = get_turf(cast_on)
	if(!T)
		return FALSE

	var/turf/source_turf = get_turf(H)
	if(T.z > H.z)
		source_turf = get_step_multiz(source_turf, UP)
	if(T.z < H.z)
		source_turf = get_step_multiz(source_turf, DOWN)
	if(!(T in get_hear(cast_range, source_turf)))
		to_chat(H, span_warning("I can't cast where I can't see!"))
		return FALSE

	new /obj/effect/temp_visual/gravity_trap(T)
	playsound(T, 'sound/magic/gravity.ogg', 80, TRUE, soundping = FALSE)
	addtimer(CALLBACK(src, PROC_REF(gravity_crush), T), GRAVITY_TELEGRAPH)
	return TRUE

/datum/action/cooldown/spell/gravity/proc/gravity_crush(turf/T)
	new /obj/effect/temp_visual/gravity(T)
	for(var/mob/living/L in T.contents)
		if(L.anti_magic_check())
			L.visible_message(span_warning("The gravity fades away around [L]!"))
			playsound(get_turf(L), 'sound/magic/magic_nulled.ogg', 100)
			continue
		if(spell_guard_check(L, TRUE))
			L.visible_message(span_warning("[L] stands firm against the crushing force!"))
			continue

		var/mark_stacks = consume_arcane_mark_stacks(L)
		var/extra_time = mark_stacks * 4
		if(L.STASTR <= 15)
			L.adjustBruteLoss(60 + extra_time)
			L.Knockdown(5 + extra_time)
			if(mark_stacks == 3)
				to_chat(L, span_userdanger("GRAVITAS COLLAPSE; TRYPTICH-MARKE DETONATION!"))
			else
				to_chat(L, span_userdanger("I'm magically weighed down, losing my footing!"))
		else
			L.OffBalance(10 + extra_time)
			L.adjustBruteLoss(15)
			to_chat(L, span_userdanger("I'm magically weighed down, but my strength resist!"))

#undef GRAVITY_TELEGRAPH
