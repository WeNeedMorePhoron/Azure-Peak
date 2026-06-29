/datum/action/cooldown/spell/ferramancy_strike
	button_icon = 'icons/mob/actions/mage_ferramancy.dmi'
	sound = 'sound/magic/scrapeblade.ogg'
	spell_color = GLOW_COLOR_METAL
	glow_intensity = GLOW_INTENSITY_MEDIUM
	attunement_school = ASPECT_NAME_FERRAMANCY

	click_to_activate = FALSE
	self_cast_possible = TRUE

	primary_resource_type = SPELL_COST_STAMINA
	primary_resource_cost = SPELLCOST_MINOR_AOE

	invocation_type = INVOCATION_SHOUT

	charge_required = FALSE
	weapon_cast_penalized = FALSE
	cooldown_time = 15 SECONDS
	shared_cooldown = "ferramancy_strike"

	associated_skill = /datum/skill/magic/arcane
	spell_tier = 2
	spell_impact_intensity = SPELL_IMPACT_MEDIUM
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC | SPELL_REQUIRES_HUMAN

	var/damage = 50
	var/npc_simple_damage_mult = 1.5
	var/blade_class = BCLASS_CUT
	var/strike_armor_pen = PEN_NONE
	var/detonate_sound = 'sound/combat/newstuck.ogg'
	var/windup_time = TELEGRAPH_DODGEABLE
	var/redraw_interval = 2
	var/sweep_step = 1
	/// Duration of Vulnerable applied to anything struck. 0 = none.
	var/vuln_on_hit = 0

/datum/action/cooldown/spell/ferramancy_strike/cast(atom/cast_on)
	. = ..()
	var/mob/living/carbon/human/H = owner
	if(!istype(H))
		return FALSE
	var/strike_duration = windup_time + length(get_pattern_turfs(H, get_cardinal(H.dir))) * sweep_step
	H.changeNext_move(strike_duration)
	// Imitate a SWINGDELAY_CANCELSLOW heavy swing: slowed, no defence, and a landed blow interrupts it.
	H.apply_status_effect(/datum/status_effect/swingdelay/disrupt, windup_time + 2, TRUE)
	INVOKE_ASYNC(src, PROC_REF(windup_and_strike), H)
	return TRUE

/datum/action/cooldown/spell/ferramancy_strike/proc/windup_and_strike(mob/living/carbon/human/H)
	var/list/indicator = list()
	var/iterations = max(1, round(windup_time / redraw_interval))
	var/datum/status_effect/swingdelay/disrupt/swing = H.has_status_effect(/datum/status_effect/swingdelay/disrupt)
	for(var/i in 1 to iterations)
		if(QDELETED(H) || H.stat != CONSCIOUS || QDELETED(swing) || swing.is_disrupted())
			break
		for(var/obj/effect/old in indicator)
			qdel(old)
		indicator.Cut()
		for(var/turf/T in get_pattern_turfs(H, get_cardinal(H.dir)))
			indicator += new /obj/effect/temp_visual/trap/ferramancy(T)
		sleep(redraw_interval)
	for(var/obj/effect/old in indicator)
		qdel(old)
	if(QDELETED(H) || H.stat != CONSCIOUS)
		return
	// The framework already played the disrupt sound/visual when the swing was broken - just don't release the strike.
	if(QDELETED(swing) || swing.is_disrupted())
		return
	strike(H, get_cardinal(H.dir))

/datum/action/cooldown/spell/ferramancy_strike/proc/strike(mob/living/carbon/human/H, facing)
	var/list/turfs = get_pattern_turfs(H, facing)
	if(!length(turfs))
		return
	playsound(get_turf(H), 'sound/magic/blade_burst.ogg', 75, TRUE)
	do_blade_animation(H, facing, turfs)
	var/idx = 0
	for(var/turf/T in turfs)
		addtimer(CALLBACK(src, PROC_REF(hit_turf), H, T, facing), idx * sweep_step)
		idx++

/datum/action/cooldown/spell/ferramancy_strike/proc/hit_turf(mob/living/carbon/human/H, turf/T, facing)
	if(QDELETED(H) || QDELETED(T))
		return
	var/hit_any = FALSE
	for(var/mob/living/L in T.contents)
		if(L == H)
			continue
		if(L.anti_magic_check())
			L.visible_message(span_warning("The arcyne blades dispel as they near [L]!"))
			playsound(get_turf(L), 'sound/magic/magic_nulled.ogg', 100)
			continue
		hit_any = TRUE
		if(ishuman(L))
			var/target_zone = H.zone_selected || BODY_ZONE_CHEST
			arcyne_strike(H, L, null, damage, target_zone, blade_class, armor_penetration = strike_armor_pen, spell_name = name, damage_type = BRUTE, npc_simple_damage_mult = npc_simple_damage_mult, skip_animation = TRUE)
		else
			var/actual_damage = damage
			if(!L.mind)
				actual_damage *= npc_simple_damage_mult
			L.adjustBruteLoss(actual_damage)
		if(vuln_on_hit)
			L.apply_status_effect(/datum/status_effect/debuff/vulnerable, vuln_on_hit)
		new /obj/effect/temp_visual/spell_impact(get_turf(L), spell_color, spell_impact_intensity)
	if(hit_any)
		playsound(T, detonate_sound, 65, TRUE)

/// Override per spell to draw a conjured blade sweeping/thrusting through the pattern. Base does nothing.
/datum/action/cooldown/spell/ferramancy_strike/proc/do_blade_animation(mob/living/carbon/human/H, facing, list/turfs)
	return

/// Override per spell to return the turfs the strike hits, in the order they should be struck.
/datum/action/cooldown/spell/ferramancy_strike/proc/get_pattern_turfs(mob/living/carbon/human/H, facing)
	return list()

/datum/action/cooldown/spell/ferramancy_strike/proc/get_cardinal(dir)
	if(dir & NORTH)
		return NORTH
	if(dir & SOUTH)
		return SOUTH
	if(dir & EAST)
		return EAST
	if(dir & WEST)
		return WEST
	return NORTH

/// Rotate a NORTH-baseline (dx, dy) offset to the given cardinal facing.
/datum/action/cooldown/spell/ferramancy_strike/proc/rotate_offset(dx, dy, facing)
	switch(facing)
		if(SOUTH)
			return list(-dx, -dy)
		if(EAST)
			return list(dy, -dx)
		if(WEST)
			return list(-dy, dx)
	return list(dx, dy)

/datum/action/cooldown/spell/ferramancy_strike/proc/facing_angle(facing)
	switch(facing)
		if(SOUTH)
			return 180
		if(EAST)
			return 270
		if(WEST)
			return 90
	return 0

/// Angle clockwise from north for the facing direction, for placing effects on an arc via sin/cos.
/datum/action/cooldown/spell/ferramancy_strike/proc/facing_position_angle(facing)
	switch(facing)
		if(EAST)
			return 90
		if(SOUTH)
			return 180
		if(WEST)
			return 270
	return 0

/// Transform for the swept greatsword: scaled, turned so the (downward) blade points radially outward at the given orbit angle.
/datum/action/cooldown/spell/ferramancy_strike/proc/crescent_matrix(position_angle)
	var/matrix/m = matrix()
	m.Scale(2)
	m.Turn(180 - position_angle)
	return m

// --- Falling Crescent: wide cardinal sweep, struck right-to-left ---

/datum/action/cooldown/spell/ferramancy_strike/falling_crescent
	name = "Falling Crescent"
	desc = "Wind up a greatsword's edge, then sweep a wide arc across the tiles in front of you, cleaving everything in reach right to left. You are slowed while winding up and can be interrupted. This strike can be defended against, but not parried or dodged.\n\n\
	Deals 50 brute damage to everything caught in the arc."
	button_icon_state = "falling_crescent"
	invocations = list("Magna Acies!")
	blade_class = BCLASS_CUT
	windup_time = TELEGRAPH_DODGEABLE

/datum/action/cooldown/spell/ferramancy_strike/falling_crescent/get_pattern_turfs(mob/living/carbon/human/H, facing)
	var/list/turfs = list()
	var/turf/origin = get_turf(H)
	if(!origin)
		return turfs
	// NORTH baseline, ordered right column -> centre -> left column for a right-to-left sweep.
	var/list/offsets = list(
		list(1, 0), list(1, 1), list(1, 2),
		list(0, 1), list(0, 2),
		list(-1, 0), list(-1, 1), list(-1, 2),
	)
	for(var/list/off in offsets)
		var/list/r = rotate_offset(off[1], off[2], facing)
		var/turf/T = locate(origin.x + r[1], origin.y + r[2], origin.z)
		if(T)
			turfs += T
	return turfs

// The conjured greatsword orbits the caster, tip pointing outward, sweeping the front right-to-left.
/datum/action/cooldown/spell/ferramancy_strike/falling_crescent/do_blade_animation(mob/living/carbon/human/H, facing, list/turfs)
	var/obj/effect/temp_visual/ferramancy_blade/blade = new(get_turf(H))
	var/center = facing_position_angle(facing)
	var/dur = max(2, length(turfs) * sweep_step)
	var/steps = 8
	var/radius = 36
	var/sweep_half = 80
	var/start_a = center + sweep_half // caster's right
	var/end_a = center - sweep_half   // caster's left
	blade.pixel_x = radius * sin(start_a)
	blade.pixel_y = radius * cos(start_a)
	blade.transform = crescent_matrix(start_a)
	blade.alpha = 200
	for(var/s in 1 to steps)
		var/a = start_a + (end_a - start_a) * (s / steps)
		animate(blade, pixel_x = radius * sin(a), pixel_y = radius * cos(a), transform = crescent_matrix(a), time = dur / steps, easing = LINEAR_EASING)
	animate(alpha = 0, time = 2)
	QDEL_IN(blade, dur + 4)

/datum/action/cooldown/spell/ferramancy_strike/sorcerers_lance
	name = "Sorcerer's Lance"
	desc = "Wind up a couched lance, then drive it forward in a straight line, skewering everything up to five tiles ahead. You are slowed while winding up and can be interrupted.\n\n\
	Deals 50 brute damage to everything caught in the line, piercing through even heavy armor."
	button_icon_state = "sorcerers_lance"
	invocations = list("Hasta Perforans!")
	blade_class = BCLASS_STAB
	strike_armor_pen = PEN_HEAVY
	windup_time = TELEGRAPH_HIGH_IMPACT
	var/line_length = 5

/datum/action/cooldown/spell/ferramancy_strike/sorcerers_lance/get_pattern_turfs(mob/living/carbon/human/H, facing)
	var/list/turfs = list()
	var/turf/T = get_turf(H)
	if(!T)
		return turfs
	for(var/i in 1 to line_length)
		T = get_step(T, facing)
		if(!T)
			break
		if(T.density)
			break
		turfs += T
	return turfs

/datum/action/cooldown/spell/ferramancy_strike/sorcerers_lance/do_blade_animation(mob/living/carbon/human/H, facing, list/turfs)
	var/obj/effect/temp_visual/ferramancy_blade/blade = new(get_turf(H))
	var/ang = facing_angle(facing)
	var/reach = length(turfs)
	var/matrix/m = matrix()
	m.Scale(1, max(2, reach))
	m.Turn(ang + 180)
	blade.transform = m
	blade.alpha = 210
	var/px = 0
	var/py = 0
	switch(facing)
		if(NORTH)
			py = reach * 16
		if(SOUTH)
			py = -reach * 16
		if(EAST)
			px = reach * 16
		if(WEST)
			px = -reach * 16
	var/dur = max(2, reach * sweep_step)
	animate(blade, pixel_x = px, pixel_y = py, time = dur, easing = SINE_EASING)
	animate(alpha = 0, time = 2)
	QDEL_IN(blade, dur + 3)

/datum/action/cooldown/spell/ferramancy_strike/hammer_of_heaven
	name = "Hammer of Heaven"
	desc = "Heave a conjured greatsword overhead, then crash it down on the ground before you, leaving any struck reeling and vulnerable.\n\n\
	Deals 65 brute damage and applies Vulnerable to everything in the smash."
	button_icon_state = "hammer_of_heaven"
	invocations = list("Frange Omnia!")
	blade_class = BCLASS_BLUNT
	windup_time = TELEGRAPH_HIGH_IMPACT
	damage = 65
	sweep_step = 0
	vuln_on_hit = 3 SECONDS

/datum/action/cooldown/spell/ferramancy_strike/hammer_of_heaven/get_pattern_turfs(mob/living/carbon/human/H, facing)
	var/list/turfs = list()
	var/turf/origin = get_turf(H)
	if(!origin)
		return turfs
	var/list/offsets = list(
		list(-1, 1), list(0, 1), list(1, 1),
	)
	for(var/list/off in offsets)
		var/list/r = rotate_offset(off[1], off[2], facing)
		var/turf/T = locate(origin.x + r[1], origin.y + r[2], origin.z)
		if(T)
			turfs += T
	return turfs

/datum/action/cooldown/spell/ferramancy_strike/hammer_of_heaven/do_blade_animation(mob/living/carbon/human/H, facing, list/turfs)
	var/turf/origin = get_turf(H)
	var/turf/front = get_step(origin, facing)
	if(!front)
		front = origin
	var/obj/effect/temp_visual/ferramancy_blade/blade = new(front)
	var/matrix/m = matrix()
	m.Scale(2.5)
	blade.transform = m
	blade.pixel_y = 64
	blade.alpha = 220
	animate(blade, pixel_y = 0, time = 2, easing = SINE_EASING) // crashes down from overhead
	animate(alpha = 0, time = 2)
	QDEL_IN(blade, 5)

// --- Conjured blade visual ---

/obj/effect/temp_visual/ferramancy_blade
	icon = 'icons/obj/magic_projectiles.dmi'
	icon_state = "air_blade_stab"
	layer = ABOVE_ALL_MOB_LAYER
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	duration = 1 SECONDS
	randomdir = FALSE

/obj/effect/temp_visual/trap
	icon = 'icons/effects/effects.dmi'
	icon_state = "trap"
	light_outer_range = 2
	duration = 12
	layer = MASSIVE_OBJ_LAYER

/obj/effect/temp_visual/trap/ferramancy
	color = GLOW_COLOR_METAL
	light_color = GLOW_COLOR_METAL

/obj/effect/temp_visual/blade_burst
	icon = 'icons/effects/wizard_spell_effects.dmi'
	icon_state = "grassblade"
	dir = NORTH
	name = "arcyne blade"
	desc = "Get out of the way!"
	randomdir = FALSE
	duration = 1 SECONDS
	layer = MASSIVE_OBJ_LAYER
