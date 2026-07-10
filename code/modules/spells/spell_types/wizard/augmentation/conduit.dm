GLOBAL_LIST_EMPTY(augment_conduits)

/datum/augment_conduit
	var/mob/living/caster
	/// ally -> beam; null while out of range
	var/list/links = list()
	var/max_links = AUGMENT_CONDUIT_MAX_LINKS

/datum/augment_conduit/New(mob/living/new_caster)
	caster = new_caster
	GLOB.augment_conduits += src
	RegisterSignal(caster, COMSIG_PARENT_QDELETING, PROC_REF(on_caster_gone))
	RegisterSignal(caster, COMSIG_MOB_DEATH, PROC_REF(on_caster_gone))
	RegisterSignal(caster, COMSIG_MOVABLE_MOVED, PROC_REF(refresh_beams))

/datum/augment_conduit/Destroy()
	for(var/mob/living/ally in links)
		unlink(ally, silent = TRUE)
	if(caster)
		UnregisterSignal(caster, list(COMSIG_PARENT_QDELETING, COMSIG_MOB_DEATH, COMSIG_MOVABLE_MOVED))
	GLOB.augment_conduits -= src
	caster = null
	return ..()

/proc/get_augment_conduit(mob/living/M)
	for(var/datum/augment_conduit/conduit in GLOB.augment_conduits)
		if(conduit.caster == M)
			return conduit
	return null

/datum/augment_conduit/proc/on_caster_gone(datum/source)
	SIGNAL_HANDLER
	qdel(src)

/datum/augment_conduit/proc/on_ally_gone(mob/living/source)
	SIGNAL_HANDLER
	unlink(source)
	if(!length(links))
		qdel(src)

/datum/augment_conduit/proc/add_link(mob/living/ally)
	if(length(links) >= max_links)
		return FALSE
	if(ally in links)
		return FALSE
	links[ally] = null
	RegisterSignal(ally, COMSIG_PARENT_QDELETING, PROC_REF(on_ally_gone))
	RegisterSignal(ally, COMSIG_MOB_DEATH, PROC_REF(on_ally_gone))
	RegisterSignal(ally, COMSIG_MOVABLE_MOVED, PROC_REF(refresh_beams))
	refresh_beams()
	return TRUE

/datum/augment_conduit/proc/unlink(mob/living/ally, silent = FALSE)
	if(!(ally in links))
		return FALSE
	var/datum/beam/B = links[ally]
	if(B && !QDELETED(B))
		qdel(B)
	links -= ally
	UnregisterSignal(ally, list(COMSIG_PARENT_QDELETING, COMSIG_MOB_DEATH, COMSIG_MOVABLE_MOVED))
	if(!silent)
		if(caster && !QDELETED(caster))
			to_chat(caster, span_warning("My conduit to [ally] unravels."))
		if(!QDELETED(ally))
			to_chat(ally, span_warning("The arcyne conduit binding me unravels."))
	return TRUE

/// A beam qdels itself past maxdistance, so refreshing only ever re-creates.
/datum/augment_conduit/proc/refresh_beams(datum/source)
	SIGNAL_HANDLER
	if(!caster || QDELETED(caster))
		return
	for(var/mob/living/ally in links)
		var/datum/beam/B = links[ally]
		if(B && !QDELETED(B))
			continue
		links[ally] = null
		if(ally.stat == DEAD || ally.z != caster.z)
			continue
		if(get_dist(caster, ally) > AUGMENT_CONDUIT_RANGE)
			continue
		links[ally] = caster.Beam(ally, icon_state = "b_beam", time = INFINITY, maxdistance = AUGMENT_CONDUIT_RANGE + 1)

/datum/augment_conduit/proc/link_names()
	var/list/names = list()
	for(var/mob/living/ally in links)
		names += "[ally]"
	return english_list(names)

/datum/augment_conduit/proc/get_receivers()
	var/list/receivers = list()
	if(!caster || QDELETED(caster))
		return receivers
	for(var/mob/living/ally in links)
		if(ally.stat == DEAD)
			continue
		if(!(ally in view(AUGMENT_CONDUIT_RANGE, caster)))
			continue
		receivers += ally
	return receivers

/datum/action/cooldown/spell/augment_conduit_link
	name = "Conduit"
	desc = "Weave a visible arcyne conduit between yourself and a fellow of my fellowship. Augury you cast apply to every linked fellow in your sight, \
	Up to two conduits may be held at once; cast upon a linked fellow to sever their conduit, \
	or upon the ground to sever them all. The bond frays if either of you dies."
	button_icon = 'icons/mob/actions/mage_augmentation.dmi'
	button_icon_state = "mirror"
	sound = 'sound/magic/haste.ogg'
	spell_color = GLOW_COLOR_BUFF
	glow_intensity = GLOW_INTENSITY_LOW
	attunement_school = ASPECT_NAME_AUGMENTATION

	click_to_activate = TRUE
	cast_range = SPELL_RANGE_GROUND
	self_cast_possible = FALSE

	primary_resource_type = SPELL_COST_STAMINA
	primary_resource_cost = SPELLCOST_UTILITY_BUFF

	invocations = list("Vinculum.")
	invocation_type = INVOCATION_WHISPER

	charge_required = FALSE
	cooldown_time = 5 SECONDS

	associated_skill = /datum/skill/magic/arcane
	spell_tier = 2
	spell_impact_intensity = SPELL_IMPACT_NONE
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC | SPELL_REQUIRES_HUMAN | SPELL_REQUIRES_SAME_Z

/datum/action/cooldown/spell/augment_conduit_link/cast(atom/cast_on)
	. = ..()
	var/mob/living/carbon/human/H = owner
	if(!istype(H))
		return FALSE
	var/datum/augment_conduit/conduit = get_augment_conduit(H)
	if(!isliving(cast_on) || cast_on == H)
		if(!conduit || !length(conduit.links))
			to_chat(H, span_warning("I hold no conduits to sever."))
			return FALSE
		for(var/mob/living/ally in conduit.links)
			conduit.unlink(ally)
		qdel(conduit)
		return TRUE
	var/mob/living/target = cast_on
	if(!target.mind)
		to_chat(H, span_warning("Their mind is too simple to hold a conduit."))
		return FALSE

	if(conduit && (target in conduit.links))
		conduit.unlink(target)
		if(!length(conduit.links))
			qdel(conduit)
		return TRUE

	if(!shares_fellowship(H, target))
		to_chat(H, span_warning("[target] shares no fellowship with me!"))
		return FALSE

	if(!conduit)
		conduit = new(H)
	if(!conduit.add_link(target))
		to_chat(H, span_warning("I cannot hold more than [conduit.max_links] conduits - I am already bound to [conduit.link_names()]."))
		return FALSE

	H.visible_message(span_notice("[H] weaves a shimmering conduit of arcyne between themselves and [target]."), \
		span_notice("I weave a conduit to [target] - my conduits now bind [conduit.link_names()]."))
	to_chat(target, span_notice("An arcyne conduit binds me to [H] - their auguries will flow to me while I remain in their sight."))
	return TRUE
