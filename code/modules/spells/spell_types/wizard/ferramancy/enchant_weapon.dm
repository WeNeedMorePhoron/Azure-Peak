#define ENCHANT_DURATION 10 MINUTES
#define ENCHANT_DURATION_GOLD 200 MINUTES

/datum/action/cooldown/spell/enchant_weapon
	button_icon = 'icons/mob/actions/mage_ferramancy.dmi'
	name = "Enchant Weapon"
	desc = "Enchant a weapon of your choice in your hand or on the ground, replacing any existing enchantment. \n\
	The enchantment will last for 10 minutes, and will automatically refresh while within 10 tiles of the caster.\n\
	If the enchanter is holding a piece of gold ore in their hand, it will be consumed to enchant the weapon permanently (200 minutes).\n\
	An enchantment cannot be applied to an already enchanted weapon.\n\
	Force Blade: Increases the force of the weapon by 5.\n\
	Durability: Increases the integrity and max integrity of the weapon by 100."
	button_icon_state = "enchant_weapon"
	sound = 'sound/magic/whiteflame.ogg'
	spell_color = GLOW_COLOR_METAL
	glow_intensity = GLOW_INTENSITY_LOW

	click_to_activate = TRUE
	cast_range = 1
	self_cast_possible = FALSE

	primary_resource_type = SPELL_COST_STAMINA
	primary_resource_cost = SPELLCOST_CONJURE

	invocations = list("Incantare Arma!")
	invocation_type = INVOCATION_WHISPER

	charge_required = TRUE
	charge_time = 3 SECONDS
	charge_drain = 2
	charge_slowdown = CHARGING_SLOWDOWN_HEAVY
	charge_sound = 'sound/magic/charging.ogg'
	cooldown_time = 1 MINUTES

	associated_skill = /datum/skill/magic/arcane
	spell_tier = 2
	spell_impact_intensity = SPELL_IMPACT_NONE

	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC | SPELL_REQUIRES_HUMAN

/datum/action/cooldown/spell/enchant_weapon/cast(atom/cast_on)
	. = ..()
	var/mob/living/carbon/human/H = owner
	if(!istype(H))
		return FALSE

	if(!istype(cast_on, /obj/item/rogueweapon))
		to_chat(H, span_warning("That is not a valid target for enchantment! You need to enchant a weapon."))
		return FALSE

	var/obj/item/rogueweapon/target_weapon = cast_on
	var/obj/item/sacrifice

	var/list/enchant_types = list(
		"Force Blade" = FORCE_BLADE_ENCHANT,
		"Durability" = DURABILITY_ENCHANT
	)

	for(var/obj/item/I in H.held_items)
		if(istype(I, /obj/item/rogueore/gold))
			sacrifice = I

	var/enchant_type = input(H, "Select the type of enchantment you want to apply:", "Enchant Weapon") as anything in enchant_types
	if(!enchant_type)
		return FALSE
	enchant_type = enchant_types[enchant_type]

	var/enchant_duration = sacrifice ? ENCHANT_DURATION_GOLD : ENCHANT_DURATION
	if(sacrifice)
		qdel(sacrifice)
		to_chat(H, span_notice("I consume the gold to enchant [target_weapon] permanently."))

	if(target_weapon.GetComponent(/datum/component/enchanted_weapon))
		qdel(target_weapon.GetComponent(/datum/component/enchanted_weapon))
	target_weapon.AddComponent(/datum/component/enchanted_weapon, enchant_duration, TRUE, H, enchant_type)
	H.visible_message(span_notice("[H] enchants [target_weapon], enveloping it in a magical glow."))
	return TRUE

#undef ENCHANT_DURATION
#undef ENCHANT_DURATION_GOLD
