// Cryomancy shared — frost stack status effects and helper procs
// Three tiers: frosted1 (-1 SPD), frosted2 (-2 SPD), frosted3 (-3 SPD)
// Fire spells shatter frost stacks (countersynergy handled in fire spell on_hit procs)

#define FROST_OVERLAY_COLOR rgb(136, 191, 255)

/// Apply one frost stack to the target. Escalates frosted1 → frosted2 → frosted3.
/proc/apply_frost_stack(mob/living/target, stacks = 1)
	if(!isliving(target))
		return
	for(var/i in 1 to stacks)
		if(target.has_status_effect(/datum/status_effect/debuff/frosted3))
			// Already at max stacks, just refresh duration
			target.apply_status_effect(/datum/status_effect/debuff/frosted3)
			return
		if(target.has_status_effect(/datum/status_effect/debuff/frosted2))
			target.remove_status_effect(/datum/status_effect/debuff/frosted2)
			target.apply_status_effect(/datum/status_effect/debuff/frosted3)
			continue
		if(target.has_status_effect(/datum/status_effect/debuff/frosted1))
			target.remove_status_effect(/datum/status_effect/debuff/frosted1)
			target.apply_status_effect(/datum/status_effect/debuff/frosted2)
			continue
		target.apply_status_effect(/datum/status_effect/debuff/frosted1)

/// Decrement one frost stack from the target. Used by fire spells for countersynergy.
/// Returns TRUE if a stack was removed.
/proc/remove_frost_stack(mob/living/target)
	if(!isliving(target))
		return FALSE
	if(target.has_status_effect(/datum/status_effect/debuff/frosted3))
		target.remove_status_effect(/datum/status_effect/debuff/frosted3)
		target.apply_status_effect(/datum/status_effect/debuff/frosted2)
		return TRUE
	if(target.has_status_effect(/datum/status_effect/debuff/frosted2))
		target.remove_status_effect(/datum/status_effect/debuff/frosted2)
		target.apply_status_effect(/datum/status_effect/debuff/frosted1)
		return TRUE
	if(target.has_status_effect(/datum/status_effect/debuff/frosted1))
		target.remove_status_effect(/datum/status_effect/debuff/frosted1)
		return TRUE
	return FALSE

/// Check if the target has any frost stacks.
/proc/has_frost_stacks(mob/living/target)
	if(!isliving(target))
		return FALSE
	return target.has_status_effect(/datum/status_effect/debuff/frosted1) || \
		target.has_status_effect(/datum/status_effect/debuff/frosted2) || \
		target.has_status_effect(/datum/status_effect/debuff/frosted3)

// --- Status Effects ---

/datum/status_effect/debuff/frosted1
	id = "frosted1"
	alert_type = /atom/movable/screen/alert/status_effect/debuff/frosted1
	duration = 15 SECONDS
	effectedstats = list(STATKEY_SPD = -1)

/atom/movable/screen/alert/status_effect/debuff/frosted1
	name = "Frosted"
	desc = "A chill seeps into my bones."
	icon_state = "debuff"

/datum/status_effect/debuff/frosted1/on_apply()
	. = ..()
	var/mob/living/target = owner
	target.add_atom_colour(FROST_OVERLAY_COLOR, TEMPORARY_COLOUR_PRIORITY)
	target.update_vision_cone()

/datum/status_effect/debuff/frosted1/on_remove()
	var/mob/living/target = owner
	target.remove_atom_colour(TEMPORARY_COLOUR_PRIORITY, FROST_OVERLAY_COLOR)
	target.update_vision_cone()
	. = ..()

/datum/status_effect/debuff/frosted2
	id = "frosted2"
	alert_type = /atom/movable/screen/alert/status_effect/debuff/frosted2
	duration = 15 SECONDS
	effectedstats = list(STATKEY_SPD = -2)

/atom/movable/screen/alert/status_effect/debuff/frosted2
	name = "Frosted II"
	desc = "The cold bites deep. My movements are sluggish."
	icon_state = "debuff"

/datum/status_effect/debuff/frosted2/on_apply()
	. = ..()
	var/mob/living/target = owner
	target.add_atom_colour(FROST_OVERLAY_COLOR, TEMPORARY_COLOUR_PRIORITY)
	target.update_vision_cone()

/datum/status_effect/debuff/frosted2/on_remove()
	var/mob/living/target = owner
	target.remove_atom_colour(TEMPORARY_COLOUR_PRIORITY, FROST_OVERLAY_COLOR)
	target.update_vision_cone()
	. = ..()

/datum/status_effect/debuff/frosted3
	id = "frosted3"
	alert_type = /atom/movable/screen/alert/status_effect/debuff/frosted3
	duration = 15 SECONDS
	effectedstats = list(STATKEY_SPD = -3)

/atom/movable/screen/alert/status_effect/debuff/frosted3
	name = "Frosted III"
	desc = "Frozen to the bone. I can barely move."
	icon_state = "debuff"

/datum/status_effect/debuff/frosted3/on_apply()
	. = ..()
	var/mob/living/target = owner
	target.add_atom_colour(FROST_OVERLAY_COLOR, TEMPORARY_COLOUR_PRIORITY)
	target.update_vision_cone()

/datum/status_effect/debuff/frosted3/on_remove()
	var/mob/living/target = owner
	target.remove_atom_colour(TEMPORARY_COLOUR_PRIORITY, FROST_OVERLAY_COLOR)
	target.update_vision_cone()
	. = ..()

// Temp visuals

/obj/effect/temp_visual/trapice
	icon = 'icons/effects/effects.dmi'
	icon_state = "frost"
	light_outer_range = 2
	light_color = "#4cadee"
	duration = 11
	layer = MASSIVE_OBJ_LAYER

/obj/effect/temp_visual/snap_freeze
	icon = 'icons/effects/effects.dmi'
	icon_state = "shieldsparkles"
	name = "rippeling arcyne ice"
	desc = "Get out of the way!"
	randomdir = FALSE
	duration = 1 SECONDS
	layer = MASSIVE_OBJ_LAYER

#undef FROST_OVERLAY_COLOR
