/proc/is_matching_bait(obj/item/bait, identifier)
	if(ispath(identifier)) //Just a path
		return istype(bait, identifier)
	if(!islist(identifier))
		return HAS_TRAIT(bait, identifier)
	var/list/special_identifier = identifier
	switch(special_identifier[FISH_BAIT_TYPE])
		if(FISH_BAIT_FOODTYPE)
			if(istype(bait, /obj/item/reagent_containers/food/snacks))
				var/obj/item/reagent_containers/food/snacks/food_bait = bait
				return food_bait.dish_type & special_identifier[FISH_BAIT_VALUE]
			else
				return bait.bait_flag & special_identifier[FISH_BAIT_VALUE]
		if(FISH_BAIT_REAGENT)
			return bait.reagents?.has_reagent(special_identifier[FISH_BAIT_VALUE], special_identifier[FISH_BAIT_AMOUNT], check_subtypes = TRUE)
		else
			CRASH("Unknown bait identifier in fish favourite/disliked list")
