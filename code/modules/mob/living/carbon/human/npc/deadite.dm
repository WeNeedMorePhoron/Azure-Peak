/mob/living/carbon/human/species/npc/deadite
	ai_controller = /datum/ai_controller/human_npc
	d_intent = INTENT_DODGE //To simulate that deadites CANNOT parry
	dodgetime = 20
	ambushable = FALSE
	infected = TRUE

/mob/living/carbon/human/species/npc/deadite/Initialize()
	. = ..()
	var/species = list(
		/datum/species/human/northern,
		/datum/species/dwarf/mountain,
		/datum/species/elf/dark,
		/datum/species/elf/wood,
		/datum/species/goblinp,
		/datum/species/aasimar,
		/datum/species/human/halfelf,
		/datum/species/halforc,
	)

	set_species(pick(species))
	gender = pick(MALE, FEMALE)

	var/obj/item/organ/ears/organ_ears = getorgan(/obj/item/organ/ears)
	var/list/deadite_firstnames = world.file2list("strings/rt/names/other/deaditenpcfirst.txt")
	var/list/deadite_lastnames  = world.file2list("strings/rt/names/other/deaditenpclast.txt")
	
	skin_tone = "#868e79"
	if(organ_ears)
		organ_ears.accessory_colors = "#868e79"

	real_name = "[pick(deadite_firstnames)] [pick(deadite_lastnames)]"
	H.dna.species.soundpack_m = GLOB.voice_packs[/datum/voicepack/zombie/m]
	H.dna.species.soundpack_f = GLOB.voice_packs[/datum/voicepack/zombie/f]

	addtimer(CALLBACK(src, PROC_REF(after_creation)), 1 SECONDS)
	equipOutfit(new /datum/outfit/job/roguetown/deadite) //Give ourselves the base outfit (traits of being a deadite + statline)

/mob/living/carbon/human/species/npc/deadite/after_creation()
	. = ..()
	src.mind_initialize()
	mob_biotypes |= MOB_UNDEAD
	//give ourselves undead eyes.
	var/obj/item/organ/eyes/eyes = getorganslot(ORGAN_SLOT_EYES)
	if(eyes)
		eyes.Remove(src,1)
		QDEL_NULL(eyes)
	eyes = SSwardrobe.provide_type(/obj/item/organ/eyes/night_vision/zombie)
	eyes.Insert(src)

	update_body()

/datum/outfit/job/roguetown/deadite/pre_equip(mob/living/carbon/human/H)
	..()
	//We simulate being a """deadite""" here
	ADD_TRAIT(src, TRAIT_LIMBATTACHMENT, TRAIT_GENERIC)
	ADD_TRAIT(src, TRAIT_BREADY, TRAIT_GENERIC)
	ADD_TRAIT(src, TRAIT_NOMOOD, TRAIT_GENERIC)
	ADD_TRAIT(src, TRAIT_NOHUNGER, TRAIT_GENERIC)
	ADD_TRAIT(src, TRAIT_EASYDISMEMBER, TRAIT_GENERIC)
	ADD_TRAIT(src, TRAIT_NOPAIN, INNATE_TRAIT)
	ADD_TRAIT(src, TRAIT_NOPAINSTUN, TRAIT_GENERIC)
	ADD_TRAIT(src, TRAIT_NOBREATH, TRAIT_GENERIC)
	ADD_TRAIT(src, TRAIT_DEATHLESS, TRAIT_GENERIC)
	ADD_TRAIT(src, TRAIT_TOXIMMUNE, TRAIT_GENERIC)
	ADD_TRAIT(src, TRAIT_CHUNKYFINGERS, TRAIT_GENERIC)
	ADD_TRAIT(src, TRAIT_NOSLEEP, TRAIT_GENERIC)
	ADD_TRAIT(src, TRAIT_BASHDOORS, TRAIT_GENERIC)
	ADD_TRAIT(src, TRAIT_BLOODLOSS_IMMUNE, TRAIT_GENERIC)
	ADD_TRAIT(src, TRAIT_ZOMBIE_SPEECH, TRAIT_GENERIC)
	ADD_TRAIT(src, TRAIT_ZOMBIE_IMMUNE, TRAIT_GENERIC)
	ADD_TRAIT(src, TRAIT_ROTMAN, TRAIT_GENERIC)
	ADD_TRAIT(src, TRAIT_SILVER_WEAK, TRAIT_GENERIC)
	ADD_TRAIT(src, TRAIT_DEADITE, TRAIT_GENERIC)

	//deadite statline - intentionally uniform
	H.STASTR = 14
	H.STASPD = 5
	H.STACON = 12
	H.STAWIL = 13
	H.STAINT = 1
	H.STAPER = 13

	//lastly, nessessity for ALL NPCs -> our examine trait
	ADD_TRAIT(src, TRAIT_NPC_EXAMINE, TRAIT_GENERIC)

	//Clear our hands out, we don't need stuff here.
	r_hand = null
	l_hand = null

/mob/living/carbon/human/proc/deadite_get_aimheight(victim)
	if(!(mobility_flags & MOBILITY_STAND))
		return rand(1, 2) // Bite their ankles!
	return pick(rand(11, 13), rand(14, 17), rand(5, 8)) // Chest, neck, and mouth; face and ears; arms and hands.

// This proc exists because non-converted deadites don't have minds and can't have the antag datum
// So we need two separate entry points for this logic
/mob/living/carbon/human/proc/do_deadite_attack(mob/living/victim)
	// first, we try to bite
	if(try_do_deadite_bite(victim))
		return TRUE // spent our turn
	return FALSE

/mob/living/carbon/human/proc/try_do_deadite_bite(mob/living/victim)
	if(!src || stat >= DEAD)
		return FALSE
	
	var/obj/item/grabbing/bite/bite = get_item_by_slot(SLOT_MOUTH)
	if(istype(bite))
		// 50% chance to continue biting if already started
		if(prob(50))
			bite.bitelimb(src)
			return TRUE
		return FALSE // try something else like grappling

	if(!victim) // if we aren't passed a target, find one at random from nearby. this is currently unused
		for(var/mob/living/carbon/human in view(1, src))
			if(human == src) //prevent self biting
				continue
			if((human.mob_biotypes & MOB_UNDEAD) || ("undead" in human.faction) || HAS_TRAIT(human, TRAIT_ZOMBIE_IMMUNE))
				continue
			victim = human

	if(!victim) // still no one to bite
		return FALSE

	if(!get_location_accessible(src, BODY_ZONE_PRECISE_MOUTH, grabs = TRUE)) // can't bite, mouth is covered!
		return FALSE

	victim.onbite(src)
	// onbite doesn't directly apply the attack delay so we do it here
	changeNext_move(/datum/intent/bite::clickcd)
	return TRUE // use up our turn regardless of if the bite succeeded or not

/mob/living/carbon/human/proc/try_do_deadite_idle()

	if(mob_timers["deadite_idle"])
		if(world.time < mob_timers["deadite_idle"] + rand(5 SECONDS, 10 SECONDS))
			return
	mob_timers["deadite_idle"] = world.time
	emote("idle")
/// Use this to attempt to add the zombie antag datum to a human
/mob/living/carbon/human/proc/zombie_check()
	if(!mind)
		return
	var/already_zombie = mind.has_antag_datum(/datum/antagonist/zombie)
	if(already_zombie)
		return already_zombie
	if(mind.has_antag_datum(/datum/antagonist/vampire))
		return
	if(mind.has_antag_datum(/datum/antagonist/werewolf))
		return
	if(mind.has_antag_datum(/datum/antagonist/gnoll))
		return
	if(mind.has_antag_datum(/datum/antagonist/hag))
		return
	if(mind.has_antag_datum(/datum/antagonist/skeleton))
		return
	if(HAS_TRAIT(src, TRAIT_ZOMBIE_IMMUNE))
		return
	return mind.add_antag_datum(/datum/antagonist/zombie)
/**
 * This occurs when one zombie infects a living human, going into instadeath from here is kind of shit and confusing
 * We instead just transform at the end
 */
/mob/living/carbon/human/proc/zombie_infect_attempt()
	var/datum/antagonist/zombie/zombie_antag = zombie_check()
	if(!zombie_antag)
		return
	if(stat >= DEAD) //do shit the natural way i guess
		return FALSE
	if(HAS_TRAIT(src, TRAIT_ZOMBIE_IMMUNE))
		return FALSE
	var/datum/status_effect/zombie_infection/infection = has_status_effect(/datum/status_effect/zombie_infection)
	if(infection)
		var/time_remaining = infection.transformation_time - world.time
		infection.transformation_time = world.time + (time_remaining * 0.8)
		return
	if(!prob(ZOMBIE_INFECTION_PROBABILITY))	//Failed the probability of infection
		return
	to_chat(src, span_danger("I feel horrible... REALLY horrible..."))
	mob_timers["puke"] = world.time
	vomit(1, blood = TRUE, stun = FALSE)
	src.infected = TRUE //Is this in use? Just in case it is
	apply_status_effect(/datum/status_effect/zombie_infection, 5 MINUTES, FALSE)
	return zombie_antag

/mob/living/carbon/human/proc/wake_zombie()
	var/datum/antagonist/zombie/zombie_antag = mind?.has_antag_datum(/datum/antagonist/zombie)
	if(!zombie_antag || zombie_antag.has_turned)
		return FALSE
	flash_fullscreen("redflash3")
	to_chat(src, span_danger("It hurts... Is this really the end for me?"))
	emote("scream") // heres your warning to others bro
	Knockdown(1)
	drop_all_held_items()
	zombie_antag.wake_zombie(TRUE)
	return TRUE
