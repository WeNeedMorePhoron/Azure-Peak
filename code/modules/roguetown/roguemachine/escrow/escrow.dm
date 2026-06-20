/obj/structure/roguemachine/escrow
	name = "COMMISSIONER"
	desc = "A brass-plated contraption with a coin slot above and an iron strongbox beneath. The guild posts and fulfills smithing or engineering work here, coin held in escrow until the job is done."
	icon = 'icons/roguetown/misc/machines.dmi'
	icon_state = "streetvendor1"
	density = TRUE
	blade_dulling = DULLING_BASH
	max_integrity = 0
	integrity_failure = 0.1
	anchored = TRUE
	layer = BELOW_OBJ_LAYER
	var/list/keycontrol = list("crafterguild", "craftermaster")
	var/budget = 0
	var/list/material_prices
	var/list/derived_material_prices
	var/percent_margin = 70
	var/flat_margin = 5
	var/item_cap_per_order = 3
	var/list/orders = list()
	var/list/manifests = list()
	var/list/manifest_deposits = list()
	var/list/catalog
	var/list/cached_catalog_data
	var/list/cached_categories
	var/list/cached_ingots
	var/catalog_view_dirty = TRUE
	/// Catalog sourcing. The base machine lists material-derived smithing/engineering
	/// recipes. Subtypes swap these for non-material goods: arcane lists enchanting
	/// rituals by tier, alchemist lists potion trade goods.
	var/catalog_includes_recipes = TRUE
	var/list/catalog_ritual_tiers
	var/list/catalog_good_behaviors
	/// FALSE for goods that aren't material-priced - suppresses the material-price panel.
	var/has_materials = TRUE
	/// OOC nudge to eligible crafters about unclaimed orders. Toggleable at the machine.
	var/ping_enabled = TRUE
	var/ping_interval = 15 MINUTES
	var/next_ping = 0
	var/list/priority_material_types = list(
		/obj/item/ingot,
		/obj/item/natural/hide,
		/obj/item/grown/log,
		/obj/item/natural/wood,
		/obj/item/roguegear,
	)
	var/list/excluded_materials = list(
		/obj/item/ingot/aalloy,
		/obj/item/ingot/drow,
	)
	var/list/excluded_material_parents = list()
	var/list/default_disabled_materials = list(
		/obj/item/ingot/blacksteel,
		/obj/item/ingot/silver,
		/obj/item/ingot/silverblessed,
		/obj/item/ingot/silverblessed/bullion,
		/obj/item/ingot/steelholy,
		/obj/item/ingot/lithmyc,
		/obj/item/ingot/purifiedaalloy,
	)
	var/list/disabled_materials = list()
	var/list/allowed_categories = list(
		ITEM_CAT_ARMOR_HELMETS,
		ITEM_CAT_ARMOR_CHESTPIECES,
		ITEM_CAT_ARMOR_LEGS,
		ITEM_CAT_ARMOR_NECK,
		ITEM_CAT_ARMOR_BOOTS,
		ITEM_CAT_ARMOR_GLOVES,
		ITEM_CAT_ARMOR_MASKS,
		ITEM_CAT_ARMOR_BRACERS,
		ITEM_CAT_ARMOR_BELTS,
		ITEM_CAT_ARMOR_BARDING,
		ITEM_CAT_ARMOR_LIGHT,
		ITEM_CAT_WEAPONS_SWORDS,
		ITEM_CAT_WEAPONS_DAGGERS,
		ITEM_CAT_WEAPONS_AXES,
		ITEM_CAT_WEAPONS_POLEARMS,
		ITEM_CAT_WEAPONS_MACES,
		ITEM_CAT_WEAPONS_FLAILS,
		ITEM_CAT_WEAPONS_SHIELDS,
		ITEM_CAT_WEAPONS_AMMO,
		ITEM_CAT_TOOLS_COOKWARE,
		ITEM_CAT_TOOLS_FIELD,
		ITEM_CAT_TOOLS_WORKSHOP,
		ITEM_CAT_TOOLS_SUNDRIES,
		ITEM_CAT_TOOLS_ROGUE,
		ITEM_CAT_VALUABLES_RINGS,
		ITEM_CAT_VALUABLES_HOLY,
		ITEM_CAT_COMPONENTS,
		ITEM_CAT_SMITHING_MISC,
		ITEM_CAT_ENG_MACHINERY,
		ITEM_CAT_ENG_CONSTRUCTION,
		ITEM_CAT_ENG_COMBAT,
		ITEM_CAT_ENG_TRIGGERS,
		ITEM_CAT_ENG_MISC,
	)
	var/list/group_order = list("Armor", "Weapons", "Tools", "Valuables", "Decoration", "Engineering", "Other")

/obj/structure/roguemachine/escrow/Initialize()
	. = ..()
	if(has_materials)
		init_material_prices()
		disabled_materials = default_disabled_materials?.Copy() || list()
	rebuild_catalog()
	update_icon()
	next_ping = world.time + ping_interval
	START_PROCESSING(SSroguemachine, src)

/obj/structure/roguemachine/escrow/Destroy()
	STOP_PROCESSING(SSroguemachine, src)
	orders?.Cut()
	manifests?.Cut()
	manifest_deposits?.Cut()
	return ..()

/obj/structure/roguemachine/escrow/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Any commissioner may build a manifest of smithing or engineering recipes and deposit coin into the machine. Submitting the manifest posts an order with the coin held in escrow.")
	. += span_info("A smith can claim an open order, deliver the finished items back into the machine, and collect the escrowed pay once every item has been delivered. An order that has been claimed cannot be cancelled by the commissioner.")
	. += span_info("A guild member may adjust material prices and margins through the machine's panel.")

/obj/structure/roguemachine/escrow/attackby(obj/item/P, mob/user, params)
	if(istype(P, /obj/item/roguecoin/aalloy) || istype(P, /obj/item/roguecoin/inqcoin))
		return
	if(istype(P, /obj/item/roguecoin))
		var/key = escrow_key(user)
		if(!key)
			return
		manifest_deposits[key] = (manifest_deposits[key] || 0) + P.get_real_price()
		qdel(P)
		playsound(loc, 'sound/misc/machinevomit.ogg', 100, TRUE, -1)
		update_user_ui(user)
		return

	if(ishuman(user))
		try_smith_deliver(P, user)

/obj/structure/roguemachine/escrow/proc/escrow_key(mob/user)
	if(!user || !user.real_name)
		return null
	return user.real_name

/obj/structure/roguemachine/escrow/proc/try_smith_deliver(obj/item/I, mob/user)
	var/key = escrow_key(user)
	if(!key)
		return
	for(var/datum/escrow_order/O in orders)
		if(O.status != "claimed" || O.smith_name != key)
			continue
		var/result = O.try_accept_item(I)
		if(result == "damaged")
			to_chat(user, span_warning("[src] refuses [I] - the work is too damaged to deliver. Mend it first."))
			return
		if(result)
			I.forceMove(src)
			playsound(loc, 'sound/misc/machinevomit.ogg', 100, TRUE, -1)
			to_chat(user, span_notice("[src] accepts [I]."))
			SStgui.update_uis(src)
			return
	to_chat(user, span_warning("[src] has no order waiting for [I]."))

/obj/structure/roguemachine/escrow/ui_state(mob/user)
	return GLOB.human_adjacent_state

/obj/structure/roguemachine/escrow/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	if(!ishuman(user))
		return
	user.changeNext_move(CLICK_CD_INTENTCAP)
	ui_interact(user)

/obj/structure/roguemachine/escrow/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		playsound(loc, 'sound/misc/beep.ogg', 100, FALSE, -1)
		ui = new(user, src, "Commissioner", name)
		ui.open()
		ui.set_autoupdate(FALSE)

/// Refresh only the acting user's UI (dynamic data) for changes that touch nobody else.
/obj/structure/roguemachine/escrow/proc/update_user_ui(mob/user)
	var/datum/tgui/ui = SStgui.get_open_ui(user, src)
	ui?.send_update()

/obj/structure/roguemachine/escrow/proc/is_guild_member(mob/user)
	if(!ishuman(user))
		return FALSE
	for(var/obj/item/roguekey/K in user.GetAllContents())
		if(K.lockid in keycontrol)
			return TRUE
	return FALSE

/obj/structure/roguemachine/escrow/obj_break(damage_flag)
	..()
	var/turf/T = get_turf(src)
	for(var/datum/escrow_order/O in orders)
		for(var/obj/item/I in O.delivered_items)
			I.forceMove(T)
	orders.Cut()
	manifests.Cut()
	var/spill = budget
	for(var/ck in manifest_deposits)
		spill += manifest_deposits[ck]
	manifest_deposits.Cut()
	budget = 0
	budget2change(spill, custom_turf = T)
	update_icon()

/obj/structure/roguemachine/escrow/update_icon()
	cut_overlays()
	if(obj_broken)
		set_light(0)
		return
	icon_state = "streetvendor1"
	if(length(orders))
		set_light(1, 1, 1, l_color = "#f1c94b")
	else
		set_light(0)
