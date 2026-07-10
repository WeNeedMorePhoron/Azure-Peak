
/datum/action/cooldown/spell/minion_order/conjurer
	name = "Order Servants"
	desc = "Issue commands to your conjured servants - primordials, champions, and the like - within 12 tiles.<br>\
	<br>\
	Cast on a turf: order them to move there.<br>\
	Cast on yourself: recall them and set them to retaliate-only.<br>\
	Cast on an enemy: order them to attack that target.<br>\
	Cast on one of your servants: toggle its stance between retaliate-only and attack-all-strangers."
	button_icon = 'icons/mob/actions/mage_conjure.dmi'
	button_icon_state = "order_servants"
	spell_color = GLOW_COLOR_ARCANE
	associated_skill = /datum/skill/magic/arcane
	zizo_spell = FALSE

/datum/action/cooldown/spell/minion_mark
	button_icon = 'icons/mob/actions/mage_conjure.dmi'
	name = "Conjurer's Mark"
	desc = "Cast on someone to mark them friendly to your conjured servants, or strip an existing mark. \
	Cast on a tile to focus any nearby primordials' elemental power there."
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

/datum/action/cooldown/spell/minion_mark/cast(atom/cast_on)
	. = ..()
	var/mob/living/user = owner
	if(!istype(user))
		return FALSE
	var/faction_tag = "[user.mind.current.real_name]_faction"
	if(isliving(cast_on))
		var/mob/living/target = cast_on
		if(target == user)
			to_chat(user, span_warning("It would be unwise to make an enemy of your own conjured servants."))
			return FALSE
		if(HAS_TRAIT(target, TRAIT_CONJURED_SUMMON))
			to_chat(user, span_warning("[target] is already bound to another conjurer."))
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
