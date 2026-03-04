/datum/runeritual/binding
	name = "binding ritual parent"
	desc = "binding parent rituals."
	category = "Binding"
	blacklisted = TRUE

/datum/runeritual/binding/proc/bind_ritual_mob(mob/living/user, turf/loc, mob/living/mob_to_bind)
	var/mob/living/simple_animal/binded
	if(isliving(mob_to_bind))
		binded = mob_to_bind
	else
		binded = new mob_to_bind(loc)
		ADD_TRAIT(binded, TRAIT_PACIFISM, TRAIT_GENERIC)
		binded.status_flags += GODMODE
		binded.candodge = FALSE
		animate(binded, color = "#ff0000",time = 5)
		binded.move_resist = MOVE_FORCE_EXTREMELY_STRONG
		binded.binded = TRUE
		binded.SetParalyzed(900)
		return binded
