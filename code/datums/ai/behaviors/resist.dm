/datum/ai_behavior/resist/perform(delta_time, datum/ai_controller/controller)
	var/mob/living/living_pawn = controller.pawn
	living_pawn.resist()
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED
