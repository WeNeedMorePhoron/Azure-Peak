/*
 * Wind Wall - Momentum-gated forcewall for Blade subclass
 *
 * Creates a 3x1 barrier perpendicular to the caster's facing direction.
 * Costs momentum instead of being a free-use spell like standard Forcewall.
 *
 * References:
 *   Forcewall (code/modules/spells/spell_types/wizard/misc/forcewall.dm) - wall creation pattern
 *   Arcyne Momentum (code/modules/spells/spell_types/eastern/arcyne_momentum.dm) - stack system
 */

/obj/effect/proc_holder/spell/invoked/wind_wall
	name = "Wind Wall"
	desc = "Channel momentum into a barrier of arcyne wind. Blocks movement and projectiles. Requires 3 momentum stacks."
	clothes_req = FALSE
	range = 2
	overlay_state = "forcewall"
	releasedrain = 20
	chargedrain = 0
	chargetime = 3
	recharge_time = 15 SECONDS
	warnie = "spellwarning"
	no_early_release = TRUE
	movement_interrupt = FALSE
	charging_slowdown = 1
	chargedloop = /datum/looping_sound/invokegen
	invocations = list("Ventus Murus!")
	invocation_type = "shout"
	gesture_required = TRUE
	xp_gain = FALSE
	var/momentum_cost = 3
	var/wall_type = /obj/structure/forcefield_weak

/obj/effect/proc_holder/spell/invoked/wind_wall/can_cast(mob/user)
	. = ..()
	if(!.)
		return FALSE
	if(get_arcyne_momentum(user) < momentum_cost)
		return FALSE

/obj/effect/proc_holder/spell/invoked/wind_wall/cast(list/targets, mob/user = usr)
	var/mob/living/carbon/human/H = user
	if(!istype(H))
		revert_cast()
		return

	// Consume momentum
	var/datum/status_effect/buff/arcyne_momentum/M = H.has_status_effect(/datum/status_effect/buff/arcyne_momentum)
	if(!M || M.stacks < momentum_cost)
		to_chat(H, span_warning("Not enough momentum! Need [momentum_cost] stacks."))
		revert_cast()
		return
	M.consume_stacks(momentum_cost)
	to_chat(H, span_notice("[momentum_cost] momentum released!"))

	// Create wall perpendicular to facing (same as Forcewall)
	var/turf/front = get_turf(targets[1])
	var/list/affected_turfs = list()
	affected_turfs += front
	if(H.dir == SOUTH || H.dir == NORTH)
		affected_turfs += get_step(front, WEST)
		affected_turfs += get_step(front, EAST)
	else
		affected_turfs += get_step(front, NORTH)
		affected_turfs += get_step(front, SOUTH)

	for(var/turf/affected_turf in affected_turfs)
		new /obj/effect/temp_visual/trap_wall(affected_turf)
		addtimer(CALLBACK(src, PROC_REF(create_wall), affected_turf, H), 1 SECONDS)

	playsound(get_turf(H), 'sound/magic/whiteflame.ogg', 50, TRUE)
	H.visible_message(span_notice("[H] sweeps a hand forward and a wall of arcyne wind manifests!"))
	return TRUE

/obj/effect/proc_holder/spell/invoked/wind_wall/proc/create_wall(turf/target, mob/user)
	new wall_type(target, user)
