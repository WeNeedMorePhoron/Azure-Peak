/mob/living/carbon/human/species/human/northern/thief //I'm a thief, give me your shit
	ai_controller = /datum/ai_controller/human_npc
	faction = list(FACTION_THIEVES)
	ambushable = FALSE
	dodgetime = 30
	a_intent = INTENT_HELP
	m_intent = MOVE_INTENT_SNEAK
	d_intent = INTENT_DODGE



/mob/living/carbon/human/species/human/northern/thief/Initialize()
	. = ..()
	set_species(/datum/species/human/northern)
	addtimer(CALLBACK(src, PROC_REF(after_creation)), 1 SECONDS)

/mob/living/carbon/human/species/human/northern/thief/after_creation()
	..()
	AddComponent(/datum/component/ai_aggro_system)
	job = "Thief"
	ADD_TRAIT(src, TRAIT_NOMOOD, TRAIT_GENERIC)
	ADD_TRAIT(src, TRAIT_NOHUNGER, TRAIT_GENERIC)
	ADD_TRAIT(src, TRAIT_LIGHT_STEP, TRAIT_GENERIC)
	ADD_TRAIT(src, TRAIT_DODGEEXPERT, TRAIT_GENERIC)
	ADD_TRAIT(src, TRAIT_LEECHIMMUNE, INNATE_TRAIT)
	ADD_TRAIT(src, TRAIT_BREADY, TRAIT_GENERIC)
	ADD_TRAIT(src, TRAIT_NPC_EXAMINE, TRAIT_GENERIC)
	equipOutfit(new /datum/outfit/job/roguetown/human/species/human/northern/thief)
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
	var/hairf = pick(list(
						/datum/sprite_accessory/hair/head/lowbraid,
						/datum/sprite_accessory/hair/head/countryponytailalt,
						/datum/sprite_accessory/hair/head/gloomy,
						/datum/sprite_accessory/hair/head/zone,
						/datum/sprite_accessory/hair/head/hime,
						/datum/sprite_accessory/hair/head/fluffy,
						/datum/sprite_accessory/hair/head/fluffylong))
	var/hairm = pick(list(
						/datum/sprite_accessory/hair/head/ponytailwitcher,
						/datum/sprite_accessory/hair/head/bowlcut, 
						/datum/sprite_accessory/hair/head/bowlcut2, 
						/datum/sprite_accessory/hair/head/rogue))

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

	if(gender == FEMALE)
		real_name = pick(world.file2list("strings/names/first_female.txt"))
	else
		real_name = pick(world.file2list("strings/names/first_male.txt"))
	update_hair()
	update_body()
	src.regenerate_icons() //Fixes the weird body but lets check performance first
	head.sellprice = HEAD_BOUNTY_THIEF


/datum/outfit/job/roguetown/human/species/human/northern/thief/pre_equip(mob/living/carbon/human/H)
	cloak = /obj/item/clothing/cloak/raincloak/mortus
	wrists = /obj/item/clothing/wrists/roguetown/bracers/leather
	if(prob(50))
		wrists = /obj/item/clothing/wrists/roguetown/bracers/copper
	armor = /obj/item/clothing/suit/roguetown/armor/plate/cuirass/copper
	if(prob(50))
		armor = /obj/item/clothing/suit/roguetown/armor/leather
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/light
	pants = /obj/item/clothing/under/roguetown/trou/leather
	head = /obj/item/clothing/head/roguetown/helmet/leather
	mask = /obj/item/clothing/mask/rogue/skullmask
	neck = /obj/item/clothing/neck/roguetown/gorget/copper
	if(prob(50))
		neck = /obj/item/clothing/neck/roguetown/leather
	gloves = /obj/item/clothing/gloves/roguetown/leather
	shoes = /obj/item/clothing/shoes/roguetown/boots/leather
	l_hand = /obj/item/rogueweapon/huntingknife/idagger
	if(prob(50))
		l_hand = /obj/item/rogueweapon/huntingknife/copper
	H.STASTR = 11
	H.STASPD = 12
	H.STACON = 5
	H.STAWIL = 5
	H.STAPER = 11
	H.STAINT = 1
	H.adjust_skillrank(/datum/skill/combat/knives, 3, TRUE)
	H.adjust_skillrank(/datum/skill/combat/maces, 2, TRUE)
	H.adjust_skillrank(/datum/skill/combat/unarmed, 2, TRUE)
	H.adjust_skillrank(/datum/skill/combat/wrestling, 2, TRUE)
	H.adjust_skillrank(/datum/skill/misc/swimming, 2, TRUE)
	H.adjust_skillrank(/datum/skill/misc/climbing, 2, TRUE)

	if(prob(30))
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
				H.dna.species.soundpack_f = GLOB.voice_packs[/datum/voicepack/female/dainty]
