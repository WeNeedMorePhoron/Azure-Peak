/obj/item/reagent_containers/food/snacks/fish
	/// Flags for fish variables that would otherwise be TRUE/FALSE
	var/fish_flags = FISH_FLAG_SHOW_IN_CATALOG

	/// Required fluid type for this fish to live.
	var/required_fluid_type = FISH_FLUID_FRESHWATER

	// Fishing related properties

	/**
	 * List of fish trait types, these may modify probabilty/difficulty depending on rod/user properties
	 * or dictate how the fish behaves or some of its qualities.
	 */
	var/list/fish_traits = list()

	/// path to datums that dictate how the fish moves during the fishing minigame
	var/fish_movement_type = /datum/fish_movement

	/// Base additive modifier to fishing difficulty
	var/fishing_difficulty_modifier = 0

	/**
	 * Bait identifiers that make catching this fish easier and more likely
	 * Bait identifiers: Path | Trait | list("Type"="Foodtype","Value"= dish_type flag like [DISH_MEAT])
	 */
	var/list/favorite_bait = list()

	/**
	 * Bait identifiers that make catching this fish harder and less likely
	 * Bait identifiers: Path | Trait | list("Type"="Foodtype","Value"= dish_type flag like [DISH_MEAT])
	 */
	var/list/disliked_bait = list()

	/// Size in centimeters. Null until update_size_and_weight is called. Number of fillets and w_class scale with it.
	var/size
	/// Average size for this fish type in centimeters. Will be used as gaussian distribution with 20% deviation for fishing, bought fish are always standard size
	var/average_size = 50
	/// Temporarily stores the new size of the fish from randomize_size_and_weight() to be used by update_size_weight() later, so that it can be deferred.
	var/temp_size
	/// The maximum size this fish can reach, calculated the first time update_size_and_weight() is called.
	var/maximum_size

	/// Weight in grams. Null until update_size_and_weight is called.
	var/weight
	/// Average weight for this fish type in grams
	var/average_weight = 1000
	/// Temporarily stores the new weight of the fish from randomize_size_and_weight() to be used by update_size_weight() later, so that it can be deferred.
	var/temp_weight
	/// The maximum weight this fish can reach, calculated the first time update_size_and_weight() is called.
	var/maximum_weight

	///The general deviation from the average weight and size this fish has in the wild
	var/weight_size_deviation = 0.2

	/**
	 * An identifier for this fish used to track progress for fish caught between rounds in
	 * a way that's resilient to repathing (and removing paths). Only catchable fish need it.
	 * Once set, the value shouldn't be changed, so don't make typos.
	 */
	var/fish_id
	///Used to redirect to another fish path so that catching this fish unlocks its entry instead.
	var/obj/item/reagent_containers/food/snacks/fish/fish_id_redirect_path

	var/matrix/base_transform

/**
 * This proc takes a base size, base weight and deviation arguments to generate new size and weight through a gaussian distribution (bell curve)
 * Mainly used to determinate the size and weight of caught fish.
 */
/obj/item/reagent_containers/food/snacks/fish/proc/randomize_size_and_weight(base_size = average_size, base_weight = average_weight, deviation = weight_size_deviation, update = TRUE)
	var/size_deviation = 0.4 * base_size
	temp_size = round(clamp(gaussian(base_size, size_deviation), average_size * 1/MAX_FISH_DEVIATION_COEFF, average_size * MAX_FISH_DEVIATION_COEFF))
	var/weight_deviation = 0.4 * base_weight
	temp_weight = round(clamp(gaussian(base_weight, weight_deviation), average_weight * 1/MAX_FISH_DEVIATION_COEFF, average_weight * MAX_FISH_DEVIATION_COEFF))
	set_max_size_and_weight(temp_size, temp_weight, force = TRUE)
	if(update)
		update_size_and_weight(temp_size, temp_weight)

	var/size_ratio = temp_size / average_size
	var/weight_ratio = temp_weight / average_weight

	// Scale the visual size based on actual size/weight vs average
	// Use average of size and weight ratios for balanced scaling
	var/scale_ratio = (size_ratio + weight_ratio) / 2

	// Clamp between 0.5x and 2.0x for reasonable visual range
	// A tiny fish (0.5x average) = 0.75 scale
	// A normal fish (1.0x average) = 1.0 scale
	// A huge fish (2.0x average) = 1.5 scale
	var/visual_scale = clamp(0.5 + (scale_ratio * 0.5), 0.5, 2.0)

	base_transform = matrix()
	base_transform.Scale(visual_scale)
	transform = base_transform

///Set the maximum size and weight a fish can reach from base size and weight args.
///Always updates if called from randomize_size_and_weight (force = TRUE), otherwise only sets if uninitialized.
/obj/item/reagent_containers/food/snacks/fish/proc/set_max_size_and_weight(base_size, base_weight, force = FALSE)
	if(!maximum_size || force)
		maximum_size = min(base_size * 2, average_size * MAX_FISH_DEVIATION_COEFF)
	if(!maximum_weight || force)
		maximum_weight = min(base_weight * 2, average_weight * MAX_FISH_DEVIATION_COEFF)

///Updates weight and size, along with weight class and number of fillets you can get.
/obj/item/reagent_containers/food/snacks/fish/proc/update_size_and_weight(new_size = average_size, new_weight = average_weight)
	if(!size)
		set_max_size_and_weight(new_size, new_weight)

	size = new_size

	switch(size)
		if(0 to FISH_SIZE_TINY_MAX)
			w_class = WEIGHT_CLASS_TINY
		if(FISH_SIZE_TINY_MAX to FISH_SIZE_SMALL_MAX)
			w_class = WEIGHT_CLASS_SMALL
		if(FISH_SIZE_SMALL_MAX to FISH_SIZE_NORMAL_MAX)
			w_class = WEIGHT_CLASS_NORMAL
		if(FISH_SIZE_NORMAL_MAX to FISH_SIZE_BULKY_MAX)
			w_class = WEIGHT_CLASS_BULKY
		if(FISH_SIZE_BULKY_MAX to INFINITY)
			w_class = WEIGHT_CLASS_HUGE

	weight = new_weight

	slices_num = max(round(size / average_size * initial(slices_num), 1), 1)

/obj/item/reagent_containers/food/snacks/fish/proc/apply_traits()
	var/list/potential_spontaneous_traits = GLOB.spontaneous_fish_traits[type]
	for(var/trait_type in potential_spontaneous_traits)
		if(!prob(potential_spontaneous_traits[trait_type]))
			continue
		var/datum/fish_trait/trait = GLOB.fish_traits[trait_type]
		if(length(fish_traits & trait.incompatible_traits))
			continue
		fish_traits |= trait_type

	for(var/fish_trait_type in fish_traits)
		var/datum/fish_trait/trait = GLOB.fish_traits[fish_trait_type]
		trait.apply_to_fish(src)

/obj/item/reagent_containers/food/snacks/fish/vv_edit_var(var_name, var_value)
	switch(var_name)
		if(NAMEOF(src, size))
			if(!isnum(var_value) || var_value == 0)
				return FALSE
			update_size_and_weight(var_value, weight)
		if(NAMEOF(src, weight))
			if(!isnum(var_value) || var_value == 0)
				return FALSE
			update_size_and_weight(size, var_value)
		else
			return ..()

	return TRUE

///Used to damage this fish while it's still alive. Prevents the fish from taking damage beyond the integrity_failure threshold
/obj/item/reagent_containers/food/snacks/fish/proc/damage_fish(amount)
	if(dead || amount <= 0)
		return
	take_damage(min(amount, obj_integrity - max_integrity * integrity_failure), sound_effect = FALSE, armor_penetration = 100)

/// fish dies when its integrity reaches 50%
/obj/item/reagent_containers/food/snacks/fish/obj_break(damage_flag)
	. = ..()
	deconstruct()
	SEND_SIGNAL(src, COMSIG_FISH_STATUS_CHANGED)
