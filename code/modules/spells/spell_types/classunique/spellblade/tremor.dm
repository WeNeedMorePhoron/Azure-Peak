/datum/action/cooldown/spell/telegraphed_strike/spellblade/tremor
	name = "Tremor"
	desc = "The earth answers. Wind up a slam, then erupt the ground in a ring around you, smashing and hurling back everyone adjacent a tile. The eruption follows you as you wind it up. \
		Builds 1 momentum on hit. At 3+ momentum: consumes 3 to double damage. Can be deflected by Defend stance."
	button_icon_state = "tremor"
	sound = null
	invocations = list("Tremor!")
	blade_class = BCLASS_BLUNT
	damage = 30
	empowered_mult = 2
	push_dist = 1
	detonate_sound = null
	momentum_on_hit = 1
	momentum_on_surge = 1

/datum/action/cooldown/spell/telegraphed_strike/spellblade/tremor/get_pattern_offsets()
	return list(
		list(-1, -1), list(0, -1), list(1, -1),
		list(-1, 0), list(1, 0),
		list(-1, 1), list(0, 1), list(1, 1),
	)

/datum/action/cooldown/spell/telegraphed_strike/spellblade/tremor/on_impact(mob/living/carbon/human/H, facing, atom/movable/visual)
	var/turf/center = get_turf(H)
	if(!center)
		return
	var/obj/item/weapon = get_strike_weapon(H)
	playsound(center, pick('sound/combat/ground_smash1.ogg', 'sound/combat/ground_smash2.ogg', 'sound/combat/ground_smash3.ogg'), 100, TRUE)
	for(var/list/off in get_pattern_offsets())
		var/turf/T = locate(center.x + off[1], center.y + off[2], center.z)
		if(T)
			new /obj/effect/temp_visual/kinetic_blast(T)
	H.visible_message(span_danger("[H] slams [weapon ? "\the [weapon.name]" : "down"] into the ground, sending shockwaves outward!"))
