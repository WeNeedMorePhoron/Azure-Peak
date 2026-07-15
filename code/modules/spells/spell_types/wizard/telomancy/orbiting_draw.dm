/datum/action/cooldown/spell/orbiting_draw
	button_icon = 'icons/mob/actions/mage_telomancy.dmi'
	name = "Orbiting Draw"
	desc = "Draw a flight of arcyne orbs into a warding orbit around yourself. Each blunts an incoming blow before winking out - when the last orb is spent, the ward is gone. Cast instantly on yourself."
	button_icon_state = "seeker_volley"
	sound = 'sound/magic/vlightning.ogg'
	spell_color = GLOW_COLOR_ARCANE
	glow_intensity = GLOW_INTENSITY_MEDIUM
	attunement_school = ASPECT_NAME_TELOMANCY

	click_to_activate = FALSE
	self_cast_possible = TRUE

	primary_resource_type = SPELL_COST_STAMINA
	primary_resource_cost = SPELLCOST_MINOR_AOE

	invocations = list("Orbis Custodit!")
	invocation_type = INVOCATION_SHOUT

	charge_required = FALSE
	cooldown_time = 25 SECONDS

	associated_skill = /datum/skill/magic/arcane
	spell_tier = 2
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC | SPELL_REQUIRES_HUMAN

	var/orb_count = 5

/datum/action/cooldown/spell/orbiting_draw/cast(atom/cast_on)
	. = ..()
	var/mob/living/carbon/human/H = owner
	if(!istype(H))
		return FALSE
	H.apply_status_effect(/datum/status_effect/buff/orbiting_draw, orb_count)
	return TRUE

/atom/movable/screen/alert/status_effect/buff/orbiting_draw
	name = "Orbiting Draw"
	desc = "Arcyne orbs circle me,ready to blunt a blow before it lands."
	icon_state = "buff"

/datum/status_effect/buff/orbiting_draw
	id = "orbiting_draw"
	duration = 30 SECONDS
	alert_type = /atom/movable/screen/alert/status_effect/buff/orbiting_draw
	var/orbs = 5
	var/list/orb_visuals

/datum/status_effect/buff/orbiting_draw/on_creation(mob/living/new_owner, count = 5)
	orbs = count
	return ..()

/datum/status_effect/buff/orbiting_draw/on_apply()
	. = ..()
	if(!.)
		return
	orb_visuals = list()
	owner.apply_status_effect(/datum/status_effect/buff/iron_skin, duration)
	RegisterSignal(owner, COMSIG_MOB_ITEM_BEING_ATTACKED, PROC_REF(on_struck))
	for(var/i in 1 to orbs)
		var/obj/effect/orbiting_draw_orb/orb = new(get_turf(owner))
		orb_visuals += orb
		orb.orbit(owner, 20, (i % 2), 18, 36, TRUE)
	owner.balloon_alert_to_viewers("<font color='[GLOW_COLOR_ARCANE]'>warded!</font>")

/datum/status_effect/buff/orbiting_draw/proc/on_struck(datum/source, mob/living/struck, mob/living/attacker, obj/item/weapon)
	SIGNAL_HANDLER
	deplete_orb()

/datum/status_effect/buff/orbiting_draw/proc/deplete_orb()
	orbs = max(0, orbs - 1)
	if(length(orb_visuals))
		var/obj/effect/spent = orb_visuals[length(orb_visuals)]
		orb_visuals -= spent
		if(!QDELETED(spent))
			animate(spent, alpha = 0, time = 2)
			QDEL_IN(spent, 2)
	if(orbs <= 0)
		owner.remove_status_effect(/datum/status_effect/buff/orbiting_draw)

/datum/status_effect/buff/orbiting_draw/on_remove()
	UnregisterSignal(owner, COMSIG_MOB_ITEM_BEING_ATTACKED)
	owner.remove_status_effect(/datum/status_effect/buff/iron_skin)
	for(var/obj/effect/orb in orb_visuals)
		if(!QDELETED(orb))
			qdel(orb)
	orb_visuals = null
	. = ..()

/obj/effect/orbiting_draw_orb
	name = "arcyne orb"
	icon = 'icons/obj/magic_projectiles.dmi'
	icon_state = "seeker_orb"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	light_color = GLOW_COLOR_ARCANE
	light_power = 2
	light_outer_range = 2
