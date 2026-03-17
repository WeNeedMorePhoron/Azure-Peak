/*
 * Magic Aspects - the discipline system for full casters.
 *
 * Each full caster picks 1 Major Aspect and 2 Minor Aspects.
 * T4 casters may pick 2 Major Aspects instead (the exception that proves the rule).
 *
 * Binding/unbinding involves reciting chants — Latin-English alternation.
 * Major aspects: Latin, English, Latin (triple). Minor aspects: Latin, English (pair).
 */

/datum/magic_aspect
	var/name = "Aspect"
	var/desc = "An arcyne discipline."
	var/fluff_desc = ""
	var/aspect_type = ASPECT_MAJOR
	/// Appended to implements when attuned: "Fire" -> "Staff of Fire"
	var/attuned_name = ""
	// Always granted spells
	var/list/fixed_spells = list()
	/// Pointbuy are optionals - for point buy aspect
	var/list/pointbuy_spells = list()
	var/pointbuy_budget = 0
	/// Assoc list: base_spell_path -> upgraded_spell_path for T4 casters.
	var/list/prestige_upgrades = list()
	var/school_color = GLOW_COLOR_ARCANE
	var/list/countersynergy = list()
	/// Major: Latin, English, Latin. Minor: Latin, English.
	var/list/binding_chants = list()
	var/list/unbinding_chants = list()

/datum/magic_aspect/proc/get_implement_name(base_name)
	if(!attuned_name)
		return base_name
	return "[base_name] of [attuned_name]"

/datum/magic_aspect/proc/grant_spells(datum/mind/target)
	var/list/granted = list()
	for(var/spell_path in fixed_spells)
		if(target.has_spell(spell_path))
			continue
		var/datum/new_spell = new spell_path
		mark_aspect_spell(new_spell)
		target.AddSpell(new_spell)
		granted += new_spell
	return granted

/datum/magic_aspect/proc/apply_prestige(datum/mind/target, user_tier)
	if(user_tier < 4 || !length(prestige_upgrades))
		return
	for(var/base_path in prestige_upgrades)
		var/upgrade_path = prestige_upgrades[base_path]
		var/datum/existing = target.get_spell(base_path)
		if(existing)
			target.RemoveSpell(existing)
			var/datum/upgraded = new upgrade_path
			mark_aspect_spell(upgraded)
			target.AddSpell(upgraded)

/datum/magic_aspect/proc/revoke_spells(datum/mind/target)
	for(var/spell_path in fixed_spells)
		var/datum/existing = target.get_spell(spell_path)
		if(existing)
			target.RemoveSpell(existing)
	for(var/base_path in prestige_upgrades)
		var/upgrade_path = prestige_upgrades[base_path]
		var/datum/existing = target.get_spell(upgrade_path)
		if(existing)
			target.RemoveSpell(existing)
	for(var/spell_path in pointbuy_spells)
		var/datum/existing = target.get_spell(spell_path)
		if(existing)
			target.RemoveSpell(existing)

/datum/magic_aspect/proc/mark_aspect_spell(datum/spell_instance)
	if(istype(spell_instance, /obj/effect/proc_holder/spell))
		var/obj/effect/proc_holder/spell/S = spell_instance
		S.learned_from_pool = "aspect_[type]"
		S.refundable = FALSE
	else if(istype(spell_instance, /datum/action/cooldown/spell))
		var/datum/action/cooldown/spell/S = spell_instance
		S.learned_from_pool = "aspect_[type]"
		S.refundable = FALSE

/datum/magic_aspect/proc/can_attune(datum/mind/target)
	if(!target)
		return FALSE
	var/list/all_attuned = list()
	if(LAZYLEN(target.major_aspects))
		all_attuned += target.major_aspects
	if(LAZYLEN(target.minor_aspects))
		all_attuned += target.minor_aspects
	for(var/datum/magic_aspect/existing in all_attuned)
		if(existing.type in countersynergy)
			return FALSE
		if(type in existing.countersynergy)
			return FALSE
	return TRUE

GLOBAL_LIST_INIT(magic_aspects_major, init_magic_aspects(ASPECT_MAJOR))
GLOBAL_LIST_INIT(magic_aspects_minor, init_magic_aspects(ASPECT_MINOR))

/proc/init_magic_aspects(filter_type)
	var/list/result = list()
	for(var/path in subtypesof(/datum/magic_aspect))
		var/datum/magic_aspect/A = path
		if(initial(A.aspect_type) == filter_type)
			result += path
	return result
