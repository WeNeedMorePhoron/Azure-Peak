/datum/job/roguetown/testmage
	title = "Test Mage"
	flag = TESTER
	department_flag = SLOP
	faction = "Station"
	total_positions = 0
	spawn_positions = 0
	min_pq = null
	allowed_sexes = list(MALE, FEMALE)
	allowed_races = RACES_ALL_KINDS
	allowed_ages = list(AGE_ADULT)
	tutorial = "A test mage with maximum aspect points for testing purposes."
	outfit = /datum/outfit/job/roguetown/testmage
	plevel_req = 0
	display_order = JDO_MERCENARY
	spells = list()
	job_traits = list(TRAIT_ARCYNE, TRAIT_ALCHEMY_EXPERT)
	job_subclasses = list(
		/datum/advclass/testmage
	)

/datum/outfit/job/roguetown/testmage

/datum/advclass/testmage
	name = "Test Mage"
	tutorial = "A test mage with maximum aspect points."
	outfit = /datum/outfit/job/roguetown/testmage
	traits_applied = list(TRAIT_ARCYNE, TRAIT_ALCHEMY_EXPERT)
	subclass_mage_aspects = list("mastery" = TRUE, "major" = 7, "minor" = 15, "utilities" = 60)
	subclass_stats = list(
		STATKEY_INT = 10,
		STATKEY_PER = 5,
		STATKEY_SPD = 3,
		STATKEY_WIL = 5,
		STATKEY_CON = 3
	)
	subclass_skills = list(
		/datum/skill/magic/arcane = SKILL_LEVEL_LEGENDARY,
		/datum/skill/misc/reading = SKILL_LEVEL_MASTER,
		/datum/skill/craft/alchemy = SKILL_LEVEL_MASTER,
		/datum/skill/combat/staves = SKILL_LEVEL_JOURNEYMAN,
	)

/datum/outfit/job/roguetown/testmage/pre_equip(mob/living/carbon/human/H)
	..()
	r_hand = /obj/item/rogueweapon/woodstaff/implement
	l_hand = /obj/item/rogueweapon/wand
	belt = /obj/item/storage/belt/rogue/leather
	beltl = /obj/item/storage/magebag/associate
	backl = /obj/item/storage/backpack/rogue/satchel
	backpack_contents = list(
		/obj/item/book/spellbook = 1,
		/obj/item/chalk = 1,
		)
	H.adjust_skillrank_up_to(/datum/skill/magic/arcane, SKILL_LEVEL_LEGENDARY, TRUE)
	H.adjust_skillrank_up_to(/datum/skill/misc/reading, SKILL_LEVEL_MASTER, TRUE)
	H.adjust_skillrank_up_to(/datum/skill/craft/alchemy, SKILL_LEVEL_MASTER, TRUE)
	H.adjust_skillrank_up_to(/datum/skill/combat/staves, SKILL_LEVEL_JOURNEYMAN, TRUE)
