/datum/action/cooldown/spell/telegraphed_strike/spellblade
	button_icon = 'icons/mob/actions/classuniquespells/spellblade.dmi'
	spell_color = GLOW_COLOR_ARCANE
	glow_intensity = GLOW_INTENSITY_MEDIUM
	sound = 'sound/combat/ground_smash1.ogg'

	primary_resource_type = SPELL_COST_STAMINA
	primary_resource_cost = SPELLCOST_SB_POKE

	cooldown_time = 12 SECONDS

	associated_skill = /datum/skill/magic/arcane
	spell_tier = 2
	spell_impact_intensity = SPELL_IMPACT_MEDIUM
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC | SPELL_REQUIRES_HUMAN | SPELL_REQUIRES_SAME_Z

	requires_weapon = TRUE
	weapon_missing_message = "I need my bound weapon in hand!"
	telegraph_type = /obj/effect/temp_visual/trap/arcyne
	blade_class = BCLASS_BLUNT
	strike_sound = null
	committed_strike = FALSE

	var/momentum_cost = 3
	var/empowered_mult = 2
	var/momentum_on_hit = 0
	var/momentum_on_surge = 1
	var/push_dist = 0
	var/empowered = FALSE

/datum/action/cooldown/spell/telegraphed_strike/spellblade/get_strike_weapon(mob/living/carbon/human/H)
	return arcyne_get_weapon(H)

/datum/action/cooldown/spell/telegraphed_strike/spellblade/get_strike_damage()
	return empowered ? damage * empowered_mult : damage

/datum/action/cooldown/spell/telegraphed_strike/spellblade/cast(atom/cast_on)
	empowered = FALSE
	. = ..()
	if(!.)
		return
	var/mob/living/carbon/human/H = owner
	var/datum/status_effect/buff/arcyne_momentum/M = H.has_status_effect(/datum/status_effect/buff/arcyne_momentum)
	if(M && M.stacks >= momentum_cost)
		M.consume_stacks(momentum_cost)
		empowered = TRUE
		to_chat(H, span_notice("[momentum_cost] momentum released - empowered strike!"))

/datum/action/cooldown/spell/telegraphed_strike/spellblade/on_antimagic_block(mob/living/L)
	L.visible_message(span_warning("The arcyne force scatters as it nears [L]!"))
	playsound(get_turf(L), 'sound/magic/magic_nulled.ogg', 100)

/datum/action/cooldown/spell/telegraphed_strike/spellblade/on_hit_target(mob/living/carbon/human/H, mob/living/L, facing)
	if(!push_dist)
		return
	var/push_dir = get_dir(H, L) || facing || pick(GLOB.cardinals)
	L.safe_throw_at(get_ranged_target_turf(L, push_dir, push_dist), push_dist, 1, H, force = MOVE_FORCE_STRONG)

/datum/action/cooldown/spell/telegraphed_strike/spellblade/on_strike_complete(mob/living/carbon/human/H, hit_count, deflected)
	if(!hit_count)
		return
	var/datum/status_effect/buff/arcyne_momentum/M = H.has_status_effect(/datum/status_effect/buff/arcyne_momentum)
	if(!M)
		return
	if(momentum_on_hit)
		M.add_stacks(momentum_on_hit)
	if(hit_count >= 2 && momentum_on_surge)
		M.add_stacks(momentum_on_surge)
		to_chat(H, span_notice("DOUBLE STRIKE! ARCYNE SURGE!"))

/obj/effect/temp_visual/trap/arcyne
	color = GLOW_COLOR_ARCANE
	light_color = GLOW_COLOR_ARCANE
	duration = 3 SECONDS
