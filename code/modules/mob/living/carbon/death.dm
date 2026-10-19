/mob/living/carbon/death(gibbed, nocutscene = FALSE, suicide = FALSE)
	if(stat == DEAD)
		return

	stop_looking()

	silent = FALSE
	losebreath = 0

//	if(!gibbed)
//		emote("deathgasp")

	. = ..()

	for(var/datum/brain_trauma/BT as anything in get_traumas())
		BT.on_death()

	if(client && !contract_spawned && !suicide) // Deathsight code here, remade a little smarter than before. Assisted suicide will help us not blare out when someone's being rot-cured.
		if(!gibbed && !mind?.has_antag_datum(/datum/antagonist/zombie) && !mind?.has_antag_datum(/datum/antagonist/skeleton) && !HAS_TRAIT(src, TRAIT_SECONDLIFE) && !HAS_TRAIT(src, TRAIT_UNFORGIVABLE))
			for(var/mob/living/player in GLOB.player_list)
				if(player.stat == DEAD || isbrain(player))
					continue
				if(!HAS_TRAIT(player, TRAIT_DEATHSIGHT))
					continue
				var/locale = prepare_deathsight_message(player)
				if(istype(player.patron, /datum/patron/divine/necra))
					to_chat(player, span_warning("Veiled whispers herald the Undermaiden's attention towards [locale]."))
				else
					to_chat(player, span_warning("I feel the faint passage of disjointed lyfe essence as it flees [locale]."))

/mob/living/carbon/proc/prepare_deathsight_message(mob/observer)
	var/area/A = get_area(src)
	if(!A || !A.deathsight_message)
		if(A)
			log_game("Deathsight: area [A.type] has no deathsight_message set. Death occurred at [AREACOORD(src)].")
		return generate_relative_deathsight(observer) // area is misconfigured; give the watcher a rough bearing instead of a broken message
	return A.deathsight_message

/mob/living/carbon/proc/generate_relative_deathsight(mob/observer)
	var/turf/death_turf = get_turf(src)
	var/turf/observer_turf = get_turf(observer)
	if(!death_turf || !observer_turf)
		return "an unknown locale, wreathed in enigmatic fog" // fallback if we can't find the area

	var/list/parts = list()
	var/paces = round(get_dist(observer_turf, death_turf), 20) // nearest 20 paces, so the bearing stays imprecise
	var/dir_text = dir2text(get_dir(observer_turf, death_turf))
	if(paces <= 0)
		parts += "somewhere close at hand"
	else if(dir_text)
		parts += "roughly [paces] paces to the [dir_text]"
	else
		parts += "roughly [paces] paces away"

	var/zdiff = death_turf.z - observer_turf.z
	if(zdiff > 0)
		parts += "[zdiff] level\s above me"
	else if(zdiff < 0)
		parts += "[abs(zdiff)] level\s below me"

	return jointext(parts, ", ")

/mob/living/carbon/dust(just_ash, drop_items, force)
	if(drop_items)
		var/turf/T = get_turf(src)
		if(T)
			for(var/X in bodyparts)
				var/obj/item/bodypart/BP = X
				for(var/obj/item/I in BP.embedded_objects)
					I.forceMove(T)
	return ..()

/mob/living/carbon/proc/inflate_gib() // Plays an animation that makes mobs appear to inflate before finally gibbing
	addtimer(CALLBACK(src, PROC_REF(gib), null, null, TRUE, TRUE), 25)
	var/matrix/M = matrix()
	M.Scale(1.8, 1.2)
	animate(src, time = 40, transform = M, easing = SINE_EASING)

/mob/living/carbon/gib(no_brain, no_organs, no_bodyparts, safe_gib = FALSE)
	if(safe_gib) // If you want to keep all the mob's items and not have them deleted
		for(var/obj/item/W in src)
			dropItemToGround(W)
			if(prob(50))
				step(W, pick(GLOB.alldirs))
	var/atom/Tsec = drop_location()
	for(var/mob/M in src)
		M.forceMove(Tsec)
		visible_message(span_danger("[M] bursts out of [src]!"))
	. = ..()

/mob/living/carbon/spill_embedded_objects()
	. = ..()
	for(var/obj/item/bodypart/bodypart as anything in bodyparts)
		for(var/obj/item/embedded_item as anything in bodypart.embedded_objects)
			bodypart.remove_embedded_object(embedded_item)

/mob/living/carbon/spill_organs(no_brain, no_organs, no_bodyparts)
	var/atom/Tsec = drop_location()
	if(!no_bodyparts)
		if(no_organs)//so the organs don't get transfered inside the bodyparts we'll drop.
			for(var/X in internal_organs)
				if(no_brain || !istype(X, /obj/item/organ/brain))
					qdel(X)
		else //we're going to drop all bodyparts except chest, so the only organs that needs spilling are those inside it.
			for(var/X in internal_organs)
				var/obj/item/organ/O = X
				if(no_brain && istype(O, /obj/item/organ/brain))
					qdel(O) //so the brain isn't transfered to the head when the head drops.
					continue
				var/org_zone = check_zone(O.zone) //both groin and chest organs.
				if(org_zone == BODY_ZONE_CHEST)
					O.Remove(src)
					O.forceMove(Tsec)
					O.throw_at(get_edge_target_turf(src,pick(GLOB.alldirs)),rand(1,3),5)
	else
		for(var/X in internal_organs)
			var/obj/item/organ/I = X
			if(no_brain && istype(I, /obj/item/organ/brain))
				qdel(I)
				continue
			if(no_organs && !istype(I, /obj/item/organ/brain))
				qdel(I)
				continue
			I.Remove(src)
			I.forceMove(Tsec)
			I.throw_at(get_edge_target_turf(src,pick(GLOB.alldirs)),rand(1,3),5)

/mob/living/carbon/spread_bodyparts()
	for(var/obj/item/bodypart/bodypart as anything in bodyparts)
		if(!bodypart.drop_limb())
			continue
		bodypart.throw_at(get_edge_target_turf(src,pick(GLOB.alldirs)),rand(1,3),5)
