/obj/structure/fluff/traveltile/bathhouse_passage
	name = "suspicious passage"
	desc = "A crevice in the wall. It looks like it leads somewhere."
	required_trait = "bathhouse_passage_seen"

/obj/structure/fluff/traveltile/bathhouse_passage/examine(mob/user)
	. = ..()
	. += span_info("A suspicious passage..that leads somewhere up north to a wet coast. probably used for smuggling. If you see someone using this, that could implies them in smuggling activities up north. You have a feeling the memories of this will fade the next week, however..")

/obj/structure/fluff/traveltile/bathhouse_passage/can_go(atom/movable/AM)
	if(AM.recent_travel && world.time < AM.recent_travel + 15 SECONDS)
		return FALSE
	if(!ishuman(AM))
		return FALSE
	var/mob/living/carbon/human/H = AM
	if(!(H.job in GLOB.bathhouse_positions))
		to_chat(H, "<b>It is a dead end.</b>")
		return FALSE
	if(world.time > H.last_client_interact + 0.3 SECONDS)
		return FALSE
	return TRUE

/obj/structure/fluff/traveltile/bathhouse_passage/try_living_travel(obj/structure/fluff/traveltile/T, mob/living/L)
	if(!can_go(L))
		return FALSE
	if(L.pulledby)
		return FALSE
	to_chat(L, "<b>I begin to squeeze through the passage...</b>")
	if(do_after(L, 20 SECONDS, needhand = FALSE, target = src))
		if(L.pulledby)
			to_chat(L, span_warning("I can't go, something's holding onto me."))
			return FALSE
		perform_travel(T, L)
		return TRUE
	return FALSE
