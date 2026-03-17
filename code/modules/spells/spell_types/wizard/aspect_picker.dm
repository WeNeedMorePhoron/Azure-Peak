/datum/aspect_picker
	var/mob/living/owner
	var/initial_setup = TRUE
	var/list/pointbuy_selections = list()

/datum/aspect_picker/New(mob/living/new_owner, setup = TRUE)
	owner = new_owner
	initial_setup = setup

/datum/aspect_picker/Destroy()
	owner = null
	. = ..()

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

	data["attuned_majors"] = list()
	for(var/datum/magic_aspect/A in owner.mind.major_aspects)
		data["attuned_majors"] += "[A.type]"

	data["attuned_minors"] = list()
	for(var/datum/magic_aspect/A in owner.mind.minor_aspects)
		data["attuned_minors"] += "[A.type]"

	data["pointbuy_selections"] = pointbuy_selections
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

/datum/aspect_picker/ui_act(action, list/params)
	if(..())
		return
	if(!owner?.mind)
		return

	switch(action)
		if("attune")
			var/path = text2path(params["path"])
			if(!path)
				return
			var/datum/magic_aspect/aspect = new path
			if(!owner.mind.attune_aspect(aspect))
				qdel(aspect)
				return
			. = TRUE

		if("remove")
			if(!initial_setup)
				return
			var/path = text2path(params["path"])
			if(!path)
				return
			var/datum/magic_aspect/target
			for(var/datum/magic_aspect/A in owner.mind.major_aspects)
				if(A.type == path)
					target = A
					break
			if(!target)
				for(var/datum/magic_aspect/A in owner.mind.minor_aspects)
					if(A.type == path)
						target = A
						break
			if(target)
				owner.mind.remove_aspect(target)
				qdel(target)
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
				selections += spell_path
			. = TRUE

		if("confirm")
			SStgui.close_uis(src)
			qdel(src)
			return TRUE
