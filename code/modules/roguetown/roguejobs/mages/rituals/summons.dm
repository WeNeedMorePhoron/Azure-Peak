// Binding Array will reuse this pattern for single-creature binding (costs 2x ritual mats)
/datum/runeritual/summoning
	name = "summoning ritual parent"
	desc = "summoning parent rituals."
	category = "Summoning"
	blacklisted = TRUE

/datum/runeritual/summoning/proc/summon_ritual_mob(mob/living/user, turf/loc, mob/living/mob_to_summon)
	var/mob/living/simple_animal/summoned
	if(isliving(mob_to_summon))
		summoned = mob_to_summon
	else
		summoned = new mob_to_summon(loc)
		ADD_TRAIT(summoned, TRAIT_PACIFISM, TRAIT_GENERIC)
		summoned.status_flags += GODMODE
		summoned.candodge = FALSE
		animate(summoned, color = "#ff0000",time = 5)
		summoned.move_resist = MOVE_FORCE_EXTREMELY_STRONG
		summoned.binded = TRUE
		summoned.SetParalyzed(900)
		return summoned
