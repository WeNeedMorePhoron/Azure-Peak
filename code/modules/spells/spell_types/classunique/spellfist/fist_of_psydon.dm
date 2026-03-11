/*
 * Fist of Psydon
 *
 * 80 damage, Blunt, No AP
 * 10s cooldown, 0.5s charge up, no slowdown
 * Push target 3 tiles if close, 2 tile if far
 * Arcable for little bit of backline support
 */

/obj/effect/proc_holder/spell/invoked/projectile/fist_of_psydon
	name = "Fist of Psydon"
	desc = "Channel mana and then punches at the air, forming a flying fist out of magickal energy. The fist flies out and strikes the target, knocking them back slightly by 3 paces if they're close and 2 paces if they're far. \n\
	Damage increased by 50% versus simple-minded creechurs.\n\
	Toggle arc mode (Ctrl+G) while the spell is active to fire it over intervening mobs. Arced attacks deal 25% less damage.\n\n\
	'Step forward, rotating your fist into the punch. And, as you strike, envision yourself repeatijng the same strike in your mynd, and open the arcyne conduit of your arms, but closes that of your legs, and that all of your body's weight is behind the strike. Then, at the very last moment, close the conduit of your arms as well, and thus arrest the strike before it come out, and you shall strike through the air at an opponent as if you were punching them from several paces away."
	clothes_req = FALSE
	range = 7 // No beyond visual range punch
	projectile_type = /obj/projectile/magic/fist_of_psydon
	action_icon = 'icons/mob/actions/classuniquespells/spellfist.dmi'
	overlay_state = "fist_of_psydon"
	sound = list('sound/combat/wooshes/punch/punchwoosh (1).ogg','sound/combat/wooshes/punch/punchwoosh (2).ogg','sound/combat/wooshes/punch/punchwoosh (3).ogg')
	active = FALSE
	releasedrain = 20 // Kinda like 4x melee attacks
	chargedrain = 0
	chargetime = 5 // 5 deciseconds so it has a telegraph.
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
	charging_slowdown = 3 // Slows you down while charging, matching normal attacks

/obj/effect/proc_holder/spell/invoked/projectile/fist_of_psydon/cast(list/targets, mob/user = usr)
	user.emote("attack", forced = TRUE)
	return ..()

/obj/projectile/magic/fist_of_psydon
	name = "Fist of Psydon"
	damage = 80
	damage_type = BRUTE
	armor_penetration = BLUNT_DEFAULT_PENFACTOR
	guard_deflectable = TRUE
	npc_simple_damage_mult = 1.5 // Makes it more effective against NPCs.
	woundclass = BCLASS_BLUNT
	nodamage = FALSE
	icon_state = "fist_of_psydon"
	hitsound = list('sound/combat/hits/blunt/genblunt (1).ogg','sound/combat/hits/blunt/genblunt (2).ogg','sound/combat/hits/blunt/genblunt (3).ogg')
	range = 7
	speed = 1.5 // Slightly slower since it can pushes you off ledge
	cannot_cross_z = TRUE

/obj/projectile/magic/fist_of_psydon/arc
	name = "Arced Fist of Psydon"
	damage = 60 // 25% damage penalty for arc shots since you can hit from behind cover
	arcshot = TRUE

/obj/projectile/magic/fist_of_psydon/on_hit(target)
	. = ..()
	var/travelled_dist = max(decayedRange - range, 0)
	var/throw_dist = travelled_dist >= 2 ? 2 : 3 // If the target is within the punch's range, knock them back 3 tiles, otherwise just 2 tiles since it's more of a tap than a full on punch. Also makes it less abusable for sniping from long range.
	var/atom/throw_target = get_edge_target_turf(firer, get_dir(firer, target))
	if(isliving(target))
		var/mob/living/L = target
		if(L.anti_magic_check() || !firer)
			L.visible_message(span_warning("[src] vanishes on contact with [target]!"))
			return BULLET_ACT_BLOCK
		L.throw_at(throw_target, throw_dist, 4)
	else
		if(isitem(target))
			var/obj/item/I = target
			var/mob/living/carbon/human/carbon_firer
			if (ishuman(firer))
				carbon_firer = firer
				if (carbon_firer?.can_catch_item())
					throw_target = get_edge_target_turf(firer, get_dir(firer, target))
			I.throw_at(throw_target, throw_dist * 2, 4) // Items can be thrown rather far away
