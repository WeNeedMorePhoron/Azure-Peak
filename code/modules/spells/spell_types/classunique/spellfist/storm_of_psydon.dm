/*
 * Storm of Psydon
 *
 * 50s cooldown, 2s charge up, no slowdown
 * The caster leaps toward the target with homing
 * On reaching target: begin combo via oraora()
 * Full combo: 3 sets of 3 punches (20 blunt each via arcyne_strike) + 1 kick (50 blunt)
 * Guard interrupts the entire combo, while each sets can be dodged / parried individually.
 * It is parried / dodged as a set because parrying each individually means this would be the stamina
 * Nuke of all time. EXTREMELY cool in PVE and cool if you manage to hit them from behind. 
 * Attacker clings to target between sets, steps toward them if they dodge away
 * If target moves out of range and attacker can't follow, combo ends
 * Two shadow clones conjured slightly offset for the aesthetic
 * Whiff with no preferred target = revert cast (no punishment)
 * Whiff with preferred target but miss = half cooldown
 */

/obj/effect/proc_holder/spell/invoked/storm_of_psydon
	name = "Storm of Psydon"
	desc = "Channel mana into your legs to leap toward a target from a distance, closing the gap rapidly. Then, channel the mana into your fists to strike them at humenly impossible speed, punching them 9 times in rapid succession before finishing with a powerful kick that sends them away. If cast too close, the lack of build up means you just strike 3 times and kick. Must select a target. If you miss, half cooldown is applied. The target can attempt to parry or dodge between each flurry of punches. A successful dodge will break the combo as you lose your grip on them. A target can also guard against your fury and interrupt it, exposing yourself. \n\n\
	'Temper the storm within, and unleash it only upon those who stray from His ways.'"
	clothes_req = FALSE
	range = 7
	action_icon = 'icons/mob/actions/classuniquespells/spellfist.dmi'
	overlay_state = "storm_of_psydon"
	sound = list('sound/combat/wooshes/punch/punchwoosh (1).ogg','sound/combat/wooshes/punch/punchwoosh (2).ogg','sound/combat/wooshes/punch/punchwoosh (3).ogg')
	active = FALSE
	releasedrain = 50
	chargedrain = 0
	chargetime = 2 SECONDS
	recharge_time = 50 SECONDS // Since it can be parried / dodged and maybe only 1/4 to 1/2 of the damage will actually land, this might be fine to have on a 50s CD. If it ends up being too strong we can increase the cooldown later. Was thinking of 45s but decided on 50s, because I realized smart 
	// spellfist will probably try to land this from behind to bypasses parry.
	warnie = "spellwarning"
	no_early_release = TRUE
	charging_slowdown = 0 // In line with Spellblade abilities - no slowdown
	chargedloop = /datum/looping_sound/invokegen
	associated_skill = /datum/skill/magic/arcane
	spell_tier = 3
	invocations = list() // Handled manually: 'Asifa! at cast start, grunt at kick
	invocation_type = "shout"
	glow_color = GLOW_COLOR_ARCANE
	glow_intensity = GLOW_INTENSITY_HIGH
	var/start_invocation = "'Asifa!"
	var/dash_range = 7
	var/step_delay = 1
	var/punch_damage = 20
	var/kick_damage = 50
	var/punch_sets = 3 // 3 sets of 3 punches
	var/punches_per_set = 3

/obj/effect/proc_holder/spell/invoked/storm_of_psydon/cast(list/targets, mob/user = usr)
	var/mob/living/carbon/human/H = user
	if(!istype(H))
		revert_cast()
		return


	// Determine preferred target from click target
	var/mob/living/preferred_target
	var/atom/clicked = targets[1]
	if(isliving(clicked))
		preferred_target = clicked
	else
		var/turf/clicked_turf = get_turf(clicked)
		if(clicked_turf)
			for(var/mob/living/L in clicked_turf)
				if(L != H && L.stat != DEAD)
					preferred_target = L
					break

	// No preferred target at all, revert cast, no punishment
	if(!preferred_target)
		to_chat(H, span_warning("I need a target to focus my fury on!"))
		revert_cast()
		return

	// Shout invocation at the start
	H.say(start_invocation, forced = "spell")

	var/turf/start = get_turf(H)
	var/facing = get_dir(start, get_turf(preferred_target)) || H.dir
	H.dir = facing

	// Already adjacent, skip dash, go straight to lame oraora
	if(get_dist(H, preferred_target) <= 1)
		if(preferred_target.anti_magic_check())
			preferred_target.visible_message(span_warning("The fury dissipates on contact with [preferred_target]!"))
			charge_counter = recharge_time / 2
			update_icon()
			return
		H.visible_message(span_danger("<b>[H] latches onto [preferred_target], punching and then kicking [preferred_target.p_them()] away!</b>"))
		oraora_lame(H, preferred_target)
		return TRUE

	H.visible_message(span_danger("<b>[H] latches onto [preferred_target], punching and then kicking [preferred_target.p_them()] away!</b>"))

	// Dash phase: step toward preferred target each tick, recalculating direction
	var/old_pass = H.pass_flags
	var/old_throwing = H.throwing
	H.pass_flags |= PASSMOB
	H.throwing = TRUE // Lets us leap over railings/fences
	var/prev_pixel_z = H.pixel_z
	var/prev_transform = H.transform

	// Launch into the air, dramatic leap arc
	animate(H, pixel_z = prev_pixel_z + 18, time = 1, easing = EASE_OUT)

	var/mob/living/hit_target
	for(var/i in 1 to dash_range)
		if(H.stat != CONSCIOUS || H.IsParalyzed() || H.IsStun() || QDELETED(H))
			break

		// Check if we're now adjacent to preferred target
		if(get_dist(H, preferred_target) <= 1)
			hit_target = preferred_target
			break

		// Recalculate direction each step, homes toward target
		facing = get_dir(get_turf(H), get_turf(preferred_target))
		if(!facing)
			break
		H.dir = facing

		var/turf/next = get_step(get_turf(H), facing)
		if(!next || next.density)
			break

		var/blocked = FALSE
		for(var/obj/structure/S in next.contents)
			if(S.density && !S.climbable)
				blocked = TRUE
				break
		if(blocked)
			break

		step(H, facing)

		if(i < dash_range)
			sleep(step_delay)

	// Slam down with impact tilt
	var/land_angle = pick(-20, -15, 15, 20)
	animate(H, pixel_z = prev_pixel_z, transform = turn(prev_transform, land_angle), time = 1, easing = EASE_IN)
	animate(transform = prev_transform, time = 2)

	H.pass_flags = old_pass
	H.throwing = old_throwing

	// Check adjacency after dash
	if(!hit_target && get_dist(H, preferred_target) <= 1)
		hit_target = preferred_target

	// Missed, half cooldown as punishment
	if(!hit_target)
		to_chat(H, span_warning("My fury finds no purchase!"))
		charge_counter = recharge_time / 2
		update_icon()
		return

	// Anti-magic check
	if(hit_target.anti_magic_check())
		hit_target.visible_message(span_warning("The fury dissipates on contact with [hit_target]!"))
		charge_counter = recharge_time / 2
		update_icon()
		return

	// We hit, begin combo
	oraora(H, hit_target)
	return TRUE

// Check if the combo can continue — keep punching even if they go down
/obj/effect/proc_holder/spell/invoked/storm_of_psydon/proc/combo_valid(mob/living/carbon/human/user, mob/living/target)
	if(QDELETED(user) || QDELETED(target))
		return FALSE
	if(user.stat != CONSCIOUS)
		return FALSE
	if(get_dist(user, target) > 1)
		return FALSE
	return TRUE

// Cling — step toward target if not adjacent. Returns TRUE if adjacent after.
/obj/effect/proc_holder/spell/invoked/storm_of_psydon/proc/cling(mob/living/carbon/human/user, mob/living/target)
	if(get_dist(user, target) <= 1)
		return TRUE
	var/turf/user_turf = get_turf(user)
	var/turf/target_turf = get_turf(target)
	if(!user_turf || !target_turf || user_turf.z != target_turf.z)
		return FALSE
	var/dir_to = get_dir(user, target)
	if(!dir_to)
		return FALSE
	user.dir = dir_to
	step(user, dir_to)
	return get_dist(user, target) <= 1

// Defense window - reset parry/dodge cooldowns so the target gets a fresh attempt each set
// Skip if the target is near stamina crit - don't let defending exhaust them
// Dodge movement is suppressed so the target stays in the combo zone
/obj/effect/proc_holder/spell/invoked/storm_of_psydon/proc/combo_defense_check(mob/living/target, mob/living/user)
	if(target.stamina + 10 >= target.max_stamina) // ~10 stam per defense, don't push into crit
		return FALSE
	// Show the attack swing so a successful defense looks like a reaction, not a whiff
	user.do_attack_animation(target, ATTACK_EFFECT_SMASH)
	playsound(get_turf(user), pick('sound/combat/wooshes/punch/punchwoosh (1).ogg','sound/combat/wooshes/punch/punchwoosh (2).ogg','sound/combat/wooshes/punch/punchwoosh (3).ogg'), 80, TRUE)
	target.last_parry = 0
	target.last_dodge = 0
	// Find the attacker's unarmed intent so parry/dodge skill calculations work properly
	var/datum/intent/unarmed_intent
	for(var/datum/intent/I in user.possible_a_intents)
		if(I.unarmed)
			unarmed_intent = I
			break
	ADD_TRAIT(target, TRAIT_DODGE_NO_MOVE, MAGIC_TRAIT)
	var/old_defprob = user.defprob
	user.defprob = 0 // Remove base defense bonus, let SPD and skills determine dodge chance
	var/defended = target.checkdefense(unarmed_intent, user)
	user.defprob = old_defprob
	REMOVE_TRAIT(target, TRAIT_DODGE_NO_MOVE, MAGIC_TRAIT)
	return defended

// Cleanup shadow images
/obj/effect/proc_holder/spell/invoked/storm_of_psydon/proc/combo_cleanup(mob/living/user, mob/living/target, obj/effect/after_image/shadow_left, obj/effect/after_image/shadow_right)
	QDEL_NULL(shadow_left)
	QDEL_NULL(shadow_right)

// Full combo — 3 sets of 3 punches + kick finisher, with shadow clones
// Target gets a defense window (parry/dodge) before each set and the kick
/obj/effect/proc_holder/spell/invoked/storm_of_psydon/proc/oraora(mob/living/carbon/human/user, mob/living/target)
	var/def_zone = user.zone_selected || BODY_ZONE_CHEST
	user.changeNext_move(CLICK_CD_MELEE * 3) // Lock out clicks for the combo

	// Conjure two shadow clones slightly offset
	var/turf/user_turf = get_turf(user)
	var/punch_dir = get_dir(user, target)
	var/lunge_px = 0
	var/lunge_py = 0
	if(punch_dir & NORTH)
		lunge_py = 6
	if(punch_dir & SOUTH)
		lunge_py = -6
	if(punch_dir & EAST)
		lunge_px = 6
	if(punch_dir & WEST)
		lunge_px = -6

	var/obj/effect/after_image/shadow_left = new(user_turf, 0, 0, 0, 0, 0, 0, 0)
	shadow_left.appearance = user.appearance
	shadow_left.pixel_x = -10
	shadow_left.pixel_y = 4
	shadow_left.alpha = 120
	shadow_left.color = "#2a0a3a"
	shadow_left.dir = user.dir
	shadow_left.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	shadow_left.name = ""

	var/obj/effect/after_image/shadow_right = new(user_turf, 0, 0, 0, 0, 0, 0, 0)
	shadow_right.appearance = user.appearance
	shadow_right.pixel_x = 10
	shadow_right.pixel_y = 4
	shadow_right.alpha = 120
	shadow_right.color = "#2a0a3a"
	shadow_right.dir = user.dir
	shadow_right.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	shadow_right.name = ""

	// Punch combo — 3 sets of 3, with defense window per set
	var/deflected = FALSE
	var/combo_broken = FALSE
	for(var/set_i in 1 to punch_sets)
		if(combo_broken)
			break
		// Cling — step toward target if they moved
		if(!cling(user, target))
			combo_broken = TRUE
			break
		// Defense window: target can parry or dodge. Skips this set but combo continues.
		if(combo_defense_check(target, user))
			continue
		user.emote("attack", forced = TRUE) // Grunt once per set
		// Move shadows to follow user and recalculate lunge direction
		var/turf/new_turf = get_turf(user)
		shadow_left.forceMove(new_turf)
		shadow_right.forceMove(new_turf)
		punch_dir = get_dir(user, target)
		lunge_px = 0
		lunge_py = 0
		if(punch_dir & NORTH)
			lunge_py = 6
		if(punch_dir & SOUTH)
			lunge_py = -6
		if(punch_dir & EAST)
			lunge_px = 6
		if(punch_dir & WEST)
			lunge_px = -6
		for(var/punch_i in 1 to punches_per_set)
			if(!combo_valid(user, target))
				combo_broken = TRUE
				break
			// Guard check — active guard still interrupts per-punch
			if(spell_guard_check(target, FALSE, deflected ? null : user))
				deflected = TRUE
				combo_broken = TRUE
				break

			arcyne_strike(user, target, null, punch_damage, def_zone, BCLASS_BLUNT, spell_name = "Storm of Psydon")
			playsound(get_turf(target), pick('sound/combat/hits/punch/punch_hard (1).ogg','sound/combat/hits/punch/punch_hard (2).ogg','sound/combat/hits/punch/punch_hard (3).ogg'), 80, TRUE)
			// Shadows lunge toward target and snap back
			animate(shadow_left, pixel_x = -10 + lunge_px, pixel_y = 4 + lunge_py, time = 0.5, easing = EASE_OUT)
			animate(pixel_x = -10, pixel_y = 4, time = 0.5, easing = EASE_IN)
			animate(shadow_right, pixel_x = 10 + lunge_px, pixel_y = 4 + lunge_py, time = 0.5, easing = EASE_OUT)
			animate(pixel_x = 10, pixel_y = 4, time = 0.5, easing = EASE_IN)
		sleep(3) // 0.3s pause between sets for defense window

	// Kick finisher, defense window before kick too
	sleep(3) // 0.3s pause before kick winds up
	if(!combo_broken && cling(user, target) && combo_valid(user, target))
		if(!combo_defense_check(target, user) && !spell_guard_check(target, FALSE, deflected ? null : user))
			user.emote("attack", forced = TRUE)
			arcyne_strike(user, target, null, kick_damage, BODY_ZONE_CHEST, BCLASS_BLUNT, spell_name = "Storm of Psydon")
			playsound(get_turf(target), pick('sound/combat/hits/blunt/genblunt (1).ogg','sound/combat/hits/blunt/genblunt (2).ogg','sound/combat/hits/blunt/genblunt (3).ogg'), 100, TRUE)
			var/atom/throw_target = get_edge_target_turf(user, get_dir(user, target))
			target.throw_at(throw_target, 3, 4)

	combo_cleanup(user, target, shadow_left, shadow_right)
	log_combat(user, target, "used Storm of Psydon")

// Lame version — adjacent cast, no dash. 2 punches + kick = 90 total
// Target gets 2 defense windows: before punches and before kick
/obj/effect/proc_holder/spell/invoked/storm_of_psydon/proc/oraora_lame(mob/living/carbon/human/user, mob/living/target)
	var/def_zone = user.zone_selected || BODY_ZONE_CHEST
	user.changeNext_move(CLICK_CD_MELEE * 2) // Lock out clicks for the combo

	var/deflected = FALSE
	var/combo_broken = FALSE
	user.emote("attack", forced = TRUE)

	// Defense window before punches: skips punches on success but kick still attempted
	if(!combo_defense_check(target, user))
		// Two quick punches
		for(var/i in 1 to 2)
			if(!combo_valid(user, target))
				combo_broken = TRUE
				break
			if(spell_guard_check(target, FALSE, deflected ? null : user))
				deflected = TRUE
				combo_broken = TRUE
				break
			arcyne_strike(user, target, null, punch_damage, def_zone, BCLASS_BLUNT, spell_name = "Storm of Psydon")
			playsound(get_turf(target), pick('sound/combat/hits/punch/punch_hard (1).ogg','sound/combat/hits/punch/punch_hard (2).ogg','sound/combat/hits/punch/punch_hard (3).ogg'), 80, TRUE)

	// Kick finisher
	sleep(1) // brief pause before kick
	if(!combo_broken && cling(user, target) && combo_valid(user, target))
		if(!combo_defense_check(target, user) && !spell_guard_check(target, FALSE, deflected ? null : user))
			user.emote("attack", forced = TRUE)
			arcyne_strike(user, target, null, kick_damage, BODY_ZONE_CHEST, BCLASS_BLUNT, spell_name = "Storm of Psydon")
			playsound(get_turf(target), pick('sound/combat/hits/blunt/genblunt (1).ogg','sound/combat/hits/blunt/genblunt (2).ogg','sound/combat/hits/blunt/genblunt (3).ogg'), 100, TRUE)
			var/atom/throw_target = get_edge_target_turf(user, get_dir(user, target))
			target.throw_at(throw_target, 3, 4)

	combo_cleanup(user, target)
	log_combat(user, target, "used Storm of Psydon (lame)")
