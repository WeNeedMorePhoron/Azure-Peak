/datum/action/cooldown/spell/conjure_boulder
	button_icon = 'icons/mob/actions/mage_geomancy.dmi'
	name = "Conjure Boulder"
	desc = "Tear a boulder from the earth and heft it in both hands as a weapon. It scales with your Arcyne Armament rather than raw strength, and lasts until a new one is summoned or the spell is forgotten. Deals blunt physical damage."
	button_icon_state = "conjure_boulder"
	sound = 'sound/foley/stone_scrape.ogg'
	spell_color = GLOW_COLOR_EARTHEN
	glow_intensity = GLOW_INTENSITY_LOW
	attunement_school = ASPECT_NAME_GEOMANCY

	click_to_activate = FALSE
	self_cast_possible = TRUE

	primary_resource_type = SPELL_COST_STAMINA
	primary_resource_cost = SPELLCOST_MINOR_PROJECTILE

	invocations = list("Arma me, Terra!")
	invocation_type = INVOCATION_SHOUT

	charge_required = FALSE
	cooldown_time = 30 SECONDS

	associated_skill = /datum/skill/magic/arcane
	spell_tier = 2
	spell_impact_intensity = SPELL_IMPACT_LOW

	point_cost = 2

	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC | SPELL_REQUIRES_HUMAN | SPELL_REQUIRES_SAME_Z

	var/obj/item/conjured_boulder = null

/datum/action/cooldown/spell/conjure_boulder/cast(atom/cast_on)
	. = ..()
	var/mob/living/user = owner
	if(!istype(user))
		return FALSE

	if(conjured_boulder)
		qdel(conjured_boulder)
	var/obj/item/natural/rock/conjured/R = new(user.drop_location())
	R.AddComponent(/datum/component/conjured_item, GLOW_COLOR_EARTHEN, FALSE, user, src)
	user.put_in_hands(R)
	conjured_boulder = R

	playsound(user, 'sound/foley/stone_scrape.ogg', 50, TRUE)
	user.visible_message(span_warning("A boulder tears itself from the earth into [user]'s grip."), span_notice("I heft a boulder from the earth itself."))
	return TRUE

/datum/action/cooldown/spell/conjure_boulder/Destroy()
	if(conjured_boulder)
		conjured_boulder.visible_message(span_warning("[conjured_boulder] crumbles back into loose earth!"))
		qdel(conjured_boulder)
	return ..()

/obj/item/natural/rock/conjured
	name = "boulder"
	desc = "A boulder torn whole from the earth and bound to the wielder's hands. Slow and unwieldy, but it hits like a landslide."
	force = 20
	force_wielded = 35
	wbalance = WBALANCE_HEAVY
	wdefense = 5
	can_parry = TRUE
	parrysound = list('sound/combat/parry/parrygen.ogg')
	max_integrity = 300
	minstr = 0
	associated_skill = /datum/skill/combat/arcyne
	possible_item_intents = list(/datum/intent/mace/strike)
	gripped_intents = list(/datum/intent/mace/strike/grand, /datum/intent/mace/smash/grand, /datum/intent/effect/daze)
	sellprice = 0
