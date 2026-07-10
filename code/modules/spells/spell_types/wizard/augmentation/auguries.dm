/datum/augury
	var/name = "Augury"
	var/desc = ""
	var/icon_state = "guidanceneu"
	var/invocation = "Augmentum!"
	var/status_type
	var/duration = AUGURY_DURATION

/datum/augury/proc/play_on(mob/living/target, duration, ascended = FALSE)
	if(!ascended)
		strip_auguries(target)
	target.apply_status_effect(status_type, duration, ascended)

/proc/strip_auguries(mob/living/target)
	for(var/datum/status_effect/buff/B in target.status_effects)
		if(B.exclusive_group == AUGURY_GROUP)
			qdel(B)

/datum/augury/sure_strike
	name = "Sure Strike"
	desc = "The bearer's next strike bypasses parry and dodge."
	icon_state = "guidance"
	invocation = "Certa!"
	status_type = /datum/status_effect/buff/empowered_strike/augury

/datum/augury/might
	name = "Might"
	desc = "+3 Strength."
	icon_state = "giants_strength"
	invocation = "Robur!"
	status_type = /datum/status_effect/buff/augury/might

/datum/augury/hawks_mark
	name = "Hawk's Mark"
	desc = "+3 Perception."
	icon_state = "hawks_eyes"
	invocation = "Acies!"
	status_type = /datum/status_effect/buff/augury/hawks_mark

/datum/augury/fleetness
	name = "Fleetness"
	desc = "+2 Speed and swifter actions."
	icon_state = "haste"
	invocation = "Velocitas!"
	status_type = /datum/status_effect/buff/augury/fleetness

/datum/augury/bulwark
	name = "Bulwark"
	desc = "Blows against the bearer's armor are blunted."
	icon_state = "stoneskin"
	invocation = "Murus!"
	status_type = /datum/status_effect/buff/iron_skin/augury

/datum/augury/second_wind
	name = "Second Wind"
	desc = "Restores a burst of stamina and lightens the bearer's fatigue."
	icon_state = "longstrider"
	invocation = "Vigor!"
	status_type = /datum/status_effect/buff/augury/second_wind

/datum/augury/rush
	name = "Rush"
	desc = "Floods the bearer's blood - restores blood and stamina, dulls pain."
	icon_state = "blood_rush"
	invocation = "Sanguis!"
	status_type = /datum/status_effect/buff/adrenaline_rush/augury
	duration = 18 SECONDS // Matches the Blood Rush spell's payload - full augury uptime would obsolete its 50-energy cost

/datum/augury/foresight
	name = "Foresight"
	desc = "Cuts 15 seconds from the bearer's Defend and Special cooldowns. Does not displace an existing Augury."
	icon_state = "readomen"
	invocation = "Praevidere!"

// Foresight is instant - it neither lingers nor occupies the one-augury-per-person slot.
/datum/augury/foresight/play_on(mob/living/target, duration, ascended = FALSE)
	var/amount = ascended ? 30 SECONDS : 15 SECONDS
	var/hastened = FALSE
	hastened |= reduce_intent_cooldown(target, /datum/status_effect/debuff/clashcd, amount)
	hastened |= reduce_intent_cooldown(target, /datum/status_effect/debuff/specialcd, amount)
	var/obj/effect/temp_visual/origin_haste/V = new
	target.vis_contents += V
	if(hastened)
		target.balloon_alert_to_viewers("<font color='#66ffcc'>cooldowns -[amount / 10]s!</font>")
	else
		to_chat(target, span_notice("I glimpse the moments ahead, but there is nothing left to hasten."))

/datum/action/cooldown/spell/augury
	abstract_type = /datum/action/cooldown/spell/augury
	name = "Augury"
	desc = "Play the Augury drawn into this slot, applying it to yourself and every conduit-linked fellow in your sight for 22 seconds. \
	Both Augury slots share a cooldown - using one scatters both and two fresh Auguries are drawn once it ends.. \
	A person can bear only one Augury at a time.."
	button_icon = 'icons/mob/actions/mage_augmentation.dmi'
	button_icon_state = "guidanceneu"
	sound = 'sound/magic/haste.ogg'
	spell_color = GLOW_COLOR_BUFF
	glow_intensity = GLOW_INTENSITY_LOW
	attunement_school = ASPECT_NAME_AUGMENTATION

	click_to_activate = FALSE
	self_cast_possible = TRUE

	primary_resource_type = SPELL_COST_STAMINA
	primary_resource_cost = SPELLCOST_AUGURY

	invocation_type = INVOCATION_WHISPER

	charge_required = FALSE
	cooldown_time = AUGURY_HAND_COOLDOWN
	shared_cooldown = "augury_hand"

	associated_skill = /datum/skill/magic/arcane
	spell_tier = 2
	spell_impact_intensity = SPELL_IMPACT_NONE
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC | SPELL_REQUIRES_HUMAN | SPELL_REQUIRES_SAME_Z

	var/slot_label = "Augury"
	var/list/draw_pool = list(
		/datum/augury/sure_strike,
		/datum/augury/might,
		/datum/augury/hawks_mark,
		/datum/augury/fleetness,
		/datum/augury/bulwark,
		/datum/augury/second_wind,
		/datum/augury/rush,
		/datum/augury/foresight,
	)
	var/datum/augury/drawn_card
	/// Excluded from the next draw.
	var/last_drawn_type

/datum/action/cooldown/spell/augury/first
	slot_label = "Augury I"

/datum/action/cooldown/spell/augury/second
	slot_label = "Augury II"

/datum/action/cooldown/spell/augury/Destroy()
	QDEL_NULL(drawn_card)
	return ..()

/datum/action/cooldown/spell/augury/Grant(mob/grant_to)
	. = ..()
	if(!owner)
		return
	if(!drawn_card && next_use_time <= world.time)
		draw_card(silent = TRUE)

/datum/action/cooldown/spell/augury/CooldownEnded()
	. = ..()
	if(QDELETED(src) || QDELETED(owner))
		return
	if(next_use_time > world.time) // stale timer from an older, shorter cooldown
		return
	if(!drawn_card)
		draw_card()

/datum/action/cooldown/spell/augury/proc/draw_card(silent = FALSE)
	var/list/candidates = draw_pool.Copy()
	if(last_drawn_type && length(candidates) > 1)
		candidates -= last_drawn_type
	if(owner)
		for(var/datum/action/cooldown/spell/augury/slot in owner.actions)
			if(slot == src || !slot.drawn_card)
				continue
			if(length(candidates) > 1)
				candidates -= slot.drawn_card.type
	var/card_path = pick(candidates)
	QDEL_NULL(drawn_card)
	drawn_card = new card_path
	last_drawn_type = card_path
	name = "[slot_label]: [drawn_card.name]"
	button_icon_state = drawn_card.icon_state
	invocations = list(drawn_card.invocation)
	build_all_button_icons()
	if(!silent && owner)
		owner.balloon_alert(owner, "drawn: [lowertext(drawn_card.name)]!")

/datum/action/cooldown/spell/augury/proc/clear_card()
	QDEL_NULL(drawn_card)
	name = "[slot_label]: Reshuffling"
	button_icon_state = "guidanceneu"
	build_all_button_icons()

/datum/action/cooldown/spell/augury/can_cast_spell(feedback = TRUE)
	. = ..()
	if(!.)
		return FALSE
	if(!drawn_card)
		if(feedback)
			owner.balloon_alert(owner, "No augury drawn!")
		return FALSE
	return TRUE

/datum/action/cooldown/spell/augury/cast(atom/cast_on)
	. = ..()
	var/mob/living/carbon/human/H = owner
	if(!istype(H) || !drawn_card)
		return FALSE

	var/datum/augury/card = drawn_card
	var/list/receivers = list(H)
	var/datum/augment_conduit/conduit = get_augment_conduit(H)
	if(conduit)
		receivers |= conduit.get_receivers()

	for(var/mob/living/target in receivers)
		card.play_on(target, card.duration)
		if(target != H)
			H.Beam(target, icon_state = "b_beam", time = 1 SECONDS)

	for(var/datum/action/cooldown/spell/augury/slot in H.actions)
		slot.clear_card()
	return TRUE

/datum/action/cooldown/spell/augury/get_spell_statistics(mob/living/user)
	var/list/stats = ..()
	var/list/pool_names = list()
	for(var/datum/augury/card_path as anything in draw_pool)
		pool_names += initial(card_path.name)
	stats += span_info("Draw pool: [pool_names.Join(", ")]. Both slots draw from this pool - never the same Augury twice in a row, and never the same as the other slot.")
	stats += span_info("A person can have one Augury active at a time, the newest Augury replaces the last.")
	return stats
