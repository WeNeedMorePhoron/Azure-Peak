/obj/item/proc/try_bakers_peel_right_click_target(atom/target, mob/user)
	return FALSE

/datum/intent/use/bakers_peel
	name = "use"
	reach = 2
	rmb_ranged = TRUE

/datum/intent/use/bakers_peel/rmb_ranged(atom/target, mob/user)
	masteritem?.try_bakers_peel_right_click_target(target, user)

/datum/intent/spear/bash/ranged/bakers_peel
	name = "swat"
	attack_verb = list("swats", "strikes")
	hitsound = list('sound/combat/hits/blunt/woodblunt (1).ogg', 'sound/combat/hits/blunt/woodblunt (2).ogg')
	damfactor = 1

/obj/item/cooking/bakers_peel
	name = "baker's peel"
	desc = "A long wooden paddle used by bakers to put food into and take food out of the oven."
	icon = 'modular/Neu_Food/icons/cookware/bakers_peel.dmi'
	icon_state = "bakerspeel0"
	drop_sound = 'sound/foley/dropsound/wooden_drop.ogg'
	resistance_flags = FLAMMABLE
	slot_flags = ITEM_SLOT_BACK
	w_class = WEIGHT_CLASS_HUGE
	wlength = WLENGTH_LONG
	twohands_required = TRUE
	possible_item_intents = list(/datum/intent/use/bakers_peel, /datum/intent/spear/bash/ranged/bakers_peel)
	gripped_intents = list(/datum/intent/use/bakers_peel, /datum/intent/spear/bash/ranged/bakers_peel)
	inhand_x_dimension = 64
	inhand_y_dimension = 64
	grid_width = 32
	grid_height = 96
	bigboy = TRUE
	force = 10
	force_wielded = 10
	throwforce = 0
	sharpness = IS_BLUNT
	can_parry = TRUE
	wdefense = 8
	associated_skill = /datum/skill/combat/staves
	var/list/loaded_items = list()
	var/max_items = 5

/obj/item/cooking/bakers_peel/examine(mob/user)
	. = ..()
	clean_loaded_items()
	if(loaded_items.len)
		. += span_info("It is carrying [loaded_items.len] item[loaded_items.len == 1 ? "" : "s"].")
	else
		. += span_info("It is empty.")

/obj/item/cooking/bakers_peel/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Left-click a tabled food item to slide up to five items onto the peel, it will prefer the same kind of food you clicked on first.")
	. += span_info("Right-click a table to unload the peel onto it. Right-click an oven to load it with food from the peel. Left-click an oven to slide food from inside it onto the peel.")
	. += span_info("It can reach tables and ovens up to two tiles away.")

/obj/item/cooking/bakers_peel/update_transform()
	. = ..()
	icon_state = ismob(loc) ? "bakerspeel1" : "bakerspeel0"

/obj/item/cooking/bakers_peel/getonmobprop(tag)
	. = ..()
	if(tag)
		switch(tag)
			if("gen")
				return list("shrink" = 0.6,"sx" = -7,"sy" = 2,"nx" = 7,"ny" = 3,"wx" = -2,"wy" = 1,"ex" = 1,"ey" = 1,"northabove" = 0,"southabove" = 1,"eastabove" = 1,"westabove" = 0,"nturn" = -38,"sturn" = 37,"wturn" = 30,"eturn" = -30,"nflip" = 0,"sflip" = 8,"wflip" = 8,"eflip" = 0)
			if("wielded")
				return list("shrink" = 0.6,"sx" = 5,"sy" = -3,"nx" = -5,"ny" = -2,"wx" = -5,"wy" = -1,"ex" = 3,"ey" = -2,"northabove" = 0,"southabove" = 1,"eastabove" = 1,"westabove" = 0,"nturn" = 7,"sturn" = -7,"wturn" = 16,"eturn" = -22,"nflip" = 8,"sflip" = 0,"wflip" = 8,"eflip" = 0)

/obj/item/cooking/bakers_peel/afterattack(atom/target, mob/living/user, proximity, params)
	if(!target || !user)
		return ..()
	if(istype(target, /obj/machinery/light/rogue/oven))
		if(take_from_oven(target, user))
			return
	if(isitem(target))
		if(scoop_from_table(target, user))
			return
	return ..()

/obj/item/cooking/bakers_peel/Destroy()
	dump_loaded_items(get_turf(src))
	return ..()

/obj/item/cooking/bakers_peel/try_bakers_peel_right_click_target(atom/target, mob/user)
	return use_on_right_click_target(target, user)

/obj/item/cooking/bakers_peel/try_bakers_peel_table_unload(atom/target, mob/user)
	var/obj/structure/table/table = target
	if(!istype(table))
		return FALSE
	return unload_onto_table(table, user)

/obj/item/cooking/bakers_peel/try_bakers_peel_oven_insert(atom/target, mob/user)
	var/obj/machinery/light/rogue/oven/oven = target
	if(!istype(oven))
		return FALSE
	return insert_into_oven(oven, user)

/obj/item/cooking/bakers_peel/proc/use_on_right_click_target(atom/target, mob/user)
	if(!target || !user)
		return FALSE
	if(!can_reach_target(target, user))
		to_chat(user, span_warning("[src] won't reach that far."))
		return TRUE
	if(istype(target, /obj/structure/table))
		return unload_onto_table(target, user)
	if(istype(target, /obj/machinery/light/rogue/oven))
		return insert_into_oven(target, user)
	return FALSE

/obj/item/cooking/bakers_peel/proc/can_reach_target(atom/target, mob/user)
	if(!user.is_holding(src))
		return FALSE
	if(get_dist(get_turf(user), get_turf(target)) > 2)
		return FALSE
	return user.CanReach(target, src)

/obj/item/cooking/bakers_peel/proc/clean_loaded_items()
	if(!loaded_items)
		loaded_items = list()
	for(var/obj/item/I as anything in loaded_items.Copy())
		if(QDELETED(I) || I.loc != src)
			loaded_items -= I

/obj/item/cooking/bakers_peel/proc/has_space()
	clean_loaded_items()
	return loaded_items.len < max_items

/obj/item/cooking/bakers_peel/proc/can_load_item(obj/item/I)
	if(!I || QDELETED(I) || I == src)
		return FALSE
	if((I.item_flags & ABSTRACT) || HAS_TRAIT(I, TRAIT_NODROP))
		return FALSE
	if(I.anchored)
		return FALSE
	if(I.wlength > WLENGTH_NORMAL)
		return FALSE
	return TRUE

/obj/item/cooking/bakers_peel/proc/is_raw_cookable_food(obj/item/I)
	if(!istype(I, /obj/item/reagent_containers/food/snacks))
		return FALSE
	var/obj/item/reagent_containers/food/snacks/food_item = I
	return food_item.cooked_type

/obj/item/cooking/bakers_peel/proc/is_matching_food(obj/item/I, obj/item/source)
	if(I.type == source.type)
		return TRUE
	return is_raw_cookable_food(source) && is_raw_cookable_food(I)

/obj/item/cooking/bakers_peel/proc/load_item(obj/item/I)
	if(!can_load_item(I) || !has_space())
		return FALSE
	I.forceMove(src)
	I.pixel_x = initial(I.pixel_x)
	I.pixel_y = initial(I.pixel_y)
	loaded_items += I
	return TRUE

/obj/item/cooking/bakers_peel/proc/scoop_from_table(obj/item/source, mob/user)
	if(!can_reach_target(source, user))
		return FALSE
	if(!has_space())
		to_chat(user, span_warning("[src] is already full."))
		return TRUE
	if(!can_load_item(source))
		return FALSE
	var/turf/table_turf = get_turf(source)
	if(!table_turf || !(locate(/obj/structure/table) in table_turf))
		return FALSE
	var/list/to_scoop = list()
	for(var/obj/item/I in table_turf)
		if(to_scoop.len >= max_items - loaded_items.len)
			break
		if(I.type == source.type && can_load_item(I))
			to_scoop += I
	for(var/obj/item/I in table_turf)
		if(to_scoop.len >= max_items - loaded_items.len)
			break
		if(I in to_scoop)
			continue
		if(is_matching_food(I, source) && can_load_item(I))
			to_scoop += I
	if(!to_scoop.len)
		return FALSE
	for(var/obj/item/I as anything in to_scoop)
		load_item(I)
	user.visible_message(span_info("[user] slides [to_scoop.len] item[to_scoop.len == 1 ? "" : "s"] onto [src]."), span_info("I slide [to_scoop.len] item[to_scoop.len == 1 ? "" : "s"] onto [src]."))
	playsound(get_turf(user), 'sound/foley/dropsound/wooden_drop.ogg', 50, TRUE)
	return TRUE

/obj/item/cooking/bakers_peel/proc/unload_onto_table(obj/structure/table/table, mob/user)
	if(!can_reach_target(table, user))
		return FALSE
	clean_loaded_items()
	if(!loaded_items.len)
		to_chat(user, span_warning("[src] is empty."))
		return TRUE
	var/turf/table_turf = get_turf(table)
	if(!table_turf)
		return FALSE
	var/count = dump_loaded_items(table_turf)
	user.visible_message(span_info("[user] turns [count] item[count == 1 ? "" : "s"] out onto [table]."), span_info("I turn [count] item[count == 1 ? "" : "s"] out onto [table]."))
	playsound(table_turf, 'sound/foley/dropsound/wooden_drop.ogg', 50, TRUE)
	return TRUE

/obj/item/cooking/bakers_peel/proc/dump_loaded_items(turf/T)
	if(!T)
		return 0
	clean_loaded_items()
	var/count = 0
	for(var/obj/item/I as anything in loaded_items.Copy())
		loaded_items -= I
		I.forceMove(T)
		I.pixel_x = initial(I.pixel_x)
		I.pixel_y = initial(I.pixel_y)
		count++
	return count

/obj/item/cooking/bakers_peel/proc/insert_into_oven(obj/machinery/light/rogue/oven/oven, mob/user)
	if(!can_reach_target(oven, user))
		return FALSE
	clean_loaded_items()
	if(!loaded_items.len)
		to_chat(user, span_warning("[src] is empty."))
		return TRUE
	var/free_space = oven.maxfood - oven.food.len
	if(free_space <= 0)
		to_chat(user, span_warning("[oven] is already full."))
		return TRUE
	var/count = 0
	for(var/obj/item/I as anything in loaded_items.Copy())
		if(count >= free_space)
			break
		if(!can_load_item(I))
			continue
		loaded_items -= I
		I.forceMove(oven)
		oven.food += I
		count++
	if(!count)
		to_chat(user, span_warning("Nothing on [src] fits in [oven]."))
		return TRUE
	var/mob/living/carbon/human/H = user
	if(istype(H))
		oven.lastuser = H
	oven.donefoods = FALSE
	oven.need_underlay_update = TRUE
	oven.update_icon()
	user.visible_message(span_info("[user] slides [count] item[count == 1 ? "" : "s"] from [src] into [oven]."), span_info("I slide [count] item[count == 1 ? "" : "s"] from [src] into [oven]."))
	playsound(get_turf(oven), 'sound/items/wood_sharpen.ogg', 50)
	return TRUE

/obj/item/cooking/bakers_peel/proc/take_from_oven(obj/machinery/light/rogue/oven/oven, mob/user)
	if(!can_reach_target(oven, user))
		return FALSE
	if(!has_space())
		to_chat(user, span_warning("[src] is already full."))
		return TRUE
	if(!oven.food.len)
		to_chat(user, span_warning("[oven] is empty."))
		return TRUE
	var/free_space = max_items - loaded_items.len
	var/count = 0
	for(var/i = oven.food.len, i >= 1, i--)
		if(count >= free_space)
			break
		var/obj/item/I = oven.food[i]
		if(!can_load_item(I))
			continue
		oven.food -= I
		load_item(I)
		count++
	if(!count)
		to_chat(user, span_warning("Nothing in [oven] fits on [src]."))
		return TRUE
	var/mob/living/carbon/human/H = user
	if(istype(H))
		oven.lastuser = H
	oven.donefoods = FALSE
	oven.need_underlay_update = TRUE
	oven.update_icon()
	user.visible_message(span_info("[user] draws [count] item[count == 1 ? "" : "s"] from [oven] onto [src]."), span_info("I draw [count] item[count == 1 ? "" : "s"] from [oven] onto [src]."))
	playsound(get_turf(oven), 'sound/items/wood_sharpen.ogg', 50)
	return TRUE
