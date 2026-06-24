/datum/ai_planning_subtree/ranged_attack_subtree
	parent_type = /datum/ai_planning_subtree/archer_base

/datum/ai_planning_subtree/ranged_attack_subtree/SelectBehaviors(datum/ai_controller/controller, delta_time)
	if(!validate_archer_equipment(controller))
		return
	var/mob/living/carbon/human/pawn = controller.pawn
	var/atom/target = controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET]
	if(!isliving(target))
		_restore_stashed_weapon(controller, pawn)
		return

	var/obj/item/quiver/Q = controller.blackboard[BB_ARCHER_NPC_QUIVER]
	var/obj/item/gun/ballistic/revolver/grenadelauncher/bow = controller.blackboard[BB_ARCHER_NPC_BOW]
	if(!length(Q?.arrows) && !bow?.chambered)
		return

	if(get_dist(pawn, target) <= ARCHER_NPC_MIN_RANGE)
		_restore_stashed_weapon(controller, pawn)
		return

	controller.queue_behavior(/datum/ai_behavior/ranged_attack_bow, BB_BASIC_MOB_CURRENT_TARGET)
	if(LAZYACCESS(controller.current_behaviors, GET_AI_BEHAVIOR(/datum/ai_behavior/ranged_attack_bow)))
		return SUBTREE_RETURN_FINISH_PLANNING

/datum/ai_behavior/ranged_attack_bow
	behavior_flags = AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION | AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_MOVE_AND_PERFORM
	action_cooldown = 0.2 SECONDS
	required_distance = ARCHER_NPC_MIN_RANGE + 4

/datum/ai_behavior/ranged_attack_bow/setup(datum/ai_controller/controller, target_key)
	. = ..()
	if(!.)
		return FALSE
	var/mob/living/carbon/human/pawn = controller.pawn
	var/atom/target = controller.blackboard[target_key]
	if(!target)
		return FALSE

	var/obj/item/gun/ballistic/revolver/grenadelauncher/bow = _find_archer_bow(pawn)
	if(!bow)
		return FALSE

	if(pawn.get_active_held_item() != bow)
		_enter_bow_stance(controller, pawn, bow)
		if(pawn.get_active_held_item() != bow)
			return FALSE

	set_movement_target(controller, target)
	SEND_SIGNAL(controller.pawn, COMSIG_COMBAT_TARGET_SET, TRUE)
	if(istype(bow, /obj/item/gun/ballistic/revolver/grenadelauncher/crossbow))
		controller.set_blackboard_key(BB_ARCHER_NPC_NEXT_SHOT, world.time)
	else
		_chamber_from_quiver(pawn, bow)
		controller.set_blackboard_key(BB_ARCHER_NPC_NEXT_SHOT, world.time + bow.get_npc_chargetime(pawn))
	return TRUE

/datum/ai_behavior/ranged_attack_bow/perform(delta_time, datum/ai_controller/controller, target_key)
	. = ..()
	var/mob/living/carbon/human/pawn = controller.pawn
	var/atom/target = controller.blackboard[target_key]

	if(!isliving(target) || (ismob(target) && target:stat == DEAD))
		finish_action(controller, FALSE, target_key)
		return
	if(get_dist(pawn, target) < ARCHER_NPC_MIN_RANGE)
		finish_action(controller, FALSE, target_key)
		return
	var/obj/item/gun/ballistic/revolver/grenadelauncher/bow = pawn.get_active_held_item()
	if(!istype(bow))
		finish_action(controller, FALSE, target_key)
		return
	if(!bow.chambered)
		if(istype(bow, /obj/item/gun/ballistic/revolver/grenadelauncher/crossbow))
			if(!_quiver_has_ammo(pawn))
				finish_action(controller, FALSE, target_key)
				return
			if(!_reload_crossbow(controller, pawn, bow, target))
				return
		else if(!_chamber_from_quiver(pawn, bow))
			finish_action(controller, FALSE, target_key)
			return

	if(controller.current_movement_target != target)
		set_movement_target(controller, target)
	pawn.face_atom(target)

	if(world.time < controller.blackboard[BB_ARCHER_NPC_NEXT_SHOT])
		return
	if(!can_see(pawn, target, 11))
		return

	_loose_arrow(pawn, target, bow)
	// A crossbow's cadence is the (slow, interruptible) span on the next cycle; bows pace off the timer.
	if(istype(bow, /obj/item/gun/ballistic/revolver/grenadelauncher/crossbow))
		controller.set_blackboard_key(BB_ARCHER_NPC_NEXT_SHOT, world.time)
	else
		controller.set_blackboard_key(BB_ARCHER_NPC_NEXT_SHOT, world.time + bow.get_npc_chargetime(pawn))

/datum/ai_behavior/ranged_attack_bow/finish_action(datum/ai_controller/controller, succeeded, target_key)
	. = ..()
	var/mob/living/carbon/human/pawn = controller.pawn
	_restore_stashed_weapon(controller, pawn)

/proc/_find_archer_bow(mob/living/carbon/human/pawn)
	var/obj/item/active = pawn.get_active_held_item()
	if(istype(active, /obj/item/gun/ballistic/revolver/grenadelauncher))
		return active
	var/obj/item/inactive = pawn.get_inactive_held_item()
	if(istype(inactive, /obj/item/gun/ballistic/revolver/grenadelauncher))
		return inactive
	for(var/obj/item/worn in pawn.get_equipped_items())
		if(istype(worn, /obj/item/gun/ballistic/revolver/grenadelauncher))
			return worn
	return null

/proc/_enter_bow_stance(datum/ai_controller/controller, mob/living/carbon/human/pawn, obj/item/gun/ballistic/revolver/grenadelauncher/bow)
	var/is_sling = istype(bow, /obj/item/gun/ballistic/revolver/grenadelauncher/sling)
	var/obj/item/active = pawn.get_active_held_item()
	if(active && active != bow && !istype(active, /obj/item/gun/ballistic/revolver/grenadelauncher))
		_stash_melee_weapon(controller, pawn, active, remember = TRUE)
	if(!is_sling)
		var/obj/item/offhand = pawn.get_inactive_held_item()
		if(offhand && offhand != bow && !istype(offhand, /obj/item/gun/ballistic/revolver/grenadelauncher))
			_stash_melee_weapon(controller, pawn, offhand, remember = FALSE)
	if(pawn.get_active_held_item() != bow)
		pawn.put_in_active_hand(bow)

/proc/_stash_melee_weapon(datum/ai_controller/controller, mob/living/carbon/human/pawn, obj/item/weapon, remember = TRUE)
	var/stashed = FALSE
	if(pawn.belt)
		for(var/slot in list(SLOT_BELT_R, SLOT_BELT_L))
			if(!pawn.get_item_by_slot(slot) && pawn.equip_to_slot_if_possible(weapon, slot, disable_warning = TRUE))
				stashed = TRUE
				break
	if(!stashed)
		pawn.dropItemToGround(weapon, TRUE, TRUE)
	if(remember)
		controller.set_blackboard_key(BB_ARCHER_NPC_STASHED_WEAPON, weapon)

/proc/_restore_stashed_weapon(datum/ai_controller/controller, mob/living/carbon/human/pawn)
	var/obj/item/stashed = controller.blackboard[BB_ARCHER_NPC_STASHED_WEAPON]
	if(QDELETED(stashed))
		controller.clear_blackboard_key(BB_ARCHER_NPC_STASHED_WEAPON)
		return
	var/obj/item/held = pawn.get_active_held_item()
	if(istype(held, /obj/item/gun/ballistic/revolver/grenadelauncher)) // never drop the bow: it must stay in inventory to re-draw
		var/stowed = FALSE
		if(pawn.belt)
			for(var/slot in list(SLOT_BELT_R, SLOT_BELT_L))
				if(!pawn.get_item_by_slot(slot) && pawn.equip_to_slot_if_possible(held, slot, disable_warning = TRUE))
					stowed = TRUE
					break
		if(!stowed && !pawn.get_inactive_held_item())
			pawn.put_in_inactive_hand(held)
			stowed = TRUE
		if(!stowed)
			return
	pawn.put_in_active_hand(stashed)
	controller.clear_blackboard_key(BB_ARCHER_NPC_STASHED_WEAPON)

/proc/_quiver_has_ammo(mob/living/carbon/human/pawn)
	for(var/obj/item/quiver/Q in pawn.get_equipped_items())
		if(length(Q.arrows))
			return TRUE
	return FALSE


/proc/_reload_crossbow(datum/ai_controller/controller, mob/living/carbon/human/pawn, obj/item/gun/ballistic/revolver/grenadelauncher/crossbow/bow, atom/target)
	if(get_dist(pawn, target) > (ARCHER_NPC_MIN_RANGE + 4))
		return FALSE
	controller.ai_movement.stop_moving_towards(controller)
	pawn.face_atom(target)
	if(!bow.cocked)
		if(pawn.doing)
			return FALSE
		if(bow.cock_sound)
			playsound(pawn, bow.cock_sound, 100, FALSE)
		if(!do_after(pawn, bow.get_npc_chargetime(pawn), pawn))
			return FALSE
		bow.cocked = TRUE
		bow.update_icon()
	. = _chamber_from_quiver(pawn, bow)
	if(. && bow.load_sound)
		playsound(pawn, bow.load_sound, bow.load_sound_volume, bow.load_sound_vary)

/proc/_chamber_from_quiver(mob/living/carbon/human/pawn, obj/item/gun/ballistic/revolver/grenadelauncher/bow)
	if(bow.chambered)
		return TRUE
	var/wanted_caliber = bow.magazine?.caliber
	for(var/obj/item/quiver/Q in pawn.get_equipped_items())
		for(var/obj/item/ammo_casing/arrow in Q.arrows)
			if(wanted_caliber && arrow.caliber != wanted_caliber)
				continue
			Q.arrows -= arrow
			Q.update_icon()
			arrow.newshot()
			arrow.forceMove(bow)
			bow.chambered = arrow
			bow.update_icon()
			return TRUE
	return FALSE

/proc/_loose_arrow(mob/living/carbon/human/pawn, atom/target, obj/item/gun/ballistic/revolver/grenadelauncher/bow)
	var/should_arc = FALSE
	var/turf/pt = get_turf(pawn)
	var/turf/tt = get_turf(target)
	if(pt && tt)
		for(var/turf/T in getline(pt, tt))
			if(T == pt || T == tt)
				continue
			for(var/mob/living/M in T)
				if(M == pawn || M == target || M.stat == DEAD)
					continue
				if(pawn.faction_check_mob(M))
					should_arc = TRUE
					break
			if(should_arc)
				break
	bow.npc_force_arc = should_arc
	var/old_spread = bow.spread
	if(should_arc)
		bow.spread += ARCHER_NPC_ARC_SPREAD_PENALTY
	bow.process_fire(target, pawn, TRUE)
	bow.spread = old_spread
	bow.npc_force_arc = FALSE
