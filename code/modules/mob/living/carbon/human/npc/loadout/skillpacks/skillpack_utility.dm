//** SURVIVAL **//

/datum/npc_skillpack/survival
	abstract_type = /datum/npc_skillpack/survival

/datum/npc_skillpack/survival/apprentice
	name = "apprentice survival"
	skills = list(
		/datum/skill/misc/swimming = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/climbing = SKILL_LEVEL_APPRENTICE,
	)

/datum/npc_skillpack/survival/journeyman
	name = "journeyman survival"
	skills = list(
		/datum/skill/misc/swimming = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/climbing = SKILL_LEVEL_JOURNEYMAN,
	)

//** CLIMBING **//

/datum/npc_skillpack/climbing
	abstract_type = /datum/npc_skillpack/climbing

/datum/npc_skillpack/climbing/journeyman
	name = "journeyman climbing"
	skills = list(/datum/skill/misc/climbing = SKILL_LEVEL_JOURNEYMAN)

//** ATHLETICS **//

/datum/npc_skillpack/athletics
	abstract_type = /datum/npc_skillpack/athletics

/datum/npc_skillpack/athletics/apprentice
	name = "apprentice athletics"
	skills = list(/datum/skill/misc/athletics = SKILL_LEVEL_APPRENTICE)

/datum/npc_skillpack/athletics/journeyman
	name = "journeyman athletics"
	skills = list(/datum/skill/misc/athletics = SKILL_LEVEL_JOURNEYMAN)

//** RIDING **//

/datum/npc_skillpack/riding
	abstract_type = /datum/npc_skillpack/riding

/datum/npc_skillpack/riding/journeyman
	name = "journeyman riding"
	skills = list(/datum/skill/misc/riding = SKILL_LEVEL_JOURNEYMAN)
