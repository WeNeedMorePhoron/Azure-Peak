#define CONJURE_UNTETHER_ID "conjure_untether"

/datum/component/conjured_minion
	var/datum/weakref/summoner_ref
	var/recoil_energy_floor = 200
	var/recoil_debuff = TRUE
	var/dismissing = FALSE
	var/leash_range = 10
	var/base_alpha = 255
	var/untether_strain = 0
	var/untether_max = 5
	var/tether_timer

/datum/component/conjured_minion/Initialize(mob/living/summoner, energy_floor = 200, apply_debuff = TRUE)
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE
	summoner_ref = WEAKREF(summoner)
	recoil_energy_floor = energy_floor
	recoil_debuff = apply_debuff
	ADD_TRAIT(parent, TRAIT_CONJURED_SUMMON, REF(src))
	RegisterSignal(parent, COMSIG_MOB_DEATH, PROC_REF(on_summon_death))
	RegisterSignal(parent, COMSIG_MOVABLE_PRE_MOVE, PROC_REF(check_leash))
	if(ishuman(parent))
		apply_phantasmal()
		RegisterSignal(parent, COMSIG_PARENT_EXAMINE, PROC_REF(on_examine))
	var/mob/living/M = parent
	base_alpha = M.alpha
	make_docile()
	addtimer(CALLBACK(src, PROC_REF(make_docile)), 1.5 SECONDS)
	tether_timer = addtimer(CALLBACK(src, PROC_REF(check_tether)), 4 SECONDS, TIMER_LOOP | TIMER_STOPPABLE)

/datum/component/conjured_minion/proc/make_docile()
	var/mob/living/M = parent
	if(QDELETED(M) || !M.ai_controller)
		return
	var/mob/living/summoner = summoner_ref?.resolve()
	if(!summoner)
		return
	M.ai_controller.set_blackboard_key(BB_FOLLOW_TARGET, summoner)
	M.ai_controller.set_blackboard_key(BB_TARGETTING_DATUM, GLOB.conjured_targetting)
	M.pet_passive = TRUE

/datum/component/conjured_minion/Destroy(force, silent)
	if(tether_timer)
		deltimer(tether_timer)
		tether_timer = null
	if(!QDELETED(parent))
		REMOVE_TRAIT(parent, TRAIT_CONJURED_SUMMON, REF(src))
		var/mob/living/M = parent
		M.remove_movespeed_modifier(CONJURE_UNTETHER_ID)
	return ..()

/datum/component/conjured_minion/proc/on_summon_death(mob/living/source, gibbed)
	SIGNAL_HANDLER
	if(dismissing)
		return
	var/mob/living/summoner = summoner_ref?.resolve()
	if(!summoner || summoner.stat == DEAD)
		return
	INVOKE_ASYNC(GLOBAL_PROC, GLOBAL_PROC_REF(apply_conjure_recoil), summoner, recoil_energy_floor, recoil_debuff)

/datum/component/conjured_minion/proc/check_leash(atom/movable/source, atom/newloc)
	SIGNAL_HANDLER
	var/mob/living/summoner = summoner_ref?.resolve()
	if(!summoner || summoner.z != source.z)
		return
	var/mob/living/M = source
	var/datum/ai_controller/AC = M.ai_controller
	if(AC && AC.blackboard[BB_TRAVEL_DESTINATION])
		return
	var/newdist = get_dist(newloc, summoner)
	if(newdist <= leash_range)
		return
	if(newdist >= get_dist(source, summoner))
		return COMPONENT_MOVABLE_BLOCK_PRE_MOVE

/datum/component/conjured_minion/proc/check_tether()
	var/mob/living/M = parent
	if(QDELETED(M) || dismissing)
		return
	var/mob/living/summoner = summoner_ref?.resolve()
	validate_combat_target(M, summoner)
	if(summoner && !QDELETED(summoner) && summoner.z == M.z)
		if(untether_strain > 0)
			relax_tether(M)
		return
	strain_tether(M)

/datum/component/conjured_minion/proc/validate_combat_target(mob/living/M, mob/living/summoner)
	var/datum/ai_controller/AC = M.ai_controller
	if(!AC)
		return
	var/mob/living/current = AC.blackboard[BB_BASIC_MOB_CURRENT_TARGET]
	if(isnull(current))
		return
	if(!QDELETED(current) && !current.stat)
		if(!summoner || QDELETED(summoner) || summoner.z != M.z)
			return
		if(get_dist(current, summoner) <= leash_range + 1)
			return
	AC.clear_blackboard_key(BB_BASIC_MOB_CURRENT_TARGET)
	if(AC.blackboard[BB_HIGHEST_THREAT_MOB] == current)
		AC.clear_blackboard_key(BB_HIGHEST_THREAT_MOB)
	var/list/table = AC.blackboard[BB_MOB_AGGRO_TABLE]
	if(islist(table))
		table -= current

/datum/component/conjured_minion/proc/strain_tether(mob/living/M)
	untether_strain++
	if(untether_strain == 1)
		M.visible_message(span_warning("[M] flickers, its form straining against the distant leyline."))
	M.alpha = max(50, M.alpha - 24)
	M.add_movespeed_modifier(CONJURE_UNTETHER_ID, update = TRUE, override = TRUE, multiplicative_slowdown = min(untether_strain, untether_max) * 0.6)
	if(untether_strain >= untether_max)
		M.visible_message(span_warning("[M] loses all cohesion, unraveling as the leyline tether snaps."))
		dismiss_conjured_minion(M)

/datum/component/conjured_minion/proc/relax_tether(mob/living/M)
	untether_strain = 0
	M.remove_movespeed_modifier(CONJURE_UNTETHER_ID)
	M.alpha = base_alpha
	M.visible_message(span_notice("[M] steadies as its master's presence returns."))

/datum/component/conjured_minion/proc/apply_phantasmal()
	var/mob/living/M = parent
	M.alpha = 170
	var/col = get_phantom_color()
	M.add_atom_colour(soften_color(col, 0.55), FIXED_COLOUR_PRIORITY)
	M.filters += filter(type = "drop_shadow", x = 0, y = 0, size = 2, offset = 0, color = col)

/datum/component/conjured_minion/proc/soften_color(col, blend = 0.55)
	var/list/parts = ReadRGB(col)
	if(length(parts) < 3)
		return col
	return rgb(parts[1] + (255 - parts[1]) * blend, parts[2] + (255 - parts[2]) * blend, parts[3] + (255 - parts[3]) * blend)

/datum/component/conjured_minion/proc/get_phantom_color()
	var/mob/living/summoner = summoner_ref?.resolve()
	var/key = summoner ? "[summoner.real_name]" : "arcyne"
	var/hash = 0
	for(var/i in 1 to length(key))
		hash += text2ascii(key, i)
	var/list/palette = list("#d13b2e", "#e0a020")
	return palette[(hash % length(palette)) + 1]

/datum/component/conjured_minion/proc/on_examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	var/mob/living/summoner = summoner_ref?.resolve()
	examine_list += span_notice("A phantasmal servant, bound to the will of [summoner ? summoner.real_name : "an unknown magus"].")

#undef CONJURE_UNTETHER_ID
