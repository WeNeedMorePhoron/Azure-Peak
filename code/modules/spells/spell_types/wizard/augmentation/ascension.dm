/datum/action/cooldown/spell/ascension
	name = "Ascension"
	desc = "The pinnacle of Augmentation. Channel every single Augury into one person at once, \ The effort strains your leyline, leaving it unready for a long while after. \
	Requires both Augury slots drawn and ready."
	button_icon = 'icons/mob/actions/mage_augmentation.dmi'
	button_icon_state = "stoneskin"
	sound = 'sound/magic/charging.ogg'
	spell_color = GLOW_COLOR_BUFF
	glow_intensity = GLOW_INTENSITY_VERY_HIGH
	attunement_school = ASPECT_NAME_AUGMENTATION

	click_to_activate = TRUE
	cast_range = SPELL_RANGE_GROUND
	self_cast_possible = TRUE

	primary_resource_type = SPELL_COST_STAMINA
	primary_resource_cost = 50
	secondary_resource_type = SPELL_COST_ENERGY
	secondary_resource_cost = 200

	invocations = list("Ascende, Ultra Omnia!")
	invocation_type = INVOCATION_SHOUT

	charge_required = TRUE
	weapon_cast_penalized = TRUE
	charge_time = CHARGETIME_MINOR
	charge_swingdelay_type = SWINGDELAY_PENALTY
	hold_drain = 1
	charge_slowdown = CHARGING_SLOWDOWN_MEDIUM
	charge_sound = 'sound/magic/charging.ogg'
	cooldown_time = 2 MINUTES

	associated_skill = /datum/skill/magic/arcane
	spell_impact_intensity = SPELL_IMPACT_HIGH
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC | SPELL_REQUIRES_HUMAN | SPELL_REQUIRES_SAME_Z

	var/hand_lockout = 60 SECONDS

/datum/action/cooldown/spell/ascension/proc/get_ready_slots()
	var/list/ready = list()
	for(var/datum/action/cooldown/spell/augury/slot in owner?.actions)
		if(slot.drawn_card && slot.next_use_time <= world.time)
			ready += slot
	return ready

/datum/action/cooldown/spell/ascension/can_cast_spell(feedback = TRUE)
	. = ..()
	if(!.)
		return FALSE
	if(length(get_ready_slots()) < 2)
		if(feedback)
			owner.balloon_alert(owner, "My hand is not ready!")
		return FALSE
	return TRUE

/datum/action/cooldown/spell/ascension/cast(atom/cast_on)
	. = ..()
	var/mob/living/carbon/human/H = owner
	if(!istype(H))
		return FALSE
	if(!isliving(cast_on))
		to_chat(H, span_warning("That is not a valid target!"))
		return FALSE
	var/list/ready_slots = get_ready_slots()
	if(length(ready_slots) < 2)
		to_chat(H, span_warning("My hand is not ready!"))
		return FALSE

	var/mob/living/target = cast_on
	strip_auguries(target)
	var/datum/action/cooldown/spell/augury/deck_source = ready_slots[1]
	for(var/card_path in deck_source.draw_pool)
		var/datum/augury/card = new card_path
		card.play_on(target, card.duration, ascended = TRUE)
		qdel(card)

	for(var/datum/action/cooldown/spell/augury/slot in H.actions)
		slot.clear_card()
		slot.StartCooldownSelf(hand_lockout)

	if(target != H)
		H.Beam(target, icon_state = "b_beam", time = 1.5 SECONDS)
	target.visible_message(span_warning("[target] radiates with overwhelming arcyne energy!"), \
		span_notice("Arcyne power surges through every fiber of my being!"))
	to_chat(H, span_notice("I channel the leyline's every omen into [target] - the full deck takes hold as one!"))
	new /obj/effect/temp_visual/spell_impact(get_turf(target), spell_color, spell_impact_intensity)
	return TRUE
