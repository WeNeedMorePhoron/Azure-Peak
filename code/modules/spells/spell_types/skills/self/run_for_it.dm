// Run for it is meant to be a DEFENSIVE ability handed out to most towners that have a legitimate reason to wander out of town
// By resetting aggro and stat nuking, I am hoping to actually put it as mostly defensive (Though it will have SOME PVP utilities for avoiding a fight).
// This is a necessary comrpomise without turning these towners into adventurer level of combat proficiency, especially if we plan to tune up wilderness deadliness without effectively shutting certain classes out of them more than we already did

#define RUN_FOR_IT_COOLDOWN (3 MINUTES) // 3 minutes should be acceptable and should let you survive most situation you get yourself into
#define RUN_FOR_IT_DURATION (10 SECONDS)
#define RUN_FOR_IT_RANGE 7
#define RUN_FOR_IT_SPEED_BONUS 4
#define RUN_FOR_IT_STAT_PENALTY 4

/obj/effect/proc_holder/spell/self/run_for_it
	name = "Run For It!"
	desc = "The Azurian wilds are dangerous, and those who walk them often enough know the greatest strategy for survival: Run! And don't step on any weird bushes or kneestingers. Briefly resets the aggro of all nearby simple animals on you and grants a burst of speed, but reduces your perception, intelligence and strength. You will not trigger ambushes, maneaters or kneestingers. Attacking ends it early."
	action_icon = 'icons/mob/actions/dendormiracles.dmi'
	overlay_icon = 'icons/mob/actions/dendormiracles.dmi'
	overlay_state = "tamebeast"
	releasedrain = 0
	chargedrain = 0
	chargetime = 0
	recharge_time = RUN_FOR_IT_COOLDOWN
	antimagic_allowed = TRUE
	clothes_req = FALSE
	invocations = list("turns tail and runs for it!")
	invocation_type = "emote"
	// Running away on solid floor, by pfranzen
	sound = 'sound/combat/run_for_it.ogg'

/obj/effect/proc_holder/spell/self/run_for_it/cast(list/targets, mob/user = usr)
	. = ..()
	if(!isliving(user))
		revert_cast()
		return FALSE
	var/mob/living/runner = user
	for(var/mob/living/simple_animal/beast in get_hearers_in_view(RUN_FOR_IT_RANGE, runner))
		beast.forget_target(runner)
	runner.apply_status_effect(/datum/status_effect/buff/run_for_it)
	return TRUE

/mob/living/simple_animal/proc/forget_target(mob/living/target)
	if(ai_controller)
		var/list/aggro_table = ai_controller.blackboard[BB_MOB_AGGRO_TABLE]
		aggro_table?.Remove(target)
		var/list/retaliate_list = ai_controller.blackboard[BB_BASIC_MOB_RETALIATE_LIST]
		retaliate_list?.Remove(target)
		if(ai_controller.blackboard[BB_HIGHEST_THREAT_MOB] == target)
			ai_controller.clear_blackboard_key(BB_HIGHEST_THREAT_MOB)
		if(ai_controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET] == target)
			ai_controller.clear_blackboard_key(BB_BASIC_MOB_CURRENT_TARGET)
			ai_controller.CancelActions()
	var/mob/living/simple_animal/hostile/hostile_beast = src
	if(istype(hostile_beast) && hostile_beast.target == target)
		hostile_beast.LoseTarget()

/atom/movable/screen/alert/status_effect/buff/run_for_it
	name = "Running For It"
	desc = "Beasts lose track of me and I will not be caught by any maneaters, kneestingers or bushes, but I am in no state to fight."
	icon_state = "buff"

/datum/status_effect/buff/run_for_it
	id = "run_for_it"
	alert_type = /atom/movable/screen/alert/status_effect/buff/run_for_it
	duration = RUN_FOR_IT_DURATION
	effectedstats = list(STATKEY_SPD = RUN_FOR_IT_SPEED_BONUS, STATKEY_PER = -RUN_FOR_IT_STAT_PENALTY, STATKEY_INT = -RUN_FOR_IT_STAT_PENALTY, STATKEY_STR = -RUN_FOR_IT_STAT_PENALTY)

/datum/status_effect/buff/run_for_it/on_apply()
	. = ..()
	if(!.)
		return
	ADD_TRAIT(owner, TRAIT_RUN_FOR_IT, id)
	ADD_TRAIT(owner, TRAIT_KNEESTINGER_IMMUNITY, id)
	RegisterSignals(owner, list(COMSIG_MOB_ITEM_ATTACK, COMSIG_MOB_FIRED_GUN, COMSIG_MOB_THROW, COMSIG_MOB_CAST_SPELL), PROC_REF(on_attack))
	RegisterSignal(owner, COMSIG_MOB_ATTACK_HAND, PROC_REF(on_attack_hand))
	to_chat(owner, span_notice("Ruuuuuuuuuuuuun!"))

/datum/status_effect/buff/run_for_it/on_remove()
	. = ..()
	REMOVE_TRAIT(owner, TRAIT_RUN_FOR_IT, id)
	REMOVE_TRAIT(owner, TRAIT_KNEESTINGER_IMMUNITY, id)
	UnregisterSignal(owner, list(COMSIG_MOB_ITEM_ATTACK, COMSIG_MOB_FIRED_GUN, COMSIG_MOB_THROW, COMSIG_MOB_CAST_SPELL, COMSIG_MOB_ATTACK_HAND))
	to_chat(owner, span_warning("I catch my breath."))

/datum/status_effect/buff/run_for_it/proc/on_attack(datum/source)
	SIGNAL_HANDLER
	qdel(src)

/datum/status_effect/buff/run_for_it/proc/on_attack_hand(mob/living/source)
	SIGNAL_HANDLER
	if(source.used_intent?.type == INTENT_HELP)
		return
	qdel(src)

#undef RUN_FOR_IT_COOLDOWN
#undef RUN_FOR_IT_DURATION
#undef RUN_FOR_IT_RANGE
#undef RUN_FOR_IT_SPEED_BONUS
#undef RUN_FOR_IT_STAT_PENALTY
