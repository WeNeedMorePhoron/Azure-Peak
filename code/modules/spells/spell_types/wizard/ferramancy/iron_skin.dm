/datum/action/cooldown/spell/iron_skin
	button_icon = 'icons/mob/actions/mage_ferramancy.dmi'
	name = "Iron Skin"
	desc = "Conjure bits of arcyne iron and steel to surround the target's armor, blunting incoming blows and protecting their equipment. Reduces incoming integrity damage to armor by 25%."
	button_icon_state = "iron_skin"
	sound = 'sound/magic/haste.ogg'
	spell_color = GLOW_COLOR_METAL
	glow_intensity = GLOW_INTENSITY_LOW

	click_to_activate = TRUE
	cast_range = 7
	self_cast_possible = TRUE

	primary_resource_type = SPELL_COST_STAMINA
	primary_resource_cost = SPELLCOST_STAT_BUFF

	invocations = list("Ferrum Tutamen.")
	invocation_type = INVOCATION_WHISPER

	charge_required = TRUE
	charge_time = CHARGETIME_POKE
	charge_drain = 1
	charge_slowdown = CHARGING_SLOWDOWN_SMALL
	charge_sound = 'sound/magic/charging.ogg'
	cooldown_time = 2 MINUTES

	associated_skill = /datum/skill/magic/arcane
	spell_tier = 2
	spell_impact_intensity = SPELL_IMPACT_NONE

/datum/action/cooldown/spell/iron_skin/cast(atom/cast_on)
	. = ..()
	if(!isliving(cast_on))
		return FALSE

	var/mob/living/target = cast_on
	playsound(get_turf(target), 'sound/magic/haste.ogg', 80, TRUE, soundping = TRUE)

	if(target != owner)
		owner.visible_message(span_notice("[owner] mutters an incantation and bits of iron materialize around [target]'s armor."))
		target.apply_status_effect(/datum/status_effect/buff/iron_skin/other)
	else
		owner.visible_message(span_notice("[owner] mutters an incantation and bits of iron materialize around their armor."))
		target.apply_status_effect(/datum/status_effect/buff/iron_skin)

	return TRUE

// --- Status effect ---

#define IRON_SKIN_FILTER "iron_skin_glow"

/atom/movable/screen/alert/status_effect/buff/iron_skin
	name = "Iron Skin"
	desc = "Bits of arcyne iron and steel surround my armor, any attacks against me are blunted."
	icon_state = "buff"

/datum/status_effect/buff/iron_skin
	id = "iron_skin"
	alert_type = /atom/movable/screen/alert/status_effect/buff/iron_skin
	duration = 1 MINUTES

/datum/status_effect/buff/iron_skin/other
	duration = 2 MINUTES

/datum/status_effect/buff/iron_skin/on_apply()
	. = ..()
	var/filter = owner.get_filter(IRON_SKIN_FILTER)
	if(!filter)
		owner.add_filter(IRON_SKIN_FILTER, 2, list("type" = "outline", "color" = "#708090", "alpha" = 40, "size" = 1))
	to_chat(owner, span_notice("Bits of arcyne iron and steel surround my armor, any blows and attacks against me are blunted."))

/datum/status_effect/buff/iron_skin/on_remove()
	. = ..()
	to_chat(owner, span_warning("The iron shell flakes away."))
	owner.remove_filter(IRON_SKIN_FILTER)

#undef IRON_SKIN_FILTER
