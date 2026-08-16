/datum/container_craft/cooking
	abstract_type = /datum/container_craft/cooking
	category = "Pot"
	crafting_time = 60 SECONDS
	reagent_requirements = list(
		/datum/reagent/water = 30
	)
	craft_verb = "cooking for "
	required_container = /obj/item/reagent_containers/glass/bucket/pot
	cook_method = COOK_BOIL
	var/datum/reagent/created_reagent
	var/water_conversion = 1
	var/datum/pollutant/finished_smell
	///the amount we pollute
	var/pollute_amount = 600
	///our required boiling temperature
	var/required_chem_temp = 374
	///what we add for optionals ie chunks of
	var/wording_choice = "chunks of"
	cooking_sound = /datum/looping_sound/boilloop

/datum/container_craft/cooking/try_craft(obj/item/crafter, list/pathed_items, mob/initiator, datum/callback/on_craft_start, datum/callback/on_craft_failed)
	if(!crafter.reagents || crafter.reagents.chem_temp < required_chem_temp)
		return FALSE
	. = ..()

/datum/container_craft/cooking/check_failure(obj/item/crafter, mob/user)
	if(!crafter.reagents || crafter.reagents.chem_temp < required_chem_temp)
		return TRUE
	return FALSE

/datum/container_craft/cooking/get_real_time(atom/host, mob/user, estimated_multiplier)
	var/real_cooking_time = crafting_time * estimated_multiplier
	return round(real_cooking_time / get_cooktime_divisor(user?.get_skill_level(used_skill)))

/datum/container_craft/cooking/create_item(obj/item/crafter, mob/initiator, list/found_optional_requirements, list/found_optional_wildcards, list/found_optional_reagents, list/removing_items)
	if(created_reagent)
		var/turf/pot_turf = get_turf(crafter)
		var/datum/reagent/first = reagent_requirements[1]
		var/reagent_amount = reagent_requirements[first]

		for(var/j = 1 to output_amount)
			crafter.reagents.add_reagent(created_reagent, reagent_amount * water_conversion)

			after_craft(null, crafter, initiator, found_optional_requirements, found_optional_wildcards, found_optional_reagents, removing_items)
			if(finished_smell)
				pot_turf.pollute_turf(finished_smell, pollute_amount)
			SEND_SIGNAL(crafter, COMSIG_CONTAINER_CRAFT_COMPLETE, null)
		playsound(pot_turf, "bubbles", 30, TRUE)
	else
		..()

/datum/container_craft/cooking/after_craft(atom/created_output, obj/item/crafter, mob/initiator, list/found_optional_requirements, list/found_optional_wildcards, list/found_optional_reagents, list/removing_items)
	. = ..()
	var/datum/reagent/found_product = crafter.reagents.get_reagent(created_reagent)
	if(!found_product)
		return

	// Update reagent name with optional ingredients
	if(length(found_optional_wildcards))
		var/extra_string = " with [wording_choice] "
		var/extra_taste = "with hints of "
		var/first_ingredient = TRUE
		var/list/all_used_ingredients = list()
		for(var/wildcard_type in found_optional_wildcards)
			var/list/items = found_optional_wildcards[wildcard_type]
			for(var/obj/item/ingredient in items)
				all_used_ingredients += ingredient
		for(var/obj/item/ingredient in all_used_ingredients)
			if(first_ingredient)
				extra_string += ingredient.name
				extra_taste += ingredient.name
				first_ingredient = FALSE
			else
				extra_string += " and [ingredient.name]"
				extra_taste += " and [ingredient.name]"
		found_product.name += extra_string
		found_product.taste_description += extra_taste
		LAZYSET(found_product.data, "custom_name", found_product.name)
		LAZYSET(found_product.data, "custom_tastes", found_product.taste_description)

/datum/container_craft/cooking/announce_start(atom/crafter, mob/initiator, estimated_multiplier)
	if(QDELETED(crafter))
		return
	crafter.visible_message(span_notice("[crafter] begins to simmer."))

/datum/container_craft/cooking/announce_fail(atom/crafter, mob/initiator)
	if(QDELETED(crafter))
		return
	crafter.visible_message(span_warning("[crafter] goes off the boil."))

/datum/container_craft/cooking/extra_html()
	var/html
	var/datum/reagent/first = reagent_requirements[1]
	var/result_amount = reagent_requirements[first]
	if(water_conversion > 0)
		result_amount = CEILING((result_amount * water_conversion), 1)
	html += "[UNIT_FORM_STRING(result_amount)] of [initial(created_reagent.name)]<br>"
	return html
