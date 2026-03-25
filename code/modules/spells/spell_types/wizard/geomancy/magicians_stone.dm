/datum/action/cooldown/spell/magicians_stone
	button_icon = 'icons/mob/actions/mage_geomancy.dmi'
	name = "Magician's Stone"
	desc = "Tear a stone from the earth itself and materialize it into your hand."
	fluff_desc = "The predecessor of Magician's Brick. Likely one of the most ancient cantrip in existence. \
	Perhaps as old as the first magi witnessing another man cracking another's head open with a rock and imagined using magick to do the same. \
	Like Magician's Brick, it does not care about antimagic, so primal is the desire to hurl a rock at someone's head its magical version \
	is but an extension of humen will. Unlike Magician's Brick, it takes a long time to prepare a second spell, but also unlike it, the piece of rock conjured \
	is real and material. Luckily for quarries around the world, this spell is mindnumbingly inefficient at outpacing them for making stones." 
	button_icon_state = "magicians_stone"
	sound = 'sound/items/stonestone.ogg'
	spell_color = GLOW_COLOR_EARTHEN
	glow_intensity = GLOW_INTENSITY_LOW

	click_to_activate = FALSE
	self_cast_possible = TRUE

	primary_resource_type = SPELL_COST_STAMINA
	primary_resource_cost = SPELLCOST_CANTRIP

	invocations = list("Emerge, Lapis.")
	invocation_type = INVOCATION_SHOUT

	charge_required = FALSE
	cooldown_time = 3 MINUTES

	associated_skill = /datum/skill/magic/arcane
	spell_tier = 1
	spell_impact_intensity = SPELL_IMPACT_NONE

	point_cost = 1

	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC | SPELL_REQUIRES_HUMAN

/datum/action/cooldown/spell/magicians_stone/cast(atom/cast_on)
	. = ..()
	var/mob/living/user = owner
	if(!istype(user))
		return FALSE

	var/obj/item/natural/stone/S = new /obj/item/natural/stone(user.drop_location())

	owner.visible_message(span_notice("[owner] clenches [owner.p_their()] fist and a stone tears itself from the earth, materializing in [owner.p_their()] hand."), span_notice("I tear a stone from the earth itself."))

	if(!user.put_in_hands(S))
		owner.visible_message(span_notice("The stone falls to the ground at [owner.p_their()] feet."))

	return TRUE
