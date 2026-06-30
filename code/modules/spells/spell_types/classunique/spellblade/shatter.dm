/datum/action/cooldown/spell/telegraphed_strike/spellblade/shatter
	name = "Shatter"
	desc = "What the blade cannot cut, the mace breaks. Wind up a heavy blow, then smash a line straight ahead of you, hurling those struck back a tile. \
		The blow will not carry through walls, but it batters any structure in its path. \
		At 3+ momentum: consumes 3 to double damage. Builds momentum on a multi-target hit. Can be deflected by Defend stance."
	button_icon_state = "shatter"
	invocations = list("Frange!")
	blade_class = BCLASS_BLUNT
	damage = 40
	empowered_mult = 2
	windup_time = TELEGRAPH_DODGEABLE
	sweep_step = 0
	push_dist = 1
	sound = null
	detonate_sound = null
	momentum_on_hit = 0
	momentum_on_surge = 1
	var/line_length = 3

/datum/action/cooldown/spell/telegraphed_strike/spellblade/shatter/get_pattern_offsets()
	var/list/offsets = list()
	for(var/i in 1 to line_length)
		offsets += list(list(0, i))
	return offsets

/datum/action/cooldown/spell/telegraphed_strike/spellblade/shatter/on_impact(mob/living/carbon/human/H, facing, atom/movable/visual)
	var/turf/center = get_turf(H)
	if(!center)
		return
	playsound(center, pick('sound/combat/hits/blunt/metalblunt (1).ogg', 'sound/combat/hits/blunt/metalblunt (2).ogg', 'sound/combat/hits/blunt/metalblunt (3).ogg'), 90, TRUE, 3)
	playsound(center, pick('sound/combat/ground_smash1.ogg', 'sound/combat/ground_smash2.ogg', 'sound/combat/ground_smash3.ogg'), 60, TRUE)
	for(var/mob/M in range(4, center))
		shake_camera(M, 1, 1)
	for(var/list/off in get_pattern_offsets())
		var/list/r = rotate_offset(off[1], off[2], facing)
		var/turf/T = locate(center.x + r[1], center.y + r[2], center.z)
		if(T && !path_blocked(center, T))
			new /obj/effect/temp_visual/kinetic_blast(T)
