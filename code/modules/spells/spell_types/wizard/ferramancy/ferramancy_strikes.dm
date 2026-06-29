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
	var/impact_delay = 0
	var/stop_at_dense = FALSE
	var/swipe_state = null
	var/vuln_on_hit = 0

/datum/action/cooldown/spell/ferramancy_strike/cast(atom/cast_on)
	. = ..()
	var/mob/living/carbon/human/H = owner
	if(!istype(H))
		return FALSE
	var/strike_duration = windup_time + impact_delay + max(0, length(get_pattern_offsets()) - 1) * sweep_step
	H.changeNext_move(strike_duration)
	H.apply_status_effect(/datum/status_effect/swingdelay/penalty/committed, strike_duration + 2, TRUE)
	INVOKE_ASYNC(src, PROC_REF(windup_and_strike), H)
	return TRUE

/datum/action/cooldown/spell/ferramancy_strike/proc/windup_and_strike(mob/living/carbon/human/H)
	var/list/indicator = list()
	var/iterations = max(1, round(windup_time / redraw_interval))
	var/turf/last_turf
	var/last_facing
	for(var/i in 1 to iterations)
		if(QDELETED(H) || H.stat != CONSCIOUS)
			break
		var/facing = get_cardinal(H.dir)
		if(get_turf(H) != last_turf || facing != last_facing)
			last_turf = get_turf(H)
			last_facing = facing
			draw_indicators(H, facing, indicator)
		sleep(redraw_interval)
	if(QDELETED(H) || H.stat != CONSCIOUS)
		clear_indicators(indicator)
		return
	strike(H, get_cardinal(H.dir), indicator)

/datum/action/cooldown/spell/ferramancy_strike/proc/draw_indicators(mob/living/carbon/human/H, facing, list/indicator)
	draw_offsets(H, facing, indicator, get_pattern_offsets())

/datum/action/cooldown/spell/ferramancy_strike/proc/draw_offsets(mob/living/carbon/human/H, facing, list/indicator, list/offs)
	var/turf/origin = get_turf(H)
	var/list/wanted = list()
	if(origin)
		for(var/list/off in offs)
			var/list/r = rotate_offset(off[1], off[2], facing)
			var/turf/T = locate(origin.x + r[1], origin.y + r[2], origin.z)
			if(T)
				wanted |= T
	for(var/obj/effect/old in indicator.Copy())
		var/turf/ot = get_turf(old)
		if(!QDELETED(old) && (ot in wanted))
			wanted -= ot
		else
			indicator -= old
			qdel(old)
	for(var/turf/T in wanted)
		indicator += new /obj/effect/temp_visual/trap/ferramancy(T)

/datum/action/cooldown/spell/ferramancy_strike/proc/clear_indicators(list/indicator)
	for(var/obj/effect/old in indicator)
		if(!QDELETED(old))
			qdel(old)

/datum/action/cooldown/spell/ferramancy_strike/proc/strike(mob/living/carbon/human/H, facing, list/indicator)
	if(!length(get_pattern_offsets()))
		clear_indicators(indicator)
		return
	playsound(get_turf(H), 'sound/magic/blade_burst.ogg', 75, TRUE)
	var/atom/movable/visual = do_blade_animation(H, facing)
	INVOKE_ASYNC(src, PROC_REF(execute_hits), H, facing, indicator, visual)

/datum/action/cooldown/spell/ferramancy_strike/proc/execute_hits(mob/living/carbon/human/H, facing, list/indicator, atom/movable/visual)
	var/turf/last_turf = get_turf(H)
	draw_indicators(H, facing, indicator)
	var/elapsed = 0
	while(elapsed < impact_delay)
		if(QDELETED(H) || H.stat != CONSCIOUS)
			clear_indicators(indicator)
			return
		if(get_turf(H) != last_turf)
			last_turf = get_turf(H)
			draw_indicators(H, facing, indicator)
		sleep(redraw_interval)
		elapsed += redraw_interval
	if(!QDELETED(H) && H.stat == CONSCIOUS)
		on_impact(H, facing, visual)
	var/list/offsets = get_pattern_offsets()
	for(var/i in 1 to length(offsets))
		if(QDELETED(H) || H.stat != CONSCIOUS)
			break
		var/list/off = offsets[i]
		var/list/r = rotate_offset(off[1], off[2], facing)
		var/turf/origin = get_turf(H)
		var/turf/T = origin ? locate(origin.x + r[1], origin.y + r[2], origin.z) : null
		if(T)
			if(stop_at_dense && T.density)
				break
			hit_turf(H, T, facing)
			if(swipe_state)
				var/obj/effect/temp_visual/dir_setting/attack_effect/slash = new(T, facing)
				slash.icon_state = swipe_state
		draw_offsets(H, facing, indicator, offsets.Copy(i + 1))
		if(sweep_step > 0 && i < length(offsets))
			sleep(sweep_step)
	clear_indicators(indicator)

/datum/action/cooldown/spell/ferramancy_strike/proc/on_impact(mob/living/carbon/human/H, facing, atom/movable/visual)
	return

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
	if(hit_any && detonate_sound)
		playsound(T, detonate_sound, 65, TRUE)

/datum/action/cooldown/spell/ferramancy_strike/proc/do_blade_animation(mob/living/carbon/human/H, facing)
	return

/datum/action/cooldown/spell/ferramancy_strike/proc/get_pattern_offsets()
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

/datum/action/cooldown/spell/ferramancy_strike/falling_crescent
	name = "Falling Crescent"
	desc = "Wind up a greatsword's edge, then sweep a wide arc across the tiles in front of you, cleaving everything in reach right to left. You are slowed and left wide open as you wind it up, but once begun it cannot be stopped - only stepped clear of. This strike can be defended against, but not parried or dodged.\n\n\
	Deals 65 brute damage to everything caught in the arc."
	button_icon_state = "falling_crescent"
	invocations = list("Acies Lunata!")
	blade_class = BCLASS_CUT
	windup_time = TELEGRAPH_DODGEABLE
	sweep_step = 2
	damage = 65
	swipe_state = "chop"

/datum/action/cooldown/spell/ferramancy_strike/falling_crescent/get_pattern_offsets()
	return list(
		list(1, 0), list(1, 1), list(1, 2),
		list(0, 1), list(0, 2),
		list(-1, 0), list(-1, 1), list(-1, 2),
	)

/datum/action/cooldown/spell/ferramancy_strike/sorcerers_lance
	name = "Sorcerer's Lance"
	desc = "Wind up a couched lance, then drive it forward in a straight line, skewering everything up to five tiles ahead. You are slowed and left wide open as you wind it up, but once begun it cannot be stopped - only stepped clear of.\n\n\
	Deals 65 brute damage to everything caught in the line, piercing through even heavy armor."
	button_icon_state = "sorcerers_lance"
	invocations = list("Hasta Perforans!")
	blade_class = BCLASS_STAB
	strike_armor_pen = PEN_HEAVY
	windup_time = TELEGRAPH_HIGH_IMPACT
	stop_at_dense = TRUE
	damage = 65
	var/line_length = 5

/datum/action/cooldown/spell/ferramancy_strike/sorcerers_lance/get_pattern_offsets()
	var/list/offsets = list()
	for(var/i in 1 to line_length)
		offsets += list(list(0, i))
	return offsets

/datum/action/cooldown/spell/ferramancy_strike/sorcerers_lance/do_blade_animation(mob/living/carbon/human/H, facing)
	var/reach = line_length
	var/obj/effect/temp_visual/ferramancy_blade/blade = new(null)
	blade.vis_holder = H
	H.vis_contents += blade
	var/matrix/m = matrix()
	m.Scale(1, max(2, reach))
	m.Turn(facing_position_angle(facing))
	blade.transform = m
	blade.alpha = 220
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
	var/dur = max(2, (reach - 1) * sweep_step)
	animate(blade, pixel_x = px, pixel_y = py, time = dur, easing = SINE_EASING)
	animate(alpha = 0, time = 2)
	QDEL_IN(blade, dur + 4)
	return blade

/datum/action/cooldown/spell/ferramancy_strike/hammer_of_heaven
	name = "Hammer of Heaven"
	desc = "Heave a conjured maul overhead, then bring it crashing down on the ground before you, leaving any struck reeling and vulnerable.\n\n\
	Deals 50 brute damage and applies Vulnerable to everything in the smash."
	button_icon_state = "hammer_of_heaven"
	invocations = list("Malleus Caeli!")
	blade_class = BCLASS_BLUNT
	windup_time = TELEGRAPH_HIGH_IMPACT
	damage = 50
	sweep_step = 0
	impact_delay = 4
	detonate_sound = null
	vuln_on_hit = 3 SECONDS
	var/hammer_scale = 1.9

/datum/action/cooldown/spell/ferramancy_strike/hammer_of_heaven/get_pattern_offsets()
	return list(
		list(-1, 1), list(0, 1), list(1, 1),
		list(-1, 2), list(0, 2), list(1, 2),
	)

/datum/action/cooldown/spell/ferramancy_strike/hammer_of_heaven/do_blade_animation(mob/living/carbon/human/H, facing)
	var/obj/effect/temp_visual/ferramancy_hammer/hammer = new(null)
	hammer.vis_holder = H
	H.vis_contents += hammer
	var/rest_y = round(6.5 * hammer_scale - 4)
	var/fwd_x = 0
	var/fwd_y = 0
	switch(facing)
		if(NORTH)
			fwd_y = 32
		if(SOUTH)
			fwd_y = -32
		if(EAST)
			fwd_x = 32
		if(WEST)
			fwd_x = -32
	var/matrix/upright = matrix()
	upright.Scale(hammer_scale)
	upright.Turn(180)
	var/matrix/airborne = matrix()
	airborne.Scale(hammer_scale, hammer_scale * 1.4)
	airborne.Turn(180)
	hammer.transform = airborne
	hammer.pixel_x = fwd_x
	hammer.pixel_y = fwd_y + rest_y + 176
	hammer.alpha = 0
	animate(hammer, pixel_y = fwd_y + rest_y, transform = upright, time = impact_delay, easing = CUBIC_EASING | EASE_IN)
	animate(hammer, alpha = 255, time = 1, flags = ANIMATION_PARALLEL)
	return hammer

/datum/action/cooldown/spell/ferramancy_strike/hammer_of_heaven/on_impact(mob/living/carbon/human/H, facing, atom/movable/visual)
	var/turf/T = get_step(get_turf(H), facing) || get_turf(H)
	if(!T)
		return
	playsound(T, pick('sound/combat/hits/blunt/metalblunt (1).ogg', 'sound/combat/hits/blunt/metalblunt (2).ogg', 'sound/combat/hits/blunt/metalblunt (3).ogg'), 90, TRUE, 4)
	playsound(T, 'sound/magic/repulse.ogg', 55, TRUE, 3)
	for(var/mob/M in range(5, T))
		shake_camera(M, 2, 1)
	new /obj/effect/temp_visual/spell_impact(T, spell_color, SPELL_IMPACT_HIGH)
	if(QDELETED(visual))
		return
	var/rest = visual.pixel_y
	animate(visual, pixel_y = rest + 4, time = 1, easing = SINE_EASING | EASE_OUT)
	animate(pixel_y = rest, time = 1, easing = SINE_EASING | EASE_IN)
	animate(alpha = 0, time = 3)

/obj/effect/temp_visual/ferramancy_blade
	icon = 'icons/obj/magic_projectiles.dmi'
	icon_state = "air_blade_stab"
	layer = ABOVE_ALL_MOB_LAYER
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	duration = 3 SECONDS
	randomdir = FALSE
	var/atom/movable/vis_holder

/obj/effect/temp_visual/ferramancy_blade/Destroy()
	if(vis_holder && !QDELETED(vis_holder))
		vis_holder.vis_contents -= src
	vis_holder = null
	return ..()

/obj/effect/temp_visual/ferramancy_hammer
	icon = 'icons/mob/actions/mage_ferramancy.dmi'
	icon_state = "hammer_of_heaven"
	layer = ABOVE_ALL_MOB_LAYER
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	duration = 1.5 SECONDS
	randomdir = FALSE
	var/atom/movable/vis_holder

/obj/effect/temp_visual/ferramancy_hammer/Destroy()
	if(vis_holder && !QDELETED(vis_holder))
		vis_holder.vis_contents -= src
	vis_holder = null
	return ..()

/obj/effect/temp_visual/trap
	icon = 'icons/effects/effects.dmi'
	icon_state = "trap"
	light_outer_range = 2
	duration = 12
	layer = MASSIVE_OBJ_LAYER

/obj/effect/temp_visual/trap/ferramancy
	color = GLOW_COLOR_METAL
	light_color = GLOW_COLOR_METAL
	duration = 3 SECONDS

/obj/effect/temp_visual/blade_burst
	icon = 'icons/effects/wizard_spell_effects.dmi'
	icon_state = "grassblade"
	dir = NORTH
	name = "arcyne blade"
	desc = "Get out of the way!"
	randomdir = FALSE
	duration = 1 SECONDS
	layer = MASSIVE_OBJ_LAYER
