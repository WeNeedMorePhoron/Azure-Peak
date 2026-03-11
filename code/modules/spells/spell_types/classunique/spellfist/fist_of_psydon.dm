/*
 * Fist of Psydon
 *
 * Self-buff that empowers the next melee strike (unarmed or weapon).
 * 10s cooldown, 0.5s charge up.
 * 50% bonus damage versus simple-minded creechurs.
 * Does not bypass parry/dodge — the normal attack still goes through defense checks.
 */

#define FIST_OF_PSYDON_FILTER "fist_of_psydon_glow"

/obj/effect/proc_holder/spell/self/fist_of_psydon
	name = "Fist of Psydon"
	desc = "Channel mana into your fists, empowering your next melee strike with a devastating arcyne-enhanced punch that deals heavy bonus blunt damage on top of the normal hit. Only work with unarmed attack. (+50 damage) \n\
	Damage increased by 50% versus simple-minded creechurs.\n\n\
	'Step forward, rotating your fist into the punch. And, as you strike, envision yourself repeating the same strike in your mynd, and open the arcyne conduit of your arms, but close that of your legs, so that all of your body's weight is behind the strike. Then, at the very last moment, close the conduit of your arms as well, and thus arrest the strike before it come out, and you shall strike as if the fist of Psydon Himself were behind the blow.'"
	clothes_req = FALSE
	action_icon = 'icons/mob/actions/classuniquespells/spellfist.dmi'
	overlay_state = "fist_of_psydon"
	sound = list('sound/combat/wooshes/punch/punchwoosh (1).ogg','sound/combat/wooshes/punch/punchwoosh (2).ogg','sound/combat/wooshes/punch/punchwoosh (3).ogg')
	releasedrain = 25
	chargedrain = 0
	recharge_time = 10 SECONDS
	warnie = "spellwarning"
	no_early_release = TRUE
	chargedloop = /datum/looping_sound/invokegen
	associated_skill = /datum/skill/magic/arcane
	spell_tier = 2
	invocations = list("Idrib!") // https://en.wiktionary.org/wiki/%D8%B6%D8%B1%D8%A8 -- "To strike, to beat, to hit" in Arabic
	invocation_type = "shout"
	glow_color = GLOW_COLOR_ARCANE
	glow_intensity = GLOW_INTENSITY_LOW

/obj/effect/proc_holder/spell/self/fist_of_psydon/cast(mob/living/carbon/human/user)
	if(!istype(user))
		revert_cast()
		return

	if(user.has_status_effect(/datum/status_effect/buff/fist_of_psydon))
		to_chat(user, span_warning("My fists are already empowered!"))
		revert_cast()
		return

	user.apply_status_effect(/datum/status_effect/buff/fist_of_psydon)
	user.emote("attackgrunt", forced = TRUE)
	user.visible_message(
		span_danger("[user]'s fists crackle with arcyne energy!"),
		span_danger("I channel Psydon's fury into my fists. The next strike shall carry His will."))
	return TRUE

/atom/movable/screen/alert/status_effect/buff/fist_of_psydon
	name = "Fist of Psydon"
	desc = "My next melee strike is empowered with arcyne force."
	icon_state = "buff"

/datum/status_effect/buff/fist_of_psydon
	id = "fist_of_psydon"
	alert_type = /atom/movable/screen/alert/status_effect/buff/fist_of_psydon
	duration = 10 SECONDS
	status_type = STATUS_EFFECT_UNIQUE
	var/bonus_damage = 60
	var/npc_simple_damage_mult = 1.5

/datum/status_effect/buff/fist_of_psydon/on_apply()
	. = ..()
	RegisterSignal(owner, COMSIG_MOB_ATTACK_HAND, PROC_REF(on_unarmed_attack))
	owner.add_filter(FIST_OF_PSYDON_FILTER, 2, list("type" = "outline", "color" = COLOR_PURPLE, "alpha" = 200, "size" = 2))

/datum/status_effect/buff/fist_of_psydon/on_remove()
	UnregisterSignal(owner, COMSIG_MOB_ATTACK_HAND)
	owner.remove_filter(FIST_OF_PSYDON_FILTER)
	. = ..()

/datum/status_effect/buff/fist_of_psydon/proc/on_unarmed_attack(datum/source, mob/living/carbon/human/attacker, mob/living/carbon/human/target, datum/martial_art/attacker_style)
	SIGNAL_HANDLER
	if(!istype(target) || target == owner || target.stat == DEAD)
		return
	// Only fire on harm-type unarmed intents (punches, kicks, etc.), not help/grab/disarm
	if(!istype(attacker.used_intent, /datum/intent/unarmed))
		return
	if(attacker.used_intent.type == INTENT_HELP || attacker.used_intent.type == INTENT_GRAB || attacker.used_intent.type == INTENT_DISARM)
		return
	INVOKE_ASYNC(src, PROC_REF(deliver_empowered_strike), attacker, target)

/datum/status_effect/buff/fist_of_psydon/proc/deliver_empowered_strike(mob/living/carbon/human/user, mob/living/target)

	arcyne_strike(user, target, null, bonus_damage, user.zone_selected || BODY_ZONE_CHEST, BCLASS_BLUNT, \
		spell_name = "Fist of Psydon", skip_animation = TRUE, allow_shield_check = TRUE, \
		npc_simple_damage_mult = npc_simple_damage_mult)
	playsound(get_turf(target), pick('sound/combat/hits/punch/punch_hard (1).ogg','sound/combat/hits/punch/punch_hard (2).ogg','sound/combat/hits/punch/punch_hard (3).ogg'), 100, TRUE)
	playsound(get_turf(target), 'sound/magic/antimagic.ogg', 60, TRUE)
	// 1-tile knockback for the "heavy punch" feel without enabling kiting
	if(isliving(target))
		var/atom/throw_target = get_edge_target_turf(user, get_dir(user, target))
		target.throw_at(throw_target, 1, 4)
	owner.remove_status_effect(/datum/status_effect/buff/fist_of_psydon)

#undef FIST_OF_PSYDON_FILTER
