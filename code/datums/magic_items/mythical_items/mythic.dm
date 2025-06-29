#define INFERNAL_FLAME_COOLDOWN 20 SECONDS // Nerfed from RW version cuz Fire is strong and every 10 seconds is too OP.

// RW's Mythic Items. But I took out Temporal Rewind and Freezing as they were one hit CC

//T4 Enchantments

/datum/magic_item/mythic/infernalflame
	name = "infernal flame"
	description = "It glows with white hot heat."
	var/last_used
	var/warned

/datum/magic_item/mythic/infernalflame/on_hit(obj/item/source, atom/target, mob/user, proximity_flag, click_parameters)
	if(world.time < src.last_used + INFERNAL_FLAME_COOLDOWN)
		return
	if(isliving(target))
		var/mob/living/targeted = target
		targeted.adjust_fire_stacks(10)
		targeted.IgniteMob()
		targeted.visible_message(span_danger("[source] sets [targeted] on fire!"))
		src.last_used = world.time

/datum/magic_item/mythic/infernalflame/projectile_hit(atom/fired_from, atom/movable/firer, atom/target, Angle)
	if(world.time < src.last_used + INFERNAL_FLAME_COOLDOWN)
		if(!warned)
			to_chat(firer, span_notice("[fired_from] is not yet ready to immolate!"))
			warned = TRUE
	if(isliving(firer) && isliving(target))
		var/mob/living/damaging = target
		if(damaging.stat != DEAD)
			damaging.adjust_fire_stacks(10)
			damaging.IgniteMob()
			damaging.visible_message(span_danger("[fired_from] sets [damaging] on fire!"))
			src.last_used = world.time

/datum/magic_item/mythic/infernalflame/on_hit_response(var/obj/item/I, var/mob/living/carbon/human/owner, var/mob/living/carbon/human/attacker)
	if(world.time < src.last_used + INFERNAL_FLAME_COOLDOWN)
		return
	if(isliving(attacker) && attacker != owner)
		attacker.adjust_fire_stacks(10)
		attacker.IgniteMob()
		attacker.visible_message(span_danger("[I] sets [attacker] on fire!"))
		src.last_used = world.time

/datum/magic_item/mythic/briarcurse
	name = "Briar's curse"
	description = "Its grip seems thorny. Must hurt to use."
	var/last_used

/datum/magic_item/mythic/briarcurse/on_apply(var/obj/item/i)
	.=..()
	i.force = i.force + 10

/datum/magic_item/mythic/briarcurse/on_hit(obj/item/source, atom/target, mob/user, proximity_flag, click_parameters)
	.=..()
	if(isliving(target))
		var/mob/living/carbon/targeted = target
		targeted.adjustBruteLoss(10)
		to_chat(user, span_notice("[source] gouges you with it's sharp edges!"))
