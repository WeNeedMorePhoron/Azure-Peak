#define STONESKIN_FILTER "stoneskin_glow"

/datum/action/cooldown/spell/conjure_arcyne_ward/stoneskin
	name = "Stoneskin"
	desc = "Conjure a stoneskin ward - a durable arcyne ward filled with earthen energy. \
	Grants brigandine-tier protection and bolsters your constitution at the cost of your speed. 400 integrity. \
	Otherwise functions as a standard arcyne ward - yields coverage to real armor, does not regenerate. \
	Cast again to dismiss. Cooldown begins when dismissed or destroyed."
	button_icon = 'icons/mob/actions/mage_geomancy.dmi'
	button_icon_state = "stoneskin"
	spell_color = GLOW_COLOR_EARTHEN
	attunement_school = ASPECT_NAME_GEOMANCY
	invocations = list("Cutis Petrae!")
	dismiss_invocation = "Cutis Solvo!"
	regen_invocation = "Cutis Restauro!"
	point_cost = 4
	spell_tier = 2
	exclusive_group = "arcyne_ward"
	ward_type = /obj/item/clothing/suit/roguetown/armor/manual/arcyne_ward/stoneskin
	regen_spell_type = /datum/action/cooldown/spell/regenerate_arcyne_ward/stoneskin

/datum/action/cooldown/spell/regenerate_arcyne_ward/stoneskin
	name = "Regenerate Stone Ward"
	spell_tier = 2

/obj/item/clothing/suit/roguetown/armor/manual/arcyne_ward/stoneskin
	name = "stone ward"
	desc = "Rock and stone."
	armor = ARMOR_BRIGANDINE
	max_integrity = 400
	ward_color = GLOW_COLOR_EARTHEN
	arcyne_armor_tier = ARCYNE_WARD_TIER_GREATER

/obj/item/clothing/suit/roguetown/armor/manual/arcyne_ward/stoneskin/setup_ward(mob/living/carbon/human/H)
	..()
	H.apply_status_effect(/datum/status_effect/buff/stoneskin)

/obj/item/clothing/suit/roguetown/armor/manual/arcyne_ward/stoneskin/cleanup_ward()
	if(ward_owner)
		ward_owner.remove_status_effect(/datum/status_effect/buff/stoneskin)
	..()

/datum/status_effect/buff/stoneskin
	id = "stoneskin"
	alert_type = /atom/movable/screen/alert/status_effect/buff/stoneskin
	duration = -1
	effectedstats = list(STATKEY_CON = 2, STATKEY_SPD = -1)
	var/outline_colour = GLOW_COLOR_EARTHEN

/atom/movable/screen/alert/status_effect/buff/stoneskin
	name = "Stoneskin"
	desc = "Rock and Stone."

/datum/status_effect/buff/stoneskin/on_apply()
	. = ..()
	if(!owner.get_filter(STONESKIN_FILTER))
		owner.add_filter(STONESKIN_FILTER, 2, list("type" = "outline", "color" = outline_colour, "alpha" = 60, "size" = 1))

/datum/status_effect/buff/stoneskin/on_remove()
	. = ..()
	owner.remove_filter(STONESKIN_FILTER)

#undef STONESKIN_FILTER
