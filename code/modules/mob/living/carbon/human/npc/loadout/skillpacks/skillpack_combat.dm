//** MELEE **//

/datum/npc_skillpack/melee
	abstract_type = /datum/npc_skillpack/melee

/datum/npc_skillpack/melee/apprentice
	name = "apprentice melee"
	skills = list(
		/datum/skill/combat/knives = SKILL_LEVEL_APPRENTICE,
		/datum/skill/combat/polearms = SKILL_LEVEL_APPRENTICE,
		/datum/skill/combat/staves = SKILL_LEVEL_APPRENTICE,
		/datum/skill/combat/maces = SKILL_LEVEL_APPRENTICE,
		/datum/skill/combat/axes = SKILL_LEVEL_APPRENTICE,
		/datum/skill/combat/swords = SKILL_LEVEL_APPRENTICE,
		/datum/skill/combat/shields = SKILL_LEVEL_APPRENTICE,
	)

/datum/npc_skillpack/melee/journeyman
	name = "journeyman melee"
	skills = list(
		/datum/skill/combat/knives = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/polearms = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/staves = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/maces = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/axes = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/swords = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/shields = SKILL_LEVEL_JOURNEYMAN,
	)

/datum/npc_skillpack/melee/expert
	name = "expert melee"
	skills = list(
		/datum/skill/combat/knives = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/polearms = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/staves = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/maces = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/axes = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/swords = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/shields = SKILL_LEVEL_EXPERT,
	)

//** BRAWL **//

/datum/npc_skillpack/brawl
	abstract_type = /datum/npc_skillpack/brawl

/datum/npc_skillpack/brawl/apprentice
	name = "apprentice brawl"
	skills = list(
		/datum/skill/combat/unarmed = SKILL_LEVEL_APPRENTICE,
		/datum/skill/combat/wrestling = SKILL_LEVEL_APPRENTICE,
	)

/datum/npc_skillpack/brawl/journeyman
	name = "journeyman brawl"
	skills = list(
		/datum/skill/combat/unarmed = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/wrestling = SKILL_LEVEL_JOURNEYMAN,
	)

/datum/npc_skillpack/brawl/expert
	name = "expert brawl"
	skills = list(
		/datum/skill/combat/unarmed = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/wrestling = SKILL_LEVEL_EXPERT,
	)

//** WRESTLING **//

/datum/npc_skillpack/wrestling
	abstract_type = /datum/npc_skillpack/wrestling

/datum/npc_skillpack/wrestling/journeyman
	name = "journeyman wrestling"
	skills = list(/datum/skill/combat/wrestling = SKILL_LEVEL_JOURNEYMAN)

/datum/npc_skillpack/wrestling/expert
	name = "expert wrestling"
	skills = list(/datum/skill/combat/wrestling = SKILL_LEVEL_EXPERT)

//** SWORDS **//

/datum/npc_skillpack/swords
	abstract_type = /datum/npc_skillpack/swords

/datum/npc_skillpack/swords/journeyman
	name = "journeyman sword"
	skills = list(/datum/skill/combat/swords = SKILL_LEVEL_JOURNEYMAN)

/datum/npc_skillpack/swords/expert
	name = "expert sword"
	skills = list(/datum/skill/combat/swords = SKILL_LEVEL_EXPERT)

/datum/npc_skillpack/swords/master
	name = "master sword"
	skills = list(/datum/skill/combat/swords = SKILL_LEVEL_MASTER)

//** SHIELDS **//

/datum/npc_skillpack/shields
	abstract_type = /datum/npc_skillpack/shields

/datum/npc_skillpack/shields/journeyman
	name = "journeyman shield"
	skills = list(/datum/skill/combat/shields = SKILL_LEVEL_JOURNEYMAN)

/datum/npc_skillpack/shields/expert
	name = "expert shield"
	skills = list(/datum/skill/combat/shields = SKILL_LEVEL_EXPERT)

//** BOWS **//

/datum/npc_skillpack/bows
	abstract_type = /datum/npc_skillpack/bows

/datum/npc_skillpack/bows/journeyman
	name = "journeyman bow"
	skills = list(/datum/skill/combat/bows = SKILL_LEVEL_JOURNEYMAN)

/datum/npc_skillpack/bows/expert
	name = "expert bow"
	skills = list(/datum/skill/combat/bows = SKILL_LEVEL_EXPERT)

/datum/npc_skillpack/bows/master
	name = "master bow"
	skills = list(/datum/skill/combat/bows = SKILL_LEVEL_MASTER)

//** CROSSBOWS **//

/datum/npc_skillpack/crossbows
	abstract_type = /datum/npc_skillpack/crossbows

/datum/npc_skillpack/crossbows/journeyman
	name = "journeyman crossbow"
	skills = list(/datum/skill/combat/crossbows = SKILL_LEVEL_JOURNEYMAN)

/datum/npc_skillpack/crossbows/expert
	name = "expert crossbow"
	skills = list(/datum/skill/combat/crossbows = SKILL_LEVEL_EXPERT)

//** KNIVES **//

/datum/npc_skillpack/knives
	abstract_type = /datum/npc_skillpack/knives

/datum/npc_skillpack/knives/journeyman
	name = "journeyman knife"
	skills = list(/datum/skill/combat/knives = SKILL_LEVEL_JOURNEYMAN)

/datum/npc_skillpack/knives/expert
	name = "expert knife"
	skills = list(/datum/skill/combat/knives = SKILL_LEVEL_EXPERT)
