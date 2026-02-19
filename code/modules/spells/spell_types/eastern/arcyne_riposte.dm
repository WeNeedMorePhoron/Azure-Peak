/*
 * Arcyne Riposte - Blade subclass guard cooldown reset
 *
 * Instant self-cast that removes the guard/riposte cooldown (clashcd),
 * letting the spellblade Guard again immediately. Costs 4 momentum.
 *
 * References:
 *   Guard cooldown (code/datums/status_effects/rogue/roguebuff.dm:1355-1357) - apply_cooldown()
 *   clashcd debuff (code/datums/status_effects/debuffs.dm:828) - 30s duration
 *   Arcyne Momentum (code/modules/spells/spell_types/eastern/arcyne_momentum.dm) - stack system
 */

/obj/effect/proc_holder/spell/self/arcyne_riposte
	name = "Arcyne Riposte"
	desc = "Channel arcyne energy to instantly reset your guard cooldown. Requires 4 momentum stacks."
	clothes_req = FALSE
	overlay_state = "blade_burst"
	releasedrain = 15
	chargedrain = 0
	chargetime = 0
	recharge_time = 2 SECONDS
	warnie = "spellwarning"
	invocations = list("Respondeo!")
	invocation_type = "shout"
	gesture_required = TRUE
	xp_gain = FALSE
	var/momentum_cost = 4

/obj/effect/proc_holder/spell/self/arcyne_riposte/can_cast(mob/user)
	. = ..()
	if(!.)
		return FALSE
	if(get_arcyne_momentum(user) < momentum_cost)
		return FALSE

/obj/effect/proc_holder/spell/self/arcyne_riposte/cast(list/targets, mob/user = usr)
	var/mob/living/carbon/human/H = user
	if(!istype(H))
		revert_cast()
		return

	// Consume momentum
	var/datum/status_effect/buff/arcyne_momentum/M = H.has_status_effect(/datum/status_effect/buff/arcyne_momentum)
	if(!M || M.stacks < momentum_cost)
		to_chat(H, span_warning("Not enough momentum! Need [momentum_cost] stacks."))
		revert_cast()
		return
	M.consume_stacks(momentum_cost)

	// Remove guard cooldown
	var/had_cd = H.has_status_effect(/datum/status_effect/debuff/clashcd)
	H.remove_status_effect(/datum/status_effect/debuff/clashcd)

	if(had_cd)
		to_chat(H, span_notice("Arcyne energy surges through me — my guard is refreshed!"))
	else
		to_chat(H, span_notice("Momentum released — I am ready."))
	playsound(get_turf(H), 'sound/magic/charged.ogg', 40, TRUE)
	H.visible_message(span_notice("[H] flares with brief arcyne light."))
	return TRUE
