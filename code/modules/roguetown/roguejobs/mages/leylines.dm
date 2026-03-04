// Leyline 
// Mages gain dayspassed + 1 charges per week. Each ritual costs 1 charge.
// Day gating: T1-T2 from day 1, T3 from day 3, T4 from day 4, T5 (Void Dragon) from day 5.
// Wrong alignment = -1 mob. Powerful leyline wrong alignment = +1 mob (Bog tax).

GLOBAL_LIST_EMPTY(leyline_sites)
GLOBAL_LIST_EMPTY(leyline_activations) // real_name -> activations used this week

/proc/get_leyline_charges(mob/living/user)
	var/used = GLOB.leyline_activations[user.real_name] || 0
	return clamp(GLOB.dayspassed + 1 - used, 0, 5)

/proc/spend_leyline_charge(mob/living/user)
	if(!GLOB.leyline_activations[user.real_name])
		GLOB.leyline_activations[user.real_name] = 0
	GLOB.leyline_activations[user.real_name]++

/proc/get_max_leyline_tier()
	if(GLOB.dayspassed >= 5)
		return 5
	if(GLOB.dayspassed >= 4)
		return 4
	if(GLOB.dayspassed >= 3)
		return 3
	return 2

// ========== Leyline Structure ==========

/obj/structure/leyline
	name = "inactive leyline"
	desc = "A curious arrangement of stones."
	icon = 'icons/effects/effects.dmi'
	icon_state = "inactiveleyline"
	anchored = TRUE
	density = FALSE
	var/active = FALSE
	var/mob/living/guardian = null
	var/time_between_uses = 12000
	var/last_process = 0
	var/alignment = "neutral" // infernal, fae, elemental, void, neutral
	var/leyline_type = "normal" // tamed, normal, powerful
	var/mega_region = ""
	var/max_uses_per_day = 2
	var/uses_today = 0
	var/last_reset_day = 0
	var/max_tier = 0 // 0 = no cap

/obj/structure/leyline/Initialize()
	. = ..()
	last_process = world.time
	GLOB.leyline_sites += src

/obj/structure/leyline/Destroy()
	GLOB.leyline_sites -= src
	return ..()

/obj/structure/leyline/proc/check_daily_reset()
	if(GLOB.dayspassed != last_reset_day)
		uses_today = 0
		last_reset_day = GLOB.dayspassed

/obj/structure/leyline/proc/has_uses_remaining()
	check_daily_reset()
	return uses_today < max_uses_per_day

/obj/structure/leyline/proc/use_charge()
	check_daily_reset()
	uses_today++

// ========== Subtypes ==========

// Tamed: in hamlet / mage tower. 4 uses, T1 only.
/obj/structure/leyline/tamed
	name = "tamed leyline"
	desc = "A carefully stabilized ley line convergence. Its energy is weak but reliable."
	leyline_type = "tamed"
	alignment = "neutral"
	max_uses_per_day = 4
	max_tier = 1

/obj/structure/leyline/normal
	leyline_type = "normal"

// Coast: elemental
/obj/structure/leyline/normal/coast
	name = "coastal leyline"
	desc = "Stones arranged in a spiral pattern. The air crackles with elemental energy."
	alignment = "elemental"
	mega_region = "coast"

// Azure Grove: fae
/obj/structure/leyline/normal/grove
	name = "sylvan leyline"
	desc = "Moss-covered stones hum with fae energy. Flowers bloom unnaturally around them."
	alignment = "fae"
	mega_region = "grove"

// Mount Decapitation: infernal
/obj/structure/leyline/normal/decap
	name = "scorched leyline"
	desc = "Blackened stones radiate infernal heat. The ground around them is cracked and ashen."
	alignment = "infernal"
	mega_region = "decap"

// Terrorbog: void. Best rewards, biggest fights. Only way to void rituals + void dragon.
/obj/structure/leyline/powerful
	name = "unstable leyline"
	desc = "A violent convergence of ley line energy. The stones tremble and the air distorts around them."
	leyline_type = "powerful"
	alignment = "void"
	mega_region = "bog"
