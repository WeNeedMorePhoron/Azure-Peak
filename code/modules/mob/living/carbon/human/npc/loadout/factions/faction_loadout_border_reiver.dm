//** ARCHETYPES **//

/datum/npc_archetype/border_reiver
	abstract_type = /datum/npc_archetype/border_reiver
	job = "Border Reiver"
	category = FACTION_REIVER
	body = /datum/npc_body/border_reiver
	traits = list(TRAIT_STEELHEARTED)

/datum/npc_archetype/border_reiver/lowgear
	name = "Border Reiver (Low Gear)"
	statpack = /datum/npc_statpack/skirmisher/soldier
	skillpacks = list(
		/datum/npc_skillpack/melee/journeyman,
		/datum/npc_skillpack/brawl/journeyman,
		/datum/npc_skillpack/athletics/apprentice,
	)
	loadouts = list(
		/datum/npc_loadout/kit/reiver_flavor/lowgear,
		/datum/npc_loadout/weapon/reiver_lowgear,
	)

/datum/npc_archetype/border_reiver/midgear
	name = "Border Reiver (Mid Gear)"
	statpack = /datum/npc_statpack/skirmisher/veteran
	skillpacks = list(
		/datum/npc_skillpack/melee/expert,
		/datum/npc_skillpack/brawl/expert,
		/datum/npc_skillpack/athletics/journeyman,
		/datum/npc_skillpack/riding/journeyman,
	)
	loadouts = list(
		/datum/npc_loadout/kit/reiver_flavor/mounted,
		/datum/npc_loadout/armor/medium/steel_mixed,
		/datum/npc_loadout/weapon/reiver_midgear,
	)

/datum/npc_archetype/border_reiver/highgear
	name = "Border Reiver (High Gear)"
	statpack = /datum/npc_statpack/skirmisher/champion
	skillpacks = list(
		/datum/npc_skillpack/melee/expert,
		/datum/npc_skillpack/brawl/expert,
		/datum/npc_skillpack/athletics/journeyman,
		/datum/npc_skillpack/riding/journeyman,
	)
	loadouts = list(
		/datum/npc_loadout/kit/reiver_flavor/mounted,
		/datum/npc_loadout/armor/heavy/steel_chain,
		/datum/npc_loadout/weapon/reiver_highgear,
	)

//** BODY **//

/datum/npc_body/border_reiver
	name = "border reiver"
	species_pool = NPC_RACES_TYPES
	beards = FALSE
	aggro_lines_file = "strings/rt/highwaymanaggrolines.txt"
	head_sellprice = HEAD_BOUNTY_REIVER

//** FLAVOR **//

/datum/npc_loadout/kit/reiver_flavor
	abstract_type = /datum/npc_loadout/kit/reiver_flavor
	cloak = list(
		/obj/item/clothing/cloak/raincloak/mageblue,
		/obj/item/clothing/cloak/thief_cloak/mageblue,
		/obj/item/clothing/cloak/cotehardie/mageblue,
	)
	belt = list(
		/obj/item/storage/belt/rogue/leather,
		/obj/item/storage/belt/rogue/leather/knifebelt/black,
		/obj/item/storage/belt/rogue/leather/black,
		/obj/item/storage/belt/rogue/leather/rope,
	)
	beltl = list(
		/obj/item/storage/belt/rogue/pouch/food,
		/obj/item/storage/belt/rogue/pouch/medicine,
		/obj/item/storage/belt/rogue/pouch/coins/poor,
		/obj/item/storage/belt/rogue/pouch/coins/mid,
		/obj/item/reagent_containers/glass/bottle/waterskin,
		/obj/item/reagent_containers/glass/bottle/alchemical/healthpot,
		/obj/item/rogueweapon/huntingknife/idagger/steel/rondel,
	)
	beltr = list(
		/obj/item/storage/belt/rogue/pouch/food,
		/obj/item/storage/belt/rogue/pouch/medicine,
		/obj/item/storage/belt/rogue/pouch/coins/poor,
		/obj/item/storage/belt/rogue/pouch/coins/mid,
		/obj/item/reagent_containers/glass/bottle/waterskin,
		/obj/item/reagent_containers/glass/bottle/alchemical/healthpot,
		/obj/item/rogueweapon/stoneaxe/handaxe,
	)

/datum/npc_loadout/kit/reiver_flavor/lowgear
	name = "reiver foot clothing"
	armor_training = ARMOR_CLASS_MEDIUM
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/lord/light
	neck = /obj/item/clothing/neck/roguetown/leather
	head = list(
		/obj/item/clothing/head/roguetown/helmet,
		/obj/item/clothing/head/roguetown/knitcap,
		/obj/item/clothing/head/roguetown/brimmed,
		/obj/item/clothing/head/roguetown/roguehood/mageblue,
	)
	pants = /obj/item/clothing/under/roguetown/tights
	shoes = /obj/item/clothing/shoes/roguetown/boots

/datum/npc_loadout/kit/reiver_flavor/mounted
	name = "reiver mounted clothing"
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/lord
	neck = /obj/item/clothing/neck/roguetown/leather
	mask = /obj/item/clothing/head/roguetown/armingcap/padded
	gloves = /obj/item/clothing/gloves/roguetown/angle
	shoes = /obj/item/clothing/shoes/roguetown/ridingboots

//** WEAPONS **//

/datum/npc_loadout/weapon/reiver_lowgear
	name = "reiver low gear weapons"
	weapons = list(
		list(/obj/item/rogueweapon/pick/militia),
		list(/obj/item/rogueweapon/greataxe/militia),
		list(/obj/item/rogueweapon/woodstaff/militia),
		list(/obj/item/rogueweapon/flail/militia),
		list(/obj/item/rogueweapon/sword/short, /obj/item/flashlight/flare/torch/prelit),
		list(/obj/item/rogueweapon/spear/short),
	)

/datum/npc_loadout/weapon/reiver_midgear
	name = "reiver mid gear weapons"
	weapons = list(
		list(/obj/item/rogueweapon/spear/short, /obj/item/rogueweapon/shield/wood),
		list(/obj/item/rogueweapon/sword/short, /obj/item/rogueweapon/shield/buckler),
		list(/obj/item/rogueweapon/spear/short),
		list(/obj/item/rogueweapon/sword/short),
		list(/obj/item/rogueweapon/sword/short, /obj/item/flashlight/flare/torch/prelit),
	)

/datum/npc_loadout/weapon/reiver_highgear
	name = "reiver high gear weapons"
	weapons = list(
		list(/obj/item/rogueweapon/spear/short, /obj/item/rogueweapon/shield/iron),
		list(/obj/item/rogueweapon/sword/rapier, /obj/item/rogueweapon/shield/buckler),
		list(/obj/item/rogueweapon/spear/short),
		list(/obj/item/rogueweapon/sword/sabre),
		list(/obj/item/rogueweapon/sword/sabre, /obj/item/flashlight/flare/torch/prelit),
	)
