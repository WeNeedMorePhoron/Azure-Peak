/datum/action/cooldown/spell/conjure_primordial
	button_icon = 'icons/mob/actions/mage_conjure.dmi'
	name = "Conjure Primordial"
	desc = "Conjure a Primordial to fight at your side. Toggle its element with Shift+G while the spell is selected: Flame, Water, or Air. \
	You can maintain only one at a time."
	button_icon_state = "conjure_primordial"
	sound = 'sound/magic/magnet.ogg'
	spell_color = GLOW_COLOR_ARCANE
	glow_intensity = GLOW_INTENSITY_MEDIUM
	attunement_school = ASPECT_NAME_CONJURATION

	click_to_activate = TRUE
	cast_range = SPELL_RANGE_GROUND

	primary_resource_type = SPELL_COST_STAMINA
	primary_resource_cost = SPELLCOST_CONJURE

	invocations = list("Exsurge, primordiale!")
	invocation_type = INVOCATION_SHOUT

	charge_required = TRUE
	charge_time = CHARGETIME_MAJOR
	hold_drain = 1
	charge_slowdown = CHARGING_SLOWDOWN_MEDIUM
	charge_sound = 'sound/magic/charging.ogg'
	cooldown_time = 45 SECONDS

	associated_skill = /datum/skill/magic/arcane
	spell_tier = 3
	spell_impact_intensity = SPELL_IMPACT_NONE
	point_cost = 6

	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC | SPELL_REQUIRES_HUMAN | SPELL_REQUIRES_SAME_Z

	var/max_primordials = 1
	var/list/conjured_mobs = list()
	var/current_mode = 1
	var/list/modes = list(
		list("name" = "Flame", "tag" = "FIRE", "path" = /mob/living/simple_animal/hostile/retaliate/rogue/primordial/fire, "color" = GLOW_COLOR_FIRE, "invocation" = "Exsurge, ignis!"),
		list("name" = "Water", "tag" = "WATER", "path" = /mob/living/simple_animal/hostile/retaliate/rogue/primordial/water, "color" = GLOW_COLOR_ICE, "invocation" = "Exsurge, unda!"),
		list("name" = "Air", "tag" = "AIR", "path" = /mob/living/simple_animal/hostile/retaliate/rogue/primordial/air, "color" = "#cfe8ff", "invocation" = "Exsurge, ventus!"),
	)

/datum/action/cooldown/spell/conjure_primordial/Grant(mob/grant_to)
	. = ..()
	apply_mode()

/datum/action/cooldown/spell/conjure_primordial/toggle_alt_mode(mob/user)
	current_mode = (current_mode % length(modes)) + 1
	apply_mode()
	to_chat(user, span_notice("[name]: [modes[current_mode]["name"]] Primordial."))
	return TRUE

/datum/action/cooldown/spell/conjure_primordial/proc/apply_mode()
	var/list/mode = modes[current_mode]
	invocations = list(mode["invocation"])
	update_mode_maptext()

/datum/action/cooldown/spell/conjure_primordial/proc/update_mode_maptext()
	var/list/mode = modes[current_mode]
	for(var/datum/hud/hud as anything in viewers)
		var/atom/movable/screen/movable/action_button/B = viewers[hud]
		var/atom/movable/screen/arc_maptext_holder/holder
		for(var/atom/movable/screen/arc_maptext_holder/existing in B.vis_contents)
			holder = existing
			break
		if(!holder)
			holder = new(B)
			B.vis_contents.Add(holder)
		holder.maptext = MAPTEXT(mode["tag"])
		holder.maptext_x = 5
		holder.color = mode["color"]

/datum/action/cooldown/spell/conjure_primordial/get_spell_statistics(mob/living/user)
	var/list/stats = ..()
	stats += span_info("Element (toggle with Shift+G): [modes[current_mode]["name"]]. Cycles Flame / Water / Air. You may hold only one primordial at a time.")
	return stats

/datum/action/cooldown/spell/conjure_primordial/cast(atom/cast_on)
	. = ..()
	var/mob/living/user = owner
	if(!istype(user))
		return FALSE

	if(istype(get_area(user), /area/rogue/indoors/ravoxarena))
		to_chat(user, span_userdanger("I reach for outer help, but something rebukes me! This challenge is only for me to overcome!"))
		return FALSE

	if(length(conjured_mobs) >= max_primordials)
		to_chat(user, span_warning("You can not possibly maintain your focus on any more primordials!"))
		return FALSE

	var/turf/T = get_turf(cast_on)
	if(!isopenturf(T) || T.is_blocked_turf())
		to_chat(user, span_warning("The targeted location is blocked. My summon fails to come forth."))
		return FALSE

	var/mob_path = modes[current_mode]["path"]
	var/mob/living/simple_animal/hostile/retaliate/rogue/primordial/conjured = new mob_path(T, user)
	conjured_mobs += conjured
	RegisterSignal(conjured, COMSIG_QDELETING, PROC_REF(remove_conjure))
	return TRUE

/datum/action/cooldown/spell/conjure_primordial/proc/remove_conjure(mob/living/simple_animal/hostile/retaliate/rogue/primordial/conjured)
	SIGNAL_HANDLER
	conjured_mobs -= conjured

/datum/action/cooldown/spell/minion_order/primordial
	name = "Order Primordial"
	desc = "Issue commands to your conjured primordials within 12 tiles.<br>\
	<br>\
	Cast on a turf: order them to move there.<br>\
	Cast on yourself: recall them and set them to retaliate-only.<br>\
	Cast on an enemy: order them to attack that target.<br>\
	Cast on your primordials: toggle its stance between retaliate-only and attack-all-strangers."
	button_icon = 'icons/mob/actions/mage_conjure.dmi'
	button_icon_state = "order_primordial"
	spell_color = GLOW_COLOR_ARCANE
	associated_skill = /datum/skill/magic/arcane
	zizo_spell = FALSE

/datum/action/cooldown/spell/primordialmark
	button_icon = 'icons/mob/actions/mage_conjure.dmi'
	name = "Primordial Mark"
	desc = "Cast on a tile to focus your nearby primordials' special ability there. \
	Cast on someone to mark them friendly to your primordials, or strip an existing mark."
	button_icon_state = "primordial_mark"
	sound = null
	spell_color = GLOW_COLOR_ARCANE
	glow_intensity = GLOW_INTENSITY_MEDIUM
	attunement_school = ASPECT_NAME_CONJURATION

	click_to_activate = TRUE
	cast_range = 7
	self_cast_possible = TRUE

	primary_resource_type = SPELL_COST_NONE
	cooldown_time = 15 SECONDS

	associated_skill = /datum/skill/magic/arcane
	spell_tier = 3
	spell_impact_intensity = SPELL_IMPACT_NONE
	point_cost = 0

	spell_requirements = SPELL_REQUIRES_HUMAN | SPELL_REQUIRES_SAME_Z

/datum/action/cooldown/spell/primordialmark/cast(atom/cast_on)
	. = ..()
	var/mob/living/user = owner
	if(!istype(user))
		return FALSE
	var/faction_tag = "[user.mind.current.real_name]_faction"
	if(isliving(cast_on))
		var/mob/living/target = cast_on
		if(target == user)
			to_chat(user, span_warning("It would be unwise to make an enemy of your own primordials."))
			return FALSE
		if(target.mind && target.mind.current)
			if(faction_tag in target.mind.current.faction)
				target.mind.current.faction -= faction_tag
				user.say("Hostis declaratus es.", language = /datum/language/common)
			else
				target.mind.current.faction += faction_tag
				user.say("Amicus declaratus es.", language = /datum/language/common)
				target.notify_faction_change()
		else if(istype(target, /mob/living/simple_animal))
			if(faction_tag in target.faction)
				target.faction -= faction_tag
				user.say("Hostis declaratus es.", language = /datum/language/common)
			else
				target.faction |= faction_tag
				user.say("Amicus declaratus es.", language = /datum/language/common)
				target.notify_faction_change()
		return TRUE
	else if(isturf(cast_on))
		var/turf/T = get_turf(cast_on)
		for(var/mob/living/simple_animal/hostile/retaliate/rogue/primordial/primordial in oview(3, T))
			if(faction_tag in primordial.faction)
				to_chat(user, "[primordial.name] will focus their ability on the marked tile!")
				primordial.ability(T, user)
		return TRUE
	return FALSE
