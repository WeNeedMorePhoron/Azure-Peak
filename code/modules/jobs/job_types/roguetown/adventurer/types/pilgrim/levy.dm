/datum/advclass/levy
	name = "Levy"
	tutorial = "When the bailiff came to your household it was the worst dae of your lyfe, dragging you away into service to the Crown with nothing more but whatever household object you managed to piece together into a weapon.<br><br>Safeguard your home from the terrors beyond the walls and those lurking in the bog, and always remember what you and your fellow troopers often say: 'Strenf'n'Numbas, carker!'. Or was it 'Get'em boys!'? Who knows!"
	allowed_sexes = list(MALE, FEMALE)
	
	outfit = /datum/outfit/job/roguetown/adventurer/levy
	traits_applied = list(TRAIT_LEVY_BOYS, TRAIT_DECEIVING_MEEKNESS, TRAIT_LEECHIMMUNE, TRAIT_JACKOFALLTRADES)
	cmode_music = 'sound/music/cmode/towner/combat_towner2.ogg'
	category_tags = list(CTAG_TOWNER)
	townie_contract_gate_exempt = TRUE
	maximum_possible_slots = 4 // fine, a squad of 4, because that's what squad means
	subclass_stats = list(
		STATKEY_STR = 2,
		STATKEY_PER = 1,
		STATKEY_SPD = 2,
		STATKEY_WIL = -1,
		STATKEY_INT = -2,
		STATKEY_LCK = -1, // worst dae of your lyfe, boyo...
	)
	subclass_skills = list(
		/datum/skill/combat/axes = SKILL_LEVEL_APPRENTICE,
		/datum/skill/combat/wrestling = SKILL_LEVEL_APPRENTICE,
		/datum/skill/combat/unarmed = SKILL_LEVEL_NOVICE,
		/datum/skill/misc/athletics = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/swimming = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/climbing = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/reading = SKILL_LEVEL_NOVICE,
		/datum/skill/craft/crafting = SKILL_LEVEL_APPRENTICE,
		/datum/skill/craft/cooking = SKILL_LEVEL_NOVICE,
		/datum/skill/craft/sewing = SKILL_LEVEL_NOVICE,
		/datum/skill/craft/carpentry = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/labor/lumberjacking = SKILL_LEVEL_APPRENTICE,
		/datum/skill/labor/farming = SKILL_LEVEL_NOVICE,
		/datum/skill/misc/hunting = SKILL_LEVEL_NOVICE,
		/datum/skill/labor/butchering = SKILL_LEVEL_APPRENTICE,
	)

/datum/outfit/job/roguetown/adventurer/levy/pre_equip(mob/living/carbon/human/H)
	..()
	head = /obj/item/clothing/head/roguetown/helmet/kettle/iron
	neck = /obj/item/clothing/neck/roguetown/coif
	mask = /obj/item/clothing/head/roguetown/armingcap
	cloak = /obj/item/clothing/cloak/tabard/stabard/bog/levy
	armor = /obj/item/clothing/suit/roguetown/armor/leather/cuirass
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson
	wrists = /obj/item/clothing/wrists/roguetown/bracers/leather
	belt = /obj/item/storage/belt/rogue/leather
	pants = /obj/item/clothing/under/roguetown/splintlegs
	shoes = /obj/item/clothing/shoes/roguetown/boots/armor/iron
	backl = /obj/item/storage/backpack/rogue/satchel
	beltl = /obj/item/signal_horn
	id = /obj/item/scomstone/bad
	backpack_contents = list(
		/obj/item/flashlight/flare/torch/lantern = 1,
		/obj/item/storage/belt/rogue/pouch/coins/poor = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
		/obj/item/rogueweapon/huntingknife = 1,
		)
	if(H.mind)
		var/list/weapons = list(
			"DA FAMILY SORD (Sword)",
			"DA BIGGA BEATSTICKE (Club)",
			"YEE-HAW!!! (Whip)",
			"MINE PITCHFORK (Polearm)",
			"MINE THRESHER (Flail)",
			"MINE SHOVEL (Axe)",
			"MINE PICK'AX (Pickaxe)",
			"MINE SCYTHE (Scythe)",
			"MINE WHOLE KITCHEN (Mess Kit + Cleaver)",
			"DESE CARKIN' HANDS (Unarmed)",
		)

		var/weapon_choice = input(H, "Choose your improvised weapon.", "WHAT DID YOU TAKE FROM YOUR HOME?") as anything in weapons
		H.set_blindness(0)
		switch(weapon_choice)
			if("MINE PITCHFORK (Polearm)")
				H.adjust_skillrank_up_to(/datum/skill/combat/polearms, SKILL_LEVEL_JOURNEYMAN, TRUE)
				r_hand = /obj/item/rogueweapon/spear/militia
				gloves = /obj/item/clothing/gloves/roguetown/chain/iron
				backr = /obj/item/rogueweapon/scabbard/gwstrap
				beltr = /obj/item/rogueweapon/stoneaxe/woodcut/woodcutter

			if("MINE THRESHER (Flail)")
				H.adjust_skillrank_up_to(/datum/skill/combat/whipsflails, SKILL_LEVEL_JOURNEYMAN, TRUE)
				r_hand = /obj/item/rogueweapon/flail/militia
				gloves = /obj/item/clothing/gloves/roguetown/chain/iron
				backr = /obj/item/rogueweapon/scabbard/gwstrap
				beltr = /obj/item/rogueweapon/stoneaxe/woodcut/woodcutter

			if ("DA FAMILY SORD (Sword)")
				H.adjust_skillrank_up_to(/datum/skill/combat/swords, SKILL_LEVEL_JOURNEYMAN, TRUE)
				r_hand = /obj/item/rogueweapon/sword/falchion/militia
				gloves = /obj/item/clothing/gloves/roguetown/chain/iron
				backr = /obj/item/rogueweapon/scabbard/sword
				beltr = /obj/item/rogueweapon/stoneaxe/woodcut/woodcutter

			if ("DA BIGGA BEATSTICKE (Club)")
				H.adjust_skillrank_up_to(/datum/skill/combat/maces, SKILL_LEVEL_JOURNEYMAN, TRUE)
				r_hand = /obj/item/rogueweapon/mace/woodclub/militia
				gloves = /obj/item/clothing/gloves/roguetown/chain/iron
				beltr = /obj/item/rogueweapon/stoneaxe/woodcut/woodcutter

			if ("MINE SHOVEL (Axe)")
				H.adjust_skillrank_up_to(/datum/skill/combat/axes, SKILL_LEVEL_JOURNEYMAN, TRUE)
				r_hand = /obj/item/rogueweapon/greataxe/militia
				gloves = /obj/item/clothing/gloves/roguetown/chain/iron
				backr = /obj/item/rogueweapon/scabbard/gwstrap
				beltr = /obj/item/rogueweapon/stoneaxe/woodcut/woodcutter

			if ("MINE PICK'AX (Pickaxe)")
				H.adjust_skillrank_up_to(/datum/skill/labor/mining, SKILL_LEVEL_JOURNEYMAN, TRUE)
				r_hand = /obj/item/rogueweapon/pick/militia
				gloves = /obj/item/clothing/gloves/roguetown/chain/iron
				backr = /obj/item/rogueweapon/stoneaxe/woodcut/woodcutter

			if ("MINE SCYTHE (Scythe)")
				H.adjust_skillrank_up_to(/datum/skill/labor/farming, SKILL_LEVEL_JOURNEYMAN, TRUE)
				r_hand = /obj/item/rogueweapon/scythe/militia
				gloves = /obj/item/clothing/gloves/roguetown/chain/iron
				backr = /obj/item/rogueweapon/scabbard/gwstrap
				beltr = /obj/item/rogueweapon/stoneaxe/woodcut/woodcutter

			if ("YEE-HAW!!! (Whip)")
				H.adjust_skillrank_up_to(/datum/skill/combat/whipsflails, SKILL_LEVEL_JOURNEYMAN, TRUE)
				r_hand = /obj/item/rogueweapon/whip
				gloves = /obj/item/clothing/gloves/roguetown/chain/iron
				backr = /obj/item/rogueweapon/stoneaxe/woodcut/woodcutter

			if ("MINE WHOLE KITCHEN (Mess Kit + Cleaver)")
				H.adjust_skillrank_up_to(/datum/skill/craft/cooking, SKILL_LEVEL_JOURNEYMAN, TRUE)
				H.adjust_skillrank_up_to(/datum/skill/combat/knives, SKILL_LEVEL_JOURNEYMAN, TRUE)
				r_hand = /obj/item/storage/gadget/messkit
				l_hand = /obj/item/rogueweapon/huntingknife/chefknife/cleaver
				gloves = /obj/item/clothing/gloves/roguetown/chain/iron
				beltr = /obj/item/rogueweapon/stoneaxe/woodcut/woodcutter

			if ("DESE CARKIN' HANDS (Unarmed)")
				H.adjust_skillrank_up_to(/datum/skill/combat/unarmed, SKILL_LEVEL_EXPERT, TRUE)
				gloves = /obj/item/clothing/gloves/roguetown/bandages/pugilist
				beltr = /obj/item/rogueweapon/stoneaxe/woodcut/woodcutter

	if(H.mind)
		SStreasury.grant_savings(ECONOMIC_DESTITUTE, H)
	
	if(H.mind)
		var/list/specialties = list(
			"SMITHING, SER!!",
			"HOMESTEADING, SER!!",
			"HUNTING, SER!!",
			"THUG LYFE, SER!!",
			"ALMOST A SQUIRE, SER!!",
			"ALMOST AN ARMSMAN, SER!!"
		)

		var/specialty_choice = input(
			H,
			"Choose your background. (The Levy does not provide tools, equipment, compensation, legal representation, funeral expenses, or refunds.)",
			"WHAT DID YE DO 'FORE DA LEVY?"
		) as anything in specialties

		switch(specialty_choice)

			if("SMITHING, SER!!")
				ADD_TRAIT(H, TRAIT_SMITHING_EXPERT, TRAIT_GENERIC)
				H.adjust_skillrank_up_to(/datum/skill/craft/blacksmithing, SKILL_LEVEL_JOURNEYMAN, TRUE)
				H.adjust_skillrank_up_to(/datum/skill/craft/armorsmithing, SKILL_LEVEL_JOURNEYMAN, TRUE)
				H.adjust_skillrank_up_to(/datum/skill/craft/weaponsmithing, SKILL_LEVEL_JOURNEYMAN, TRUE)

			if("HOMESTEADING, SER!!")
				ADD_TRAIT(H, TRAIT_HOMESTEAD_EXPERT, TRAIT_GENERIC)
				H.adjust_skillrank_up_to(/datum/skill/labor/farming, SKILL_LEVEL_JOURNEYMAN, TRUE)
				H.adjust_skillrank_up_to(/datum/skill/craft/carpentry, SKILL_LEVEL_JOURNEYMAN, TRUE)

			if("HUNTING, SER!!")
				ADD_TRAIT(H, TRAIT_SURVIVAL_EXPERT, TRAIT_GENERIC)
				H.adjust_skillrank_up_to(/datum/skill/misc/hunting, SKILL_LEVEL_JOURNEYMAN, TRUE)
				H.adjust_skillrank_up_to(/datum/skill/labor/butchering, SKILL_LEVEL_JOURNEYMAN, TRUE)

			if("TAILORING, SER!!")
				ADD_TRAIT(H, TRAIT_SEWING_EXPERT, TRAIT_GENERIC)
				H.adjust_skillrank_up_to(/datum/skill/craft/sewing, SKILL_LEVEL_JOURNEYMAN, TRUE)

			if("THUG LYFE, SER!!")
				H.grant_language(/datum/language/thievescant)
				ADD_TRAIT(H, TRAIT_DODGEEXPERT, TRAIT_GENERIC)

			if("ALMOST A SQUIRE, SER!!")
				ADD_TRAIT(H, TRAIT_SQUIRE_REPAIR, TRAIT_GENERIC)
				ADD_TRAIT(H, TRAIT_MEDIUMARMOR, TRAIT_GENERIC)

			if("ALMOST AN ARMSMAN, SER!!")
				ADD_TRAIT(H, TRAIT_MEDIUMARMOR, TRAIT_GENERIC)
				H.adjust_skillrank_up_to(/datum/skill/combat/shields, SKILL_LEVEL_JOURNEYMAN, TRUE)
				id = /obj/item/scomstone/bad/garrison
