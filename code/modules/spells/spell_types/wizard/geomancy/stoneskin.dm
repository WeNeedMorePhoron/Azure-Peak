/datum/action/cooldown/spell/stoneskin
	button_icon = 'icons/mob/actions/mage_geomancy.dmi'
	name = "Stoneskin"
	desc = "Harden my skin into a shell of living stone. While it holds, blows against me are blunted by a quarter, but I move sluggishly. Cast again to shed it."
	button_icon_state = "stoneskin"
	sound = 'sound/foley/stone_scrape.ogg'
	spell_color = GLOW_COLOR_EARTHEN
	glow_intensity = GLOW_INTENSITY_LOW
	attunement_school = ASPECT_NAME_GEOMANCY

	click_to_activate = FALSE
	self_cast_possible = TRUE

	primary_resource_type = SPELL_COST_STAMINA
	primary_resource_cost = SPELLCOST_CANTRIP

	invocations = list("Cutis Petrae!")
	invocation_type = INVOCATION_SHOUT

	charge_required = FALSE
	cooldown_time = 2 SECONDS

	associated_skill = /datum/skill/magic/arcane
	spell_tier = 2
	spell_impact_intensity = SPELL_IMPACT_NONE

	point_cost = 2

	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC | SPELL_REQUIRES_HUMAN

/datum/action/cooldown/spell/stoneskin/cast(atom/cast_on)
	. = ..()
	var/mob/living/carbon/human/H = owner
	if(!istype(H))
		return FALSE
	playsound(H, 'sound/foley/stone_scrape.ogg', 50, TRUE)
	if(H.has_status_effect(/datum/status_effect/buff/iron_skin/stoneskin))
		H.remove_status_effect(/datum/status_effect/buff/iron_skin/stoneskin)
	else
		H.apply_status_effect(/datum/status_effect/buff/iron_skin/stoneskin)
	return TRUE

/atom/movable/screen/alert/status_effect/buff/iron_skin/stoneskin
	name = "Stoneskin"
	desc = "My skin is hardened to living stone - blows against me are blunted, but I move sluggishly."

/datum/status_effect/buff/iron_skin/stoneskin
	id = "stoneskin"
	alert_type = /atom/movable/screen/alert/status_effect/buff/iron_skin/stoneskin
	duration = -1
	effectedstats = list(STATKEY_SPD = -2)
	outline_colour = GLOW_COLOR_EARTHEN
	var/obj/effect/abstract/particle_holder/dust_holder

/datum/status_effect/buff/iron_skin/stoneskin/on_apply()
	. = ..()
	dust_holder = new /obj/effect/abstract/particle_holder(owner, /particles/stoneskin)

/datum/status_effect/buff/iron_skin/stoneskin/on_remove()
	QDEL_NULL(dust_holder)
	. = ..()

/particles/stoneskin
	icon = 'icons/effects/particles/smoke.dmi'
	icon_state = list("smoke_1" = 1, "smoke_2" = 1, "smoke_3" = 1)
	width = 64
	height = 64
	count = 30
	spawning = 0.7
	lifespan = 1.2 SECONDS
	fade = 0.6 SECONDS
	fadein = 0.3 SECONDS
	color = "#8f8f8f"
	position = generator("box", list(-9, -10, 0), list(9, 10, 0), UNIFORM_RAND)
	velocity = generator("box", list(-0.15, -0.05, 0), list(0.15, 0.25, 0), NORMAL_RAND)
	scale = 0.35
	friction = 0.15
