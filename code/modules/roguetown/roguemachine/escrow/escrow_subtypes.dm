// Per-guild Commissioner variants. Each swaps the catalog source and keycontrol;
// the base machine handles smithing/engineering recipes.

/obj/structure/roguemachine/escrow/tailor
	name = "TAILORING COMMISSIONER"
	desc = "A brass-plated commission board for the weavers' and tailors' guild. Coin held in escrow until the work is delivered."
	keycontrol = list("tailor", "crafterguild", "craftermaster")
	allowed_categories = list(
		ITEM_CAT_GARMENT_COMMON,
		ITEM_CAT_GARMENT_FINE,
		ITEM_CAT_TAILOR_MISC,
		ITEM_CAT_CLOTH_MASK,
		ITEM_CAT_ARMOR_LIGHT,
		ITEM_CAT_ARMOR_HELMETS,
		ITEM_CAT_ARMOR_CHESTPIECES,
		ITEM_CAT_ARMOR_LEGS,
		ITEM_CAT_ARMOR_NECK,
		ITEM_CAT_ARMOR_BOOTS,
		ITEM_CAT_ARMOR_GLOVES,
		ITEM_CAT_ARMOR_BRACERS,
		ITEM_CAT_ARMOR_BELTS,
		ITEM_CAT_ARMOR_BARDING,
	)
	group_order = list("Garments", "Armor", "Other")
	priority_material_types = list(
		/obj/item/natural/hide,
		/obj/item/natural/silk,
		/obj/item/natural/cloth,
		/obj/item/natural/fibers,
		/obj/item/natural/fur,
	)
	default_disabled_materials = list()
	excluded_material_parents = list(
		/obj/item/ingot,
		/obj/item/roguegear,
	)

/obj/structure/roguemachine/escrow/tailor/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("This commissioner accepts tailoring and garment work only.")

/obj/structure/roguemachine/escrow/arcane
	name = "ARCANE COMMISSIONER"
	desc = "A brass-plated commission board sigil-etched for the mages' circle. Coin held in escrow until the enchanted scrolls are delivered."
	keycontrol = list("mage")
	catalog_includes_recipes = FALSE
	catalog_ritual_tiers = list(1, 2, 3)
	has_materials = FALSE
	group_order = list("Magical", "Other")

/obj/structure/roguemachine/escrow/arcane/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("This commissioner accepts specific enchantment scrolls. Pay is the scroll's worth plus the guild's margin; a mage claims the order and delivers the finished scroll to collect.")

/obj/structure/roguemachine/escrow/alchemist
	name = "ALCHEMICAL COMMISSIONER"
	desc = "A brass-plated commission board racked with empty vials for the apothecaries' guild. Coin held in escrow until the potions are delivered."
	keycontrol = list("apothecary")
	catalog_includes_recipes = FALSE
	catalog_good_behaviors = list(TRADE_BEHAVIOR_POTION)
	has_materials = FALSE
	group_order = list("Potions", "Other")

/obj/structure/roguemachine/escrow/alchemist/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("This commissioner accepts potions. Deliver any container holding enough of the requested brew - it is measured by volume and handed to the commissioner on collection.")
