/datum/action/cooldown/spell/fire_curtain
	name = "Fire Curtain"
	desc = "Conjure a 1x5 curtain of flame at a target location, perpendicular to your facing. \
	The fire does not block movement but will burn anything that passes through or stands in it. \
	You are not immune to your own curtain."
	button_icon_state = "fireball_multi"
	sound = 'sound/magic/fireball.ogg'
	spell_color = GLOW_COLOR_FIRE
	glow_intensity = GLOW_INTENSITY_HIGH

	click_to_activate = TRUE
	cast_range = 7
	self_cast_possible = TRUE

	primary_resource_type = SPELL_COST_STAMINA
	primary_resource_cost = SPELLCOST_MAJOR_AOE

	invocations = list("Velum Ignis!")
	invocation_type = INVOCATION_SHOUT

	charge_required = TRUE
	charge_time = 1 SECONDS
	charge_drain = 1
	charge_slowdown = CHARGING_SLOWDOWN_MEDIUM
	charge_sound = 'sound/magic/charging_fire.ogg'
	cooldown_time = 30 SECONDS

	associated_skill = /datum/skill/magic/arcane

	var/curtain_width = 5
	var/hotspot_life = 10 SECONDS
	var/conjure_time = 2 SECONDS

/datum/action/cooldown/spell/fire_curtain/cast(atom/cast_on)
	. = ..()
	var/mob/living/carbon/human/H = owner
	if(!istype(H))
		return FALSE

	var/turf/center = get_turf(cast_on)
	if(!center)
		return FALSE

	var/list/affected_turfs = get_curtain_turfs(center, H.dir)

	for(var/turf/T in affected_turfs)
		new /obj/effect/temp_visual/trap_wall/fire(T)

	H.visible_message(span_danger("[H] begins to conjure a wall of flame!"))
	playsound(get_turf(H), 'sound/magic/charging_fire.ogg', 60, TRUE)

	if(!do_after(H, conjure_time, target = H))
		to_chat(H, span_warning("The conjuration is interrupted!"))
		return FALSE

	spawn_curtain(affected_turfs)

	H.visible_message(span_danger("[H] conjures a wall of flame!"))
	return TRUE

/datum/action/cooldown/spell/fire_curtain/proc/get_curtain_turfs(turf/center, facing)
	var/list/turfs = list(center)
	var/spread_dir1
	var/spread_dir2
	if(facing == NORTH || facing == SOUTH)
		spread_dir1 = WEST
		spread_dir2 = EAST
	else
		spread_dir1 = NORTH
		spread_dir2 = SOUTH

	var/half = (curtain_width - 1) / 2
	var/turf/current = center
	for(var/i in 1 to half)
		current = get_step(current, spread_dir1)
		if(current)
			turfs += current
	current = center
	for(var/i in 1 to half)
		current = get_step(current, spread_dir2)
		if(current)
			turfs += current
	return turfs

/datum/action/cooldown/spell/fire_curtain/proc/spawn_curtain(list/turfs)
	for(var/turf/T in turfs)
		new /obj/effect/hotspot(T, null, null, hotspot_life)
		new /obj/effect/temp_visual/fire(T)
	playsound(turfs[1], pick('sound/misc/explode/incendiary (1).ogg', 'sound/misc/explode/incendiary (2).ogg'), 120, TRUE, 6)

/obj/effect/temp_visual/trap_wall/fire
	color = GLOW_COLOR_FIRE
	light_color = GLOW_COLOR_FIRE
	duration = 2 SECONDS
