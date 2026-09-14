//** IRON **//

/datum/npc_loadout/armor/medium
	abstract_type = /datum/npc_loadout/armor/medium
	armor_training = ARMOR_CLASS_MEDIUM

/datum/npc_loadout/armor/medium/iron_hauberk
	name = "iron hauberk"
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson
	armor = /obj/item/clothing/suit/roguetown/armor/chainmail/hauberk/iron
	neck = /obj/item/clothing/neck/roguetown/coif/heavypadding
	head = /obj/item/clothing/head/roguetown/helmet/kettle/iron
	gloves = /obj/item/clothing/gloves/roguetown/chain/iron
	wrists = /obj/item/clothing/wrists/roguetown/bracers/iron
	pants = /obj/item/clothing/under/roguetown/chainlegs/iron
	shoes = /obj/item/clothing/shoes/roguetown/boots/armor/iron

//** STEEL **//

/datum/npc_loadout/armor/medium/steel_mixed
	name = "mixed steel armor"
	armor = list(
		/obj/item/clothing/suit/roguetown/armor/brigandine/light,
		/obj/item/clothing/suit/roguetown/armor/chainmail/hauberk,
		/obj/item/clothing/suit/roguetown/armor/plate/cuirass,
		/obj/item/clothing/suit/roguetown/armor/plate/cuirass/fluted,
	)
	head = list(
		/obj/item/clothing/head/roguetown/helmet,
		/obj/item/clothing/head/roguetown/helmet/skullcap,
		/obj/item/clothing/head/roguetown/helmet/sallet,
	)
	wrists = /obj/item/clothing/wrists/roguetown/bracers/jackchain
	pants = /obj/item/clothing/under/roguetown/brigandinelegs
