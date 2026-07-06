/datum/food_recipe/dough/corn_wet
	name = "unfinished corn dough"
	base_item = /obj/item/reagent_containers/powder/flour/cornmeal
	ingredients = list(/datum/reagent/water = 10)
	result_type = /obj/item/reagent_containers/food/snacks/rogue/corndough_base
	extra_steps = list("knead it by hand (left click with an empty hand on)")
	hidden = TRUE
	book_category = FOOD_CAT_DOUGHS

/datum/food_recipe/dough/corn
	name = "corn dough"
	base_item = /obj/item/reagent_containers/food/snacks/rogue/corndough_base
	ingredients = list(
		/obj/item/reagent_containers/powder/flour/cornmeal
	)
	result_type = /obj/item/reagent_containers/food/snacks/rogue/corndough
	book_category = FOOD_CAT_DOUGHS
