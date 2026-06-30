GLOBAL_LIST_INIT(searaider_aggro, world.file2list("strings/rt/searaideraggrolines.txt"))

/mob/living/carbon/human/species/human/northern/searaider
	ai_controller = /datum/ai_controller/human_npc
	d_intent = INTENT_PARRY
	faction = list(FACTION_GRONNMEN, FACTION_STATION)
	ambushable = FALSE
	dodgetime = 30
	blood_toll_bucket = STATS_KILLED_GRONNMEN


/mob/living/carbon/human/species/human/northern/searaider/ambush
	threat_point = THREAT_MODERATE
	ambush_faction = "raiders"



/mob/living/carbon/human/species/human/northern/searaider/Initialize()
	. = ..()
	set_species(pick(NPC_RACES_TYPES))
	addtimer(CALLBACK(src, PROC_REF(after_creation)), 1 SECONDS)


/mob/living/carbon/human/species/human/northern/searaider/after_creation()
	..()
	AddComponent(/datum/component/ai_aggro_system)
	SEND_SIGNAL(src, COMSIG_MOB_MODIFY_AGGRO_LINES, GLOB.searaider_aggro, TRUE)
	job = "Sea Raider"
	ADD_TRAIT(src, TRAIT_NOMOOD, TRAIT_GENERIC)
	ADD_TRAIT(src, TRAIT_NOHUNGER, TRAIT_GENERIC)
	ADD_TRAIT(src, TRAIT_HEAVYARMOR, TRAIT_GENERIC)
	ADD_TRAIT(src, TRAIT_LEECHIMMUNE, INNATE_TRAIT)
	ADD_TRAIT(src, TRAIT_BREADY, TRAIT_GENERIC)
	ADD_TRAIT(src, TRAIT_NPC_EXAMINE, TRAIT_GENERIC)
	equipOutfit(new /datum/outfit/job/roguetown/human/species/human/northern/searaider)
	var/obj/item/bodypart/head/head = get_bodypart(BODY_ZONE_HEAD)
	head.sellprice = HEAD_BOUNTY_SEARAIDER
	var/hairf = pick(list(
						/datum/sprite_accessory/hair/head/lowbraid,
						/datum/sprite_accessory/hair/head/countryponytailalt))
	var/hairm = pick(list(
						/datum/sprite_accessory/hair/head/ponytailwitcher,
						/datum/sprite_accessory/hair/head/lowbraid))
	var/beard = pick(list(
						/datum/sprite_accessory/hair/facial/viking,
						/datum/sprite_accessory/hair/facial/manly,
						/datum/sprite_accessory/hair/facial/longbeard))
	dna.species.handle_body(src)
	//Begin RANDOMISE here
	gender = pick(MALE, FEMALE)
	dna.species.random_character(src) //Now we just randomise here, MUST be called after both race + gender
	//But then we must do our y'know, hair and shit after this.
	random_voice_NPC()
	//Next up, we add hair BECAUSE we want the sovlful styles, only
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

	var/obj/item/organ/eyes/organ_eyes = getorgan(/obj/item/organ/eyes)
	organ_eyes.eye_color = random_eye_color()
	organ_eyes.accessory_colors = "[eye_color][eye_color]"

	if(gender == FEMALE)
		real_name = pick(world.file2list("strings/rt/names/human/vikingf.txt"))
	else
		real_name = pick(world.file2list("strings/rt/names/human/vikingm.txt"))
	update_hair()
	update_body()
	src.regenerate_icons() //Fixes the weird body but lets check performance first


/datum/outfit/job/roguetown/human/species/human/northern/searaider/pre_equip(mob/living/carbon/human/H)
	belt = /obj/item/storage/belt/rogue/leather //Cosmetic + Holding repair kits for looting mostly.
	if(prob(15))
		beltl = /obj/item/repair_kit/bad //So you can get repair kits easier from looting them
	wrists = /obj/item/clothing/wrists/roguetown/bracers/leather
	if(prob(50))
		wrists = wrists = /obj/item/clothing/wrists/roguetown/bracers/copper
	shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/vagrant
	if(prob(50))
		shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/sailor //We don't want anything that dips below waist, looks bad w/kilt
	if(prob(20))
		id = /obj/item/clothing/neck/roguetown/psicross/inhumen/graggar //SHATTER MY BINDS
	var/armor_choice = rand(1, 4)
	switch(armor_choice)
		if(1)
			armor = /obj/item/clothing/suit/roguetown/armor/chainmail/iron
		if(2)
			armor = /obj/item/clothing/suit/roguetown/armor/leather/hide
		if(3)
			armor = /obj/item/clothing/suit/roguetown/armor/plate/cuirass/copper
		if(4)
			armor = /obj/item/clothing/suit/roguetown/armor/gambeson
	var/cloak_choice = rand(1, 4)
	switch(cloak_choice)
		if(1)
			cloak = /obj/item/clothing/cloak/raincloak/furcloak/brown
		if(2)
			cloak = /obj/item/clothing/cloak/raincloak/furcloak/black
		if(3)
			cloak = /obj/item/clothing/cloak/raincloak/furcloak //White
		if(4)
			cloak = /obj/item/clothing/cloak/volfmantle
	var/leg_choice = rand(1, 3)
	switch(leg_choice)
		if(1)
			pants = /obj/item/clothing/under/roguetown/chainlegs/iron
		if(2)
			pants = /obj/item/clothing/under/roguetown/chainlegs/iron/kilt
		if(3)
			pants = /obj/item/clothing/under/roguetown/heavy_leather_pants/bronzeskirt
	if(prob(60)) //60% of a random helmet
		var/helmet_choice = rand(1, 4)
		switch(helmet_choice)
			if(1)
				head = /obj/item/clothing/head/roguetown/helmet/horned //SOVL
			if(2)
				head = /obj/item/clothing/head/roguetown/helmet/sallet/iron/banded
			if(3)
				head = /obj/item/clothing/head/roguetown/helmet/leather/volfhelm
			if(4)
				head = /obj/item/clothing/head/roguetown/helmet/leather
	var/neck_choice = rand(1, 3)
	switch(neck_choice)
		if(1)
			neck = /obj/item/clothing/neck/roguetown/gorget //SOVL
		if(2)
			neck = /obj/item/clothing/neck/roguetown/chaincoif/iron
		if(3)
			neck = /obj/item/clothing/neck/roguetown/bevor/iron
	gloves = /obj/item/clothing/gloves/roguetown/leather
	if(prob(40))
		gloves = /obj/item/clothing/gloves/roguetown/plate/iron/banded
	switch(rand(1, 6))
		if(1)
			r_hand = /obj/item/rogueweapon/sword/iron
			l_hand = /obj/item/rogueweapon/shield/wood
		if(2)
			r_hand = /obj/item/rogueweapon/stoneaxe/handaxe
			l_hand = /obj/item/rogueweapon/shield/wood
		if(3)
			r_hand = /obj/item/rogueweapon/spear
		if(4)
			r_hand = /obj/item/rogueweapon/greataxe
		if(5)
			r_hand = /obj/item/rogueweapon/greatsword/iron
		if(6) //GRAGGAR, LET ME BE WITNESSED
			r_hand = /obj/item/rogueweapon/stoneaxe/handaxe/copper
			l_hand = /obj/item/rogueweapon/stoneaxe/handaxe/copper
			ADD_TRAIT(H, TRAIT_DUALWIELDER, TRAIT_GENERIC) //lets them actually use it, not just for show, sire.

	shoes = /obj/item/clothing/shoes/roguetown/boots/furlinedboots
	if(prob(30))
		shoes = /obj/item/clothing/shoes/roguetown/boots/leather
	H.STASPD = 9
	H.STACON = 7
	H.STAWIL = 8
	H.STAPER = 8 //AIMING? Who needs that lame-ass shit? GRAGGAR GRAGGAR GRAGGAR!!
	H.STAINT = 8 //Minimal req to use specials
	H.STASTR = 14
	H.adjust_skillrank(/datum/skill/combat/polearms, 3, TRUE)
	H.adjust_skillrank(/datum/skill/combat/maces, 3, TRUE)
	H.adjust_skillrank(/datum/skill/combat/axes, 3, TRUE)
	H.adjust_skillrank(/datum/skill/combat/swords, 3, TRUE)
	H.adjust_skillrank(/datum/skill/combat/shields, 3, TRUE)
	H.adjust_skillrank(/datum/skill/combat/unarmed, 3, TRUE)
	H.adjust_skillrank(/datum/skill/combat/wrestling, 3, TRUE)
	H.adjust_skillrank(/datum/skill/misc/swimming, 2, TRUE)
	H.adjust_skillrank(/datum/skill/misc/climbing, 2, TRUE)

	H.dna.species.soundpack_m = GLOB.voice_packs[/datum/voicepack/male/warrior]
	H.dna.species.soundpack_f = GLOB.voice_packs[/datum/voicepack/female/warrior]

/mob/living/carbon/human/species/human/northern/searaider/archer
	ai_controller = /datum/ai_controller/human_npc/archer
	var/archer_outfit = /datum/outfit/job/roguetown/human/species/human/northern/searaider/archer

/mob/living/carbon/human/species/human/northern/searaider/archer/ambush
	threat_point = THREAT_MODERATE
	ambush_faction = "raiders"

/mob/living/carbon/human/species/human/northern/searaider/archer/ambush/reaver
	archer_outfit = /datum/outfit/job/roguetown/human/species/human/northern/searaider/archer/reaver

/mob/living/carbon/human/species/human/northern/searaider/archer/after_creation()
	..()
	STAPER = 12
	STAINT = 8
	STASTR = 12 // These are archers
	for(var/obj/item/I in held_items)
		qdel(I)
	for(var/obj/item/I in get_equipped_items(FALSE))
		if(istype(I, /obj/item/gun) || istype(I, /obj/item/quiver))
			qdel(I)
	equipOutfit(new archer_outfit)

/datum/outfit/job/roguetown/human/species/human/northern/searaider/archer/pre_equip(mob/living/carbon/human/H)
	wrists = /obj/item/clothing/wrists/roguetown/bracers/leather
	armor = /obj/item/clothing/suit/roguetown/armor/chainmail/iron
	shirt = /obj/item/clothing/suit/roguetown/shirt/tunic
	pants = /obj/item/clothing/under/roguetown/tights
	head = /obj/item/clothing/head/roguetown/helmet/leather
	gloves = /obj/item/clothing/gloves/roguetown/leather
	shoes = /obj/item/clothing/shoes/roguetown/boots/leather
	backr = /obj/item/gun/ballistic/revolver/grenadelauncher/bow/recurve
	backl = /obj/item/quiver/arrows
	r_hand = /obj/item/rogueweapon/sword/iron
	H.STASPD = 9
	H.STACON = 8
	H.STAWIL = 8
	H.STAPER = 13
	H.STAINT = 1
	H.STASTR = 12
	H.adjust_skillrank(/datum/skill/combat/bows, 3, TRUE)
	H.adjust_skillrank(/datum/skill/combat/polearms, 3, TRUE)
	H.adjust_skillrank(/datum/skill/combat/maces, 3, TRUE)
	H.adjust_skillrank(/datum/skill/combat/axes, 3, TRUE)
	H.adjust_skillrank(/datum/skill/combat/swords, 3, TRUE)
	H.adjust_skillrank(/datum/skill/combat/shields, 3, TRUE)
	H.adjust_skillrank(/datum/skill/combat/unarmed, 3, TRUE)
	H.adjust_skillrank(/datum/skill/combat/wrestling, 3, TRUE)
	H.adjust_skillrank(/datum/skill/misc/swimming, 2, TRUE)
	H.adjust_skillrank(/datum/skill/misc/climbing, 2, TRUE)
	H.upgrade_ai_controller(/datum/ai_controller/human_npc/archer)

/datum/outfit/job/roguetown/human/species/human/northern/searaider/archer/reaver/pre_equip(mob/living/carbon/human/H)
	..()
	backl = /obj/item/quiver/randomfill/reaver
