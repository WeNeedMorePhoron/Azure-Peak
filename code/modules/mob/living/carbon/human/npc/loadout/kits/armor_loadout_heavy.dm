//** IRON CHAIN **//

/datum/npc_loadout/armor/heavy
	abstract_type = /datum/npc_loadout/armor/heavy
	armor_training = ARMOR_CLASS_HEAVY

/datum/npc_loadout/armor/heavy/iron_chain
	abstract_type = /datum/npc_loadout/armor/heavy/iron_chain
	head = /obj/item/clothing/head/roguetown/helmet/heavy/knight/iron
	shirt = /obj/item/clothing/suit/roguetown/armor/chainmail/hauberk/iron
	neck = /obj/item/clothing/neck/roguetown/chaincoif/iron
	wrists = /obj/item/clothing/wrists/roguetown/bracers/iron
	gloves = /obj/item/clothing/gloves/roguetown/plate/iron
	pants = /obj/item/clothing/under/roguetown/chainlegs/iron
	shoes = /obj/item/clothing/shoes/roguetown/boots/armor/iron
	belt = /obj/item/storage/belt/rogue/leather

/datum/npc_loadout/armor/heavy/iron_chain/iron_plate
	name = "iron chain with iron plate"
	armor = /obj/item/clothing/suit/roguetown/armor/plate/iron

/datum/npc_loadout/armor/heavy/iron_chain/cuirass
	name = "iron chain with cuirass"
	armor = /obj/item/clothing/suit/roguetown/armor/plate/cuirass/iron

/datum/npc_loadout/armor/heavy/iron_chain/full_plate
	name = "iron chain with full plate"
	armor = /obj/item/clothing/suit/roguetown/armor/plate/full/iron
	neck = /obj/item/clothing/neck/roguetown/chaincoif/full

/datum/npc_loadout/armor/heavy/iron_chain/mixed_plate
	name = "iron chain with mixed plate"
	armor = list(
		/obj/item/clothing/suit/roguetown/armor/brigandine/light,
		/obj/item/clothing/suit/roguetown/armor/plate/cuirass/iron,
		/obj/item/clothing/suit/roguetown/armor/plate/scale,
	)
	neck = /obj/item/clothing/neck/roguetown/chaincoif/full
	head = /obj/item/clothing/head/roguetown/helmet/heavy/knight/skettle

//** STEEL CHAIN **//

/datum/npc_loadout/armor/heavy/steel_chain
	name = "steel chain"
	armor = /obj/item/clothing/suit/roguetown/armor/chainmail/hauberk/heavy
	neck = /obj/item/clothing/neck/roguetown/chaincoif
	head = /obj/item/clothing/head/roguetown/helmet
	wrists = /obj/item/clothing/wrists/roguetown/bracers
	pants = /obj/item/clothing/under/roguetown/brigandinelegs
