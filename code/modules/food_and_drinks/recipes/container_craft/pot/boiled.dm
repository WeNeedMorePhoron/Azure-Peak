/datum/container_craft/cooking/boil
	abstract_type = /datum/container_craft/cooking/boil
	category = FOOD_CAT_BOILED
	crafting_time = 5 SECONDS
	reagent_requirements = list(
		/datum/reagent/water = 5
	)

	var/datum/pollutant/cooked_smell

/datum/container_craft/cooking/boil/after_craft(atom/created_output, obj/item/crafter, mob/initiator, list/removing_items)
	. = ..()
	if(cooked_smell)
		created_output.AddComponent(/datum/component/temporary_pollution_emission, cooked_smell, 20, 5 MINUTES)

	for(var/obj/item/reagent_containers/food/snacks/item in removing_items)
		item.initialize_cooked_food(created_output, 1)

/datum/container_craft/cooking/boil/noodles
	name = "Noodles"
	requirements = list(/obj/item/reagent_containers/food/snacks/rogue/eggdoughnoodles = 1)
	output = /obj/item/reagent_containers/food/snacks/rogue/noodles
	cooked_smell = /datum/pollutant/food/pasta

/datum/container_craft/cooking/boil/sheetnoodles
	name = "Sheet Noodles"
	requirements = list(/obj/item/reagent_containers/food/snacks/rogue/eggdoughsheetnoodles = 1)
	output = /obj/item/reagent_containers/food/snacks/rogue/sheetnoodles
	cooked_smell = /datum/pollutant/food/pasta
