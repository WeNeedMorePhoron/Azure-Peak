// Legacy proc_holder Thunderstrike — kept for spell_list reference
// Visual types and new system spell in fulgurmancy/thunderstrike.dm
// New system spell: /datum/action/cooldown/spell/thunderstrike

/obj/effect/proc_holder/spell/invoked/thunderstrike
	name = "Thunderstrike"
	desc = "Call a high-damage strike of lightning onto an area, followed by lesser aftershocks that ripple outwards in concentric layers."
	cost = 6
	range = 7
	releasedrain = SPELLCOST_MAJOR_AOE
	overlay_state = "thunderstrike"
	chargedrain = 1
	chargetime = 35
	recharge_time = 20 SECONDS
	warnie = "spellwarning"
	no_early_release = TRUE
	movement_interrupt = FALSE
	charging_slowdown = 3
	chargedloop = /datum/looping_sound/invokelightning
	associated_skill = /datum/skill/magic/arcane
	gesture_required = TRUE
	human_req = TRUE
	spell_tier = 3
	invocations = list("Feri Fulmine Hostem!") // Based on Zeus - Strike the Enemy with Lightning!
	invocation_type = "shout"
	glow_color = GLOW_COLOR_LIGHTNING
	glow_intensity = GLOW_INTENSITY_HIGH
	var/damage = 100
	var/delay1 = 4
	var/delay2 = 7
	var/delay3 = 10

/obj/effect/proc_holder/spell/invoked/thunderstrike/cast(list/targets, mob/user = usr)
	var/turf/centerpoint = get_turf(targets[1])

	var/turf/source_turf = get_turf(user)
	if(centerpoint.z > user.z)
		source_turf = get_step_multiz(source_turf, UP)
	if(centerpoint.z < user.z)
		source_turf = get_step_multiz(source_turf, DOWN)
	if(!(centerpoint in get_hear(range, source_turf)))
		to_chat(user, span_warning("I can't cast where I can't see!"))
		return
	new /obj/effect/temp_visual/trap/thunderstrike(centerpoint)
	addtimer(CALLBACK(src, PROC_REF(thunderstrike_damage), centerpoint, 1), wait = delay1)

	for(var/turf/effect_layer_one in range(1, centerpoint))
		if(!(effect_layer_one in get_hear(1, centerpoint)))
			continue
		if(get_dist(centerpoint, effect_layer_one) != 1)
			continue
		new /obj/effect/temp_visual/trap/thunderstrike/layer_one(effect_layer_one)
		addtimer(CALLBACK(src, PROC_REF(thunderstrike_damage), effect_layer_one, 0.5), wait = delay2)

	for(var/turf/effect_layer_two in range(2, centerpoint))
		if(!(effect_layer_two in get_hear(2, centerpoint)))
			continue
		if(get_dist(centerpoint, effect_layer_two) != 2)
			continue
		new /obj/effect/temp_visual/trap/thunderstrike/layer_two(effect_layer_two)
		addtimer(CALLBACK(src, PROC_REF(thunderstrike_damage), effect_layer_two, 0.25), wait = delay3)
	return TRUE

/obj/effect/proc_holder/spell/invoked/thunderstrike/proc/thunderstrike_damage(var/turf/effect_layer, damage_mod)
	new /obj/effect/temp_visual/thunderstrike_actual(effect_layer)
	playsound(effect_layer, 'sound/magic/lightning.ogg', 50)
	for(var/mob/living/L in effect_layer.contents)
		if(L.anti_magic_check())
			L.visible_message(span_warning("The lightning fades away around [L]!"))
			playsound(effect_layer, 'sound/magic/magic_nulled.ogg', 100)
			continue
		if(spell_guard_check(L, TRUE))
			L.visible_message(span_warning("[L] weathers the lightning strike!"))
			continue
		L.electrocute_act(damage * damage_mod, src, 1, SHOCK_NOSTUN)
