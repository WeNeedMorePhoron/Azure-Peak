/obj/effect/proc_holder/spell/invoked/diminish
	name = "Diminish"
	desc = "Diminishes the target's martial instincts through origin magick, reducing their ability to parry and dodge by 20%."
	overlay_state = "diminish"
	releasedrain = 50
	chargedrain = 0
	chargetime = 0
	range = 3
	warnie = "sydwarning"
	movement_interrupt = FALSE
	chargedloop = null
	sound = list('sound/magic/convergence1.ogg','sound/magic/convergence2.ogg','sound/magic/convergence3.ogg','sound/magic/convergence4.ogg')
	invocation_type = "none"
	associated_skill = /datum/skill/magic/arcane
	antimagic_allowed = TRUE
	recharge_time = 20 SECONDS
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
	target.apply_status_effect(/datum/status_effect/buff/convergence)
	return TRUE
