//** GAMBESON **//

/datum/npc_loadout/armor/light
	abstract_type = /datum/npc_loadout/armor/light
	armor_training = ARMOR_CLASS_LIGHT

/datum/npc_loadout/armor/light/gambeson
	name = "gambeson with leather"
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson
	wrists = /obj/item/clothing/wrists/roguetown/bracers/leather
	pants = /obj/item/clothing/under/roguetown/trou/leather
	shoes = /obj/item/clothing/shoes/roguetown/boots/leather

/datum/npc_loadout/armor/light/gambeson/helmeted
	name = "gambeson with helmet"
	armor = list(
		/obj/item/clothing/suit/roguetown/armor/leather = 1,
		NPC_NOTHING = 3,
	)
	head = list(
		/obj/item/clothing/head/roguetown/helmet/kettle/iron = 2,
		/obj/item/clothing/head/roguetown/helmet/sallet/iron = 1,
		/obj/item/clothing/head/roguetown/helmet/skullcap = 2,
		/obj/item/clothing/head/roguetown/armingcap = 1,
		NPC_NOTHING = 1,
	)

//** LEATHER **//

/datum/npc_loadout/armor/light/leather
	name = "leather armor"
	wrists = /obj/item/clothing/wrists/roguetown/bracers/leather
	armor = /obj/item/clothing/suit/roguetown/armor/leather
	pants = /obj/item/clothing/under/roguetown/trou/leather
	gloves = /obj/item/clothing/gloves/roguetown/leather
	shoes = /obj/item/clothing/shoes/roguetown/boots/leather

/datum/npc_loadout/armor/light/leather/iron_bracers
	name = "leather armor with iron bracers"
	wrists = /obj/item/clothing/wrists/roguetown/bracers/iron

//** STUDDED **//

/datum/npc_loadout/armor/light/studded
	name = "studded leather armor"
	wrists = /obj/item/clothing/wrists/roguetown/bracers/leather/heavy
	armor = /obj/item/clothing/suit/roguetown/armor/leather/studded
	pants = /obj/item/clothing/under/roguetown/heavy_leather_pants
	gloves = /obj/item/clothing/gloves/roguetown/leather
	shoes = /obj/item/clothing/shoes/roguetown/boots/leather

//** BRIGANDINE **//

/datum/npc_loadout/armor/light/brigandine
	name = "light brigandine armor"
	wrists = /obj/item/clothing/wrists/roguetown/bracers/brigandine
	armor = /obj/item/clothing/suit/roguetown/armor/brigandine/light
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson
	pants = /obj/item/clothing/under/roguetown/brigandinelegs
	gloves = /obj/item/clothing/gloves/roguetown/leather
	shoes = /obj/item/clothing/shoes/roguetown/boots/leather
