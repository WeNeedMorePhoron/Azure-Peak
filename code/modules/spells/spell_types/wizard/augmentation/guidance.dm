/datum/action/cooldown/spell/augment_buff/guidance
	name = "Guidance"
	desc = "Sharpens the senses with arcyne focus, honing the target's awareness. (+3 Perception)\nSuperseded by Hawk's Eyes - the two do not stack."
	button_icon_state = "guidance"

	invocations = list("Ducere")
	cooldown_time = 90 SECONDS

	point_cost = 1

/datum/action/cooldown/spell/augment_buff/guidance/cast(atom/cast_on)
	. = ..()
	var/mob/living/carbon/human/H = owner
	if(!istype(H))
		return FALSE

	if(!isliving(cast_on))
		to_chat(H, span_warning("That is not a valid target!"))
		return FALSE

	var/mob/living/spelltarget = cast_on

	if(spelltarget.has_status_effect(/datum/status_effect/buff/attune_hawk))
		to_chat(H, span_warning("Hawk's Eyes already sharpens [spelltarget == H ? "my" : "[spelltarget]'s"] senses - Guidance would do nothing."))
		H.balloon_alert(H, "superseded!")
		return FALSE

	if(spelltarget != H)
		H.visible_message("[H] mutters an incantation and [spelltarget] briefly shines orange.")
	else
		H.visible_message("[H] mutters an incantation and they briefly shine orange.")
	apply_buff_to(spelltarget, /datum/status_effect/buff/guidance, STAT_BUFF_SELF_DURATION)

	return TRUE
