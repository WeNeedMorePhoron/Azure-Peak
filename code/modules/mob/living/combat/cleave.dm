/datum/cleave_pattern
	var/list/tile_offsets = list()
	var/max_targets = 1
	var/damage_falloff = 0.15
	var/min_damage_mult = 0.7
	var/respect_dir = TRUE
	var/desc = "Cleaves into nearby targets."

/datum/cleave_pattern/proc/get_damage_mult(total_targets)
	if(total_targets <= 1)
		return 1
	return max(1 - ((total_targets - 1) * damage_falloff), min_damage_mult)

/datum/cleave_pattern/proc/get_cardinal_dir(mob/living/user, turf/origin)
	var/use_dir = user.dir
	if(!(use_dir & (use_dir - 1)))
		return use_dir
	if(origin)
		var/adx = abs(origin.x - user.x)
		var/ady = abs(origin.y - user.y)
		if(adx > ady)
			return use_dir & (EAST|WEST)
		return use_dir & (NORTH|SOUTH)
	if(use_dir & NORTH)
		return NORTH
	return SOUTH

/datum/cleave_pattern/proc/get_cleave_turfs(mob/living/user, turf/origin)
	var/list/turfs = list()
	if(!origin || !user)
		return turfs
	var/use_dir = get_cardinal_dir(user, origin)
	for(var/list/offset in tile_offsets)
		var/dx = offset[1]
		var/dy = offset[2]
		if(respect_dir)
			switch(use_dir)
				if(SOUTH)
					dx = -dx
					dy = -dy
				if(WEST)
					var/holder = dx
					dx = -dy
					dy = holder
				if(EAST)
					var/holder = dx
					dx = dy
					dy = -holder
		var/turf/T = locate(origin.x + dx, origin.y + dy, origin.z)
		if(T && isturf(T) && !T.density)
			turfs += T
	return turfs

/datum/cleave_pattern/proc/count_cleave_targets(mob/living/user, mob/living/primary, list/cleave_turfs)
	var/count = 0
	for(var/turf/T in cleave_turfs)
		for(var/mob/living/L in T)
			if(L == primary || L == user)
				continue
			if(L.stat == DEAD)
				continue
			count++
			if(max_targets && count >= max_targets)
				return count
	return count

/datum/cleave_pattern/proc/get_pattern_display()
	var/list/all_points = list(list(0, 0))
	for(var/list/offset in tile_offsets)
		all_points += list(list(offset[1], offset[2]))
	var/min_x = 0
	var/max_x = 0
	var/min_y = -1
	var/max_y = 0
	for(var/list/p in all_points)
		min_x = min(min_x, p[1])
		max_x = max(max_x, p[1])
		min_y = min(min_y, p[2])
		max_y = max(max_y, p[2])
	var/list/rows = list()
	for(var/y = max_y, y >= min_y, y--)
		var/row = ""
		for(var/x = min_x, x <= max_x, x++)
			var/found = FALSE
			if(x == 0 && y == 0)
				row += "<font color='#fa4'>O</font>"
				found = TRUE
			else if(x == 0 && y == -1)
				row += "<font color='#8f8'>@</font>"
				found = TRUE
			if(!found)
				for(var/list/p in all_points)
					if(p[1] == x && p[2] == y)
						row += "<font color='#f44'>X</font>"
						found = TRUE
						break
			if(!found)
				row += "."
		rows += row
	return rows.Join("\n")

/datum/cleave_pattern/proc/show_cleave_visuals(mob/living/user, turf/origin)
	var/resolved_dir = get_cardinal_dir(user, origin)
	var/list/turfs = get_cleave_turfs(user, origin)
	if(!(origin in turfs))
		turfs += origin
	for(var/turf/T in turfs)
		new /obj/effect/temp_visual/dir_setting/cleave_visual(T, resolved_dir)

/obj/effect/temp_visual/dir_setting/cleave_visual
	layer = HUD_LAYER
	plane = ABOVE_LIGHTING_PLANE
	icon = 'icons/effects/effects.dmi'
	icon_state = "cut"
	duration = 5

// ---- Predefined Patterns ----

/datum/cleave_pattern/adjacent
	tile_offsets = list(list(-1, 0), list(1, 0))
	max_targets = 1
	desc = "Cleaves into an adjacent target."

/datum/cleave_pattern/forward_cleave
	tile_offsets = list(list(0, 1))
	max_targets = 1
	desc = "Cleaves forward into a second target."

/datum/cleave_pattern/wide_sweep
	tile_offsets = list(list(-1, 0), list(1, 0), list(0, -1), list(0, 1))
	max_targets = 2
	desc = "Sweeps wide, cleaving up to two nearby targets."

/datum/cleave_pattern/horizontal_sweep
	tile_offsets = list(list(-1, 0), list(0, 0), list(1, 0))
	max_targets = 2
	desc = "Sweeps horizontally, cleaving up to two additional targets."

/datum/cleave_pattern/frontal_arc
	tile_offsets = list(list(-1, 0), list(1, 0), list(-1, 1), list(0, 1), list(1, 1))
	max_targets = 4 // Anti Dorpel pattern.
	desc = "Sweeps in a massive arc, hitting up to four targets to the sides and ahead."
