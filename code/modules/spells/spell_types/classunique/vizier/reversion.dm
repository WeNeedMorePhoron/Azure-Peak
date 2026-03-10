/obj/effect/proc_holder/spell/invoked/reversion
	name = "Reversion"
	desc = "Marks the chosen target's body and position. Within 30 seconds, cast again to revert them to their marked condition and location."
	releasedrain = 60
	chargedrain = 0
	chargetime = 0
	recharge_time = 60 SECONDS
	warnie = "sydwarning"
	movement_interrupt = FALSE
	sound = 'sound/magic/timeforward.ogg'
	associated_skill = /datum/skill/magic/arcane
	overlay_state = "sands_of_time"
	invocation_type = "none"
	var/mob/living/carbon/stasis_target
	var/brute = 0
	var/burn = 0
	var/oxy = 0
	var/toxin = 0
	var/turf/origin
	var/firestacks = 0
	var/divinefirestacks = 0
	var/sunderfirestacks = 0
	var/blood = 0
	var/stasis_active = FALSE
	miracle = FALSE
	ignore_los = FALSE
	cost = 3
	glow_color = GLOW_COLOR_ARCANE
	glow_intensity = GLOW_INTENSITY_LOW

/obj/effect/proc_holder/spell/invoked/reversion/cast(list/targets, mob/user = usr)
	if(!isliving(targets[1]))
		revert_cast()
		return FALSE

	var/mob/living/carbon/target = targets[1]

	if(stasis_active)
		if(stasis_target == target)
			revert_stasis()
			return TRUE
		else
			to_chat(user, span_warning("I already have someone marked for reversion!"))
			revert_cast()
			return FALSE

	stasis_target = target
	stasis_active = TRUE
	target.apply_status_effect(/datum/status_effect/buff/stasis)
	brute = target.getBruteLoss()
	burn = target.getFireLoss()
	oxy = target.getOxyLoss()
	toxin = target.getToxLoss()
	origin = get_turf(target)
	blood = target.blood_volume
	var/datum/status_effect/fire_handler/fire_stacks/fire_status = target.has_status_effect(/datum/status_effect/fire_handler/fire_stacks)
	firestacks = fire_status?.stacks
	var/datum/status_effect/fire_handler/fire_stacks/sunder/sunder_status = target.has_status_effect(/datum/status_effect/fire_handler/fire_stacks/sunder)
	sunderfirestacks = sunder_status?.stacks
	var/datum/status_effect/fire_handler/fire_stacks/divine/divine_status = target.has_status_effect(/datum/status_effect/fire_handler/fire_stacks/divine)
	divinefirestacks = divine_status?.stacks
	to_chat(target, span_warning("I feel a part of me was left behind..."))
	to_chat(user, span_notice("I mark [target] for reversion. Cast again on them to trigger the revert."))
	play_indicator(target,'icons/mob/overhead_effects.dmi', "timestop", 300, OBJ_LAYER)
	addtimer(CALLBACK(src, PROC_REF(expire_stasis)), wait = 30 SECONDS)

	return TRUE

/obj/effect/proc_holder/spell/invoked/reversion/proc/revert_stasis()
	if(!stasis_active || !stasis_target)
		return
	var/mob/living/carbon/target = stasis_target
	stasis_active = FALSE
	stasis_target = null
	target.remove_status_effect(/datum/status_effect/buff/stasis)
	do_teleport(target, origin, no_effects=TRUE)
	var/brutenew = target.getBruteLoss()
	var/burnnew = target.getFireLoss()
	var/oxynew = target.getOxyLoss()
	target.adjust_fire_stacks(firestacks)
	target.adjust_fire_stacks(sunderfirestacks, /datum/status_effect/fire_handler/fire_stacks/sunder)
	target.adjust_fire_stacks(divinefirestacks, /datum/status_effect/fire_handler/fire_stacks/divine)
	target.adjustBruteLoss(brutenew*-1 + brute)
	target.adjustFireLoss(burnnew*-1 + burn)
	target.adjustOxyLoss(oxynew*-1 + oxy)
	target.adjustToxLoss(target.getToxLoss()*-1 + toxin)
	target.blood_volume = blood
	playsound(target.loc, 'sound/magic/timereverse.ogg', 100, FALSE)
	to_chat(target, span_warning("Time reverses - my body snaps back!"))
	charge_counter = 0

/obj/effect/proc_holder/spell/invoked/reversion/proc/expire_stasis()
	if(!stasis_active)
		return
	revert_stasis()

/obj/effect/proc_holder/spell/invoked/reversion/proc/play_indicator(mob/living/carbon/target, icon_path, overlay_name, clear_time, overlay_layer)
	if(!ishuman(target))
		return
	if(target.stat != DEAD)
		var/mob/living/carbon/humie = target
		var/datum/species/species =	humie.dna.species
		var/list/offset_list
		if(humie.gender == FEMALE)
			offset_list = species.offset_features[OFFSET_HEAD_F]
		else
			offset_list = species.offset_features[OFFSET_HEAD]
			var/mutable_appearance/appearance = mutable_appearance(icon_path, overlay_name, overlay_layer)
			if(offset_list)
				appearance.pixel_x += (offset_list[1])
				appearance.pixel_y += (offset_list[2]+12)
			appearance.appearance_flags = RESET_COLOR
			target.overlays_standing[OBJ_LAYER] = appearance
			target.apply_overlay(OBJ_LAYER)
			update_icon()
			addtimer(CALLBACK(humie, PROC_REF(clear_overhead_indicator), appearance, target), clear_time)

/obj/effect/proc_holder/spell/invoked/reversion/proc/clear_overhead_indicator(appearance,mob/living/carbon/target)
	target.remove_overlay(OBJ_LAYER)
	cut_overlay(appearance, TRUE)
	qdel(appearance)
	update_icon()
	return
