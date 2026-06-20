// Catalog assembly, line-spec pricing/naming dispatch, and the guild-tunable
// material price table. Line specs are heterogeneous: anvil/crafting recipes
// (material-priced), enchanting rituals (tier-priced scrolls), and trade goods
// (base-priced potions). Each dispatch proc branches on the key type.

/obj/structure/roguemachine/escrow/proc/toggle_material_enabled(path)
	if(!path || path_is_excluded(path))
		return FALSE
	if(path in disabled_materials)
		disabled_materials -= path
	else
		disabled_materials += path
	rebuild_catalog()
	return TRUE

/obj/structure/roguemachine/escrow/proc/init_material_prices()
	material_prices = list()
	for(var/path in GLOB.material_baseline_prices)
		if(path_is_excluded_parent(path))
			continue
		var/baseline = GLOB.material_baseline_prices[path]
		if(baseline <= 0)
			continue
		material_prices[path] = max(1, round(baseline * PRICING_ENGINE_COMMISSIONER_MARKUP))
	derived_material_prices = list()
	for(var/path in GLOB.derived_sellprices)
		if(path in material_prices)
			continue
		if(path_is_excluded_parent(path))
			continue
		var/derived = GLOB.derived_sellprices[path]
		if(derived <= 0)
			continue
		derived_material_prices[path] = max(1, round(derived * PRICING_ENGINE_COMMISSIONER_MARKUP))

/obj/structure/roguemachine/escrow/proc/path_is_excluded_parent(path)
	if(!length(excluded_material_parents))
		return FALSE
	for(var/parent in excluded_material_parents)
		if(ispath(path, parent))
			return TRUE
	return FALSE

/obj/structure/roguemachine/escrow/proc/get_material_price(path)
	if(material_prices && (path in material_prices))
		return material_prices[path]
	if(derived_material_prices && (path in derived_material_prices))
		return derived_material_prices[path]
	return 0

/obj/structure/roguemachine/escrow/proc/has_material_price(path)
	if(material_prices && (path in material_prices))
		return TRUE
	if(derived_material_prices && (path in derived_material_prices))
		return TRUE
	return FALSE

/obj/structure/roguemachine/escrow/proc/rebuild_catalog()
	catalog = list()
	if(catalog_includes_recipes)
		var/anvil_allowed = !length(allowed_categories) || (ITEM_CAT_SMITHING_MISC in allowed_categories)
		for(var/datum/anvil_recipe/AR in GLOB.anvil_recipes)
			if(AR.hides_from_books || !AR.name || !AR.created_item || !AR.req_bar)
				continue
			if(!(AR.req_bar in material_prices))
				continue
			if(!anvil_allowed && !(AR.display_category in allowed_categories))
				continue
			if(recipe_uses_excluded_material(AR))
				continue
			if(recipe_uses_disabled_material(AR))
				continue
			catalog += AR
		for(var/datum/crafting_recipe/CR in GLOB.crafting_recipes)
			if(CR.hides_from_books || !CR.name || !CR.result || !CR.display_category)
				continue
			if(length(allowed_categories) && !(CR.display_category in allowed_categories))
				continue
			if(!recipe_has_only_raw_materials(CR))
				continue
			if(recipe_uses_excluded_material(CR))
				continue
			if(recipe_uses_disabled_material(CR))
				continue
			catalog += CR
	if(length(catalog_ritual_tiers))
		for(var/datum/runeritual/enchanting/RR in GLOB.commission_enchant_rituals)
			if(!(RR.tier in catalog_ritual_tiers))
				continue
			catalog += RR
	if(length(catalog_good_behaviors))
		for(var/good_id in GLOB.trade_goods)
			var/datum/trade_good/TG = GLOB.trade_goods[good_id]
			if(!(TG.behavior in catalog_good_behaviors))
				continue
			if(TG.base_price <= 0)
				continue
			catalog += TG
	if(has_materials)
		prune_unused_material_prices()
	dirty_catalog_view()

/obj/structure/roguemachine/escrow/proc/recipe_uses_disabled_material(datum/recipe)
	if(!length(disabled_materials))
		return FALSE
	if(istype(recipe, /datum/anvil_recipe))
		var/datum/anvil_recipe/AR = recipe
		if(AR.req_bar in disabled_materials)
			return TRUE
		if(islist(AR.additional_items))
			for(var/path in AR.additional_items)
				if(path in disabled_materials)
					return TRUE
	else if(istype(recipe, /datum/crafting_recipe))
		var/datum/crafting_recipe/CR = recipe
		if(islist(CR.reqs))
			for(var/path in CR.reqs)
				if(path in disabled_materials)
					return TRUE
	return FALSE

/obj/structure/roguemachine/escrow/proc/recipe_uses_excluded_material(datum/recipe)
	if(!length(excluded_materials) && !length(excluded_material_parents))
		return FALSE
	if(istype(recipe, /datum/anvil_recipe))
		var/datum/anvil_recipe/AR = recipe
		if(path_is_excluded(AR.req_bar))
			return TRUE
		if(islist(AR.additional_items))
			for(var/path in AR.additional_items)
				if(path_is_excluded(path))
					return TRUE
	else if(istype(recipe, /datum/crafting_recipe))
		var/datum/crafting_recipe/CR = recipe
		if(islist(CR.reqs))
			for(var/path in CR.reqs)
				if(path_is_excluded(path))
					return TRUE
	return FALSE

/obj/structure/roguemachine/escrow/proc/path_is_excluded(path)
	if(!path)
		return FALSE
	if(path in excluded_materials)
		return TRUE
	return path_is_excluded_parent(path)

/obj/structure/roguemachine/escrow/proc/recipe_has_only_raw_materials(datum/crafting_recipe/CR)
	if(!islist(CR.reqs) || !length(CR.reqs))
		return FALSE
	for(var/path in CR.reqs)
		if(!has_material_price(path))
			return FALSE
	return TRUE

/obj/structure/roguemachine/escrow/proc/prune_unused_material_prices()
	var/list/used = list()
	for(var/datum/R in catalog)
		if(istype(R, /datum/anvil_recipe))
			var/datum/anvil_recipe/AR = R
			if(AR.req_bar)
				used[AR.req_bar] = TRUE
			if(islist(AR.additional_items))
				for(var/path in AR.additional_items)
					used[path] = TRUE
		else if(istype(R, /datum/crafting_recipe))
			var/datum/crafting_recipe/CR = R
			if(islist(CR.reqs))
				for(var/path in CR.reqs)
					used[path] = TRUE
	for(var/path in material_prices.Copy())
		if(path in disabled_materials)
			continue
		if(!(path in used))
			material_prices -= path

/obj/structure/roguemachine/escrow/proc/dirty_catalog_view()
	catalog_view_dirty = TRUE
	update_static_data_for_all_viewers()

/obj/structure/roguemachine/escrow/proc/rebuild_catalog_view()
	var/list/catalog_data = list()
	var/list/cats = list()
	var/list/ingots = list()
	for(var/datum/R in catalog)
		var/cat = recipe_category(R)
		if(!(cat in cats))
			cats += cat
		var/primary_ingot = recipe_primary_ingot(R)
		var/ingot_name = ""
		if(primary_ingot)
			var/atom/AP = primary_ingot
			ingot_name = initial(AP.name)
			if(!(ingot_name in ingots))
				ingots += ingot_name
		catalog_data += list(list(
			"ref" = "\ref[R]",
			"name" = recipe_name(R),
			"category" = cat,
			"price" = recipe_price(R),
			"ingot" = ingot_name,
			"materials" = recipe_materials(R),
		))
	cached_catalog_data = catalog_data
	cached_categories = cats
	cached_ingots = ingots
	catalog_view_dirty = FALSE

/obj/structure/roguemachine/escrow/proc/recipe_name(datum/recipe)
	if(istype(recipe, /datum/anvil_recipe))
		var/datum/anvil_recipe/AR = recipe
		return AR.name
	if(istype(recipe, /datum/runeritual))
		var/datum/runeritual/RR = recipe
		if(length(RR.result_atoms))
			var/atom/A = RR.result_atoms[1]
			return initial(A.name)
		return RR.name
	if(istype(recipe, /datum/trade_good))
		var/datum/trade_good/TG = recipe
		return TG.name
	var/datum/crafting_recipe/CR = recipe
	return CR.name

/obj/structure/roguemachine/escrow/proc/recipe_category(datum/recipe)
	if(istype(recipe, /datum/anvil_recipe))
		var/datum/anvil_recipe/AR = recipe
		return AR.display_category || ITEM_CAT_SMITHING_MISC
	if(istype(recipe, /datum/crafting_recipe))
		var/datum/crafting_recipe/CR = recipe
		return CR.display_category || ITEM_CAT_MISCELLANEOUS
	if(istype(recipe, /datum/runeritual))
		return ITEM_CAT_MAGICAL
	if(istype(recipe, /datum/trade_good))
		var/datum/trade_good/TG = recipe
		if(TG.behavior == TRADE_BEHAVIOR_POTION)
			return ITEM_CAT_POTION
		return TG.display_category || TG.category || ITEM_CAT_MISCELLANEOUS
	return ITEM_CAT_SMITHING_MISC

/obj/structure/roguemachine/escrow/proc/recipe_primary_ingot(datum/recipe)
	if(istype(recipe, /datum/anvil_recipe))
		var/datum/anvil_recipe/AR = recipe
		return AR.req_bar
	if(istype(recipe, /datum/crafting_recipe))
		var/datum/crafting_recipe/CR = recipe
		if(!islist(CR.reqs))
			return null
		var/best_path
		var/best_qty = 0
		for(var/path in CR.reqs)
			if(!(path in material_prices))
				continue
			var/qty = CR.reqs[path]
			if(qty > best_qty)
				best_qty = qty
				best_path = path
		return best_path
	return null

/obj/structure/roguemachine/escrow/proc/recipe_material_cost(datum/recipe)
	var/total = 0
	if(istype(recipe, /datum/anvil_recipe))
		var/datum/anvil_recipe/AR = recipe
		total += get_material_price(AR.req_bar)
		if(islist(AR.additional_items))
			for(var/path in AR.additional_items)
				total += get_material_price(path)
	else if(istype(recipe, /datum/crafting_recipe))
		var/datum/crafting_recipe/CR = recipe
		if(islist(CR.reqs))
			for(var/path in CR.reqs)
				total += get_material_price(path) * CR.reqs[path]
	return total

/obj/structure/roguemachine/escrow/proc/recipe_materials(datum/recipe)
	// Potion goods aren't crafted from item materials - show the reagent they must hold.
	if(istype(recipe, /datum/trade_good))
		var/datum/trade_good/TG = recipe
		if(TG.reagent_type)
			var/datum/reagent/RG = TG.reagent_type
			return list(list("name" = "[initial(RG.name)] ([TG.required_volume]dr)", "qty" = 1))
		return list()
	var/list/tally = list()
	if(istype(recipe, /datum/anvil_recipe))
		var/datum/anvil_recipe/AR = recipe
		if(AR.req_bar)
			tally[AR.req_bar] = (tally[AR.req_bar] || 0) + 1
		if(islist(AR.additional_items))
			for(var/path in AR.additional_items)
				tally[path] = (tally[path] || 0) + 1
	else if(istype(recipe, /datum/crafting_recipe))
		var/datum/crafting_recipe/CR = recipe
		if(islist(CR.reqs))
			for(var/path in CR.reqs)
				tally[path] = (tally[path] || 0) + CR.reqs[path]
	else if(istype(recipe, /datum/runeritual))
		var/datum/runeritual/RR = recipe
		if(islist(RR.required_atoms))
			for(var/path in RR.required_atoms)
				tally[path] = (tally[path] || 0) + RR.required_atoms[path]
	var/list/sorted_paths = list()
	for(var/path in tally)
		var/qty = tally[path]
		var/inserted = FALSE
		for(var/i in 1 to length(sorted_paths))
			if(tally[sorted_paths[i]] < qty)
				sorted_paths.Insert(i, path)
				inserted = TRUE
				break
		if(!inserted)
			sorted_paths += path
	var/list/out = list()
	for(var/path in sorted_paths)
		var/atom/A = path
		out += list(list(
			"name" = initial(A.name),
			"qty" = tally[path],
		))
	return out

/// The pre-margin worth of a line item. Material cost for recipes; an explicit base
/// price for goods that are not material-derived (scrolls priced by tier, potions by
/// their trade-good base price).
/obj/structure/roguemachine/escrow/proc/recipe_base_value(datum/recipe)
	if(istype(recipe, /datum/runeritual))
		var/datum/runeritual/RR = recipe
		return ritual_tier_price(RR.tier)
	if(istype(recipe, /datum/trade_good))
		var/datum/trade_good/TG = recipe
		return TG.base_price || 0
	return recipe_material_cost(recipe)

/obj/structure/roguemachine/escrow/proc/ritual_tier_price(tier)
	switch(tier)
		if(1)
			return SELLPRICE_ENCHSCROLL_BASIC
		if(2)
			return SELLPRICE_ENCHSCROLL_SUPERIOR
		if(3)
			return SELLPRICE_ENCHSCROLL_GREATER
		if(4)
			return SELLPRICE_ENCHSCROLL_GREATER * 2
	return 0

/obj/structure/roguemachine/escrow/proc/recipe_price(datum/recipe)
	var/base = recipe_base_value(recipe)
	return round(base * (1 + percent_margin / 100)) + flat_margin

/obj/structure/roguemachine/escrow/proc/is_priority_material(path)
	for(var/parent in priority_material_types)
		if(ispath(path, parent))
			return TRUE
	return FALSE
