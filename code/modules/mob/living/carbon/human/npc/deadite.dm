/mob/living/carbon/human/species/npc/deadite
	ai_controller = /datum/ai_controller/human_npc
	d_intent = INTENT_DODGE //To simulate that deadites CANNOT parry
	dodgetime = 14
	ambushable = FALSE
	infected = TRUE

/mob/living/carbon/human/species/npc/deadite/Initialize()
	. = ..()
	var/species = list(
		/datum/species/human/northern,
		/datum/species/human/northern,
		/datum/species/human/northern,
		/datum/species/human/northern,
		/datum/species/elf/wood, //Extra bias towards humens and elves/half elves Because deadites are locals likely
		/datum/species/elf/wood,
		/datum/species/elf/wood,
		/datum/species/elf/wood,
		/datum/species/human/halfelf,
		/datum/species/human/halfelf,
		/datum/species/human/halfelf,
		/datum/species/human/halfelf,
		/datum/species/dwarf/mountain, //Racial bias ticks of w/other races from here on
		/datum/species/goblinp,
		/datum/species/elf/dark,
		/datum/species/aasimar,
		/datum/species/halforc,
		/datum/species/tieberian,
		/datum/species/anthromorph,
		/datum/species/anthromorphsmall,
		/datum/species/demihuman,
		/datum/species/akula,
		/datum/species/moth,
		/datum/species/tabaxi,
		/datum/species/vulpkanin,
		/datum/species/vulpkanin,
		/datum/species/dracon,
	)

	set_species(pick(species))
	gender = pick(MALE, FEMALE)
	dna.species.handle_body(src)
	dna.species.random_character(src)
	var/obj/item/bodypart/head/head = get_bodypart(BODY_ZONE_HEAD)
	var/hairf = pick(list(
						/datum/sprite_accessory/hair/head/lowbraid,
						/datum/sprite_accessory/hair/head/countryponytailalt,
						/datum/sprite_accessory/hair/head/gloomy,
						/datum/sprite_accessory/hair/head/zone,
						/datum/sprite_accessory/hair/head/hime,
						/datum/sprite_accessory/hair/head/stacy,
						/datum/sprite_accessory/hair/head/sabitsuki,
						/datum/sprite_accessory/hair/head/sabitsuki_ponytail, 
						/datum/sprite_accessory/hair/head/kusanagi_alt,
						/datum/sprite_accessory/hair/head/fluffy,
						/datum/sprite_accessory/hair/head/fluffylong))
	var/hairm = pick(list(
						/datum/sprite_accessory/hair/head/ponytailwitcher,
						/datum/sprite_accessory/hair/head/bowlcut, 
						/datum/sprite_accessory/hair/head/bowlcut2,
						/datum/sprite_accessory/hair/head/lowbraid,
						/datum/sprite_accessory/hair/head/emo,
						/datum/sprite_accessory/hair/head/sabitsuki,
						/datum/sprite_accessory/hair/head/sabitsuki_ponytail, 
						/datum/sprite_accessory/hair/head/rogue))
	var/beard = pick(list(/datum/sprite_accessory/hair/facial/stubble,
						/datum/sprite_accessory/hair/facial/manly,
						/datum/sprite_accessory/hair/facial/fiveoclockmoustache,
						/datum/sprite_accessory/hair/facial/sevenoclockm,
						/datum/sprite_accessory/hair/facial/chinlessbeard,
						/datum/sprite_accessory/hair/facial/fullbeard,
						/datum/sprite_accessory/hair/facial/chinstrap,
						/datum/sprite_accessory/hair/facial/vandyke,
						/datum/sprite_accessory/hair/facial/longbeard))

	//Random voices, this can probably be more random-ish but it'll do for now
	var/voice_choice = rand(1, 30)
	switch(voice_choice)
		if(1)
			src.voice_color = "0bb1e4"
		if(2)
			src.voice_color = "d30c0c"
		if(3)
			src.voice_color = "4d4afc"
		if(4)
			src.voice_color = "da40c0"
		if(5)
			src.voice_color = "51e251"
		if(6)
			src.voice_color = "a059cf"
		if(7)
			src.voice_color = "8700c5"
		if(8)
			src.voice_color = "cfc886"
		if(9)
			src.voice_color = "ff9100"
		if(10)
			src.voice_color = "a0a0a0"
		if(11)
			src.voice_color = "797979"
		if(12)
			src.voice_color = "ff5e00"
		if(13)
			src.voice_color = "cf855a"
		if(14)
			src.voice_color = "50b854"
		if(15)
			src.voice_color = "575ec5"
		if(16)
			src.voice_color = "9b51ad"
		if(17)
			src.voice_color = "ad4b79"
		if(18)
			src.voice_color = "a5ac46"
		if(19)
			src.voice_color = "aaaaaa"
		if(20)
			src.voice_color = "727272"
		if(21)
			src.voice_color = "c98f8f"
		if(22)
			src.voice_color = "fff9a4"
		if(23)
			src.voice_color = "c389d1"
		if(24)
			src.voice_color = "6b88da"
		if(25)
			src.voice_color = "ffffff"
		if(26)
			src.voice_color = "7bbb40"
		if(27)
			src.voice_color = "ff7627"
		if(28)
			src.voice_color = "c7c7c7"
		if(29)
			src.voice_color = "6e77aa"
		if(30)
			src.voice_color = "b3ae72"
	//Next up, we add hair
	var/datum/bodypart_feature/hair/head/new_hair = new()
	var/datum/bodypart_feature/hair/facial/new_facial = new()

	if(gender == FEMALE)
		new_hair.set_accessory_type(hairf, null, src)
	else
		new_hair.set_accessory_type(hairm, null, src)
		new_facial.set_accessory_type(beard, null, src)

	var/haircolor_choice = rand(1, 6)
	switch(haircolor_choice)
		if(1) //Blond-Brown
			new_hair.accessory_colors = "#C1A287"
			new_hair.hair_color = "#C1A287"
			new_facial.accessory_colors = "#C1A287"
			new_facial.hair_color = "#C1A287"
			hair_color = "#C1A287"
		if(2) //Ginger-ish
			new_hair.accessory_colors = "#A56B3D"
			new_hair.hair_color = "#A56B3D"
			new_facial.accessory_colors = "#A56B3D"
			new_facial.hair_color = "#A56B3D"
			hair_color = "#A56B3D"
		if(3) //Black
			new_hair.accessory_colors = "#0d0c2e"
			new_hair.hair_color = "#0d0c2e"
			new_facial.accessory_colors = "#0d0c2e"
			new_facial.hair_color = "#0d0c2e"
			hair_color = "#0d0c2e"
		if(4) //Red
			new_hair.accessory_colors = "#a53d3d"
			new_hair.hair_color = "#a53d3d"
			new_facial.accessory_colors = "#a53d3d"
			new_facial.hair_color = "#a53d3d"
			hair_color = "#a53d3d"
		if(5) //Olive
			new_hair.accessory_colors = "#767c3f"
			new_hair.hair_color = "#767c3f"
			new_facial.accessory_colors = "#767c3f"
			new_facial.hair_color = "#767c3f"
			hair_color = "#767c3f"
		if(6) //Dark Brown
			new_hair.accessory_colors = "#503516"
			new_hair.hair_color = "#503516"
			new_facial.accessory_colors = "#503516"
			new_facial.hair_color = "#503516"
			hair_color = "#503516"
		if(7) //Dull Blond
			new_hair.accessory_colors = "#bdbb6b"
			new_hair.hair_color = "#bdbb6b"
			new_facial.accessory_colors = "#bdbb6b"
			new_facial.hair_color = "#bdbb6b"
			hair_color = "#bdbb6b"
		if(8) //Dull Brown
			new_hair.accessory_colors = "#7e6d53"
			new_hair.hair_color = "#7e6d53"
			new_facial.accessory_colors = "#7e6d53"
			new_facial.hair_color = "#7e6d53"
			hair_color = "#7e6d53"

	//Add our hair bodypart features
	head.add_bodypart_feature(new_hair)
	head.add_bodypart_feature(new_facial)

	dna.update_ui_block(DNA_HAIR_COLOR_BLOCK)

	var/list/deadite_firstnames = world.file2list("strings/rt/names/other/deaditenpcfirst.txt")
	var/list/deadite_lastnames  = world.file2list("strings/rt/names/other/deaditenpclast.txt")


	real_name = "[pick(deadite_firstnames)] [pick(deadite_lastnames)]"

	addtimer(CALLBACK(src, PROC_REF(after_creation)), 1 SECONDS) //A second delay, let us race up first

/mob/living/carbon/human/species/npc/deadite/after_creation()
	. = ..()
	equipOutfit(new /datum/outfit/job/roguetown/deadite)
	make_deadite()

/mob/living/carbon/human/proc/make_deadite()
	//called after creation so species isn't overriding our skin color
	mob_biotypes |= MOB_UNDEAD
	//give ourselves undead eyes.
	var/obj/item/organ/eyes/eyes = getorganslot(ORGAN_SLOT_EYES)
	if(eyes)
		eyes.Remove(src,1)
		QDEL_NULL(eyes)
	eyes = SSwardrobe.provide_type(/obj/item/organ/eyes/night_vision/zombie)
	eyes.Insert(src)
	update_body()
	var/obj/item/organ/ears/organ_ears = getorgan(/obj/item/organ/ears)
	skin_tone = "#868e79"
	faction += "undead"
	faction -= "station"
	faction -= "neutral"
		//Give ourselves the deadite voicepack
	src.dna.species.soundpack_m = GLOB.voice_packs[/datum/voicepack/zombie/m]
	src.dna.species.soundpack_f = GLOB.voice_packs[/datum/voicepack/zombie/f]
	for(var/obj/item/bodypart/part as anything in bodyparts)
		if(!part.rotted && !part.skeletonized)
			part.rotted = TRUE
		part.update_disabled()
	if(organ_ears)
		organ_ears.accessory_colors = "#868e79"
	src.regenerate_icons()

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
	src.STASTR = 14
	src.STASPD = 5
	src.STACON = 12
	src.STAWIL = 13
	src.STAINT = 1
	src.STAPER = 13

	//lastly, nessessity for ALL NPCs -> our examine trait
	ADD_TRAIT(src, TRAIT_NPC_EXAMINE, TRAIT_GENERIC)

/datum/outfit/job/roguetown/deadite/pre_equip(mob/living/carbon/human/H)
	..()
	//We simulate being a """deadite""" here
	head = null
	beltr = null
	beltl = null
	if(prob(30))
		cloak = /obj/item/clothing/cloak/raincloak/brown
	else
		cloak = null
	if(prob(10))
		gloves = /obj/item/clothing/gloves/roguetown/fingerless
	else
		gloves = null

	if(H.gender == FEMALE)
		armor = /obj/item/clothing/suit/roguetown/shirt/rags
	else
		armor = null
		pants = /obj/item/clothing/under/roguetown/tights/vagrant
		if(prob(50))
			pants = /obj/item/clothing/under/roguetown/tights/vagrant/l
		shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/vagrant
		if(prob(50))
			shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/vagrant/l

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
