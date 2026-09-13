GLOBAL_LIST_INIT(npc_skillpacks, build_npc_skillpacks())

/proc/build_npc_skillpacks()
	. = list()
	for(var/datum/npc_skillpack/skillpack_type as anything in subtypesof(/datum/npc_skillpack))
		if(IS_ABSTRACT(skillpack_type))
			continue
		.[skillpack_type] = new skillpack_type()

/proc/get_npc_skillpack(datum/npc_skillpack/skillpack)
	if(istype(skillpack))
		return skillpack
	if(!ispath(skillpack, /datum/npc_skillpack))
		return null
	. = GLOB.npc_skillpacks[skillpack]
	if(!.)
		stack_trace("get_npc_skillpack called with unregistered skillpack type [skillpack]")

/datum/npc_skillpack
	abstract_type = /datum/npc_skillpack
	var/name = "skillpack"
	var/list/skills

/datum/npc_skillpack/proc/apply(mob/living/carbon/human/H)
	if(!H)
		return
	for(var/skill in skills)
		H.adjust_skillrank_up_to(skill, skills[skill], TRUE)
