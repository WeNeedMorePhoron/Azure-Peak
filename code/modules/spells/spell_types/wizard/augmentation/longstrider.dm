// Longstrider — Augmentation AOE self-cast buff (new action system)
// Status effect kept in buffs_debuffs/longstrider.dm
/datum/action/cooldown/spell/longstrider
	button_icon = 'icons/mob/actions/mage_augmentation.dmi'
	name = "Longstrider"
	desc = "Grant yourself and any creatures adjacent to you free movement through rough terrain for 15 minutes."
	button_icon_state = "longstrider"
	sound = 'sound/magic/haste.ogg'
	spell_color = GLOW_COLOR_BUFF
	glow_intensity = GLOW_INTENSITY_LOW

	click_to_activate = TRUE
	self_cast_possible = TRUE

	primary_resource_type = SPELL_COST_STAMINA
	primary_resource_cost = SPELLCOST_UTILITY_BUFF

	invocations = list("Aranea Deambulatio")
	invocation_type = INVOCATION_WHISPER

	charge_required = TRUE
	charge_time = 1 SECONDS
	charge_drain = 0
	charge_slowdown = CHARGING_SLOWDOWN_NONE
	charge_sound = 'sound/magic/charging.ogg'
	cooldown_time = 1.5 MINUTES

	associated_skill = /datum/skill/magic/arcane
	spell_tier = 1

	point_cost = 2

	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC | SPELL_REQUIRES_HUMAN

/datum/action/cooldown/spell/longstrider/cast(atom/cast_on)
	. = ..()
	var/mob/living/carbon/human/H = owner
	if(!istype(H))
		return FALSE

	H.visible_message("[H] mutters an incantation and a dim pulse of light radiates out from them.")
	for(var/mob/living/L in range(1, H))
		L.apply_status_effect(/datum/status_effect/buff/longstrider)

	return TRUE
