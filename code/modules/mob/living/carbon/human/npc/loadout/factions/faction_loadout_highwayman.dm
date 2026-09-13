//** BODY **//

/datum/npc_body/northern_commoner/soldier/highwayman
	name = "highwayman"
	aggro_lines_file = "strings/rt/highwaymanaggrolines.txt"
	head_sellprice = HEAD_BOUNTY_HIGHWAYMAN

//** FLAVOR **//

/datum/npc_loadout/kit/bandit_flavor
	name = "bandit clothing"
	armor_training = ARMOR_CLASS_MEDIUM
	shoes = list(
		/obj/item/clothing/shoes/roguetown/boots/leather,
		/obj/item/clothing/shoes/roguetown/boots,
	)
	belt = list(
		/obj/item/storage/belt/rogue/leather/rope = 90,
		/obj/item/storage/belt/rogue/leather/knifebelt/iron = 10,
	)
	shirt = list(
		/obj/item/clothing/suit/roguetown/shirt/undershirt/vagrant,
		/obj/item/clothing/suit/roguetown/armor/gambeson/light,
	)
	neck = list(
		/obj/item/clothing/neck/roguetown/coif = 49,
		/obj/item/clothing/neck/roguetown/leather = 49,
		/obj/item/storage/belt/rogue/pouch/bombs = 2,
	)
	cloak = list(
		/obj/item/clothing/cloak/raincloak/furcloak/brown,
		/obj/item/clothing/cloak/raincloak/red,
		/obj/item/clothing/cloak/raincloak/green,
		/obj/item/clothing/cloak/raincloak/blue,
		/obj/item/clothing/cloak/raincloak/brown,
	)
	mask = list(
		/obj/item/clothing/mask/rogue/ragmask/red,
		/obj/item/clothing/mask/rogue/ragmask/black,
		/obj/item/clothing/mask/rogue/skullmask,
	)
	head = list(
		/obj/item/clothing/head/roguetown/helmet/leather,
		/obj/item/clothing/head/roguetown/helmet/leather/volfhelm,
		/obj/item/clothing/head/roguetown/helmet/tricorn,
		/obj/item/clothing/head/roguetown/armingcap,
		/obj/item/clothing/head/roguetown/menacing/bandit,
	)
	slot_chance = list("cloak" = 30, "mask" = 50, "head" = 50)

/datum/npc_loadout/kit/bandit_flavor/mount_reaver
	name = "mount reaver clothing"
	wrists = /obj/item/clothing/wrists/roguetown/bracers/iron
	mask = /obj/item/clothing/mask/rogue/ragmask/black
	belt = list(
		/obj/item/storage/belt/rogue/leather/rope = 765,
		/obj/item/storage/belt/rogue/leather/knifebelt/iron = 235,
	)
	slot_chance = list("cloak" = 30, "head" = 50)

//** ROLE KITS **//

/datum/npc_loadout/kit/bandit_shooter
	name = "bandit archer clothing"
	clear_slots = list("head", "mask", "neck")
	armor = /obj/item/clothing/suit/roguetown/shirt/rags
	shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/vagrant
	gloves = /obj/item/clothing/gloves/roguetown/leather
	wrists = /obj/item/clothing/wrists/roguetown/bracers/leather

/datum/npc_loadout/armor/heavy/iron_chain/iron_plate/road_knight
	cloak = /obj/item/clothing/cloak/raincloak/furcloak/brown

/datum/npc_loadout/armor/heavy/iron_chain/cuirass/sharpshooter
	name = "iron chain with cuirass and bow"
	cloak = /obj/item/clothing/cloak/raincloak/green
	beltr = /obj/item/rogueweapon/sword/short/iron
	backr = /obj/item/gun/ballistic/revolver/grenadelauncher/bow
	backl = /obj/item/quiver/randomfill/reaver

//** WEAPONS **//

/datum/npc_loadout/weapon/bandit_shortsword
	r_hand = /obj/item/rogueweapon/sword/short/iron
	l_hand = /obj/item/rogueweapon/shield/wood
	slot_chance = list("l_hand" = 45)

/datum/npc_loadout/weapon/bandit_cudgel
	r_hand = /obj/item/rogueweapon/mace/cudgel
	l_hand = /obj/item/rogueweapon/shield/wood
	slot_chance = list("l_hand" = 25)

/datum/npc_loadout/weapon/bandit_falchion
	r_hand = /obj/item/rogueweapon/sword/falchion/militia
	l_hand = /obj/item/rogueweapon/shield/wood
	slot_chance = list("l_hand" = 20)

/datum/npc_loadout/weapon/bandit_pick
	r_hand = /obj/item/rogueweapon/pick/militia
	l_hand = /obj/item/rogueweapon/shield/buckler/palloy
	slot_chance = list("l_hand" = 35)

/datum/npc_loadout/weapon/bandit_greataxe
	r_hand = /obj/item/rogueweapon/greataxe/militia

/datum/npc_loadout/weapon/bandit_staff
	l_hand = /obj/item/rogueweapon/woodstaff/militia

/datum/npc_loadout/weapon/bandit_dagger
	r_hand = /obj/item/rogueweapon/huntingknife/idagger
	l_hand = /obj/item/rogueweapon/shield/buckler/palloy
	slot_chance = list("l_hand" = 65)

/datum/npc_loadout/weapon/bandit_bow
	r_hand = /obj/item/rogueweapon/sword/short/iron
	backr = /obj/item/gun/ballistic/revolver/grenadelauncher/bow
	backl = /obj/item/quiver/randomfill/highwayman

/datum/npc_loadout/weapon/bandit_crossbow
	r_hand = /obj/item/rogueweapon/huntingknife/idagger
	backr = /obj/item/gun/ballistic/revolver/grenadelauncher/crossbow/iron
	backl = /obj/item/quiver/bolt/npc

/datum/npc_loadout/weapon/road_knight
	r_hand = /obj/item/rogueweapon/sword/iron
	l_hand = /obj/item/rogueweapon/shield/heater

//** ARCHETYPES **//

/datum/npc_archetype/highwayman
	name = "Highwayman"
	job = "Highwayman"
	category = "Bandits"
	faction_tag = "bandits"
	threat_point = THREAT_HIGH
	body = /datum/npc_body/northern_commoner/soldier/highwayman
	statpack = /datum/npc_statpack/soldier
	skillpacks = list(
		/datum/npc_skillpack/melee/apprentice,
		/datum/npc_skillpack/brawl/apprentice,
		/datum/npc_skillpack/survival/apprentice,
	)
	loadouts = list(
		/datum/npc_loadout/armor/light/leather,
		/datum/npc_loadout/kit/bandit_flavor,
	)
	loadout_pools = list(list(
		/datum/npc_loadout/weapon/bandit_shortsword,
		/datum/npc_loadout/weapon/bandit_cudgel,
		/datum/npc_loadout/weapon/bandit_falchion,
		/datum/npc_loadout/weapon/bandit_pick,
		/datum/npc_loadout/weapon/bandit_greataxe,
		/datum/npc_loadout/weapon/bandit_staff,
		/datum/npc_loadout/weapon/bandit_dagger,
	))

/datum/npc_archetype/highwayman/mount_reaver
	name = "Mount Reaver"
	job = "Mount Reaver"
	threat_point = THREAT_TOUGH
	statpack = /datum/npc_statpack/veteran
	skillpacks = list(
		/datum/npc_skillpack/melee/journeyman,
		/datum/npc_skillpack/brawl/journeyman,
		/datum/npc_skillpack/wrestling/expert,
		/datum/npc_skillpack/survival/apprentice,
		/datum/npc_skillpack/climbing/journeyman,
	)
	loadouts = list(
		/datum/npc_loadout/armor/light/leather,
		/datum/npc_loadout/kit/bandit_flavor/mount_reaver,
	)

/datum/npc_archetype/highwayman/archer
	name = "Highwayman Archer"
	job = "Highwayman Archer"
	statpack = /datum/npc_statpack/soldier/marksman
	skillpacks = list(
		/datum/npc_skillpack/melee/apprentice,
		/datum/npc_skillpack/brawl/apprentice,
		/datum/npc_skillpack/survival/apprentice,
		/datum/npc_skillpack/bows/expert,
	)
	loadouts = list(
		/datum/npc_loadout/armor/light/leather,
		/datum/npc_loadout/kit/bandit_flavor,
		/datum/npc_loadout/kit/bandit_shooter,
		/datum/npc_loadout/weapon/bandit_bow,
	)
	loadout_pools = null
	ai_controller = /datum/ai_controller/human_npc/archer

/datum/npc_archetype/highwayman/crossbowman
	name = "Highwayman Crossbowman"
	job = "Highwayman Crossbowman"
	statpack = /datum/npc_statpack/soldier/marksman
	skillpacks = list(
		/datum/npc_skillpack/melee/apprentice,
		/datum/npc_skillpack/brawl/apprentice,
		/datum/npc_skillpack/survival/apprentice,
		/datum/npc_skillpack/crossbows/expert,
	)
	loadouts = list(
		/datum/npc_loadout/armor/light/leather,
		/datum/npc_loadout/kit/bandit_flavor,
		/datum/npc_loadout/kit/bandit_shooter,
		/datum/npc_loadout/weapon/bandit_crossbow,
	)
	loadout_pools = null
	ai_controller = /datum/ai_controller/human_npc/archer

/datum/npc_archetype/highwayman/road_knight
	name = "Road Knight"
	job = "Road Knight"
	threat_point = THREAT_DEADLY
	statpack = /datum/npc_statpack/champion
	traits = list(TRAIT_BADTRAINER)
	skillpacks = list(
		/datum/npc_skillpack/melee/apprentice,
		/datum/npc_skillpack/brawl/journeyman,
		/datum/npc_skillpack/wrestling/expert,
		/datum/npc_skillpack/swords/master,
		/datum/npc_skillpack/shields/expert,
		/datum/npc_skillpack/survival/apprentice,
	)
	loadouts = list(
		/datum/npc_loadout/armor/light/leather,
		/datum/npc_loadout/kit/bandit_flavor,
		/datum/npc_loadout/armor/heavy/iron_chain/iron_plate/road_knight,
		/datum/npc_loadout/weapon/road_knight,
	)
	loadout_pools = null

/datum/npc_archetype/highwayman/sharpshooter
	name = "Highwayman Sharpshooter"
	job = "Highwayman Sharpshooter"
	threat_point = THREAT_DEADLY
	statpack = /datum/npc_statpack/champion/marksman
	traits = list(TRAIT_BADTRAINER)
	skillpacks = list(
		/datum/npc_skillpack/melee/apprentice,
		/datum/npc_skillpack/brawl/apprentice,
		/datum/npc_skillpack/wrestling/journeyman,
		/datum/npc_skillpack/swords/journeyman,
		/datum/npc_skillpack/bows/master,
		/datum/npc_skillpack/survival/apprentice,
	)
	loadouts = list(
		/datum/npc_loadout/armor/light/leather,
		/datum/npc_loadout/kit/bandit_flavor,
		/datum/npc_loadout/armor/heavy/iron_chain/cuirass/sharpshooter,
	)
	loadout_pools = null
	ai_controller = /datum/ai_controller/human_npc/archer
