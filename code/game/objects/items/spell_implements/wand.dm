/obj/item/rogueweapon/wand
	base_implement_name = "lesser wand"
	name = "lesser wand"
	desc = "A slender implement of carved wood tipped with a focus-gem. It channels the caster's attunement, empowering their staple spells. Light enough to wield alongside a shield."
	icon = 'icons/obj/items/wands.dmi'
	icon_state = "wand_lesser"
	lefthand_file = 'icons/obj/items/wands.dmi'
	righthand_file = 'icons/obj/items/wands.dmi'
	force = 5
	throwforce = 5
	w_class = WEIGHT_CLASS_SMALL
	slot_flags = ITEM_SLOT_HIP
	sharpness = IS_BLUNT
	can_parry = FALSE
	wlength = WLENGTH_SHORT
	wdefense = 1
	max_integrity = 80
	resistance_flags = FIRE_PROOF
	associated_skill = /datum/skill/magic/arcane
	possible_item_intents = list(SPEAR_BASH)
	sellprice = 34
	var/implement_tier = IMPLEMENT_TIER_LESSER
	var/implement_multiplier = IMPLEMENT_MULT_LESSER

/obj/item/rogueweapon/wand/greater
	base_implement_name = "greater wand"
	name = "greater wand"
	desc = "A well-crafted wand set with a quality focus-gem. It channels the caster's attunement with notable potency."
	icon_state = "wand_greater"
	max_integrity = 100
	sellprice = 42
	implement_tier = IMPLEMENT_TIER_GREATER
	implement_multiplier = IMPLEMENT_MULT_GREATER

/obj/item/rogueweapon/wand/grand
	base_implement_name = "grand wand"
	name = "grand wand"
	desc = "A masterwork wand crowned with a gem of extraordinary quality. It channels the caster's attunement with devastating efficiency."
	icon_state = "wand_grand"
	max_integrity = 120
	sellprice = 121
	implement_tier = IMPLEMENT_TIER_GRAND
	implement_multiplier = IMPLEMENT_MULT_GRAND

/obj/item/rogueweapon/wand/examine(mob/user)
	. = ..()
	if(implement_multiplier)
		. += span_notice("This implement empowers staple spells by [round((implement_multiplier - 1) * 100)]% when held.")

/obj/item/rogueweapon/wand/attune_implement(spell_color, spell_name)
	apply_attunement_glow(src, spell_color, implement_tier, spell_name)
