/datum/aspect_picker
	var/mob/living/owner
	var/initial_setup = TRUE
	var/list/pointbuy_selections = list()
	/// Staged selections - not applied until confirm. List of type paths.
	var/list/staged_majors = list()
	var/list/staged_minors = list()

/datum/aspect_picker/New(mob/living/new_owner, setup = TRUE)
	owner = new_owner
	initial_setup = setup

/datum/aspect_picker/Destroy()
	owner = null
	. = ..()

/datum/aspect_picker/ui_state(mob/user)
	return GLOB.always_state

/datum/aspect_picker/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AspectPicker", "Arcyne Aspects", 820, 560)
		ui.open()

/datum/aspect_picker/ui_static_data(mob/user)
	var/list/data = list()
	data["major_aspects"] = build_aspect_list(GLOB.magic_aspects_major)
	data["minor_aspects"] = build_aspect_list(GLOB.magic_aspects_minor)
	return data

/datum/aspect_picker/ui_data(mob/user)
	var/list/data = list()
	if(!owner?.mind)
		return data
	var/user_tier = get_user_spell_tier(owner)
	data["user_tier"] = user_tier
	data["max_majors"] = (user_tier >= 4) ? MAX_MAJOR_ASPECTS_T4 : MAX_MAJOR_ASPECTS_T3
	data["max_minors"] = MAX_MINOR_ASPECTS
	data["initial_setup"] = initial_setup

	// Show both already-attuned and staged selections
	data["attuned_majors"] = list()
	for(var/datum/magic_aspect/A in owner.mind.major_aspects)
		data["attuned_majors"] += "[A.type]"
	for(var/path in staged_majors)
		data["attuned_majors"] |= "[path]"

	data["attuned_minors"] = list()
	for(var/datum/magic_aspect/A in owner.mind.minor_aspects)
		data["attuned_minors"] += "[A.type]"
	for(var/path in staged_minors)
		data["attuned_minors"] |= "[path]"

	data["pointbuy_selections"] = pointbuy_selections

	// Collect all selected/granted spell paths so the UI can grey out duplicates
	// This includes both pointbuy selections AND fixed spells from all staged aspects
	var/list/all_selected_spells = list()
	for(var/aspect_path_str in pointbuy_selections)
		var/list/selections = pointbuy_selections[aspect_path_str]
		for(var/spell_path_str in selections)
			all_selected_spells |= spell_path_str
	// Include fixed spells from already-attuned and staged aspects
	var/list/all_staged = staged_majors + staged_minors
	for(var/datum/magic_aspect/A in owner.mind.major_aspects)
		for(var/spell_path in A.fixed_spells)
			all_selected_spells |= "[spell_path]"
	for(var/datum/magic_aspect/A in owner.mind.minor_aspects)
		for(var/spell_path in A.fixed_spells)
			all_selected_spells |= "[spell_path]"
	for(var/staged_path in all_staged)
		var/datum/magic_aspect/staged = new staged_path
		for(var/spell_path in staged.fixed_spells)
			all_selected_spells |= "[spell_path]"
		qdel(staged)
	data["all_selected_spells"] = all_selected_spells

	// Collect spent budget per aspect
	var/list/spent_budgets = list()
	for(var/aspect_path_str in pointbuy_selections)
		var/resolved = text2path(aspect_path_str)
		if(!resolved)
			continue
		var/datum/magic_aspect/temp = new resolved
		spent_budgets[aspect_path_str] = get_pointbuy_spent(aspect_path_str, temp)
		qdel(temp)
	data["spent_budgets"] = spent_budgets

	return data

/datum/aspect_picker/proc/build_aspect_list(list/aspect_paths)
	var/list/result = list()
	for(var/path in aspect_paths)
		var/datum/magic_aspect/A = new path
		var/list/entry = list()
		entry["path"] = "[path]"
		entry["name"] = A.name
		entry["desc"] = A.desc
		entry["fluff_desc"] = A.fluff_desc
		entry["aspect_type"] = A.aspect_type
		entry["attuned_name"] = A.attuned_name
		entry["school_color"] = A.school_color
		entry["pointbuy_budget"] = A.pointbuy_budget

		entry["fixed_spells"] = list()
		for(var/spell_path in A.fixed_spells)
			entry["fixed_spells"] += list(build_spell_entry(spell_path))

		entry["pointbuy_spells"] = list()
		for(var/spell_path in A.pointbuy_spells)
			entry["pointbuy_spells"] += list(build_spell_entry(spell_path))

		entry["countersynergy"] = list()
		for(var/counter_path in A.countersynergy)
			entry["countersynergy"] += "[counter_path]"

		result += list(entry)
		qdel(A)
	return result

/datum/aspect_picker/proc/build_spell_entry(spell_path)
	var/list/entry = list()
	entry["path"] = "[spell_path]"
	if(ispath(spell_path, /datum/action/cooldown/spell))
		var/datum/action/cooldown/spell/S = spell_path
		entry["name"] = initial(S.name)
		entry["desc"] = initial(S.desc)
		entry["cost"] = initial(S.point_cost)
	else
		var/obj/effect/proc_holder/spell/S = spell_path
		entry["name"] = initial(S.name)
		entry["desc"] = initial(S.desc)
		entry["cost"] = initial(S.cost)
	return entry

/// Check if a staged path conflicts with other staged paths via countersynergy
/datum/aspect_picker/proc/has_countersynergy(check_path)
	var/datum/magic_aspect/check = new check_path
	var/list/all_staged = staged_majors + staged_minors
	for(var/staged_path in all_staged)
		if(staged_path == check_path)
			continue
		var/datum/magic_aspect/staged = new staged_path
		if(staged.type in check.countersynergy)
			qdel(check)
			qdel(staged)
			return TRUE
		if(check.type in staged.countersynergy)
			qdel(check)
			qdel(staged)
			return TRUE
		qdel(staged)
	qdel(check)
	return FALSE

/datum/aspect_picker/ui_act(action, list/params)
	if(..())
		return
	if(!owner?.mind)
		return

	var/user_tier = get_user_spell_tier(owner)
	var/max_majors = (user_tier >= 4) ? MAX_MAJOR_ASPECTS_T4 : MAX_MAJOR_ASPECTS_T3

	switch(action)
		if("attune")
			var/path = text2path(params["path"])
			if(!path)
				return
			// Check countersynergy against staged selections
			if(has_countersynergy(path))
				to_chat(owner, span_warning("This aspect conflicts with my current selections."))
				return
			// Determine if major or minor
			var/datum/magic_aspect/temp = new path
			var/aspect_type = temp.aspect_type
			qdel(temp)
			switch(aspect_type)
				if(ASPECT_MAJOR)
					if(length(staged_majors) >= max_majors)
						to_chat(owner, span_warning("I cannot select another major aspect."))
						return
					if(path in staged_majors)
						return
					staged_majors += path
				if(ASPECT_MINOR)
					if(length(staged_minors) >= MAX_MINOR_ASPECTS)
						to_chat(owner, span_warning("I cannot select another minor aspect."))
						return
					if(path in staged_minors)
						return
					staged_minors += path
			. = TRUE

		if("remove")
			if(!initial_setup)
				return
			var/path = text2path(params["path"])
			if(!path)
				return
			staged_majors -= path
			staged_minors -= path
			pointbuy_selections -= params["path"]
			. = TRUE

		if("pointbuy_toggle")
			var/aspect_path = params["aspect_path"]
			var/spell_path = params["spell_path"]
			if(!aspect_path || !spell_path)
				return
			if(!pointbuy_selections[aspect_path])
				pointbuy_selections[aspect_path] = list()
			var/list/selections = pointbuy_selections[aspect_path]
			if(spell_path in selections)
				selections -= spell_path
			else
				// Check if this spell is already selected in another aspect
				if(is_spell_selected_elsewhere(spell_path, aspect_path))
					to_chat(owner, span_warning("I have already selected this spell from another aspect."))
					return
				// Check budget before adding
				var/resolved_aspect_path = text2path(aspect_path)
				if(resolved_aspect_path)
					var/datum/magic_aspect/temp = new resolved_aspect_path
					var/budget = temp.pointbuy_budget
					var/spent = get_pointbuy_spent(aspect_path, temp)
					var/spell_cost = get_spell_cost_from_path(text2path(spell_path))
					qdel(temp)
					if(spent + spell_cost > budget)
						to_chat(owner, span_warning("Not enough points remaining in this aspect's budget."))
						return
				selections += spell_path
			. = TRUE

		if("confirm")
			if(!length(staged_majors) && !length(staged_minors))
				to_chat(owner, span_warning("You must select at least one aspect."))
				return
			// Apply all staged selections to the mind
			for(var/path in staged_majors)
				var/datum/magic_aspect/aspect = new path
				if(!owner.mind.attune_aspect(aspect))
					qdel(aspect)
			for(var/path in staged_minors)
				var/datum/magic_aspect/aspect = new path
				if(!owner.mind.attune_aspect(aspect))
					qdel(aspect)
			// Apply pointbuy selections for attuned aspects
			for(var/aspect_path_str in pointbuy_selections)
				var/aspect_path = text2path(aspect_path_str)
				if(!aspect_path)
					continue
				var/datum/magic_aspect/attuned
				for(var/datum/magic_aspect/A in owner.mind.major_aspects)
					if(A.type == aspect_path)
						attuned = A
						break
				if(!attuned)
					for(var/datum/magic_aspect/A in owner.mind.minor_aspects)
						if(A.type == aspect_path)
							attuned = A
							break
				if(!attuned)
					continue
				var/list/selections = pointbuy_selections[aspect_path_str]
				for(var/spell_path_str in selections)
					var/spell_path = text2path(spell_path_str)
					if(!spell_path)
						continue
					if(owner.mind.has_spell(spell_path))
						continue
					var/datum/new_spell = new spell_path
					attuned.mark_aspect_spell(new_spell)
					owner.mind.AddSpell(new_spell)
			// Check if learnspell should remain
			owner.mind.check_learnspell()

			// Check if there are remaining aspect slots
			var/max_maj = (user_tier >= 4) ? MAX_MAJOR_ASPECTS_T4 : MAX_MAJOR_ASPECTS_T3
			var/current_majors = LAZYLEN(owner.mind.major_aspects)
			var/current_minors = LAZYLEN(owner.mind.minor_aspects)
			var/has_remaining = (current_majors < max_maj) || (current_minors < MAX_MINOR_ASPECTS)

			if(has_remaining)
				// Reset staged lists for next round of picks
				staged_majors.Cut()
				staged_minors.Cut()
				pointbuy_selections = list()
				SStgui.close_uis(src)
				to_chat(owner, span_notice("Aspects applied. You have remaining slots — use your spellbook to continue selecting."))
			else
				SStgui.close_uis(src)
				qdel(src)
			return TRUE

/// Check if a spell is already selected in a different aspect's pointbuy or granted as a fixed spell
/datum/aspect_picker/proc/is_spell_selected_elsewhere(spell_path, exclude_aspect_path)
	// Check pointbuy selections in other aspects
	for(var/other_aspect_path in pointbuy_selections)
		if(other_aspect_path == exclude_aspect_path)
			continue
		var/list/other_selections = pointbuy_selections[other_aspect_path]
		if(spell_path in other_selections)
			return TRUE
	// Check fixed spells in all staged aspects
	var/resolved_spell = text2path(spell_path)
	if(resolved_spell)
		var/list/all_staged = staged_majors + staged_minors
		for(var/staged_path in all_staged)
			if("[staged_path]" == exclude_aspect_path)
				continue
			var/datum/magic_aspect/staged = new staged_path
			if(resolved_spell in staged.fixed_spells)
				qdel(staged)
				return TRUE
			qdel(staged)
	return FALSE

/// Get total points spent in an aspect's pointbuy selections
/datum/aspect_picker/proc/get_pointbuy_spent(aspect_path_str, datum/magic_aspect/aspect)
	var/list/selections = pointbuy_selections[aspect_path_str]
	if(!length(selections))
		return 0
	var/total = 0
	for(var/spell_path_str in selections)
		total += get_spell_cost_from_path(text2path(spell_path_str))
	return total

/// Get spell cost from a type path (handles both spell systems)
/datum/aspect_picker/proc/get_spell_cost_from_path(spell_path)
	if(!spell_path)
		return 0
	if(ispath(spell_path, /datum/action/cooldown/spell))
		var/datum/action/cooldown/spell/S = spell_path
		return initial(S.point_cost)
	var/obj/effect/proc_holder/spell/S = spell_path
	return initial(S.cost)

/datum/aspect_picker/ui_close(mob/user)
	// If the user closes the window without confirming, clean up without applying
	// Staged selections are lost
	qdel(src)
