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

//** SCAVENGED **//

/datum/npc_loadout/armor/medium/scavenged
	name = "scavenged armor"
	armor = list(
		/obj/item/clothing/suit/roguetown/armor/chainmail/iron,
		/obj/item/clothing/suit/roguetown/armor/leather/hide,
		/obj/item/clothing/suit/roguetown/armor/plate/cuirass/copper,
		/obj/item/clothing/suit/roguetown/armor/gambeson,
	)
	wrists = list(
		/obj/item/clothing/wrists/roguetown/bracers/leather,
		/obj/item/clothing/wrists/roguetown/bracers/copper,
	)
	pants = list(
		/obj/item/clothing/under/roguetown/chainlegs/iron,
		/obj/item/clothing/under/roguetown/chainlegs/iron/kilt,
		/obj/item/clothing/under/roguetown/heavy_leather_pants/bronzeskirt,
	)
	head = list( //60% of a random helmet
		/obj/item/clothing/head/roguetown/helmet/horned = 3, //SOVL
		/obj/item/clothing/head/roguetown/helmet/sallet/iron/banded = 3,
		/obj/item/clothing/head/roguetown/helmet/leather/volfhelm = 3,
		/obj/item/clothing/head/roguetown/helmet/leather = 3,
		NPC_NOTHING = 8,
	)
	neck = list(
		/obj/item/clothing/neck/roguetown/gorget, //SOVL
		/obj/item/clothing/neck/roguetown/chaincoif/iron,
		/obj/item/clothing/neck/roguetown/bevor/iron,
	)
	gloves = list(
		/obj/item/clothing/gloves/roguetown/leather = 60,
		/obj/item/clothing/gloves/roguetown/plate/iron/banded = 40,
	)

/datum/npc_loadout/armor/medium/scavenged/archer
	name = "scavenged armor with leather helm"
	wrists = /obj/item/clothing/wrists/roguetown/bracers/leather
	armor = /obj/item/clothing/suit/roguetown/armor/chainmail/iron
	head = /obj/item/clothing/head/roguetown/helmet/leather
	gloves = /obj/item/clothing/gloves/roguetown/leather
