//** ARCHETYPES **//

/datum/npc_archetype/searaider
	name = "Sea Raider"
	job = "Sea Raider"
	category = FACTION_GRONNMEN
	faction_tag = "raiders"
	threat_point = THREAT_TOUGH
	body = /datum/npc_body/northern_commoner/searaider
	statpack = /datum/npc_statpack/searaider
	skillpacks = list(
		/datum/npc_skillpack/melee/journeyman,
		/datum/npc_skillpack/brawl/journeyman,
		/datum/npc_skillpack/survival/apprentice,
	)
	loadouts = list(
		/datum/npc_loadout/armor/medium/scavenged,
		/datum/npc_loadout/kit/searaider_flavor,
	)
	loadout_pools = list(list(
		/datum/npc_loadout/weapon/searaider_melee = 5,
		/datum/npc_loadout/weapon/searaider_dual_axes = 1,
	))

/datum/npc_archetype/searaider/archer
	name = "Sea Raider Archer"
	statpack = /datum/npc_statpack/searaider/archer
	skillpacks = list(
		/datum/npc_skillpack/melee/journeyman,
		/datum/npc_skillpack/brawl/journeyman,
		/datum/npc_skillpack/survival/apprentice,
		/datum/npc_skillpack/bows/journeyman,
	)
	loadouts = list(
		/datum/npc_loadout/armor/medium/scavenged/archer,
		/datum/npc_loadout/kit/searaider_flavor/archer,
		/datum/npc_loadout/weapon/searaider_bow,
	)
	loadout_pools = null
	ai_controller = /datum/ai_controller/human_npc/archer

/datum/npc_archetype/searaider/archer/scarce
	name = "Sea Raider Archer (Scarce Arrows)"
	loadouts = list(
		/datum/npc_loadout/armor/medium/scavenged/archer,
		/datum/npc_loadout/kit/searaider_flavor/archer,
		/datum/npc_loadout/weapon/searaider_bow/scarce,
	)

/datum/npc_archetype/searaider/archer/reaver
	name = "Sea Raider Archer (Reaver Arrows)"
	loadouts = list(
		/datum/npc_loadout/armor/medium/scavenged/archer,
		/datum/npc_loadout/kit/searaider_flavor/archer,
		/datum/npc_loadout/weapon/searaider_bow/reaver,
	)

/datum/npc_archetype/searaider/huscarl
	name = "Sea Raider Huscarl"
	job = "Sea Raider Huscarl"
	threat_point = THREAT_DEADLY
	statpack = /datum/npc_statpack/searaider/huscarl
	traits = list(TRAIT_BADTRAINER)
	skillpacks = list(
		/datum/npc_skillpack/melee/journeyman,
		/datum/npc_skillpack/brawl/expert,
		/datum/npc_skillpack/swords/master,
		/datum/npc_skillpack/axes/expert,
		/datum/npc_skillpack/survival/apprentice,
	)
	loadouts = list(
		/datum/npc_loadout/kit/searaider_flavor/huscarl,
		/datum/npc_loadout/armor/heavy/iron_chain/scale,
		/datum/npc_loadout/weapon/searaider_greatsword,
	)
	loadout_pools = null

//** BODY **//

/datum/npc_body/northern_commoner/searaider
	name = "sea raider"
	male_name_file = "strings/rt/names/human/vikingm.txt"
	female_name_file = "strings/rt/names/human/vikingf.txt"
	aggro_lines_file = "strings/rt/searaideraggrolines.txt"
	head_sellprice = HEAD_BOUNTY_SEARAIDER
	voicepack_chance = 100
	voicepacks = list(
		list(/datum/voicepack/male/warrior, /datum/voicepack/female/warrior),
	)

//** STATS **//

/datum/npc_statpack/searaider
	name = "sea raider"
	strength = 14
	speed = 9
	constitution = 7
	willpower = 8
	perception = 8 //AIMING? Who needs that lame-ass shit? GRAGGAR GRAGGAR GRAGGAR!!
	intelligence = 8 //Minimal req to use specials

/datum/npc_statpack/searaider/archer
	name = "sea raider archer"
	strength = 12
	willpower = 7
	perception = 11

/datum/npc_statpack/searaider/huscarl
	name = "sea raider huscarl"
	strength = 15
	constitution = 10
	willpower = 9
	perception = 9

//** FLAVOR **//

/datum/npc_loadout/kit/searaider_flavor
	name = "sea raider clothing"
	armor_training = ARMOR_CLASS_HEAVY
	belt = /obj/item/storage/belt/rogue/leather //Cosmetic + Holding repair kits for looting mostly.
	beltl = list(
		/obj/item/repair_kit/bad = 15, //So you can get repair kits easier from looting them
		NPC_NOTHING = 85,
	)
	shirt = list(
		/obj/item/clothing/suit/roguetown/shirt/undershirt/vagrant,
		/obj/item/clothing/suit/roguetown/shirt/undershirt/sailor, //We don't want anything that dips below waist, looks bad w/kilt
	)
	id = list(
		/obj/item/clothing/neck/roguetown/psicross/inhumen/graggar = 20, //SHATTER MY BINDS
		NPC_NOTHING = 80,
	)
	cloak = list(
		/obj/item/clothing/cloak/raincloak/furcloak/brown,
		/obj/item/clothing/cloak/raincloak/furcloak/black,
		/obj/item/clothing/cloak/raincloak/furcloak, //White
		/obj/item/clothing/cloak/volfmantle,
	)
	shoes = list(
		/obj/item/clothing/shoes/roguetown/boots/furlinedboots = 70,
		/obj/item/clothing/shoes/roguetown/boots/leather = 30,
	)

/datum/npc_loadout/kit/searaider_flavor/archer
	name = "sea raider archer clothing"
	shirt = /obj/item/clothing/suit/roguetown/shirt/tunic
	pants = /obj/item/clothing/under/roguetown/tights
	shoes = /obj/item/clothing/shoes/roguetown/boots/leather

/datum/npc_loadout/kit/searaider_flavor/huscarl
	name = "sea raider huscarl clothing"
	cloak = /obj/item/clothing/cloak/raincloak/furcloak/brown

//** WEAPONS **//

/datum/npc_loadout/weapon/searaider_melee
	name = "sea raider melee weapons"
	weapons = list(
		list(/obj/item/rogueweapon/sword/iron, /obj/item/rogueweapon/shield/wood),
		list(/obj/item/rogueweapon/stoneaxe/handaxe, /obj/item/rogueweapon/shield/wood),
		list(/obj/item/rogueweapon/spear),
		list(/obj/item/rogueweapon/greataxe),
		list(/obj/item/rogueweapon/greatsword/iron),
	)

/datum/npc_loadout/weapon/searaider_dual_axes
	name = "sea raider dual axes"
	r_hand = /obj/item/rogueweapon/stoneaxe/handaxe/copper
	l_hand = /obj/item/rogueweapon/stoneaxe/handaxe/copper
	traits = list(TRAIT_DUALWIELDER)

/datum/npc_loadout/weapon/searaider_bow
	r_hand = /obj/item/rogueweapon/sword/iron
	backr = /obj/item/gun/ballistic/revolver/grenadelauncher/bow/recurve
	backl = /obj/item/quiver/npc

/datum/npc_loadout/weapon/searaider_bow/scarce
	backl = /obj/item/quiver/arrows/scarce

/datum/npc_loadout/weapon/searaider_bow/reaver
	backl = /obj/item/quiver/randomfill/reaver

/datum/npc_loadout/weapon/searaider_greatsword
	r_hand = /obj/item/rogueweapon/greatsword/iron
