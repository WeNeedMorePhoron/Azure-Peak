/datum/ai_planning_subtree/find_weapon
	var/vision_range = 9

/proc/ai_npc_has_weapon(mob/living/carbon/human/pawn)
	if(!istype(pawn))
		return FALSE
	for(var/obj/item/held in pawn.held_items)
		if(istype(held, /obj/item/rogueweapon/shield))
			continue
		if(istype(held, /obj/item/rogueweapon) || istype(held, /obj/item/gun))
			return TRUE
	var/datum/ai_controller/controller = pawn.ai_controller
	var/datum/component/ai_inventory_manager/inv = controller?.get_inventory()
	if(inv?.get_item(AI_ITEM_GUN)) // a bow worn/stowed anywhere - this is an archer, leave the loot
		return TRUE
	return FALSE

/datum/ai_planning_subtree/find_weapon/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	. = ..()
	var/atom/target = controller.blackboard[BB_MOB_EQUIP_TARGET]
	if(!QDELETED(target))
		// Busy with something
		return

	if(ai_npc_has_weapon(controller.pawn))
		return

	controller.queue_behavior(/datum/ai_behavior/find_and_set/better_weapon, BB_MOB_EQUIP_TARGET, null, vision_range)
