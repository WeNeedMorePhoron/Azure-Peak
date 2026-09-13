GLOBAL_LIST_INIT(npc_archetypes, build_npc_archetypes())

/proc/build_npc_archetypes()
	. = list()
	for(var/datum/npc_archetype/archetype_type as anything in subtypesof(/datum/npc_archetype))
		if(IS_ABSTRACT(archetype_type))
			continue
		.[archetype_type] = new archetype_type()

/proc/get_npc_archetype(datum/npc_archetype/archetype)
	if(istype(archetype))
		return archetype
	if(!ispath(archetype, /datum/npc_archetype))
		return null
	. = GLOB.npc_archetypes[archetype]
	if(!.)
		stack_trace("get_npc_archetype called with unregistered archetype type [archetype]")

/datum/npc_archetype
	abstract_type = /datum/npc_archetype
	var/name = "NPC"
	var/job
	var/category
	var/faction_tag
	var/threat_point = 0
	var/body
	var/statpack
	var/list/skillpacks
	var/outfit_type = /datum/outfit/npc
	var/list/loadouts
	var/list/loadout_pools
	var/ai_controller
	var/list/traits

/datum/npc_archetype/proc/apply_early(mob/living/carbon/human/H)
	var/datum/npc_body/npc_body = get_npc_body(body)
	if(npc_body)
		npc_body.apply_early(H)

/datum/npc_archetype/proc/apply(mob/living/carbon/human/H)
	if(!H)
		return
	if(job)
		H.job = job
	var/datum/npc_body/npc_body = get_npc_body(body)
	var/datum/npc_statpack/npc_statpack = get_npc_statpack(statpack)
	if(npc_body)
		npc_body.apply_setup(H)
	for(var/trait in traits)
		var/trait_source = traits[trait] || INNATE_TRAIT
		ADD_TRAIT(H, trait, trait_source)
	if(npc_statpack)
		npc_statpack.apply(H)
	apply_skillpacks(H)
	if(ai_controller)
		H.upgrade_ai_controller(ai_controller)
	H.equipOutfit(build_outfit())
	if(npc_body)
		npc_body.apply_appearance(H)
		npc_body.apply_name(H)
		npc_body.finish(H)

/datum/npc_archetype/proc/apply_skillpacks(mob/living/carbon/human/H)
	for(var/path in skillpacks)
		var/datum/npc_skillpack/skillpack = get_npc_skillpack(path)
		if(skillpack)
			skillpack.apply(H)

/datum/npc_archetype/proc/build_outfit()
	var/datum/outfit/npc/outfit = new outfit_type
	outfit.loadouts = resolve_loadouts()
	return outfit

/datum/npc_archetype/proc/resolve_loadouts()
	. = list()
	if(length(loadouts))
		. += loadouts
	for(var/pool in loadout_pools)
		var/picked = resolve_npc_pick(pool)
		if(picked)
			. += picked

/mob/living/carbon/human/proc/init_npc_archetype()
	var/datum/npc_archetype/archetype = get_npc_archetype(npc_archetype)
	if(!archetype)
		return
	archetype.apply_early(src)
	addtimer(CALLBACK(src, PROC_REF(after_creation)), 1 SECONDS)

/mob/living/carbon/human/proc/apply_npc_archetype()
	var/datum/npc_archetype/archetype = get_npc_archetype(npc_archetype)
	if(!archetype)
		return
	archetype.apply(src)
