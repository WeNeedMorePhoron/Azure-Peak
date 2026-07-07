/mob/living/regenerate_icons()
	if(notransform)
		return 1
	update_inv_hands()
	update_inv_handcuffed()
	update_inv_legcuffed()

/mob/living/var/scorched_ablaze = FALSE
/mob/living/var/obj/effect/dummy/lighting_obj/moblight/scorched_moblight

/mob/living/update_fire(fire_icon = "Generic_mob_burning")
	remove_overlay(FIRE_LAYER)
	if(on_fire || islava(loc) || scorched_ablaze)
		var/mutable_appearance/new_fire_overlay = mutable_appearance('icons/mob/OnFire.dmi', fire_icon, -FIRE_LAYER)
		var/datum/status_effect/fire_handler/fire_stacks/fire_status = has_status_effect(/datum/status_effect/fire_handler/fire_stacks)
		var/datum/status_effect/fire_handler/fire_stacks/divine_status = has_status_effect(/datum/status_effect/fire_handler/fire_stacks/divine)
		if(divine_status?.stacks > fire_status?.stacks)
			new_fire_overlay.color = list(0,0,0, 0,0,0, 0,0,0, 1,1,1)
		new_fire_overlay.appearance_flags = RESET_COLOR
		overlays_standing[FIRE_LAYER] = new_fire_overlay

	apply_overlay(FIRE_LAYER)

	if(scorched_ablaze && !on_fire)
		if(!scorched_moblight || QDELETED(scorched_moblight))
			scorched_moblight = new /obj/effect/dummy/lighting_obj/moblight/fire(src)
		else
			scorched_moblight.set_light_on(TRUE)
	else
		QDEL_NULL(scorched_moblight)

/mob/living/proc/update_turflayer(input)
	return

/mob/living/update_turflayer(input)
	return // RTCHANGE
