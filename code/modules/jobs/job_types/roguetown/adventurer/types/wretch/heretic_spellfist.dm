// Heretic Spellfist - Wretch spellfist 
// You get T1 as a toolkit for self sustain. NOT A WRESTLING CLASS
/datum/advclass/wretch/heretic_spellfist
	name = "Heretic Spellfist"
	tutorial = "You are a Heretic Spellfist, a battlemage that combines arcyne magyck with martial prowess to enhance yourself in unarmed combat. Your art descends from the Pontifexes of Naledi, warrior-monks who first learned to channel arcyne power through their fists — though the technique has since spread to radical Psydonite sects and Lingyuese monasteries alike. In your journey to power, you have managed to gain the blessing of a divine patron, granting you access to miracles to further augment your abilities. Come what may. With Faith, Fists and Magyck, all will be overcome."
	allowed_sexes = list(MALE, FEMALE)
	allowed_races = RACES_ALL_KINDS
	outfit = /datum/outfit/job/roguetown/wretch/heretic_spellfist
	maximum_possible_slots = 2
	class_select_category = CLASS_CAT_BATTLEMAGE
	category_tags = list(CTAG_WRETCH)
	traits_applied = list(TRAIT_DODGEEXPERT, TRAIT_CIVILIZEDBARBARIAN, TRAIT_ARCYNE_T1)
	subclass_stats = list(
		STATKEY_STR = 1,
		STATKEY_SPD = 1,
		STATKEY_WIL = 2,
		STATKEY_PER = 1,
		STATKEY_CON = 1
	)
	subclass_spell_point_pools = list("utility" = 4)
	subclass_skills = list(
		/datum/skill/combat/wrestling = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/unarmed = SKILL_LEVEL_EXPERT,
		/datum/skill/misc/swimming = SKILL_LEVEL_NOVICE,
		/datum/skill/misc/climbing = SKILL_LEVEL_EXPERT,
		/datum/skill/misc/athletics = SKILL_LEVEL_EXPERT,
		/datum/skill/misc/reading = SKILL_LEVEL_APPRENTICE,
		/datum/skill/magic/arcane = SKILL_LEVEL_APPRENTICE,
		/datum/skill/magic/holy = SKILL_LEVEL_NOVICE,
	)
	subclass_stashed_items = list(
		"Sewing Kit" = /obj/item/repair_kit/bad,
		"Armor Plates" = /obj/item/repair_kit/metal/bad,
	)

/datum/outfit/job/roguetown/wretch/heretic_spellfist/pre_equip(mob/living/carbon/human/H)
	..()
	head = /obj/item/clothing/head/roguetown/headband/monk
	shoes = /obj/item/clothing/shoes/roguetown/boots/armor/iron
	pants = /obj/item/clothing/under/roguetown/brigandinelegs
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/heavy
	armor = /obj/item/clothing/suit/roguetown/armor/brigandine/light
	gloves = /obj/item/clothing/gloves/roguetown/angle
	neck = /obj/item/clothing/neck/roguetown/gorget
	wrists = /obj/item/clothing/wrists/roguetown/bracers/leather/heavy
	belt = /obj/item/storage/belt/rogue/leather
	backl = /obj/item/storage/backpack/rogue/satchel
	beltl = /obj/item/storage/belt/rogue/pouch/coins/poor
	beltr = /obj/item/rogueweapon/huntingknife
	var/naledi_book = pick(/obj/item/book/rogue/naledi1, /obj/item/book/rogue/naledi2, /obj/item/book/rogue/naledi3, /obj/item/book/rogue/naledi4)
	backpack_contents = list(
		/obj/item/flashlight/flare/torch = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
		/obj/item/reagent_containers/glass/bottle/alchemical/healthpot = 1,
		(naledi_book) = 1
	)


	var/weapon_choice = input(H, "Choose your sidearm.", "SIDEARM") as anything in list("Katar", "Knuckledusters")
	switch(weapon_choice)
		if("Katar")
			H.put_in_hands(new /obj/item/rogueweapon/katar(H))
		if("Knuckledusters")
			H.put_in_hands(new /obj/item/rogueweapon/knuckles(H))

	if(H.mind)
		H.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/projectile/fist_of_psydon)
		H.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/projectile/grasp_of_psydon)
		H.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/blink)
		H.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/storm_of_psydon)
		H.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/touch/prestidigitation)

	var/datum/devotion/C = new /datum/devotion(H, H.patron)
	C.grant_miracles(H, cleric_tier = CLERIC_T1, passive_gain = CLERIC_REGEN_MINOR, devotion_limit = CLERIC_REQ_1, start_maxed = TRUE)

	H.cmode_music = 'sound/music/combat_heretic.ogg'
	wretch_select_bounty(H)
