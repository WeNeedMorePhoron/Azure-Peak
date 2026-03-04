/*
 * ========== Leylines ==========
 *
 * Leylines are the sites where mages perform encounter rituals. Scattered across the world
 * in different regions, each aligned to a realm. Mages must travel to find them.
 *
 * Charge system (veil attunement): each mage gains dayspassed + 1 charges per week (max 5).
 * Each ritual costs 1 charge. This naturally gates early-week spam while
 * rewarding patience — by day 4-5 you can chain several rituals in one trip.
 * Since charges are limited, mages are expected to go out to realm-aligned leylines
 * rather than waste charges on tamed ones that always give fewer mobs.
 *
 * Day gating: T1-T2 always available, T3 from day 3, T4 from day 4, T5 from day 5.
 * This keeps the first few days focused on lower-tier encounters.
 *
 * Leyline types:
 *   Tamed (hamlet/tower) — 4 uses/day, T1 only, neutral alignment.
 *     Neutral = not aligned with anything, so rituals always get -1 mob (training wheels).
 *   Normal (coast/grove/decap) — 2 uses/day, up to T4. Realm-aligned.
 *     Matching ritual alignment = full mob count. Wrong alignment = -1 mob.
 *   Powerful (bog) — 2 uses/day, up to T5. Void-aligned. Always +1 primary mob.
 *     Wrong alignment in Bog nets to normal — the +1 and -1 cancel out.
 */

GLOBAL_LIST_EMPTY(leyline_sites)
GLOBAL_LIST_EMPTY(leyline_activations)

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
	var/alignment = "neutral"
	var/leyline_type = "normal"
	var/mega_region = ""
	var/max_uses_per_day = 2
	var/uses_today = 0
	var/last_reset_day = 0
	var/max_tier = 0

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

/obj/structure/leyline/attack_hand(mob/living/user)
	if(!isarcyne(user))
		to_chat(user, span_notice("You sense faint energy from the stones, but cannot comprehend its nature."))
		return
	check_daily_reset()
	var/charges = get_leyline_charges(user)
	var/remaining = max_uses_per_day - uses_today
	to_chat(user, span_notice("This [name] pulses with [alignment] energy."))
	to_chat(user, span_notice("Leyline uses remaining today: [remaining]. Your veil attunement: [charges]."))
	if(max_tier)
		to_chat(user, span_notice("Maximum ritual tier: [max_tier]."))
	to_chat(user, span_notice("Draw a summoning circle nearby to begin a leyline encounter."))

/obj/structure/leyline/tamed
	name = "tamed leyline"
	desc = "A carefully stabilized ley line convergence. Its energy is weak but reliable."
	leyline_type = "tamed"
	alignment = "neutral"
	max_uses_per_day = 4
	max_tier = 1

/obj/structure/leyline/normal
	leyline_type = "normal"

/obj/structure/leyline/normal/coast
	name = "coastal leyline"
	desc = "Stones arranged in a spiral pattern. The air crackles with elemental energy."
	alignment = "elemental"
	mega_region = "coast"

/obj/structure/leyline/normal/grove
	name = "sylvan leyline"
	desc = "Moss-covered stones hum with fae energy. Flowers bloom unnaturally around them."
	alignment = "fae"
	mega_region = "grove"

/obj/structure/leyline/normal/decap
	name = "scorched leyline"
	desc = "Blackened stones radiate infernal heat. The ground around them is cracked and ashen."
	alignment = "infernal"
	mega_region = "decap"

/obj/structure/leyline/powerful
	name = "unstable leyline"
	desc = "A violent convergence of ley line energy. The stones tremble and the air distorts around them."
	leyline_type = "powerful"
	alignment = "void"
	mega_region = "bog"
