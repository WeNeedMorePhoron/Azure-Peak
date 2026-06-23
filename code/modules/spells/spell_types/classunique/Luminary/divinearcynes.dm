/datum/action/cooldown/spell/selfbuff
	name = "Divine Arcynes"
	desc = "Improves your reflexes and wrap yourself with soothing light"
	button_icon_state = "guidance"
	sound = 'sound/magic/astrata_choir.ogg'
	glow_intensity = 0

	click_to_activate = FALSE

	primary_resource_cost = SPELL_COST_STAMINA

	secondary_resource_cost = SPELLCOST_UTILITY_BUFF

	invocations = list("Blessed Arcynes guide me true!")
	invocation_type = INVOCATION_SHOUT

	charge_required = FALSE
	cooldown_time = 4 MINUTES

	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC | SPELL_REQUIRES_HUMAN | SPELL_REQUIRES_SAME_Z

/datum/action/cooldown/spell/selfbuff/cast(atom/cast_on)
	. = ..()
	var/mob/living/carbon/human/H = owner
	H.apply_status_effect(/datum/status_effect/buff/song/fervor/lesser_guidance)
	H.apply_status_effect(/datum/status_effect/buff/healingaura)
	return TRUE

/atom/movable/screen/alert/status_effect/buff/song/fervor/lesser_guidance
	name = "Awakening"
	desc = "Arcyne quickens the Mynd. (+12% chance to bypass parry / dodge, +12% chance to parry / dodge)"
	icon_state = "buff"

/datum/status_effect/buff/song/fervor/lesser_guidance
	id = "guidance"
	alert_type = /atom/movable/screen/alert/status_effect/buff/song/fervor/lesser_guidance
	duration = 60 SECONDS

/datum/status_effect/buff/song/fervor/lesser_guidance/on_apply()
	. = ..()
	to_chat(owner, span_warning("Blessed Arcynes guides me true!"))

/datum/status_effect/buff/song/fervor/lesser_guidance/on_remove()
	. = ..()
	REMOVE_TRAIT(owner, TRAIT_LESSER_GUIDANCE, MAGIC_TRAIT)
	to_chat(owner, span_warning("Blessed Arcynes seeps out of my control!"))

/atom/movable/screen/alert/status_effect/buff/healingaura
	name = "Recovery"
	desc = "Holy light shoothes the Heart.(very low health regeneration effect)"
	icon_state = "buff"

/datum/status_effect/buff/healingaura

	id = "stoneskin"
	alert_type = /atom/movable/screen/alert/status_effect/buff/healingaura
	duration = 120 SECONDS
	var/healing_on_tick = 0.5

/datum/status_effect/buff/healingaura/tick()
	var/obj/effect/temp_visual/heal/H = new /obj/effect/temp_visual/heal_rogue(get_turf(owner))
	H.color = "#0abdbd"
	if(owner.blood_volume < BLOOD_VOLUME_OKAY)
		owner.blood_volume = min(owner.blood_volume+healing_on_tick, BLOOD_VOLUME_OKAY)
	var/list/wCount = owner.get_wounds()
	if(length(wCount))
		owner.heal_wounds(healing_on_tick, list(/datum/wound/slash, /datum/wound/puncture, /datum/wound/bite, /datum/wound/bruise, /datum/wound/dynamic, /datum/wound/dislocation))
		owner.update_damage_overlays()
	owner.adjustBruteLoss(-healing_on_tick, 0)
	owner.adjustFireLoss(-healing_on_tick, 0)
	owner.adjustOxyLoss(-healing_on_tick, 0)
	owner.adjustToxLoss(-healing_on_tick, 0)
	owner.adjustOrganLoss(ORGAN_SLOT_BRAIN, -healing_on_tick)
	owner.adjustCloneLoss(-healing_on_tick, 0)

