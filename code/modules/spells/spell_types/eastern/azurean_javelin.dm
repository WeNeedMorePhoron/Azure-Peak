/*
 * Azurean Javelin - Phalanx subclass phantom spear projectile
 *
 * Conjures a phantom spear and hurls it. Armor-piercing, applies slowdown
 * even on armored targets. Does NOT throw your actual weapon.
 * 2-3 second charge time makes it predictable and dodgeable in PvP.
 *
 * References:
 *   Air Blade (code/modules/spells/spell_types/wizard/projectiles_single/air_blade.dm) - projectile pattern
 *   Fetch (code/modules/spells/spell_types/wizard/projectiles_single/fetch.dm) - on_hit effects
 */

/obj/effect/proc_holder/spell/invoked/projectile/azurean_javelin
	name = "Azurean Javelin"
	desc = "Conjure a phantom spear of arcyne force and hurl it. Armor-piercing, slows the target on hit."
	clothes_req = FALSE
	range = 7
	projectile_type = /obj/projectile/energy/azurean_javelin
	sound = list('sound/combat/wooshes/bladed/wooshsmall (1).ogg')
	active = FALSE
	releasedrain = 30
	chargedrain = 1
	chargetime = 20 // 2 seconds charge
	recharge_time = 20 SECONDS
	warnie = "spellwarning"
	no_early_release = TRUE
	movement_interrupt = FALSE
	charging_slowdown = 2
	chargedloop = /datum/looping_sound/invokegen
	overlay_state = "air_blade"
	invocations = list("Pilum Azureum!")
	invocation_type = "shout"
	gesture_required = TRUE
	xp_gain = FALSE

/// Intent dancing: stab intent = direct throw, cut intent = arced throw (over allies)
/obj/effect/proc_holder/spell/invoked/projectile/azurean_javelin/cast(list/targets, mob/user = usr)
	var/mob/living/carbon/human/H = user
	if(istype(H) && H.used_intent?.blade_class == BCLASS_CUT)
		projectile_type = /obj/projectile/energy/azurean_javelin/arc
	else
		projectile_type = /obj/projectile/energy/azurean_javelin
	. = ..()

/// Phantom spear projectile — armor-piercing, applies slowdown on hit
/obj/projectile/energy/azurean_javelin
	name = "Azurean Javelin"
	icon_state = "air_blade_stab"
	damage = 35
	woundclass = BCLASS_STAB
	nodamage = FALSE
	speed = 3
	npc_simple_damage_mult = 4 // Can one shot a wolf simple mob. This is designed to be PVP viable so focus on AP instead of damage. 
	armor_penetration = 50
	hitsound = 'sound/combat/hits/bladed/genthrust (1).ogg'

/obj/projectile/energy/azurean_javelin/on_hit(target)
	. = ..()
	if(isliving(target))
		var/mob/living/L = target
		if(L.anti_magic_check())
			visible_message(span_warning("[src] disperses on contact with [L]!"))
			playsound(get_turf(L), 'sound/magic/magic_nulled.ogg', 100)
			return BULLET_ACT_BLOCK
		// Apply speed debuff regardless of armor
		L.apply_status_effect(/datum/status_effect/debuff/azurean_javelin_slow)
		to_chat(L, span_danger("An arcyne javelin pierces through — my movements are sluggish!"))
		playsound(get_turf(L), hitsound, 100)
		if(firer)
			log_combat(firer, L, "javelin-struck", src, "(DMG: [damage]) (AP: [armor_penetration])")

/// Arced variant — flies over allies, same damage (PVE support tool)
/obj/projectile/energy/azurean_javelin/arc
	name = "Arced Azurean Javelin"
	arcshot = TRUE

/// Speed debuff applied by Azurean Javelin on hit
/datum/status_effect/debuff/azurean_javelin_slow
	id = "azurean_javelin_slow"
	duration = 4 SECONDS
	effectedstats = list(STATKEY_SPD = -3)
	alert_type = null
