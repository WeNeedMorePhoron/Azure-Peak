/*
 * Arcyne Momentum - Weapon-driven resource system for Spellblade 2
 *
 * The spellblade binds a weapon as their arcyne conduit. Successful strikes
 * with the bound weapon build momentum stacks on the wielder. Stacks are
 * spent to cast momentum-gated abilities. Issen consumes all stacks.
 *
 * Architecture:
 *   Component (arcyne_conduit) on weapon → catches COMSIG_ITEM_ATTACK_SUCCESS
 *     → adds stacks to status effect (arcyne_momentum) on the wielder
 *     → status effect stores stacks, updates visuals/buttons/alert
 *     → can_cast checks stacks for momentum-gated spells
 *
 * If the status effect is somehow removed, the next hit re-applies it.
 *
 * References:
 *   Enchant Weapon (code/modules/spells/spell_types/wizard/misc/enchant_weapon.dm) - weapon component pattern
 *   Arcyne Mark (code/modules/spells/spell_types/wizard/spells_status_effects.dm) - stacking pattern
 *   Pestilent Blade (code/modules/spells/roguetown/acolyte/pestra/pestra_components.dm) - COMSIG_ITEM_ATTACK_SUCCESS
 */

#define MOMENTUM_FILTER "momentum_glow"
#define CONDUIT_FILTER "arcyne_conduit"

// =====================================================================
// ---- Weapon Component ----
// =====================================================================

/// Component attached to a bound weapon. Builds arcyne momentum on the wielder when attacks land.
/datum/component/arcyne_conduit
	dupe_mode = COMPONENT_DUPE_UNIQUE
	var/outline_color = "#4a90d9"

/datum/component/arcyne_conduit/Initialize(outline_color_override)
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE
	if(outline_color_override)
		outline_color = outline_color_override
	var/obj/item/I = parent
	I.add_filter(CONDUIT_FILTER, 2, list("type" = "outline", "color" = outline_color, "alpha" = 200, "size" = 1))
	RegisterSignal(parent, COMSIG_ITEM_ATTACK_SUCCESS, PROC_REF(on_attack_success))
	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, PROC_REF(on_examine))

/datum/component/arcyne_conduit/UnregisterFromParent()
	var/obj/item/I = parent
	if(istype(I))
		I.remove_filter(CONDUIT_FILTER)
	UnregisterSignal(parent, list(COMSIG_ITEM_ATTACK_SUCCESS, COMSIG_PARENT_EXAMINE))

/// On successful hit: ensure wielder has momentum status effect, add a stack.
/datum/component/arcyne_conduit/proc/on_attack_success(obj/item/source, mob/living/target, mob/living/user)
	SIGNAL_HANDLER
	if(!isliving(user) || !isliving(target))
		return
	if(target.stat == DEAD)
		return
	// Self-healing: re-apply status effect if it was somehow removed
	var/datum/status_effect/buff/arcyne_momentum/M = user.has_status_effect(/datum/status_effect/buff/arcyne_momentum)
	if(!M)
		M = user.apply_status_effect(/datum/status_effect/buff/arcyne_momentum)
	if(M)
		M.add_stacks(1)

/datum/component/arcyne_conduit/proc/on_examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	examine_list += span_notice("This weapon pulses with faint arcyne energy. It is bound as an arcyne conduit.")

// =====================================================================
// ---- Bind Spell ----
// =====================================================================

/// Binds the held weapon as an arcyne conduit. No weapon type restriction yet.
/// Future: var/list/allowed_weapon_types for subclass-specific filtering (swords/polearms).
/obj/effect/proc_holder/spell/self/arcyne_bind
	name = "Arcyne Bind"
	desc = "Bind your held weapon as an arcyne conduit. Successful strikes with bound weapons build arcyne momentum."
	clothes_req = FALSE
	overlay_state = "enchant_weapon"
	releasedrain = 20
	chargedrain = 0
	chargetime = 0
	recharge_time = 5 SECONDS
	warnie = "yourstate"
	invocations = list("Vinculum Arcanum...")
	invocation_type = "shout"
	gesture_required = TRUE
	xp_gain = FALSE

/obj/effect/proc_holder/spell/self/arcyne_bind/cast(list/targets, mob/user = usr)
	var/mob/living/carbon/human/H = user
	if(!istype(H))
		revert_cast()
		return

	var/obj/item/weapon = H.get_active_held_item()
	if(!weapon)
		to_chat(H, span_warning("I need to hold a weapon to bind it!"))
		revert_cast()
		return

	// Future: weapon type restriction per subclass would go here
	// if(!is_valid_conduit_type(weapon))
	//     to_chat(H, span_warning("[weapon] is not a valid conduit for my fighting style!"))
	//     revert_cast()
	//     return

	if(weapon.GetComponent(/datum/component/arcyne_conduit))
		to_chat(H, span_warning("[weapon] is already bound as a conduit!"))
		revert_cast()
		return

	weapon.AddComponent(/datum/component/arcyne_conduit)
	to_chat(H, span_notice("I bind [weapon] as my arcyne conduit. Its strikes will build momentum."))
	playsound(get_turf(H), 'sound/magic/charged.ogg', 50, TRUE)
	H.visible_message(span_notice("[H] passes a hand over [weapon], which begins to glow faintly."))
	return TRUE

// =====================================================================
// ---- Alert ----
// =====================================================================

/atom/movable/screen/alert/status_effect/buff/arcyne_momentum
	name = "Arcyne Momentum (0)"
	desc = "Strikes with my bound weapon fuel arcyne power. Build stacks to unleash abilities."
	icon_state = "buff"

// =====================================================================
// ---- Status Effect (passive stack store — weapon component drives it) ----
// =====================================================================

/datum/status_effect/buff/arcyne_momentum
	id = "arcyne_momentum"
	alert_type = /atom/movable/screen/alert/status_effect/buff/arcyne_momentum
	duration = -1 // Permanent — removed only explicitly
	tick_interval = 20 // 2-second ticks for overcharge processing
	status_type = STATUS_EFFECT_UNIQUE
	var/stacks = 0
	var/max_stacks = 10
	var/glow_colour = "#4a90d9"   // Blue arcyne glow (stage 2)
	var/crackle_colour = "#7b5ea7" // Purple overcharge (stage 3)
	var/overcharge_threshold = 8
	var/overcharge_damage = 5
	var/is_overcharged = FALSE
	var/static/mutable_appearance/electricity_overlay

/datum/status_effect/buff/arcyne_momentum/on_apply()
	. = ..()
	// No signal registration — the arcyne_conduit component on the bound weapon drives stacking
	update_alert()

/datum/status_effect/buff/arcyne_momentum/on_remove()
	if(is_overcharged)
		owner.cut_overlay(electricity_overlay)
	owner.clear_fullscreen("momentum_strain")
	owner.remove_filter(MOMENTUM_FILTER)
	. = ..()

/// Adds stacks, capped at max_stacks. Updates visuals and spell buttons.
/datum/status_effect/buff/arcyne_momentum/proc/add_stacks(amount)
	var/old_stacks = stacks
	stacks = min(stacks + amount, max_stacks)
	if(stacks == old_stacks)
		return
	update_visuals()
	update_alert()
	update_spell_buttons()
	// Feedback on reaching thresholds
	if(old_stacks < 3 && stacks >= 3)
		to_chat(owner, span_notice("Arcyne momentum building... I can feel power gathering."))
		playsound(get_turf(owner), 'sound/magic/charging.ogg', 30, TRUE)
	if(old_stacks < 6 && stacks >= 6)
		to_chat(owner, span_warning("Arcyne momentum surging! My abilities are fully empowered!"))
		playsound(get_turf(owner), 'sound/magic/charged.ogg', 50, TRUE)
	if(old_stacks < overcharge_threshold && stacks >= overcharge_threshold)
		to_chat(owner, span_boldwarning("ARCYNE OVERCHARGE! Energy crackles through my body — I need to release it!"))
		playsound(get_turf(owner), 'sound/magic/charged.ogg', 70, TRUE)

/// Consumes up to `amount` stacks. Returns how many were actually consumed.
/datum/status_effect/buff/arcyne_momentum/proc/consume_stacks(amount)
	var/consumed = min(stacks, amount)
	stacks = max(stacks - amount, 0)
	update_visuals()
	update_alert()
	update_spell_buttons()
	return consumed

/// Consumes ALL stacks. Returns how many were consumed.
/datum/status_effect/buff/arcyne_momentum/proc/consume_all_stacks()
	var/consumed = stacks
	stacks = 0
	update_visuals()
	update_alert()
	update_spell_buttons()
	return consumed

/// Updates the glow/filter, electricity overlay, and screen narrowing based on current stacks.
/datum/status_effect/buff/arcyne_momentum/proc/update_visuals()
	// Always remove first to force a clean filter rebuild (in-place updates don't always trigger client redraw)
	owner.remove_filter(MOMENTUM_FILTER)
	// Glow filter stages
	if(stacks >= overcharge_threshold)
		// Stage 4: Overcharge — intense purple glow
		owner.add_filter(MOMENTUM_FILTER, 2, list("type" = "outline", "color" = crackle_colour, "alpha" = 200, "size" = 2))
	else if(stacks >= 6)
		// Stage 3: Purple crackling glow
		owner.add_filter(MOMENTUM_FILTER, 2, list("type" = "outline", "color" = crackle_colour, "alpha" = 150, "size" = 2))
	else if(stacks >= 3)
		// Stage 2: Blue glow
		owner.add_filter(MOMENTUM_FILTER, 2, list("type" = "outline", "color" = glow_colour, "alpha" = 100, "size" = 1))
	// Electricity overlay at overcharge
	if(stacks >= overcharge_threshold)
		if(!is_overcharged)
			enter_overcharge()
	else if(is_overcharged)
		exit_overcharge()
	// Screen narrowing — strain from momentum buildup
	if(stacks >= overcharge_threshold)
		owner.overlay_fullscreen("momentum_strain", /atom/movable/screen/fullscreen/impaired, 2)
	else if(stacks >= 6)
		owner.overlay_fullscreen("momentum_strain", /atom/movable/screen/fullscreen/impaired, 1)
	else
		owner.clear_fullscreen("momentum_strain")

/// Updates the alert name with current stack count.
/datum/status_effect/buff/arcyne_momentum/proc/update_alert()
	if(!linked_alert)
		return
	linked_alert.name = "Arcyne Momentum ([stacks]/[max_stacks])"

/// Refreshes all spell button icons so momentum-gated spells update their availability.
/datum/status_effect/buff/arcyne_momentum/proc/update_spell_buttons()
	if(!owner?.mind)
		return
	for(var/obj/effect/proc_holder/spell/S in owner.mind.spell_list)
		if(S.action)
			S.action.UpdateButtonIcon(status_only = TRUE)

/// Periodic tick — handles overcharge self-damage and gasping at high stacks.
/datum/status_effect/buff/arcyne_momentum/tick()
	if(stacks >= overcharge_threshold)
		// Overcharge: self-damage every tick
		owner.adjustBruteLoss(overcharge_damage)
		// Random gasping/panting
		if(prob(50))
			owner.emote(pick("gasp", "breathgasp"))
	else if(stacks >= 6)
		// High stacks: occasional strain feedback
		if(prob(20))
			owner.emote("gasp")

/// Enters overcharge state — adds electricity overlay and warns the player.
/datum/status_effect/buff/arcyne_momentum/proc/enter_overcharge()
	is_overcharged = TRUE
	if(!electricity_overlay)
		electricity_overlay = mutable_appearance('icons/effects/64x64.dmi', "electricity")
		electricity_overlay.pixel_x = -16
		electricity_overlay.pixel_y = -16
	owner.add_overlay(electricity_overlay)
	to_chat(owner, span_boldwarning("Electricity crackles across my body as arcyne energy overloads!"))

/// Exits overcharge state — removes electricity overlay.
/datum/status_effect/buff/arcyne_momentum/proc/exit_overcharge()
	is_overcharged = FALSE
	owner.cut_overlay(electricity_overlay)

// =====================================================================
// ---- Helper proc ----
// =====================================================================

/// Returns the mob's current momentum stacks, or 0 if they have no momentum status.
/proc/get_arcyne_momentum(mob/living/target)
	if(!istype(target))
		return 0
	var/datum/status_effect/buff/arcyne_momentum/M = target.has_status_effect(/datum/status_effect/buff/arcyne_momentum)
	if(!M)
		return 0
	return M.stacks

// =====================================================================
// ---- Momentum-gated Repulse variants for testing ----
// =====================================================================

/// Base type — handles can_cast gating and momentum consumption. Subtypes just set cost/power.
/obj/effect/proc_holder/spell/invoked/repulse/momentum
	cost = 0
	xp_gain = FALSE
	var/momentum_cost = 2

/obj/effect/proc_holder/spell/invoked/repulse/momentum/can_cast(mob/user)
	. = ..()
	if(!.)
		return FALSE
	if(get_arcyne_momentum(user) < momentum_cost)
		return FALSE

/obj/effect/proc_holder/spell/invoked/repulse/momentum/cast(list/targets, mob/user, stun_amt = 5)
	if(!isliving(user))
		return ..()
	var/mob/living/L = user
	var/datum/status_effect/buff/arcyne_momentum/M = L.has_status_effect(/datum/status_effect/buff/arcyne_momentum)
	if(!M || M.stacks < momentum_cost)
		to_chat(user, span_warning("Not enough momentum! Need [momentum_cost] stacks."))
		revert_cast()
		return
	M.consume_stacks(momentum_cost)
	to_chat(user, span_notice("[momentum_cost] momentum released!"))
	return ..()

/obj/effect/proc_holder/spell/invoked/repulse/momentum/t1
	name = "Momentum Repulse I"
	desc = "A weak repulsive burst. Requires 2 momentum stacks."
	momentum_cost = 2

/obj/effect/proc_holder/spell/invoked/repulse/momentum/t2
	name = "Momentum Repulse II"
	desc = "A standard repulsive burst. Requires 4 momentum stacks."
	momentum_cost = 4
	push_range = 2

/obj/effect/proc_holder/spell/invoked/repulse/momentum/t3
	name = "Momentum Repulse III"
	desc = "A strong repulsive burst. Requires 6 momentum stacks."
	momentum_cost = 6
	push_range = 2
	maxthrow = 4

/obj/effect/proc_holder/spell/invoked/repulse/momentum/t4
	name = "Momentum Repulse IV"
	desc = "Maximum repulsive force. Requires 8 momentum stacks."
	momentum_cost = 8
	push_range = 3
	maxthrow = 5

#undef MOMENTUM_FILTER
#undef CONDUIT_FILTER
