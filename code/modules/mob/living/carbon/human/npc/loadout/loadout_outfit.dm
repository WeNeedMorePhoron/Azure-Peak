/datum/outfit/npc
	name = "NPC"
	var/list/loadouts

/datum/outfit/npc/pre_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	apply_armor_training(H)
	apply_loadouts(H, visualsOnly)

/datum/outfit/npc/proc/apply_loadouts(mob/living/carbon/human/H, visualsOnly = FALSE)
	for(var/path in loadouts)
		var/datum/npc_loadout/loadout = get_npc_loadout(path)
		if(!loadout)
			continue
		loadout.apply(src, H, visualsOnly)

/datum/outfit/npc/proc/get_armor_training()
	. = ARMOR_CLASS_NONE
	for(var/path in loadouts)
		var/datum/npc_loadout/loadout = get_npc_loadout(path)
		if(!loadout)
			continue
		. = max(., loadout.armor_training)

/datum/outfit/npc/proc/apply_armor_training(mob/living/carbon/human/H)
	if(!H)
		return
	switch(get_armor_training())
		if(ARMOR_CLASS_MEDIUM)
			ADD_TRAIT(H, TRAIT_MEDIUMARMOR, NPC_LOADOUT_TRAIT)
		if(ARMOR_CLASS_HEAVY)
			ADD_TRAIT(H, TRAIT_HEAVYARMOR, NPC_LOADOUT_TRAIT)
