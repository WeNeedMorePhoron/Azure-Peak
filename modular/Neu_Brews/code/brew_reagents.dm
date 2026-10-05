/datum/reagent/consumable
	var/datum/status_effect/buff/brew/brew_buff

/datum/reagent/consumable/proc/apply_brew(mob/living/M, fresh = FALSE)
	if(!brew_buff)
		return
	if(fresh || M.has_status_effect(brew_buff))
		M.apply_status_effect(brew_buff)

/datum/reagent/consumable/herbal_tea
	drink_type = DRINKTYPE_CAFFEINE
	reagent_state = LIQUID
	hydration_factor = 5
	overdose_threshold = 0
	metabolization_rate = REAGENTS_METABOLISM
	alpha = 173

/datum/reagent/consumable/herbal_tea/on_mob_metabolize(mob/living/L)
	. = ..()
	apply_brew(L, TRUE)

/datum/reagent/consumable/herbal_tea/on_mob_life(mob/living/carbon/M)
	. = ..()
	apply_brew(M)
