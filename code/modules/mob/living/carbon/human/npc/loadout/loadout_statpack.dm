GLOBAL_LIST_INIT(npc_statpacks, build_npc_statpacks())

/proc/build_npc_statpacks()
	. = list()
	for(var/datum/npc_statpack/statpack_type as anything in subtypesof(/datum/npc_statpack))
		if(IS_ABSTRACT(statpack_type))
			continue
		.[statpack_type] = new statpack_type()

/proc/get_npc_statpack(datum/npc_statpack/statpack)
	if(istype(statpack))
		return statpack
	if(!ispath(statpack, /datum/npc_statpack))
		return null
	. = GLOB.npc_statpacks[statpack]
	if(!.)
		stack_trace("get_npc_statpack called with unregistered statpack type [statpack]")

/datum/npc_statpack
	abstract_type = /datum/npc_statpack
	var/name = "statpack"
	var/strength
	var/speed
	var/constitution
	var/intelligence
	var/willpower
	var/perception
	var/luck

/datum/npc_statpack/proc/apply(mob/living/carbon/human/H)
	if(!H)
		return
	H.STASTR = resolve_stat(strength, H.STASTR)
	H.STASPD = resolve_stat(speed, H.STASPD)
	H.STACON = resolve_stat(constitution, H.STACON)
	H.STAINT = resolve_stat(intelligence, H.STAINT)
	H.STAWIL = resolve_stat(willpower, H.STAWIL)
	H.STAPER = resolve_stat(perception, H.STAPER)
	H.STALUC = resolve_stat(luck, H.STALUC)

/datum/npc_statpack/proc/resolve_stat(entry, current)
	if(isnull(entry))
		return current
	if(!islist(entry))
		return entry
	var/list/range = entry
	if(length(range) < 2)
		return length(range) ? range[1] : current
	return rand(range[1], range[2])
