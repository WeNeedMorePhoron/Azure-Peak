/datum/telegraphed_strike/weapon_special
	uses_antimagic = FALSE
	requires_weapon = FALSE
	strike_sound = null
	var/force_mult = 1
	var/flat_bonus = 0
	var/flat_damage = null
	var/strike_d_type = null
	var/parryable = FALSE

/datum/telegraphed_strike/weapon_special/get_strike_weapon(mob/living/carbon/human/H)
	var/datum/special_intent/S = host
	return S?.iparent

/datum/telegraphed_strike/weapon_special/get_strike_damage()
	if(!isnull(flat_damage))
		return flat_damage
	var/datum/special_intent/S = host
	var/obj/item/rogueweapon/W = S?.iparent
	if(!istype(W))
		return damage
	return (W.force_dynamic * force_mult) + flat_bonus

/datum/telegraphed_strike/weapon_special/guard_check(mob/living/carbon/human/H, mob/living/L, deflected = FALSE)
	if(!parryable || !ishuman(L))
		return FALSE
	if(L.has_status_effect(/datum/status_effect/buff/parry_buffer))
		return TRUE
	var/datum/status_effect/buff/clash/guard = L.has_status_effect(/datum/status_effect/buff/clash)
	if(!guard)
		return FALSE
	L.visible_message(span_warning("[L] turns aside [name] with a well-timed guard!"))
	to_chat(L, span_notice("My guard turns aside [name]!"))
	var/obj/item/held = L.get_active_held_item()
	if(held?.parrysound)
		playsound(get_turf(L), pick(held.parrysound), 100)
	else
		playsound(get_turf(L), pick(L.parry_sound), 100)
	L.apply_status_effect(/datum/status_effect/buff/parry_buffer)
	L.apply_status_effect(/datum/status_effect/buff/adrenaline_rush/melee)
	guard.deflected_spell = TRUE
	L.remove_status_effect(/datum/status_effect/buff/clash)
	return TRUE

/datum/telegraphed_strike/weapon_special/proc/get_hit_zone(mob/living/L)
	var/datum/special_intent/S = host
	return S?.get_aimed_zone(L)

/datum/telegraphed_strike/weapon_special/apply_strike_hit(mob/living/carbon/human/H, mob/living/L, obj/item/weapon, dmg, facing)
	var/datum/special_intent/S = host
	if(!S)
		return
	var/obj/item/rogueweapon/W = weapon
	var/dtype = strike_d_type
	if(!dtype && istype(W))
		dtype = W.d_type
	S.apply_generic_weapon_damage(L, dmg, dtype, get_hit_zone(L), blade_class)

/datum/telegraphed_strike/weapon_special/spawn_impact_vfx(mob/living/L)
	return

/datum/special_intent/telegraphed
	name = "telegraphed special"
	desc = "A telegraphed strike that follows you as you wind it up."
	respect_adjacency = FALSE
	range = 0
	var/strike_type = /datum/telegraphed_strike/weapon_special
	var/datum/telegraphed_strike/strike

/datum/special_intent/telegraphed/Destroy()
	QDEL_NULL(strike)
	return ..()

/datum/special_intent/telegraphed/proc/get_strike()
	if(!strike)
		strike = new strike_type()
		strike.host = src
	return strike

/datum/special_intent/telegraphed/process_attack()
	SHOULD_CALL_PARENT(FALSE)
	if(!ishuman(howner))
		return
	var/mob/living/carbon/human/H = howner
	var/datum/telegraphed_strike/E = get_strike()
	E.name = name
	if(!E.begin_strike(H))
		return
	_add_log()
	apply_cooldown(cooldown)

/datum/telegraphed_strike/weapon_special/greatsword_swing
	blade_class = BCLASS_CUT
	windup_time = TELEGRAPH_DODGEABLE
	charging_slowdown = 2
	parryable = TRUE
	strike_sound = 'sound/combat/wooshes/bladed/wooshlarge (3).ogg'
	detonate_sound = 'sound/combat/sp_gsword_hit.ogg'
	var/slow_dur = 2

/datum/telegraphed_strike/weapon_special/greatsword_swing/get_pattern_offsets()
	return list(
		list(-1, -1), list(0, -1), list(1, -1),
		list(-1, 0), list(1, 0),
		list(-1, 1), list(0, 1), list(1, 1),
	)

/datum/telegraphed_strike/weapon_special/greatsword_swing/get_sweep_bands()
	return list(get_pattern_offsets())

/datum/telegraphed_strike/weapon_special/greatsword_swing/get_hit_zone(mob/living/L)
	return BODY_ZONE_CHEST

/datum/telegraphed_strike/weapon_special/greatsword_swing/on_hit_target(mob/living/carbon/human/H, mob/living/L, facing)
	L.Slowdown(slow_dur)
