/obj/effect/proc_holder/spell/invoked/diminish
	name = "Diminish"
	desc = "Diminishes the target's martial instincts through origin magick, reducing their ability to parry and dodge by 20%."
	releasedrain = 60
	chargedrain = 1
	chargetime = 1 SECONDS
	range = 3
	warnie = "sydwarning"
	no_early_release = TRUE
	movement_interrupt = FALSE
	charging_slowdown = 2
	chargedloop = /datum/looping_sound/invokegen
	sound = list('sound/magic/diminish1.ogg','sound/magic/diminish2.ogg','sound/magic/diminish3.ogg','sound/magic/diminish4.ogg')
	action_icon = 'icons/mob/actions/classuniquespells/vizier.dmi'
	overlay_state = "diminish"
	invocation_type = "none"
	associated_skill = /datum/skill/magic/arcane
	antimagic_allowed = TRUE
	recharge_time = 60 SECONDS
	miracle = FALSE
	ignore_los = FALSE
	cost = 2
	glow_color = GLOW_COLOR_ARCANE
	glow_intensity = GLOW_INTENSITY_LOW

/obj/effect/proc_holder/spell/invoked/diminish/cast(list/targets, mob/living/user)
	. = ..()
	if(!isliving(targets[1]))
		revert_cast()
		return FALSE

	var/mob/living/target = targets[1]
	target.visible_message(span_warning("Origin magick diminishes [target]'s instincts!"), span_warning("My instincts feel sluggish and predictable!"))
	user.Beam(target,icon_state="lichbeam",time=1 SECONDS)
	target.apply_status_effect(/datum/status_effect/buff/diminish)
	return TRUE
