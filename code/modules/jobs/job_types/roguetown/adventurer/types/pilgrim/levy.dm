/datum/advclass/levy
	name = "Levy"
	tutorial = "When the bailiff came to your household, it was the worst dae of your lyfe. Dragged into service of the Crown, you were given little more than a helmet, a tabard and whatever household tool you could fashion into a weapon.<br><br>As one of the Levy, you are among the first sent to answer reports of danger beyond the walls. Whether brigands, beasts, or devils-spawn, it is your duty to find the threat, send word, and hold the line until real Armsmen arrive to earn their keep."
	allowed_sexes = list(MALE, FEMALE)
	
	outfit = /datum/outfit/job/roguetown/adventurer/levy
	traits_applied = list(TRAIT_LEVY, TRAIT_DECEIVING_MEEKNESS, TRAIT_LEECHIMMUNE, TRAIT_SELF_RELIANCE)
	cmode_music = 'sound/music/cmode/towner/combat_towner2.ogg'
	category_tags = list(CTAG_TOWNER)
	townie_contract_gate_exempt = TRUE
	maximum_possible_slots = 4 // fine, a squad of 4, because that's what squad means
	subclass_stats = list(
		STATKEY_STR = 1,
		STATKEY_CON = 1,
		STATKEY_SPD = 1,
		STATKEY_LCK = -1,
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
			"THE FAMILY SWORD (Sword)",
			"THE LEGENDARY BOG-STICK (Club)",
			"AN OLDE CATTLE LASH (Whip)",
			"THE FINEST PITCHFORK (Polearm)",
			"MINE THRESHER (Flail)",
			"A GOOD SHOVEL (Axe)",
			"THE MINER'S PICKAXE (Pickaxe)",
			"MINE SCYTHE (Scythe)",
			"THE WHOLE KITCHEN (Mess Kit + Cleaver)",
			"THESE GODS-GIVEN FISTS (Unarmed)",
		)

		var/weapon_choice = tgui_input_list(
			H,
			"Choose what you could nab and turn into a weapon.",
			"WHAT IS YOUR WEAPON?",
			weapons
		)


		H.set_blindness(0)
		switch(weapon_choice)

			if ("THE FAMILY SWORD (Sword)")
				H.adjust_skillrank_up_to(/datum/skill/combat/swords, SKILL_LEVEL_JOURNEYMAN, TRUE)
				r_hand = /obj/item/rogueweapon/sword/falchion/militia
				gloves = /obj/item/clothing/gloves/roguetown/chain/iron
				backr = /obj/item/rogueweapon/scabbard/sword
				beltr = /obj/item/rogueweapon/stoneaxe/woodcut/woodcutter

			if ("THE LEGENDARY BOG-STICK (Club)")
				H.adjust_skillrank_up_to(/datum/skill/combat/maces, SKILL_LEVEL_JOURNEYMAN, TRUE)
				r_hand = /obj/item/rogueweapon/mace/woodclub/militia
				gloves = /obj/item/clothing/gloves/roguetown/chain/iron
				beltr = /obj/item/rogueweapon/stoneaxe/woodcut/woodcutter

			if ("AN OLDE CATTLE LASH (Whip)")
				H.adjust_skillrank_up_to(/datum/skill/combat/whipsflails, SKILL_LEVEL_JOURNEYMAN, TRUE)
				r_hand = /obj/item/rogueweapon/whip
				gloves = /obj/item/clothing/gloves/roguetown/chain/iron
				backr = /obj/item/rogueweapon/stoneaxe/woodcut/woodcutter

			if("THE FINEST PITCHFORK (Polearm)")
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

			if ("A GOOD SHOVEL (Axe)")
				H.adjust_skillrank_up_to(/datum/skill/combat/axes, SKILL_LEVEL_JOURNEYMAN, TRUE)
				r_hand = /obj/item/rogueweapon/greataxe/militia
				gloves = /obj/item/clothing/gloves/roguetown/chain/iron
				backr = /obj/item/rogueweapon/scabbard/gwstrap
				beltr = /obj/item/rogueweapon/stoneaxe/woodcut/woodcutter

			if ("THE MINER'S PICKAXE (Pickaxe)")
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

			if ("THE WHOLE KITCHEN (Mess Kit + Cleaver)")
				H.adjust_skillrank_up_to(/datum/skill/craft/cooking, SKILL_LEVEL_JOURNEYMAN, TRUE)
				H.adjust_skillrank_up_to(/datum/skill/combat/knives, SKILL_LEVEL_JOURNEYMAN, TRUE)
				r_hand = /obj/item/storage/gadget/messkit
				l_hand = /obj/item/rogueweapon/huntingknife/chefknife/cleaver
				gloves = /obj/item/clothing/gloves/roguetown/chain/iron
				beltr = /obj/item/rogueweapon/stoneaxe/woodcut/woodcutter

			if ("THESE GODS-GIVEN FISTS (Unarmed)")
				H.adjust_skillrank_up_to(/datum/skill/combat/unarmed, SKILL_LEVEL_JOURNEYMAN, TRUE)
				gloves = /obj/item/clothing/gloves/roguetown/bandages/pugilist
				beltr = /obj/item/rogueweapon/stoneaxe/woodcut/woodcutter

	if(H.mind)
		SStreasury.grant_savings(ECONOMIC_DESTITUTE, H)
	
	if(H.mind)
		var/list/specialties = list(
			"A HOMESTEADER, SER!!",
			"A THUG, SER!!",
			"A KNAVE, SER!!",
			"ALMOST A SQUIRE, SER!!",
			"ALMOST AN ARMSMAN, SER!!"
		)

		var/specialty_choice = tgui_input_list(H, "Choose your background. (The Levy does not provide tools, equipment, compensation, legal representation, funeral expenses, or refunds.)",
			"JOB BEFORE THE LEVY?",
			specialties
		)

		switch(specialty_choice)

			if("A HOMESTEADER, SER!!")
				ADD_TRAIT(H, TRAIT_JACKOFALLTRADES, TRAIT_GENERIC)
				H.change_stat(STATKEY_INT, 1)
				H.change_stat(STATKEY_SPD, 1)

			if("A THUG, SER!!")
				H.grant_language(/datum/language/thievescant)
				ADD_TRAIT(H, TRAIT_NOPAINSTUN, TRAIT_GENERIC)
				H.change_stat(STATKEY_CON, 1)

			if("A KNAVE, SER!!")
				H.grant_language(/datum/language/thievescant)
				ADD_TRAIT(H, TRAIT_DODGEEXPERT, TRAIT_GENERIC)
				H.change_stat(STATKEY_SPD, 1)

			if("ALMOST A SQUIRE, SER!!")
				ADD_TRAIT(H, TRAIT_SQUIRE_REPAIR, TRAIT_GENERIC)
				ADD_TRAIT(H, TRAIT_MEDIUMARMOR, TRAIT_GENERIC)
				H.change_stat(STATKEY_WIL, 1)

			if("ALMOST AN ARMSMAN, SER!!")
				ADD_TRAIT(H, TRAIT_MEDIUMARMOR, TRAIT_GENERIC)
				H.adjust_skillrank_up_to(/datum/skill/combat/shields, SKILL_LEVEL_JOURNEYMAN, TRUE)
				id = /obj/item/scomstone/bad/garrison
				H.change_stat(STATKEY_WIL, 1)

/// Point at a target and shout a context-sensitive contact report. Only works if there is more than one TRAIT_LEVY around.
/mob/proc/callout_point(atom/A)
	if(!client || !mind)
		return

	if(istype(A, /obj/effect/temp_visual/point))
		return

	if(!linepoint(A))
		return

	if(world.time < mob_timers["contact_callout"] + 10 SECONDS)
		return

	var/nearby_levies = 0
	for(var/mob/living/carbon/human/H in view(8, src))
		if(H == src)
			continue

		if(HAS_TRAIT(H, TRAIT_LEVY))
			nearby_levies++

	if(!nearby_levies)
		return

	mob_timers["contact_callout"] = world.time

	var/contact_name = A.name

	if(ishuman(A))
		var/mob/living/carbon/human/H = A

		var/masked = (H.wear_mask && (H.wear_mask.flags_inv & HIDEFACE)) || (H.head && (H.head.flags_inv & HIDEFACE))

		if(masked)
			var/list/d_list = H.get_mob_descriptors()
			var/list/name_parts = list()

			for(var/desc_type in d_list)
				var/datum/mob_descriptor/descriptor = MOB_DESCRIPTOR(desc_type)

				if(descriptor.slot in list(MOB_DESCRIPTOR_SLOT_TRAIT, MOB_DESCRIPTOR_SLOT_STATURE))
					name_parts += descriptor.name

			contact_name = length(name_parts) ? jointext(name_parts, " ") : "masked figure"

		else if(H.job)
			contact_name = H.job

	var/held_item = get_active_held_item()
	var/action

	if(istype(A, /obj/item/rogueore/gold) || istype(A, /obj/item/rogueore/silver) || istype(A, /obj/item/roguegem))
		action = "We're rich!"

	else if(ismob(A))
		if(istype(held_item, /obj/item/gun/ballistic))
			action = "Shoot them!"
		else if(istype(held_item, /obj/item/rogueweapon))
			action = "Cut them down!"
		else
			action = "Get them!"

	else if(isturf(A))
		action = "Over there!"

	else
		action = "Break it!"

	var/target_callout
	if(ismob(A))
		target_callout = capitalize(parse_zone(zone_selected))

	var/dist = get_dist(src, A)
	var/dir_text = dir2text(get_dir(src, A))

	if(dir_text)
		var/msg = "[capitalize(contact_name)], [dist] [dist == 1 ? "pace" : "paces"], [dir_text]! [action]"

		if(target_callout)
			msg += " Strike the [target_callout]!"

		say_verb(msg)
