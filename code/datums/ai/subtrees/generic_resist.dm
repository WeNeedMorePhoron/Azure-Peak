/datum/ai_planning_subtree/generic_resist/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	var/mob/living/living_pawn = controller.pawn

	if(!pawn.has_status_effect(STATUS_EFFECT_PARALYZED) || !pawn.has_status_effect(STATUS_EFFECT_STUN)) //No point if we're -> Paralyzed or Stunned
		if(controller.blackboard[BB_RESISTING])
			controller.queue_behavior(/datum/ai_behavior/resist)
			if(isliving(living_pawn.pulledby))
				controller.set_blackboard_key(BB_BASIC_MOB_CURRENT_TARGET, living_pawn.pulledby)
				controller.set_blackboard_key(BB_HIGHEST_THREAT_MOB, living_pawn.pulledby)
			return // Don't block planning — melee and kick subtrees run after this.
		if(SHOULD_RESIST(living_pawn))
			controller.queue_behavior(/datum/ai_behavior/resist)
			if(isliving(living_pawn.pulledby))
				controller.set_blackboard_key(BB_BASIC_MOB_CURRENT_TARGET, living_pawn.pulledby)
				controller.set_blackboard_key(BB_HIGHEST_THREAT_MOB, living_pawn.pulledby)
			return // Resist + fight, don't block combat.
	else
		return

/datum/ai_behavior/resist/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living/living_pawn = controller.pawn

	if(!pawn.has_status_effect(STATUS_EFFECT_PARALYZED) || !pawn.has_status_effect(STATUS_EFFECT_STUN)) //No point if we're -> Paralyzed or Stunned
		living_pawn.ai_controller.set_blackboard_key(BB_RESISTING, TRUE)
		living_pawn.execute_resist()
		finish_action(controller, TRUE)
		return TRUE
	else
		return

/datum/ai_behavior/resist/finish_action(datum/ai_controller/controller, succeeded, ...)
	. = ..()

	if(!pawn.has_status_effect(STATUS_EFFECT_PARALYZED) || !pawn.has_status_effect(STATUS_EFFECT_STUN)) //No point if we're -> Paralyzed or Stunned
		var/mob/living/living_pawn = controller.pawn
		if(QDELETED(living_pawn))
			return
		if(SHOULD_RESIST(living_pawn))
			living_pawn.ai_controller.set_blackboard_key(BB_RESISTING, TRUE)
		else
			living_pawn.ai_controller.set_blackboard_key(BB_RESISTING, FALSE)
	else
		return
