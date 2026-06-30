/* 
*	these guys are intended to be a speedbump to solo adventurers at mount decap
*	deadly but small in numbers. come back with a party, chump
*/

/mob/living/carbon/human/species/human/northern/mad_touched_treasure_hunter
	ai_controller = /datum/ai_controller/human_npc
	d_intent = INTENT_PARRY
	faction = list(FACTION_MADMEN, FACTION_BANDITS) // Avoid them hitting bandits in dungeon
	ambushable = FALSE
	dodgetime = 15
	var/mad_outfit = /datum/outfit/job/roguetown/human/species/human/northern/mad_touched_treasure_hunter

/mob/living/carbon/human/species/human/northern/mad_touched_treasure_hunter/ambush
	threat_point = THREAT_DANGEROUS
	ambush_faction = "treasure_hunters"

/mob/living/carbon/human/species/human/northern/mad_touched_treasure_hunter/Initialize()
	. = ..()
	set_species(/datum/species/human/northern)
	addtimer(CALLBACK(src, PROC_REF(after_creation)), 1 SECONDS)

/mob/living/carbon/human/species/human/northern/mad_touched_treasure_hunter/after_creation()
	..()
	AddComponent(/datum/component/ai_aggro_system)
	job = "Mad-touched Treasure Hunter"
	ADD_TRAIT(src, TRAIT_NOMOOD, TRAIT_GENERIC)
	ADD_TRAIT(src, TRAIT_NOHUNGER, TRAIT_GENERIC)
	ADD_TRAIT(src, TRAIT_MEDIUMARMOR, TRAIT_GENERIC)
	ADD_TRAIT(src, TRAIT_INFINITE_STAMINA, TRAIT_GENERIC)
	ADD_TRAIT(src, TRAIT_HEAVYARMOR, TRAIT_GENERIC)
	ADD_TRAIT(src, TRAIT_LEECHIMMUNE, INNATE_TRAIT)
	ADD_TRAIT(src, TRAIT_DISFIGURED, TRAIT_GENERIC)
	ADD_TRAIT(src, TRAIT_CRITICAL_RESISTANCE, TRAIT_GENERIC)
	ADD_TRAIT(src, TRAIT_NOPAINSTUN, TRAIT_GENERIC)
	ADD_TRAIT(src, TRAIT_NOPAIN, TRAIT_GENERIC)
	ADD_TRAIT(src, TRAIT_NPC_EXAMINE, TRAIT_GENERIC)
	equipOutfit(new mad_outfit)
	gender = pick(MALE, FEMALE)
	dna.species.handle_body(src)

	var/species = list(
		/datum/species/human/northern,
		/datum/species/human/northern, //Extra bias towards humens and wood/half elves
		/datum/species/human/northern,
		/datum/species/elf/wood,
		/datum/species/elf/wood,
		/datum/species/human/halfelf,
		/datum/species/human/halfelf,
		/datum/species/dwarf/mountain,
	)
	
	set_species(pick(species))
	var/obj/item/bodypart/head/head = get_bodypart(BODY_ZONE_HEAD)
	head.sellprice = HEAD_BOUNTY_MAD_TOUCHED
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
	//No beard, doesn't fit well with our hood.

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
	//Now we take skin-tone picks
	var/obj/item/organ/ears/organ_ears = getorgan(/obj/item/organ/ears)
	var/skintone_choice = rand(1, 7) //Heavily simplified
	switch(skintone_choice)
		if(1)
			skin_tone = "SKIN_COLOR_GRENZELHOFT"
			if(organ_ears)
				organ_ears.accessory_colors = "SKIN_COLOR_GRENZELHOFT"
		if(2)
			skin_tone = "SKIN_COLOR_AVAR"
			if(organ_ears)
				organ_ears.accessory_colors = "SKIN_COLOR_AVAR"
		if(3)
			skin_tone = "SKIN_COLOR_OTAVA"
			if(organ_ears)
				organ_ears.accessory_colors = "SKIN_COLOR_OTAVA"
		if(4)
			skin_tone = "SKIN_COLOR_SHALVISTINE"
			if(organ_ears)
				organ_ears.accessory_colors = "SKIN_COLOR_SHALVISTINE"
		if(5)
			skin_tone = "SKIN_COLOR_LALVESTINE"
			if(organ_ears)
				organ_ears.accessory_colors = "SKIN_COLOR_LALVESTINE"
		if(6)
			skin_tone = "SKIN_COLOR_NALEDI"
			if(organ_ears)
				organ_ears.accessory_colors = "SKIN_COLOR_NALEDI"
		if(7)
			skin_tone = "SKIN_COLOR_KAZENGUN"
			if(organ_ears)
				organ_ears.accessory_colors = "SKIN_COLOR_KAZENGUN"
	//Add our hair bodypart features
	head.add_bodypart_feature(new_hair)
	head.add_bodypart_feature(new_facial)

	dna.update_ui_block(DNA_HAIR_COLOR_BLOCK)

	var/obj/item/organ/eyes/organ_eyes = getorgan(/obj/item/organ/eyes)
	if(organ_eyes)
		var/eye_choice = rand(1, 8)
		switch(eye_choice)
			if(1)
				organ_eyes.eye_color = "#336699"
				organ_eyes.accessory_colors = "#336699#336699"
			if(2)
				organ_eyes.eye_color = "#339933"
				organ_eyes.accessory_colors = "#339933#339933"
			if(3)
				organ_eyes.eye_color = "#995333"
				organ_eyes.accessory_colors = "#995333#995333"
			if(4)
				organ_eyes.eye_color = "#131313" //Souless greytider look
				organ_eyes.accessory_colors = "#131313#131313"
			if(5)
				organ_eyes.eye_color = "#999233"
				organ_eyes.accessory_colors = "#999233#999233"
			if(6)
				organ_eyes.eye_color = "#993333"
				organ_eyes.accessory_colors = "#993333#993333"
			if(7)
				organ_eyes.eye_color = "#33997a"
				organ_eyes.accessory_colors = "#33997a#33997a"
			if(8)
				organ_eyes.eye_color = "#78bcc5"
				organ_eyes.accessory_colors = "#78bcc5#78bcc5"
	
	real_name = pick(world.file2list("strings/rt/names/human/mad_touched_names.txt"))

	update_hair()
	update_body()
	src.regenerate_icons() //Fixes the weird body


/datum/outfit/job/roguetown/human/species/human/northern/mad_touched_treasure_hunter/pre_equip(mob/living/carbon/human/H)
	wrists = /obj/item/clothing/wrists/roguetown/bracers/iron
	mask = /obj/item/clothing/mask/rogue/facemask/steel/paalloy/mad_touched
	armor = /obj/item/clothing/suit/roguetown/armor/leather/heavy
	pants = /obj/item/clothing/under/roguetown/platelegs/iron
	belt = /obj/item/storage/belt/rogue/leather
	neck = /obj/item/clothing/neck/roguetown/chaincoif/chainmantle
	gloves = /obj/item/clothing/gloves/roguetown/plate/iron/banded
	cloak = /obj/item/clothing/cloak/wickercloak
	if(prob(40))
		var/amulet_choice = rand(1, 4)
		switch(amulet_choice)
			if(1)
				id = /obj/item/clothing/neck/roguetown/psicross/inhumen/aalloy //ZIZO. ZIZO. ZIZO.
			if(2)
				id = /obj/item/clothing/neck/roguetown/psicross/aalloy
			if(3)
				id = /obj/item/clothing/neck/roguetown/psicross/noc/aalloy
			if(4)
				id = /obj/item/clothing/neck/roguetown/psicross/inhumen/matthios //IS THIS TRVE?!
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson
	if(prob(20))
		shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/light
	if(prob(33))
		beltl = /obj/item/reagent_containers/glass/bottle/alchemical/healthpot
	head = /obj/item/clothing/head/roguetown/menacing/mad_touched_treasure_hunter
	if(prob(50))
		head = /obj/item/clothing/head/roguetown/menacing/bandit/mad_touched_treasure_hunter //IS THIS TRVE?!
	if(prob(33))
		r_hand = /obj/item/rogueweapon/greatsword/paalloy
	else if(prob(33))
		r_hand = /obj/item/rogueweapon/shield/buckler
		l_hand = /obj/item/rogueweapon/huntingknife/idagger/steel/padagger
	else
		r_hand = /obj/item/rogueweapon/sword/sabre/bronzekhopesh
		l_hand = /obj/item/rogueweapon/sword/sabre/bronzekhopesh
		ADD_TRAIT(H, TRAIT_DUALWIELDER, TRAIT_GENERIC) //Making them an absolute menace again

	shoes = /obj/item/clothing/shoes/roguetown/boots/leather/reinforced
	//carbon ai is still pretty dumb so making them a threat to players requires pretty crazy looking stats. don't think too hard about it.
	H.STASTR = 15
	H.STASPD = 15
	H.STACON = 12
	H.STAWIL = 12
	H.STAPER = 15
	H.STAINT = 12

	H.adjust_skillrank(/datum/skill/combat/polearms, 4, TRUE)
	H.adjust_skillrank(/datum/skill/combat/maces, 2, TRUE)
	H.adjust_skillrank(/datum/skill/combat/axes, 2, TRUE)
	H.adjust_skillrank(/datum/skill/combat/swords, 4, TRUE)
	H.adjust_skillrank(/datum/skill/combat/knives, 4, TRUE)
	H.adjust_skillrank(/datum/skill/combat/shields, 4, TRUE)
	H.adjust_skillrank(/datum/skill/combat/unarmed, 3, TRUE)
	H.adjust_skillrank(/datum/skill/combat/wrestling, 3, TRUE)
	H.adjust_skillrank(/datum/skill/misc/swimming, 2, TRUE)
	H.adjust_skillrank(/datum/skill/misc/climbing, 2, TRUE)

	if(prob(40))
		var/voicepack_choice = rand(1, 4)
		switch(voicepack_choice)
			if(1)
				H.dna.species.soundpack_m = GLOB.voice_packs[/datum/voicepack/male/warrior]
				H.dna.species.soundpack_f = GLOB.voice_packs[/datum/voicepack/female/warrior]
			if(2)
				H.dna.species.soundpack_m = GLOB.voice_packs[/datum/voicepack/male/stern]
				H.dna.species.soundpack_f = GLOB.voice_packs[/datum/voicepack/female/haughty]
			if(3)
				H.dna.species.soundpack_m = GLOB.voice_packs[/datum/voicepack/male/foppish]
				H.dna.species.soundpack_f = GLOB.voice_packs[/datum/voicepack/female/dainty]
			if(4)
				H.dna.species.soundpack_m = GLOB.voice_packs[/datum/voicepack/male/knight]
				H.dna.species.soundpack_f = GLOB.voice_packs[/datum/voicepack/female/haughty]

/obj/item/clothing/head/roguetown/menacing/bandit/mad_touched_treasure_hunter //its here so it doesnt wind up on some class' loadout.
	name = "sack hood"
	desc = "A ragged hood of thick red dyed jute fibres. The itchiness is unbearable."
	sewrepair = TRUE
	armor = ARMOR_LEATHER

/obj/item/clothing/head/roguetown/menacing/mad_touched_treasure_hunter //its here so it doesnt wind up on some class' loadout.
	name = "sack hood"
	desc = "A ragged hood of thick jute fibres. The itchiness is unbearable."
	sewrepair = TRUE
	color = "#999999"
	armor = ARMOR_LEATHER

/obj/item/clothing/mask/rogue/facemask/steel/paalloy/mad_touched
	name = "eerie ancient mask"

/obj/item/clothing/mask/rogue/facemask/steel/paalloy/mad_touched/equipped(mob/user, slot)
	. = ..()
	if(slot == SLOT_WEAR_MASK)
		ADD_TRAIT(src, TRAIT_NODROP, CURSED_ITEM_TRAIT)
		var/mob/living/carbon/human/mad_touched = user
		mad_touched.apply_damage(25, BRUTE, BODY_ZONE_HEAD)

/obj/item/clothing/mask/rogue/facemask/steel/paalloy/mad_touched/dropped(mob/user)
	. = ..()
	REMOVE_TRAIT(src, TRAIT_NODROP, CURSED_ITEM_TRAIT)

/mob/living/carbon/human/species/human/northern/mad_touched_treasure_hunter/archer
	ai_controller = /datum/ai_controller/human_npc/archer
	mad_outfit = /datum/outfit/job/roguetown/human/species/human/northern/mad_touched_treasure_hunter/archer

/mob/living/carbon/human/species/human/northern/mad_touched_treasure_hunter/archer/ambush
	threat_point = THREAT_DANGEROUS
	ambush_faction = "treasure_hunters"

/mob/living/carbon/human/species/human/northern/mad_touched_treasure_hunter/archer/after_creation()
	..()
	job = "Mad-touched Marksman"

/datum/outfit/job/roguetown/human/species/human/northern/mad_touched_treasure_hunter/archer/pre_equip(mob/living/carbon/human/H)
	..()
	backr = /obj/item/gun/ballistic/revolver/grenadelauncher/bow/recurve
	backl = /obj/item/quiver/randomfill/highwayman
	beltr = /obj/item/quiver/randomfill/highwayman
	H.adjust_skillrank(/datum/skill/combat/bows, 5, TRUE)

/datum/ambush_config/solo_treasure_hunter
	mob_types = list(
		/mob/living/carbon/human/species/human/northern/mad_touched_treasure_hunter/ambush = 1,
	)
	threat_point = THREAT_ELITE
	faction_tag = "treasure_hunters"

/datum/ambush_config/duo_treasure_hunter
	mob_types = list(
		/mob/living/carbon/human/species/human/northern/mad_touched_treasure_hunter/ambush = 2,
	)
	threat_point = 2 * THREAT_ELITE
	faction_tag = "treasure_hunters"

/datum/ambush_config/treasure_hunter_posse
	mob_types = list(
		/mob/living/carbon/human/species/human/northern/mad_touched_treasure_hunter/ambush = 3,
	)
	threat_point = 3 * THREAT_ELITE
	faction_tag = "treasure_hunters"
