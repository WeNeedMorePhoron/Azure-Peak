
/datum/crafting_recipe/roguetown/cooking/mix_taraxamint
	name = "Taraxacum-Mentha tea mix"
	display_category = ITEM_CAT_FOODSTUFF_PRESERVED
	reqs = list(
		/obj/item/alch/taraxacum = 1,
		/obj/item/alch/mentha = 1)
	result = /obj/item/reagent_containers/food/snacks/mix_taraxamint
	craftdiff = 1
	structurecraft = /obj/structure/table
	req_table = TRUE

/datum/crafting_recipe/roguetown/cooking/mix_utricasalvia
	name = "Utrica-Salvia tea mix"
	display_category = ITEM_CAT_FOODSTUFF_PRESERVED
	reqs = list(
		/obj/item/alch/urtica = 1,
		/obj/item/alch/salvia = 1)
	result = /obj/item/reagent_containers/food/snacks/mix_utricasalvia
	craftdiff = 1
	structurecraft = /obj/structure/table
	req_table = TRUE

/datum/crafting_recipe/roguetown/cooking/mix_sbiten
	name = "Sbiten Brick"
	display_category = ITEM_CAT_FOODSTUFF_PRESERVED
	reqs = list(
		/obj/item/reagent_containers/food/snacks/rogue/honey/spider = 1,
		/obj/item/reagent_containers/food/snacks/pumpkinspice = 1)
	result = /obj/item/reagent_containers/food/snacks/mix_sbiten
	craftdiff = 2 //requires more effort than just smash 2 herbs together
	structurecraft = /obj/structure/table
	req_table = TRUE

