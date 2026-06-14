/datum/advclass/levy
	name = "Levy"
	tutorial = "When the Bailiff came knocking for you, it was the worst dae of your lyfe. Hastily pressed into the Crown's service with little more than a helmet, a household tool turned weapon and a bottle of beer for comfort, you joined the Levy squad.<br><br>As one of Azurea's so-called \"folk-heroes\", you are first to answer a peasant's reports of danger beyond the walls. Find the problem and solve it yourself or, if dire, send word for backup, and hold the line until the Armsmen or Wardens arrive to earn their keep."
	allowed_sexes = list(MALE, FEMALE)
	
	outfit = /datum/outfit/job/roguetown/adventurer/levy
	traits_applied = list(TRAIT_LEVY, TRAIT_DECEIVING_MEEKNESS, TRAIT_BOGWALKER, TRAIT_SELF_RELIANCE)
	cmode_music = 'sound/music/cmode/towner/combat_towner2.ogg'
	category_tags = list(CTAG_TOWNER)
	townie_contract_gate_exempt = TRUE
	maximum_possible_slots = 4 // a squad of 4, because that's what squad means
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
		/datum/skill/craft/masonry = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/craft/blacksmithing = SKILL_LEVEL_NOVICE,
		/datum/skill/craft/armorsmithing = SKILL_LEVEL_NOVICE,
		/datum/skill/craft/weaponsmithing = SKILL_LEVEL_NOVICE,
		/datum/skill/labor/lumberjacking = SKILL_LEVEL_JOURNEYMAN,
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
	beltl = /obj/item/flashlight/flare/torch/lantern/bog
	id = /obj/item/scomstone/bad/garrison

	to_chat(H, span_notice("<b>THE WEAPON I COULD SCROUNGE UP:</b>"))
	to_chat(H, span_info("<b>THE FAMILY SWORD</b> - Journeyman Swords. Comes with a militia falchion."))
	to_chat(H, span_info("<b>THE LEGENDARY BOG-STICK</b> - Journeyman Maces. Comes with a militia club."))
	to_chat(H, span_info("<b>AN OLDE CATTLE LASH</b> - Journeyman Whips & Flails. Comes with a whip."))
	to_chat(H, span_info("<b>THE FINEST PITCHFORK</b> - Journeyman Polearms. Comes with a militia spear."))
	to_chat(H, span_info("<b>MINE THRESHER</b> - Journeyman Whips & Flails. Comes with a militia flail."))
	to_chat(H, span_info("<b>A GOOD SHOVEL</b> - Journeyman Axes. Comes with a militia greataxe."))
	to_chat(H, span_info("<b>THE MINER'S PICKAXE</b> - Journeyman Mining. Comes with a militia pickaxe."))
	to_chat(H, span_info("<b>MINE SCYTHE</b> - Journeyman Farming. Comes with a militia scythe."))
	to_chat(H, span_info("<b>THE WHOLE KITCHEN</b> - Journeyman Cooking and Knives. Comes with a mess kit and cleaver."))
	to_chat(H, span_info("<b>THESE GODS-GIVEN FISTS</b> - Journeyman Unarmed. Comes with handwraps."))

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

		var/weapon_choice = tgui_input_list(H, "Choose what you could nab and turn into a weapon.", "WHAT IS YOUR WEAPON?", weapons)
		H.set_blindness(0)
		switch(weapon_choice)

			if ("THE FAMILY SWORD (Sword)")
				H.adjust_skillrank_up_to(/datum/skill/combat/swords, SKILL_LEVEL_JOURNEYMAN, TRUE)
				r_hand = /obj/item/rogueweapon/sword/falchion/militia
				gloves = /obj/item/clothing/gloves/roguetown/chain/iron
				backr = /obj/item/rogueweapon/scabbard/sword
				beltr = /obj/item/rogueweapon/stoneaxe/woodcut/wardenpick/bog

			if ("THE LEGENDARY BOG-STICK (Club)")
				H.adjust_skillrank_up_to(/datum/skill/combat/maces, SKILL_LEVEL_JOURNEYMAN, TRUE)
				r_hand = /obj/item/rogueweapon/mace/woodclub/militia
				gloves = /obj/item/clothing/gloves/roguetown/chain/iron
				beltr = /obj/item/rogueweapon/stoneaxe/woodcut/wardenpick/bog

			if ("AN OLDE CATTLE LASH (Whip)")
				H.adjust_skillrank_up_to(/datum/skill/combat/whipsflails, SKILL_LEVEL_JOURNEYMAN, TRUE)
				r_hand = /obj/item/rogueweapon/whip
				gloves = /obj/item/clothing/gloves/roguetown/chain/iron
				backr = /obj/item/rogueweapon/stoneaxe/woodcut/wardenpick/bog

			if("THE FINEST PITCHFORK (Polearm)")
				H.adjust_skillrank_up_to(/datum/skill/combat/polearms, SKILL_LEVEL_JOURNEYMAN, TRUE)
				r_hand = /obj/item/rogueweapon/spear/militia
				gloves = /obj/item/clothing/gloves/roguetown/chain/iron
				backr = /obj/item/rogueweapon/scabbard/gwstrap
				beltr = /obj/item/rogueweapon/stoneaxe/woodcut/wardenpick/bog

			if("MINE THRESHER (Flail)")
				H.adjust_skillrank_up_to(/datum/skill/combat/whipsflails, SKILL_LEVEL_JOURNEYMAN, TRUE)
				r_hand = /obj/item/rogueweapon/flail/militia
				gloves = /obj/item/clothing/gloves/roguetown/chain/iron
				beltr = /obj/item/rogueweapon/stoneaxe/woodcut/wardenpick/bog

			if ("A GOOD SHOVEL (Axe)")
				H.adjust_skillrank_up_to(/datum/skill/combat/axes, SKILL_LEVEL_JOURNEYMAN, TRUE)
				r_hand = /obj/item/rogueweapon/greataxe/militia
				gloves = /obj/item/clothing/gloves/roguetown/chain/iron
				backr = /obj/item/rogueweapon/scabbard/gwstrap
				beltr = /obj/item/rogueweapon/stoneaxe/woodcut/wardenpick/bog

			if ("THE MINER'S PICKAXE (Pickaxe)")
				H.adjust_skillrank_up_to(/datum/skill/labor/mining, SKILL_LEVEL_JOURNEYMAN, TRUE)
				r_hand = /obj/item/rogueweapon/pick/militia
				gloves = /obj/item/clothing/gloves/roguetown/chain/iron
				backr = /obj/item/rogueweapon/stoneaxe/woodcut/wardenpick/bog

			if ("MINE SCYTHE (Scythe)")
				H.adjust_skillrank_up_to(/datum/skill/labor/farming, SKILL_LEVEL_JOURNEYMAN, TRUE)
				r_hand = /obj/item/rogueweapon/scythe/militia
				gloves = /obj/item/clothing/gloves/roguetown/chain/iron
				backr = /obj/item/rogueweapon/scabbard/gwstrap
				beltr = /obj/item/rogueweapon/stoneaxe/woodcut/wardenpick/bog

			if ("THE WHOLE KITCHEN (Mess Kit + Cleaver)")
				H.adjust_skillrank_up_to(/datum/skill/craft/cooking, SKILL_LEVEL_JOURNEYMAN, TRUE)
				H.adjust_skillrank_up_to(/datum/skill/combat/knives, SKILL_LEVEL_JOURNEYMAN, TRUE)
				r_hand = /obj/item/storage/gadget/messkit
				l_hand = /obj/item/rogueweapon/huntingknife/chefknife/cleaver
				gloves = /obj/item/clothing/gloves/roguetown/chain/iron
				beltr = /obj/item/rogueweapon/stoneaxe/woodcut/wardenpick/bog

			if ("THESE GODS-GIVEN FISTS (Unarmed)")
				H.adjust_skillrank_up_to(/datum/skill/combat/unarmed, SKILL_LEVEL_JOURNEYMAN, TRUE)
				gloves = /obj/item/clothing/gloves/roguetown/bandages/pugilist
				beltr = /obj/item/rogueweapon/stoneaxe/woodcut/wardenpick/bog

	if(H.mind)
		SStreasury.grant_savings(ECONOMIC_DESTITUTE, H)

	to_chat(H, span_notice("<b>JOB BEFORE THE LEVY?</b>"))

	to_chat(H, span_info("<b>A BUM, SER!!</b><br>\
	Traits: None.<br>\
	Stats: +3 LUC, -1 INT.<br>\
	Skills: No extras.<br>\
	Equipment: Satchel, Rope, Signal Horn, 4x Beer.<br>"))

	to_chat(H, span_info("<b>A HOMESTEADER, SER!!</b><br>\
	Traits: Jack of All Trades, Homestead Expert, Survival Expert.<br>\
	Stats: +2 INT, +1 SPD, -3 CON.<br>\
	Skills: No extras.<br>\
	Equipment: Backpack, Small Shovel, Stone Hammer, Chisel, Handsaw, Hoe, Hunting Knife, Rope, Poor Coin Pouch, Signal Horn, Beer, Broom.<br><br>"))

	to_chat(H, span_info("<b>A COOKER-DOC, SER!!</b><br>\
	Traits: Medicine Expert, Cicerone.<br>\
	Stats: +1 INT, +2 SPD, -3 CON.<br>\
	Skills: Medicine (Expert), Cooking (Expert), Alchemy (Apprentice). Gains Secular Diagnose.<br>\
	Equipment: Backpack, Bedroll, 4x Fish Vinegar Potions, Signal Horn, Hunting Knife, Rope, Beer, Bottle Kit, Calendula Seeds, Sugarcane Seeds, Healing Juice Recipe, Surgery Bag.<br><br>"))

	to_chat(H, span_info("<b>A THUG, SER!!</b><br>\
	Traits: Enduring. Learns Thieves' Cant.<br>\
	Stats: +1 CON, -1 INT.<br>\
	Skills: Athletics (Journeyman), Maces (Journeyman).<br>\
	Equipment: Satchel, Cudgel, Signal Horn, Hunting Knife, 2x Beer.<br><br>"))

	to_chat(H, span_info("<b>A SCAVENGER, SER!!</b><br>\
	Traits: Dodge Expert.<br>\
	Stats: +2 SPD, +1 INT, +1 LCK, -1 STR, -3 CON.<br>\
	Skills: Knives (Journeyman), Sewing (Journeyman).<br>\
	Equipment: Backpack, Combat Knife, Scissors, Signal Horn, Triumph Beer, Rope.<br><br>"))

	to_chat(H, span_info("<b>ALMOST A SQUIRE, SER!!</b><br>\
	Traits: Squire Repair, Medium Armor Training.<br>\
	Stats: +1 WIL.<br>\
	Skills: No extras.<br>\
	Equipment: Satchel, Rich Coin Pouch, Stone Hammer, Polishing Cream, Armor Brush, Signal Horn, Needle.<br><br>"))

	to_chat(H, span_info("<b>ALMOST AN ARMSMAN, SER!!</b><br>\
	Traits: Medium Armor Training.<br>\
	Stats: +1 WIL.<br>\
	Skills: Shields (Journeyman).<br>\
	Equipment: Satchel, Chain, Rope, Signal Horn, Poor Coin Pouch, Hunting Knife, Beer.<br><br>"))
	
	if(H.mind)
		var/list/specialties = list(
			"A BUM, SER!!",
			"A HOMESTEADER, SER!!",
			"A COOKER-DOC, SER!!",
			"A THUG, SER!!",
			"A SCAVENGER, SER!!",
			"ALMOST A SQUIRE, SER!!",
			"ALMOST AN ARMSMAN, SER!!"
		)

		var/specialty_choice = tgui_input_list(H, "Choose your background. (The Levy is not legally obligated to provide tools, equipment, compensation, legal representation, funeral expenses, or refunds. Good luck, and we love you.)", "JOB BEFORE THE LEVY?", specialties)
		switch(specialty_choice)

			if("A BUM, SER!!") // the real hero, gain LUC instead of losing it, -1 INT for the vanilla feel. no gear, full balls.
				H.change_stat(STATKEY_LCK, 3)
				H.change_stat(STATKEY_INT, -1)
				backl = /obj/item/storage/backpack/rogue/backpack
				backpack_contents = list(
					/obj/item/rope = 1,
					/obj/item/reagent_containers/glass/bottle/rogue/triumphbeer = 4, // this one is for good luck, you'll need it, OHH YOU'LL NEED IT.
					/obj/item/signal_horn = 1,
					)

			if("A HOMESTEADER, SER!!") // basic bitch siege engineer guy, may be mogged by default but ig JoAT lets them be omni-journeyman on all, shrug.
				ADD_TRAIT(H, TRAIT_JACKOFALLTRADES, TRAIT_GENERIC)
				ADD_TRAIT(H, TRAIT_HOMESTEAD_EXPERT, TRAIT_GENERIC)
				ADD_TRAIT(H, TRAIT_SURVIVAL_EXPERT, TRAIT_GENERIC)
				H.change_stat(STATKEY_INT, 2)
				H.change_stat(STATKEY_CON, -3)
				H.change_stat(STATKEY_SPD, 1)
				backl = /obj/item/storage/backpack/rogue/backpack
				backpack_contents = list(
					/obj/item/rogueweapon/shovel/small = 1,
					/obj/item/rogueweapon/hammer/stone = 1,
					/obj/item/rogueweapon/chisel = 1,
					/obj/item/rogueweapon/handsaw = 1,
					/obj/item/storage/belt/rogue/pouch/coins/poor = 1,
					/obj/item/rogueweapon/huntingknife = 1,
					/obj/item/rope = 1,
					/obj/item/reagent_containers/glass/bottle/rogue/triumphbeer = 1, // this one is for good luck, you'll need it
					/obj/item/signal_horn = 1,
					/obj/item/rogueweapon/hoe = 1,
					/obj/item/broom = 1,
					)

			if("A COOKER-DOC, SER!!") // JESSIE, WE GOTTA COOK!!! -- This is intended to be the Barber-Surgeon's cousin.
				ADD_TRAIT(H, TRAIT_MEDICINE_EXPERT, TRAIT_GENERIC)
				ADD_TRAIT(H, TRAIT_CICERONE, TRAIT_GENERIC)
				H.AddSpell(new /obj/effect/proc_holder/spell/invoked/diagnose/secular)
				H.adjust_skillrank_up_to(/datum/skill/misc/medicine, SKILL_LEVEL_EXPERT, TRUE) // so secular diagnose gives better info
				H.adjust_skillrank_up_to(/datum/skill/craft/cooking, SKILL_LEVEL_EXPERT, TRUE) // brew fish potions for field-healing, ser!!!
				H.adjust_skillrank_up_to(/datum/skill/craft/alchemy, SKILL_LEVEL_APPRENTICE, TRUE) // this is for drug-crafting
				H.change_stat(STATKEY_INT, 1)
				H.change_stat(STATKEY_CON, -3)
				H.change_stat(STATKEY_SPD, 2)
				backl = /obj/item/storage/backpack/rogue/backpack
				backpack_contents = list(
					/obj/item/bedroll = 1,
					/obj/item/reagent_containers/glass/bottle/rogue/healthpot/zarum/bog = 4, // bringing the fighting juice for the squad!
					/obj/item/signal_horn = 1,
					/obj/item/rogueweapon/huntingknife = 1,
					/obj/item/rope = 1,
					/obj/item/reagent_containers/glass/bottle/rogue/triumphbeer = 1, // this one is for good luck, you'll need it
					/obj/item/bottle_kit = 1,
					/obj/item/herbseed/calendula = 1,
					/obj/item/seeds/sugarcane = 1,
					/obj/item/paper/vinegar_healpot_recipe = 1,
					/obj/item/storage/belt/rogue/surgery_bag = 1,
					)

			if("A THUG, SER!!") // meatball that's dumb and meaty and does nothing but do that, comes with a cudgel to sell that idea better
				H.grant_language(/datum/language/thievescant)
				ADD_TRAIT(H, TRAIT_NOPAINSTUN, TRAIT_GENERIC)
				H.adjust_skillrank_up_to(/datum/skill/misc/athletics, SKILL_LEVEL_JOURNEYMAN, TRUE)
				H.adjust_skillrank_up_to(/datum/skill/combat/maces, SKILL_LEVEL_JOURNEYMAN, TRUE)
				H.change_stat(STATKEY_CON, 1)
				H.change_stat(STATKEY_INT, -1)
				backl = /obj/item/storage/backpack/rogue/satchel
				backpack_contents = list(
					/obj/item/rogueweapon/mace/cudgel = 1,
					/obj/item/signal_horn = 1,
					/obj/item/rogueweapon/huntingknife = 1,
					/obj/item/reagent_containers/glass/bottle/rogue/triumphbeer = 2, // this one is for good luck, you'll need it. And an extra one because you're going to suffer a lot.
					)

			if("A SCAVENGER, SER!!") // squishier fast on your feet, mr. back-and-forth man whose specialty is dragging stuff around and being dodgy. also free combat knife!
				ADD_TRAIT(H, TRAIT_DODGEEXPERT, TRAIT_GENERIC)
				H.adjust_skillrank_up_to(/datum/skill/combat/knives, SKILL_LEVEL_JOURNEYMAN, TRUE)
				H.adjust_skillrank_up_to(/datum/skill/craft/sewing, SKILL_LEVEL_JOURNEYMAN, TRUE) // for reliable dismantling of clothing
				H.change_stat(STATKEY_SPD, 2)
				H.change_stat(STATKEY_INT, 1)
				H.change_stat(STATKEY_STR, -1)
				H.change_stat(STATKEY_CON, -3)
				H.change_stat(STATKEY_LCK, 1)
				backl = /obj/item/storage/backpack/rogue/backpack
				backpack_contents = list(
					/obj/item/rogueweapon/huntingknife/combat = 1,
					/obj/item/rogueweapon/huntingknife/scissors = 1,
					/obj/item/signal_horn = 1,
					/obj/item/reagent_containers/glass/bottle/rogue/triumphbeer = 1, // this one is for good luck, you'll need it
					/obj/item/rope = 1,
					)

			if("ALMOST A SQUIRE, SER!!") // probably should start richer to show that this is prolly the most prestigious
				ADD_TRAIT(H, TRAIT_SQUIRE_REPAIR, TRAIT_GENERIC)
				ADD_TRAIT(H, TRAIT_MEDIUMARMOR, TRAIT_GENERIC)
				H.change_stat(STATKEY_WIL, 1)
				backl = /obj/item/storage/backpack/rogue/satchel
				backpack_contents = list(
					/obj/item/rogueweapon/hammer/stone = 1,
					/obj/item/polishing_cream = 1,
					/obj/item/armor_brush = 1,
					/obj/item/signal_horn = 1,
					/obj/item/storage/belt/rogue/pouch/coins/rich = 1,
					/obj/item/needle/thorn = 1,
					)

			if("ALMOST AN ARMSMAN, SER!!") // this is probably going to be the poster boy, but what can we do
				ADD_TRAIT(H, TRAIT_MEDIUMARMOR, TRAIT_GENERIC)
				H.adjust_skillrank_up_to(/datum/skill/combat/shields, SKILL_LEVEL_JOURNEYMAN, TRUE)
				H.change_stat(STATKEY_WIL, 1)
				backl = /obj/item/storage/backpack/rogue/satchel
				backpack_contents = list(
					/obj/item/rope/chain = 1,
					/obj/item/signal_horn = 1,
					/obj/item/storage/belt/rogue/pouch/coins/poor = 1,
					/obj/item/rogueweapon/huntingknife = 1,
					/obj/item/rope = 1,
					/obj/item/reagent_containers/glass/bottle/rogue/triumphbeer = 1, // this one is for good luck, you'll need it
					)


//A note for the Doc!
/obj/item/paper/vinegar_healpot_recipe
	name = "Healing Juice Recipe"
	desc = "One of your finest discoveries. The secret formula to make a healing potion that transcends all alchemy!"
	info = {"
		<font face='Times New Roman' color='#000000'>
		- Get a barrel or a distiller.<br><br>
		- Pour in at least 200 drams of water.<br><br>
		- Go for the Fish Vinegar. That's the potion base.<br><br>
		- Add HONEY, calendula, fish mince, salt, and a healthy dose of love and care. The quantity is as 'as much as it feels right'. You'll understand.<br>
		- Wait a little while.<br><br>
		- Once it stops bubbling and smells like home, it's ready.<br><br>
		- Bottle it with a bottlin' kit.<br><br>
		- Voila!~ This brew is guaranteed to put some hair on your chest; and remember: 'Real Bogdwellers don't whine! They drink wine!'
		</font>
	"}
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
