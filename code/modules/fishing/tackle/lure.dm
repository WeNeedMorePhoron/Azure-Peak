/// Checks if the bait is liked by the fish type or not. Returns a multiplier that affects the chance of catching it.
/obj/item/proc/check_bait(obj/item/reagent_containers/food/snacks/fish/fish)
	if(HAS_TRAIT(src, TRAIT_OMNI_BAIT))
		return 1
	var/catch_multiplier = 1

	var/list/properties = SSfishing.fish_properties[isfish(fish) ? fish.type : fish]
	//Bait matching likes doubles the chance
	var/list/fav_bait = properties[FISH_PROPERTIES_FAV_BAIT]
	for(var/bait_identifer in fav_bait)
		if(is_matching_bait(src, bait_identifer))
			catch_multiplier *= 2
	//Bait matching dislikes
	var/list/disliked_bait = properties[FISH_PROPERTIES_BAD_BAIT]
	for(var/bait_identifer in disliked_bait)
		if(is_matching_bait(src, bait_identifer))
			catch_multiplier *= 0.5
	return catch_multiplier

/obj/item/fishing/lure
	name = "fishing lure"
	desc = "A ball of something fish want, rolled to sit on a hook."
	icon = 'icons/roguetown/items/fishing.dmi'
	icon_state = "mixedbait"
	w_class = WEIGHT_CLASS_SMALL
	grid_width = 32
	grid_height = 32
	/**
	 * A list with two keys delimiting the spinning interval in which a mouse click has to be pressed while fishing.
	 * This is passed down to the fishing rod, and then to the lure during the minigame.
	 */
	var/spin_frequency = list(2 SECONDS, 3 SECONDS)
	var/consumable = FALSE

/obj/item/fishing/lure/Initialize(mapload)
	. = ..()
	add_traits(list(TRAIT_FISHING_BAIT, TRAIT_BAIT_ALLOW_FISHING_DUD, TRAIT_OMNI_BAIT), INNATE_TRAIT)
	if(!consumable)
		ADD_TRAIT(src, TRAIT_BAIT_UNCONSUMABLE, INNATE_TRAIT)
	RegisterSignal(src, COMSIG_ITEM_FISHING_ROD_SLOTTED, PROC_REF(on_fishingrod_slotted))
	RegisterSignal(src, COMSIG_ITEM_FISHING_ROD_UNSLOTTED, PROC_REF(on_fishingrod_unslotted))

/obj/item/fishing/lure/proc/on_fishingrod_slotted(datum/source, obj/item/fishingrod/rod, slot)
	SIGNAL_HANDLER
	rod.spin_frequency = spin_frequency

/obj/item/fishing/lure/proc/on_fishingrod_unslotted(datum/source, obj/item/fishingrod/rod, slot)
	SIGNAL_HANDLER
	rod.spin_frequency = null

///Called for every fish subtype by the fishing subsystem when initializing, to populate the list of fish that can be catched with this lure.
/obj/item/fishing/lure/proc/is_catchable_fish(obj/item/reagent_containers/food/snacks/fish/fish, list/fish_properties)
	return TRUE

/obj/item/fishing/lure/examine(mob/user)
	. = ..()
	. += span_info("It has to be spun with a frequency of [spin_frequency[1] * 0.1] to [spin_frequency[2] * 0.1] seconds while fishing.")
	if(HAS_TRAIT(user, TRAIT_EXPERT_FISHER))
		. += span_tinynotice("Thanks to your experience, you can examine it again to get a list of fish you can catch with it.")

///Check if the fish is in the list of catchable fish for this fishing lure. Return value is a multiplier.
/obj/item/fishing/lure/check_bait(obj/item/reagent_containers/food/snacks/fish/fish)
	var/multiplier = 0
	var/is_instance = istype(fish)
	var/list/fish_properties = SSfishing.fish_properties[is_instance ? fish.type : fish]
	if(is_type_in_list(src, fish_properties[FISH_PROPERTIES_FAV_BAIT]))
		multiplier += FISHING_LURE_FAVOURITE_WEIGHT
	if(is_instance)
		if(is_catchable_fish(fish, fish_properties))
			multiplier += FISHING_LURE_CATCHABLE_WEIGHT
	else if(fish in SSfishing.lure_catchables[type])
		multiplier += FISHING_LURE_CATCHABLE_WEIGHT
	return multiplier

/obj/item/fishing/lure/meat
	name = "red bait"
	desc = "A small amount of meat, rolled into a ball. Tends to attract eels."
	icon_state = "meatbait"
	icon = 'icons/roguetown/items/fishing.dmi'
	spin_frequency = list(2 SECONDS, 3 SECONDS)
	consumable = TRUE
	bait_flag = DISH_MEAT

/obj/item/fishing/lure/meat/is_catchable_fish(obj/item/reagent_containers/food/snacks/fish/fish, list/fish_properties)
	if(/datum/fish_trait/vegan in fish.fish_traits)
		return FALSE
	return TRUE

/obj/item/fishing/lure/meat/check_bait(obj/item/reagent_containers/food/snacks/fish/fish)
	var/multiplier = ..()
	if(multiplier <= 0)
		return multiplier

	if(/datum/fish_trait/carnivore in fish.fish_traits)
		multiplier *= FISHING_BAIT_RED_CARNIVORE_MULT

	return multiplier

/obj/item/fishing/lure/dough
	name = "doughy bait"
	desc = "A small amount of dough, rolled into a ball. Tends to attract carps."
	icon = 'icons/roguetown/items/food.dmi'
	icon_state = "doughslice"
	icon = 'icons/roguetown/items/food.dmi'
	spin_frequency = list(2 SECONDS, 3 SECONDS)
	consumable = TRUE
	bait_flag = DISH_BREAD

/obj/item/fishing/lure/dough/is_catchable_fish(obj/item/reagent_containers/food/snacks/fish/fish, list/fish_properties)
	if(/datum/fish_trait/carnivore in fish.fish_traits)
		return FALSE
	return TRUE

/obj/item/fishing/lure/dough/check_bait(obj/item/reagent_containers/food/snacks/fish/fish)
	var/multiplier = ..()
	if(multiplier <= 0)
		return multiplier

	if(/datum/fish_trait/vegan in fish.fish_traits)
		multiplier *= FISHING_BAIT_DOUGH_HERBIVORE_MULT

	return multiplier

/obj/item/fishing/lure/gray
	name = "gray bait"
	desc = "A small amount of dough and meat, rolled into a ball. Attracts a little bit of everything."
	icon_state = "mixedbait"
	icon = 'icons/roguetown/items/fishing.dmi'
	spin_frequency = list(2 SECONDS, 3 SECONDS)
	consumable = TRUE
	bait_flag = DISH_BREAD | DISH_MEAT

/obj/item/fishing/lure/speckled
	name = "speckled bait"
	desc = "A complex blend of meat, flour, and berries rolled into a ball. Its smell scares off smaller fish."
	icon = 'icons/roguetown/items/fishing.dmi'
	icon_state = "speckledbait"
	spin_frequency = list(2.5 SECONDS, 3.5 SECONDS)
	consumable = TRUE
	bait_flag = DISH_BREAD | DISH_MEAT | DISH_FRUIT

/obj/item/fishing/lure/speckled/is_catchable_fish(obj/item/reagent_containers/food/snacks/fish/fish, list/fish_properties)
	// Catches most things, excluding tiny fish
	if(fish.size < fish.average_size * 0.5)
		return FALSE
	return TRUE

/obj/item/fishing/lure/speckled/check_bait(obj/item/reagent_containers/food/snacks/fish/fish)
	var/multiplier = ..()
	if(multiplier <= 0)
		return multiplier

	if(fish.size < fish.average_size * 0.9)
		multiplier *= FISHING_BAIT_SPECKLED_SMALL_MULT

	return multiplier

/obj/item/fishing/lure/deluxe
	name = "enchanted bait"
	desc = "A ball of unknown ingredients, formulated by Abyssorian priests. Rarely catches something truly special."
	icon = 'icons/roguetown/items/fishing.dmi'
	icon_state = "deluxebait"
	spin_frequency = list(2 SECONDS, 3.5 SECONDS)
	consumable = TRUE

/obj/item/fishing/lure/deluxe/is_catchable_fish(obj/item/reagent_containers/food/snacks/fish/fish, list/fish_properties)
	return TRUE

/obj/item/fishing/lure/deluxe/check_bait(obj/item/reagent_containers/food/snacks/fish/fish)
	var/multiplier = ..()

	if(prob(FISHING_BAIT_ENCHANTED_CHANCE))
		multiplier *= FISHING_BAIT_ENCHANTED_MULT

	return multiplier
