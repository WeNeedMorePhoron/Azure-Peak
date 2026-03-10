/*
 * Grasp of Psydon
 *
 * 20 damage, Blunt, No AP
 * 10s cooldown, 0.5s charge up, no slowdown
 * Fetch (pull) target up to 7 tiles toward the caster
 * Varieties on Fetch (and less OP frankly)
 */

/obj/effect/proc_holder/spell/invoked/projectile/grasp_of_psydon
	name = "Grasp of Psydon"
	desc = "Send forth a flying hand made of arcyne energy, dealing a modest amount of damage and pulling the target towards you up to 7 paces. Can be used to pull enemies into melee range or to snag items from a distance.\n\n\
	'Push forth your hand with your conduit open, and imagine, with His will, seizing upon the very object or person you desire within your grasp, then, pull your hand backward. Close, and clench your fist, pushing forward slightly, opening your conduit again, and you shall seize your enemy from afar, and pull them toward you.'"
	clothes_req = FALSE
	range = 7
	projectile_type = /obj/projectile/magic/grasp_of_psydon
	action_icon = 'icons/mob/actions/classuniquespells/spellfist.dmi'
	overlay_state = "grasp_of_psydon"
	sound = list('sound/combat/wooshes/punch/punchwoosh (1).ogg','sound/combat/wooshes/punch/punchwoosh (2).ogg','sound/combat/wooshes/punch/punchwoosh (3).ogg')
	active = FALSE
	releasedrain = 20 // 20 as standard so there's some stam management
	chargedrain = 0
	chargetime = 5
	recharge_time = 10 SECONDS
	warnie = "spellwarning"
	no_early_release = TRUE
	chargedloop = /datum/looping_sound/invokegen
	associated_skill = /datum/skill/magic/arcane
	spell_tier = 2
	invocations = list("Iqbid!") // https://en.wiktionary.org/wiki/%D9%82%D8%A8%D8%B6 -- "To seize, to take, to grab" in Arabic
	invocation_type = "shout"
	glow_color = GLOW_COLOR_ARCANE
	glow_intensity = GLOW_INTENSITY_LOW
	charging_slowdown = 0 // In line with Spellblade abilities - no slowdown

/obj/effect/proc_holder/spell/invoked/projectile/grasp_of_psydon/cast(list/targets, mob/user = usr)
	user.emote("attack", forced = TRUE)
	return ..()

/obj/projectile/magic/grasp_of_psydon
	name = "Grasp of Psydon"
	damage = 20
	damage_type = BRUTE
	armor_penetration = BLUNT_DEFAULT_PENFACTOR
	guard_deflectable = TRUE
	npc_simple_damage_mult = 1.5 // Makes it more effective against NPCs.
	woundclass = BCLASS_BLUNT
	nodamage = FALSE
	icon = 'icons/effects/effects.dmi'
	hitsound = 'sound/combat/grabbreak.ogg'
	icon_state = "youricon" // TODO
	range = 7
	speed = 1.5
	cannot_cross_z = TRUE
	var/fetch_distance = 7

/obj/projectile/magic/grasp_of_psydon/on_hit(target)
	. = ..()
	var/atom/throw_target = get_step(firer, get_dir(firer, target))
	if(isliving(target))
		var/mob/living/L = target
		if(L.anti_magic_check() || !firer)
			L.visible_message(span_warning("[src] vanishes on contact with [target]!"))
			return BULLET_ACT_BLOCK
		L.throw_at(throw_target, fetch_distance, 4)
	else
		if(isitem(target))
			var/obj/item/I = target
			var/mob/living/carbon/human/carbon_firer
			if (ishuman(firer))
				carbon_firer = firer
				if (carbon_firer?.can_catch_item())
					throw_target = get_turf(firer)
			I.throw_at(throw_target, fetch_distance, 3)
