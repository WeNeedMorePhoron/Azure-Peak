#define SCORCH_ADAPTATION_DURATION (10 SECONDS)
#define SCORCH_ADAPTATION_KEY "scorch_adaptation"
#define SCORCH_OVERLAY_COLOR rgb(255, 138, 61)

/obj/effect/temp_visual/scorch_flash
	icon = 'icons/mob/OnFire.dmi'
	icon_state = "Generic_mob_burning"
	layer = ABOVE_MOB_LAYER
	duration = 8

/proc/apply_scorch_stack(mob/living/target, stacks = 1)
	if(!isliving(target))
		return
	new /obj/effect/temp_visual/scorch_flash(get_turf(target))
	var/final_tier = 0
	for(var/i in 1 to stacks)
		if(target.has_status_effect(/datum/status_effect/debuff/scorched4))
			try_scorch_expose(target)
			final_tier = 4
			break
		if(target.has_status_effect(/datum/status_effect/debuff/scorched3))
			target.remove_status_effect(/datum/status_effect/debuff/scorched3)
			target.apply_status_effect(/datum/status_effect/debuff/scorched4)
			try_scorch_expose(target)
			final_tier = 4
			break
		if(target.has_status_effect(/datum/status_effect/debuff/scorched2))
			target.remove_status_effect(/datum/status_effect/debuff/scorched2)
			target.apply_status_effect(/datum/status_effect/debuff/scorched3)
			final_tier = 3
			continue
		if(target.has_status_effect(/datum/status_effect/debuff/scorched1))
			target.remove_status_effect(/datum/status_effect/debuff/scorched1)
			target.apply_status_effect(/datum/status_effect/debuff/scorched2)
			final_tier = 2
			continue
		target.apply_status_effect(/datum/status_effect/debuff/scorched1)
		final_tier = max(final_tier, 1)
	switch(final_tier)
		if(1)
			target.balloon_alert_to_viewers("<font color='#ff8a3d'>scorched I</font>")
		if(2)
			target.balloon_alert_to_viewers("<font color='#ff8a3d'>scorched II (-1 wil)</font>")
		if(3)
			target.balloon_alert_to_viewers("<font color='#ff8a3d'>scorched III (-2 wil)</font>")

/proc/try_scorch_expose(mob/living/target)
	if(!isliving(target))
		return FALSE
	if(target.mob_timers[SCORCH_ADAPTATION_KEY] && world.time < target.mob_timers[SCORCH_ADAPTATION_KEY])
		var/remaining = round((target.mob_timers[SCORCH_ADAPTATION_KEY] - world.time) / 10)
		target.balloon_alert_to_viewers("<font color='#ff8a3d'>fire adapted ([remaining]s)</font>")
		return FALSE
	target.apply_status_effect(/datum/status_effect/debuff/exposed)
	target.mob_timers[SCORCH_ADAPTATION_KEY] = world.time + SCORCH_ADAPTATION_DURATION
	target.balloon_alert_to_viewers("<font color='#ff4a2a'>SCORCHED - EXPOSED!</font>")
	playsound(get_turf(target), 'sound/misc/explode/incendiary (1).ogg', 100, TRUE)
	new /obj/effect/temp_visual/fire(get_turf(target))
	return TRUE

/proc/remove_scorch_stack(mob/living/target)
	if(!isliving(target))
		return FALSE
	if(target.has_status_effect(/datum/status_effect/debuff/scorched4))
		target.remove_status_effect(/datum/status_effect/debuff/scorched4)
		target.apply_status_effect(/datum/status_effect/debuff/scorched3)
		return TRUE
	if(target.has_status_effect(/datum/status_effect/debuff/scorched3))
		target.remove_status_effect(/datum/status_effect/debuff/scorched3)
		target.apply_status_effect(/datum/status_effect/debuff/scorched2)
		return TRUE
	if(target.has_status_effect(/datum/status_effect/debuff/scorched2))
		target.remove_status_effect(/datum/status_effect/debuff/scorched2)
		target.apply_status_effect(/datum/status_effect/debuff/scorched1)
		return TRUE
	if(target.has_status_effect(/datum/status_effect/debuff/scorched1))
		target.remove_status_effect(/datum/status_effect/debuff/scorched1)
		return TRUE
	return FALSE

/proc/has_scorch_stacks(mob/living/target)
	if(!isliving(target))
		return FALSE
	return get_scorch_stacks(target) > 0

/proc/get_scorch_stacks(mob/living/target)
	if(!isliving(target))
		return 0
	if(target.has_status_effect(/datum/status_effect/debuff/scorched4))
		return 4
	if(target.has_status_effect(/datum/status_effect/debuff/scorched3))
		return 3
	if(target.has_status_effect(/datum/status_effect/debuff/scorched2))
		return 2
	if(target.has_status_effect(/datum/status_effect/debuff/scorched1))
		return 1
	return 0

/proc/remove_all_scorch_stacks(mob/living/target)
	if(!isliving(target))
		return
	target.remove_status_effect(/datum/status_effect/debuff/scorched4)
	target.remove_status_effect(/datum/status_effect/debuff/scorched3)
	target.remove_status_effect(/datum/status_effect/debuff/scorched2)
	target.remove_status_effect(/datum/status_effect/debuff/scorched1)

/datum/status_effect/debuff/scorched1
	id = "scorched1"
	alert_type = /atom/movable/screen/alert/status_effect/debuff/scorched1
	duration = 25 SECONDS

/atom/movable/screen/alert/status_effect/debuff/scorched1
	name = "Scorched"
	desc = "Flames lick at me, but I can shake this off."
	icon_state = "debuff"

/datum/status_effect/debuff/scorched1/on_apply()
	. = ..()
	owner.add_atom_colour(SCORCH_OVERLAY_COLOR, TEMPORARY_COLOUR_PRIORITY)

/datum/status_effect/debuff/scorched1/on_remove()
	owner.remove_atom_colour(TEMPORARY_COLOUR_PRIORITY, SCORCH_OVERLAY_COLOR)
	. = ..()

/datum/status_effect/debuff/scorched2
	id = "scorched2"
	alert_type = /atom/movable/screen/alert/status_effect/debuff/scorched2
	duration = 25 SECONDS
	effectedstats = list(STATKEY_WIL = -1)

/atom/movable/screen/alert/status_effect/debuff/scorched2
	name = "Scorched II"
	desc = "The heat gnaws at my resolve."
	icon_state = "debuff"

/datum/status_effect/debuff/scorched2/on_apply()
	. = ..()
	owner.add_atom_colour(SCORCH_OVERLAY_COLOR, TEMPORARY_COLOUR_PRIORITY)

/datum/status_effect/debuff/scorched2/on_remove()
	owner.remove_atom_colour(TEMPORARY_COLOUR_PRIORITY, SCORCH_OVERLAY_COLOR)
	. = ..()

/datum/status_effect/debuff/scorched3
	id = "scorched3"
	alert_type = /atom/movable/screen/alert/status_effect/debuff/scorched3
	duration = 25 SECONDS
	effectedstats = list(STATKEY_WIL = -2)

/atom/movable/screen/alert/status_effect/debuff/scorched3
	name = "Scorched III"
	desc = "The burning fear saps my will to fight."
	icon_state = "debuff"

/datum/status_effect/debuff/scorched3/on_apply()
	. = ..()
	owner.add_atom_colour(SCORCH_OVERLAY_COLOR, TEMPORARY_COLOUR_PRIORITY)

/datum/status_effect/debuff/scorched3/on_remove()
	owner.remove_atom_colour(TEMPORARY_COLOUR_PRIORITY, SCORCH_OVERLAY_COLOR)
	. = ..()

/datum/status_effect/debuff/scorched4
	id = "scorched4"
	alert_type = /atom/movable/screen/alert/status_effect/debuff/scorched4
	duration = 25 SECONDS
	effectedstats = list(STATKEY_WIL = -2)

/atom/movable/screen/alert/status_effect/debuff/scorched4
	name = "Scorched IV"
	desc = "I am utterly consumed by flame - my defenses are wide open."
	icon_state = "debuff"

/datum/status_effect/debuff/scorched4/on_apply()
	. = ..()
	owner.add_atom_colour(SCORCH_OVERLAY_COLOR, TEMPORARY_COLOUR_PRIORITY)

/datum/status_effect/debuff/scorched4/on_remove()
	owner.remove_atom_colour(TEMPORARY_COLOUR_PRIORITY, SCORCH_OVERLAY_COLOR)
	. = ..()

#undef SCORCH_ADAPTATION_DURATION
#undef SCORCH_ADAPTATION_KEY
#undef SCORCH_OVERLAY_COLOR
