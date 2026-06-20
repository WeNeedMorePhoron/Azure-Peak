// Stable singleton instances of every craftable enchanting ritual, used by the
// arcane Commissioner as catalog line-keys. Built once at init like GLOB.trade_goods
// so posted orders keep a stable reference across catalog rebuilds.
GLOBAL_LIST_INIT(commission_enchant_rituals, init_commission_enchant_rituals())

/proc/init_commission_enchant_rituals()
	var/list/out = list()
	for(var/ritual_type in subtypesof(/datum/runeritual/enchanting))
		var/datum/runeritual/enchanting/RR = new ritual_type()
		if(RR.blacklisted || !length(RR.result_atoms))
			continue
		out += RR
	return out

/datum/escrow_order
	var/commissioner_name
	var/datum/weakref/commissioner_ref
	var/smith_name
	var/list/recipe_quantities = list()
	var/deposited = 0
	var/list/delivered_items = list()
	var/list/delivered_counts = list()
	/// reagent_type -> volume accumulated, for potion (reagent-volume) line goods.
	var/list/delivered_volume = list()
	var/status = "open"
	var/day_posted = 0
	var/day_claimed = 0
	var/commissioner_note = ""
	var/list/cached_required_counts
	var/list/cached_required_volumes
	var/list/cached_lines
	var/list/cached_materials

/datum/escrow_order/proc/label()
	var/list/parts = list()
	for(var/key in recipe_quantities)
		var/name_str
		if(istype(key, /datum/anvil_recipe))
			var/datum/anvil_recipe/AR = key
			name_str = AR.name
		else if(istype(key, /datum/crafting_recipe))
			var/datum/crafting_recipe/CR = key
			name_str = CR.name
		else if(istype(key, /datum/runeritual))
			var/datum/runeritual/RR = key
			name_str = RR.name
		else if(istype(key, /datum/trade_good))
			var/datum/trade_good/TG = key
			name_str = TG.name
		parts += "[name_str] x[recipe_quantities[key]]"
	return jointext(parts, ", ")

/datum/escrow_order/proc/required_result_counts()
	if(cached_required_counts)
		return cached_required_counts
	var/list/out = list()
	for(var/key in recipe_quantities)
		var/want = recipe_quantities[key]
		var/result_path
		if(istype(key, /datum/anvil_recipe))
			var/datum/anvil_recipe/AR = key
			result_path = AR.created_item
			want *= max(1, AR.createditem_num)
		else if(istype(key, /datum/crafting_recipe))
			var/datum/crafting_recipe/CR = key
			if(islist(CR.result))
				var/list/rl = CR.result
				if(length(rl))
					result_path = rl[1]
			else
				result_path = CR.result
		else if(istype(key, /datum/runeritual))
			var/datum/runeritual/RR = key
			if(length(RR.result_atoms))
				result_path = RR.result_atoms[1]
		else if(istype(key, /datum/trade_good))
			var/datum/trade_good/TG = key
			if(TG.item_type)
				result_path = TG.item_type
		if(!result_path)
			continue
		out[result_path] = (out[result_path] || 0) + want
	cached_required_counts = out
	return out

/datum/escrow_order/proc/required_reagent_volumes()
	if(cached_required_volumes)
		return cached_required_volumes
	var/list/out = list()
	for(var/key in recipe_quantities)
		if(!istype(key, /datum/trade_good))
			continue
		var/datum/trade_good/TG = key
		if(!TG.reagent_type || TG.required_volume <= 0)
			continue
		out[TG.reagent_type] = (out[TG.reagent_type] || 0) + (recipe_quantities[key] * TG.required_volume)
	cached_required_volumes = out
	return out

/datum/escrow_order/proc/is_fulfilled()
	var/list/needed = required_result_counts()
	var/list/needed_vol = required_reagent_volumes()
	if(!length(needed) && !length(needed_vol))
		return FALSE
	for(var/path in needed)
		if((delivered_counts[path] || 0) < needed[path])
			return FALSE
	for(var/rtype in needed_vol)
		if((delivered_volume[rtype] || 0) < needed_vol[rtype])
			return FALSE
	return TRUE

/datum/escrow_order/proc/try_accept_item(obj/item/I)
	// Reagent (potion) goods: accept any container carrying a wanted reagent, bank its
	// volume toward the requirement, and store the container for the commissioner to collect.
	var/list/needed_vol = required_reagent_volumes()
	if(length(needed_vol) && istype(I, /obj/item/reagent_containers))
		var/obj/item/reagent_containers/RC = I
		if(RC.reagents)
			for(var/rtype in needed_vol)
				if((delivered_volume[rtype] || 0) >= needed_vol[rtype])
					continue
				var/contained = RC.reagents.get_reagent_amount(rtype)
				if(contained <= 0)
					continue
				delivered_volume[rtype] = (delivered_volume[rtype] || 0) + contained
				delivered_items += I
				return TRUE
	if(I.max_integrity > 0 && I.obj_integrity < I.max_integrity * ESCROW_DURABILITY_FLOOR)
		return "damaged"
	var/list/needed = required_result_counts()
	for(var/path in needed)
		if(I.type != path)
			continue
		if((delivered_counts[path] || 0) < needed[path])
			delivered_counts[path] = (delivered_counts[path] || 0) + 1
			delivered_items += I
			return TRUE
	return FALSE
