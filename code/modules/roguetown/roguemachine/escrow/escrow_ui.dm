// tgui backend for the "Commissioner" interface: static catalog/material payload,
// dynamic per-user manifest/order payload, and the act handler that routes panel input.

/obj/structure/roguemachine/escrow/ui_static_data(mob/user)
	var/list/data = list()
	if(catalog_view_dirty || isnull(cached_catalog_data))
		rebuild_catalog_view()
	data["catalog"] = cached_catalog_data
	data["categories"] = cached_categories
	data["ingots"] = cached_ingots
	data["group_order"] = group_order
	data["percent_margin"] = percent_margin
	data["flat_margin"] = flat_margin
	data["item_cap_per_order"] = item_cap_per_order
	data["has_materials"] = has_materials ? TRUE : FALSE

	var/list/materials_data = list()
	if(has_materials)
		for(var/path in material_prices)
			var/atom/A = path
			materials_data += list(list(
				"path" = "[path]",
				"name" = initial(A.name),
				"price" = material_prices[path],
				"priority" = is_priority_material(path) ? TRUE : FALSE,
				"enabled" = (path in disabled_materials) ? FALSE : TRUE,
			))
	data["materials"] = materials_data
	return data

/// Build the parts of an order's UI payload that never change after posting.
/obj/structure/roguemachine/escrow/proc/build_order_cache(datum/escrow_order/O)
	var/list/order_lines = list()
	var/list/mat_tally = list()
	for(var/datum/R in O.recipe_quantities)
		var/recipe_qty = O.recipe_quantities[R]
		order_lines += list(list(
			"name" = recipe_name(R),
			"qty" = recipe_qty,
		))
		for(var/list/m in recipe_materials(R))
			mat_tally[m["name"]] = (mat_tally[m["name"]] || 0) + (m["qty"] * recipe_qty)
	var/list/order_materials = list()
	for(var/mname in mat_tally)
		order_materials += list(list(
			"name" = mname,
			"qty" = mat_tally[mname],
		))
	O.cached_lines = order_lines
	O.cached_materials = order_materials

/obj/structure/roguemachine/escrow/ui_data(mob/user)
	prune_expired_orders()
	var/list/data = list()
	data["can_read"] = (ishuman(user) && user.can_read(src, TRUE)) ? TRUE : FALSE
	data["is_guildmaster"] = is_guild_member(user) ? TRUE : FALSE
	var/user_key = escrow_key(user)
	data["budget"] = budget
	data["my_deposit"] = (user_key && manifest_deposits[user_key]) || 0
	data["my_manifest_items"] = user_key ? manifest_item_count(user_key) : 0
	data["has_active_order"] = (user_key && has_active_order(user_key)) ? TRUE : FALSE
	data["ping_enabled"] = ping_enabled ? TRUE : FALSE
	data["open_order_count"] = count_open_orders()

	var/list/manifest_data = list()
	var/list/cart = user_key ? manifests[user_key] : null
	var/manifest_total = 0
	if(cart)
		for(var/datum/R in cart)
			var/qty = cart[R]
			var/unit = recipe_price(R)
			var/line_total = unit * qty
			manifest_total += line_total
			manifest_data += list(list(
				"ref" = "\ref[R]",
				"name" = recipe_name(R),
				"category" = recipe_category(R),
				"qty" = qty,
				"unit_price" = unit,
				"line_total" = line_total,
			))
	data["manifest"] = manifest_data
	data["manifest_total"] = manifest_total

	var/list/orders_data = list()
	for(var/datum/escrow_order/O in orders)
		if(isnull(O.cached_lines))
			build_order_cache(O)
		var/list/needed = O.required_result_counts()
		var/list/fulfillment = list()
		var/done_count = 0
		var/needed_count = 0
		for(var/path in needed)
			var/want = needed[path]
			var/have = O.delivered_counts[path] || 0
			done_count += min(have, want)
			needed_count += want
			var/atom/A = path
			fulfillment += list(list(
				"name" = initial(A.name),
				"have" = have,
				"want" = want,
				"unit" = "",
			))
		var/list/needed_vol = O.required_reagent_volumes()
		for(var/rtype in needed_vol)
			var/want = needed_vol[rtype]
			var/have = O.delivered_volume[rtype] || 0
			done_count += min(have, want)
			needed_count += want
			var/datum/reagent/RG = rtype
			fulfillment += list(list(
				"name" = initial(RG.name),
				"have" = have,
				"want" = want,
				"unit" = "dr",
			))
		var/days_left = 0
		var/expiry_label = ""
		if(O.status == "open")
			days_left = max(0, ESCROW_OPEN_EXPIRY_DAYS - (GLOB.dayspassed - O.day_posted))
			expiry_label = "expires in"
		else if(O.status == "claimed" && O.day_claimed)
			days_left = max(0, ESCROW_CLAIM_EXPIRY_DAYS - (GLOB.dayspassed - O.day_claimed))
			expiry_label = "claim expires in"
		orders_data += list(list(
			"ref" = "\ref[O]",
			"commissioner_name" = O.commissioner_name,
			"smith_name" = O.smith_name || "",
			"deposited" = O.deposited,
			"status" = O.status,
			"lines" = O.cached_lines,
			"materials" = O.cached_materials,
			"fulfillment" = fulfillment,
			"done_count" = done_count,
			"needed_count" = needed_count,
			"is_commissioner" = (user_key && user_key == O.commissioner_name) ? TRUE : FALSE,
			"is_smith" = (user_key && user_key == O.smith_name) ? TRUE : FALSE,
			"is_fulfilled" = O.is_fulfilled() ? TRUE : FALSE,
			"days_left" = days_left,
			"expiry_label" = expiry_label,
			"note" = O.commissioner_note,
		))
	data["orders"] = orders_data
	return data

/obj/structure/roguemachine/escrow/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	if(!ishuman(usr))
		return
	if(is_guild_member(usr))
		switch(action)
			if("set_percent_margin")
				var/n = text2num(params["value"])
				if(isnum(n))
					percent_margin = clamp(round(n), 0, 500)
					dirty_catalog_view()
				return FALSE
			if("set_flat_margin")
				var/n = text2num(params["value"])
				if(isnum(n))
					flat_margin = max(0, round(n))
					dirty_catalog_view()
				return FALSE
			if("set_material_price")
				var/path = text2path(params["path"])
				var/n = text2num(params["value"])
				if(path && (path in material_prices) && isnum(n))
					material_prices[path] = max(0, round(n))
					dirty_catalog_view()
				return FALSE
			if("toggle_material")
				var/path = text2path(params["path"])
				if(path)
					toggle_material_enabled(path)
				return FALSE
			if("set_item_cap")
				var/n = text2num(params["value"])
				if(isnum(n))
					item_cap_per_order = clamp(round(n), 1, 10)
					update_static_data_for_all_viewers()
				return FALSE
			if("toggle_pings")
				ping_enabled = !ping_enabled
				SStgui.update_uis(src)
				return FALSE

	switch(action)
		if("manifest_inc")
			var/datum/R = locate(params["ref"]) in catalog
			if(R)
				manifest_change(usr, R, text2num(params["delta"]) || 1)
			update_user_ui(usr)
			return FALSE
		if("manifest_dec")
			var/datum/R = locate(params["ref"]) in catalog
			if(R)
				manifest_change(usr, R, -(text2num(params["delta"]) || 1))
			update_user_ui(usr)
			return FALSE
		if("manifest_remove")
			var/datum/R = locate(params["ref"]) in catalog
			var/usr_key = escrow_key(usr)
			var/list/cart = usr_key ? manifests[usr_key] : null
			if(R && cart)
				cart -= R
			update_user_ui(usr)
			return FALSE
		if("submit_manifest")
			submit_manifest(usr, params["note"])
			return TRUE
		if("refund_deposit")
			refund_deposit(usr)
			update_user_ui(usr)
			return FALSE
		if("cancel_order")
			var/datum/escrow_order/O = locate(params["ref"]) in orders
			if(O)
				cancel_order(O, usr)
			return TRUE
		if("claim_order")
			var/datum/escrow_order/O = locate(params["ref"]) in orders
			if(O)
				claim_order(O, usr)
			return TRUE
		if("release_order")
			var/datum/escrow_order/O = locate(params["ref"]) in orders
			if(O)
				release_order(O, usr)
			return TRUE
		if("complete_order")
			var/datum/escrow_order/O = locate(params["ref"]) in orders
			if(O)
				complete_order(O, usr)
			return TRUE
		if("collect_order")
			var/datum/escrow_order/O = locate(params["ref"]) in orders
			if(O)
				collect_order(O, usr)
			return TRUE
		if("force_release_order")
			if(!is_guild_member(usr))
				return TRUE
			var/datum/escrow_order/O = locate(params["ref"]) in orders
			if(O)
				release_order(O, usr, TRUE)
			return TRUE
		if("reject_order")
			var/datum/escrow_order/O = locate(params["ref"]) in orders
			if(O)
				reject_order(O, usr, params["reason"])
			return TRUE
		if("settle_partial")
			var/datum/escrow_order/O = locate(params["ref"]) in orders
			if(O)
				settle_partial_order(O, usr)
			return TRUE
