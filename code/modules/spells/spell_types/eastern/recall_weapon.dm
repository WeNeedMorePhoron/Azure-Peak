/*
 * Recall Weapon - Teleport bound weapon back to hand
 *
 * Searches for any item with the arcyne_conduit component on the same z-level
 * and teleports it back to the caster's hand. Useful after throwing or being disarmed.
 *
 * References:
 *   Arcyne Conduit (code/modules/spells/spell_types/eastern/arcyne_momentum.dm) - component on bound weapons
 */

/obj/effect/proc_holder/spell/self/recall_weapon
	name = "Recall Weapon"
	desc = "Recall your bound weapon to your hand from anywhere on the same level."
	clothes_req = FALSE
	overlay_state = "rune5"
	releasedrain = 15
	chargedrain = 0
	chargetime = 0
	recharge_time = 5 SECONDS
	warnie = "spellwarning"
	invocations = list("Revoca, ferrum...")
	invocation_type = "shout"
	gesture_required = TRUE
	xp_gain = FALSE

/obj/effect/proc_holder/spell/self/recall_weapon/cast(list/targets, mob/user = usr)
	var/mob/living/carbon/human/H = user
	if(!istype(H))
		revert_cast()
		return

	// Find bound weapon with arcyne_conduit component
	var/obj/item/bound_weapon
	for(var/obj/item/I in world)
		if(I.z != H.z)
			continue
		if(I.GetComponent(/datum/component/arcyne_conduit))
			bound_weapon = I
			break

	if(!bound_weapon)
		to_chat(H, span_warning("I have no bound weapon to recall!"))
		revert_cast()
		return

	// Already holding it?
	if(bound_weapon in H.held_items)
		to_chat(H, span_warning("My bound weapon is already in my hand!"))
		revert_cast()
		return

	// Try to put it in hand
	var/turf/weapon_turf = get_turf(bound_weapon)
	if(!weapon_turf)
		to_chat(H, span_warning("Cannot locate my bound weapon!"))
		revert_cast()
		return

	// Remove from any container/mob holding it
	if(ismob(bound_weapon.loc))
		var/mob/holder = bound_weapon.loc
		holder.dropItemToGround(bound_weapon, TRUE)

	// Visual at source
	playsound(weapon_turf, 'sound/magic/blink.ogg', 30, TRUE)

	// Teleport to hand
	if(!H.put_in_hands(bound_weapon))
		bound_weapon.forceMove(get_turf(H))
		to_chat(H, span_notice("My bound weapon returns to my feet — my hands are full!"))
	else
		to_chat(H, span_notice("My bound weapon flies back to my hand!"))

	playsound(get_turf(H), 'sound/magic/blink.ogg', 40, TRUE)
	H.visible_message(span_notice("[bound_weapon] flies through the air back to [H]'s hand!"))
	return TRUE
