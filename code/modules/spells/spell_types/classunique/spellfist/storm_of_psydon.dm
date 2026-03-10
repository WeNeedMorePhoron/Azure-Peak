/*
 * Storm of Psydon (Ultimate)
 *
 * 75s cooldown, 3s charge up, no slowdown
 * The caster BECOMES a projectile - (Step toward them, with homing)
 * On hitting first living target: lock both in place, call oraora()
 * Full combo: 3 sets of 3 punches (20 blunt each via arcyne_strike) + 1 kick (50 blunt)
 * Both immobilized for duration (~0.8s), checked every 0.2s
 * Two shadow clones conjured slightly offset for the aesthetic (You know what this refers to)
 * Whiff with no preferred target = revert cast (no punishment)
 * Whiff with preferred target but miss = half cooldown
 */

/obj/effect/proc_holder/spell/invoked/storm_of_psydon
	name = "Storm of Psydon"
	desc = "TODO"
	clothes_req = FALSE
	range = 7
	action_icon = 'icons/mob/actions/spellfist.dmi'
	overlay_state = "storm_of_psydon"
	sound = list('sound/combat/wooshes/punch/punchwoosh (1).ogg','sound/combat/wooshes/punch/punchwoosh (2).ogg','sound/combat/wooshes/punch/punchwoosh (3).ogg')
	active = FALSE
	releasedrain = 50
	chargedrain = 0
	chargetime = 2 SECONDS
	recharge_time = 75 SECONDS
	warnie = "spellwarning"
	no_early_release = TRUE
	charging_slowdown = 0 // In line with Spellblade abilities - no slowdown
	chargedloop = /datum/looping_sound/invokegen
	associated_skill = /datum/skill/magic/arcane
	spell_tier = 3
	invocations = list("'Asifa!") // https://en.wiktionary.org/wiki/%D8%B9%D8%A7%D8%B5%D9%81%D8%A9 -- "Storm / Tempest" in Arabic
	invocation_type = "shout"
	glow_color = GLOW_COLOR_ARCANE
	glow_intensity = GLOW_INTENSITY_HIGH
	var/dash_range = 7
	var/step_delay = 1
	var/punch_damage = 20
	var/kick_damage = 50
	var/punch_sets = 3 // 3 sets of 3 punches
	var/punches_per_set = 3
	var/immobilize_good = 8 // Full combo duration in deciseconds — ~0.8s for 3 sets + kick
	var/immobilize_lame = 4 // Lame combo duration in deciseconds — ~0.4s for 2 punches + kick

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

	// No preferred target at all — revert cast, no punishment
	if(!preferred_target)
		to_chat(H, span_warning("I need a target to focus my fury on!"))
		revert_cast()
		return

	var/turf/start = get_turf(H)
	var/facing = get_dir(start, get_turf(preferred_target)) || H.dir
	H.dir = facing

	// Already adjacent — skip dash, go straight to lame oraora
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

	// Dash phase — step toward preferred target each tick, recalculating direction
	var/old_pass = H.pass_flags
	H.pass_flags |= PASSMOB

	var/mob/living/hit_target
	for(var/i in 1 to dash_range)
		if(H.stat != CONSCIOUS || H.IsParalyzed() || H.IsStun() || QDELETED(H))
			break

		// Check if we're now adjacent to preferred target
		if(get_dist(H, preferred_target) <= 1)
			hit_target = preferred_target
			break

		// Recalculate direction each step — homes toward target
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

	H.pass_flags = old_pass

	// Check adjacency after dash
	if(!hit_target && get_dist(H, preferred_target) <= 1)
		hit_target = preferred_target

	// Missed — half cooldown as punishment
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

	// We hit — ORAORA
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

// Cleanup immobilize + shadow images
/obj/effect/proc_holder/spell/invoked/storm_of_psydon/proc/combo_cleanup(mob/living/user, mob/living/target, obj/effect/after_image/shadow_left, obj/effect/after_image/shadow_right)
	if(!QDELETED(user))
		user.SetImmobilized(0)
	if(!QDELETED(target))
		target.SetImmobilized(0)
	QDEL_NULL(shadow_left)
	QDEL_NULL(shadow_right)

// Full combo — 3x3 punches + kick finisher, with shadow clones
/obj/effect/proc_holder/spell/invoked/storm_of_psydon/proc/oraora(mob/living/carbon/human/user, mob/living/target)
	var/def_zone = user.zone_selected || BODY_ZONE_CHEST

	// Immobilize both for just as long as the punching requires
	user.Immobilize(immobilize_good)
	target.Immobilize(immobilize_good)

	// Conjure two shadow clones slightly offset (yes, Jojo reference)
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

	// Punch combo — 3 sets of 3
	var/deflected = FALSE
	var/combo_broken = FALSE
	for(var/set_i in 1 to punch_sets)
		if(combo_broken)
			break
		for(var/punch_i in 1 to punches_per_set)
			if(!combo_valid(user, target))
				combo_broken = TRUE
				break
			// Parry check — first parry exposes attacker, subsequent ones are silent
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
			sleep(1) // 0.1s between each punch

	// Kick finisher — skip if parried or broken
	if(!combo_broken && combo_valid(user, target))
		if(!spell_guard_check(target, FALSE, deflected ? null : user))
			arcyne_strike(user, target, null, kick_damage, BODY_ZONE_CHEST, BCLASS_BLUNT, spell_name = "Storm of Psydon")
			playsound(get_turf(target), pick('sound/combat/hits/blunt/genblunt (1).ogg','sound/combat/hits/blunt/genblunt (2).ogg','sound/combat/hits/blunt/genblunt (3).ogg'), 100, TRUE)
			var/atom/throw_target = get_edge_target_turf(user, get_dir(user, target))
			target.throw_at(throw_target, 3, 4)

	combo_cleanup(user, target, shadow_left, shadow_right)
	log_combat(user, target, "used Storm of Psydon")

// Lame version — adjacent cast, no dash. 2 punches + kick = 90 total
/obj/effect/proc_holder/spell/invoked/storm_of_psydon/proc/oraora_lame(mob/living/carbon/human/user, mob/living/target)
	var/def_zone = user.zone_selected || BODY_ZONE_CHEST

	// Immobilize both for just as long as the punching requires
	user.Immobilize(immobilize_lame)
	target.Immobilize(immobilize_lame)

	var/deflected = FALSE
	// Two quick punches
	for(var/i in 1 to 2)
		if(!combo_valid(user, target))
			break
		if(spell_guard_check(target, FALSE, deflected ? null : user))
			deflected = TRUE
			break
		arcyne_strike(user, target, null, punch_damage, def_zone, BCLASS_BLUNT, spell_name = "Storm of Psydon")
		playsound(get_turf(target), pick('sound/combat/hits/punch/punch_hard (1).ogg','sound/combat/hits/punch/punch_hard (2).ogg','sound/combat/hits/punch/punch_hard (3).ogg'), 80, TRUE)

	// Kick finisher
	if(!deflected && combo_valid(user, target))
		if(!spell_guard_check(target, FALSE, deflected ? null : user))
			arcyne_strike(user, target, null, kick_damage, BODY_ZONE_CHEST, BCLASS_BLUNT, spell_name = "Storm of Psydon")
			playsound(get_turf(target), pick('sound/combat/hits/blunt/genblunt (1).ogg','sound/combat/hits/blunt/genblunt (2).ogg','sound/combat/hits/blunt/genblunt (3).ogg'), 100, TRUE)
			var/atom/throw_target = get_edge_target_turf(user, get_dir(user, target))
			target.throw_at(throw_target, 3, 4)

	combo_cleanup(user, target)
	log_combat(user, target, "used Storm of Psydon (lame)")
