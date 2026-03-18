// Great Shelter - Hearthcraft minor aspect spell
// Conjures a small prefab house: arcyne walls + door, bed, hearth, and oven.
// The caster must bring their own cooking tools.
//
// Layout (5x5 footprint, 3x3 interior, door always south):
//   [wall] [wall] [wall] [wall] [wall]
//   [wall] [bed ] [    ] [    ] [wall]
//   [wall] [    ] [    ] [oven] [wall]
//   [wall] [    ] [hrt ] [    ] [wall]
//   [wall] [wall] [door] [wall] [wall]
//
// Interior contains: bed, hearth, oven (blue-tinted)
// All structures expire after shelter_duration.

#define SHELTER_DURATION 15 MINUTES

/datum/action/cooldown/spell/great_shelter
	name = "Great Shelter"
	desc = "Conjure a cramped but functional shelter from arcyne force. \
	Contains a bed, a hearth, and an oven. Bring your own cooking tools. \
	The shelter lasts for 15 minutes."
	button_icon_state = "yourewizardharry"
	sound = 'sound/spellbooks/crystal.ogg'
	spell_color = GLOW_COLOR_ARCANE
	glow_intensity = GLOW_INTENSITY_MEDIUM

	click_to_activate = TRUE
	cast_range = 3
	self_cast_possible = FALSE

	primary_resource_type = SPELL_COST_STAMINA
	primary_resource_cost = SPELLCOST_CONJURE
	secondary_resource_type = SPELL_COST_ENERGY
	secondary_resource_cost = 400

	invocations = list("Domus Arcana!")
	invocation_type = INVOCATION_SHOUT

	charge_required = TRUE
	charge_time = 3 SECONDS
	charge_drain = 1
	charge_slowdown = 3
	charge_sound = 'sound/magic/charging.ogg'
	cooldown_time = 5 MINUTES

	associated_skill = /datum/skill/magic/arcane
	spell_tier = 1

	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC | SPELL_REQUIRES_HUMAN | SPELL_REQUIRES_NO_MOVE

/datum/action/cooldown/spell/great_shelter/cast(atom/cast_on)
	. = ..()
	var/mob/living/carbon/human/H = owner
	if(!istype(H))
		return FALSE

	var/turf/center = get_turf(cast_on)
	if(!center)
		return FALSE

	// Check the 5x5 area is clear
	for(var/turf/T in range(2, center))
		if(T.density)
			to_chat(H, span_warning("There isn't enough space to conjure a shelter here!"))
			return FALSE

	playsound(center, 'sound/spellbooks/crystal.ogg', 100, TRUE)
	H.visible_message(span_warning("[H] conjures a shelter from arcyne force!"))

	// Build 5x5 perimeter walls with door on south face
	for(var/turf/T in range(2, center))
		var/dist = get_dist(center, T)
		if(dist <= 1)
			continue // Interior 3x3, handled below
		// Perimeter tile - door goes at dead south
		if(get_dir(center, T) == SOUTH && dist == 2)
			new /obj/structure/mineral_door/forcefield_door/shelter(T, H)
		else
			new /obj/structure/forcefield_weak/shelter_wall(T, H)

	// Interior furnishings - placed within the 3x3 interior
	var/turf/northwest = locate(center.x - 1, center.y + 1, center.z)
	var/turf/east = locate(center.x + 1, center.y, center.z)
	var/turf/south_center = locate(center.x, center.y - 1, center.z)

	new /obj/structure/bed/rogue/conjured(northwest)
	new /obj/machinery/light/rogue/hearth/conjured(south_center)
	new /obj/machinery/light/rogue/oven/conjured(east)

	return TRUE

// --- Conjured structures ---

/obj/structure/forcefield_weak/shelter_wall
	name = "arcyne wall"
	desc = "A shimmering wall of arcyne force. It hums faintly."
	max_integrity = 200
	icon = 'icons/roguetown/misc/structure.dmi'
	icon_state = "yourewizardharry" // TODO: Proper arcyne wall sprite
	color = "#6495ED"

/obj/structure/forcefield_weak/shelter_wall/Initialize(mapload, mob/summoner)
	. = ..()
	QDEL_IN(src, SHELTER_DURATION)

/obj/structure/mineral_door/forcefield_door/shelter
	name = "arcyne door"
	desc = "A shimmering door of arcyne force."
	color = "#6495ED"
	var/mob/caster

/obj/structure/mineral_door/forcefield_door/shelter/Initialize(mapload, mob/summoner)
	. = ..()
	caster = summoner
	QDEL_IN(src, SHELTER_DURATION)

/obj/structure/bed/rogue/conjured
	name = "arcyne bed"
	desc = "A bed conjured from arcyne force. It looks uncomfortable, but functional."
	color = "#6495ED"

/obj/structure/bed/rogue/conjured/Initialize(mapload)
	. = ..()
	QDEL_IN(src, SHELTER_DURATION)

/obj/machinery/light/rogue/hearth/conjured
	name = "arcyne hearth"
	desc = "A hearth of blue arcyne flame. It burns without fuel."
	color = "#6495ED"

/obj/machinery/light/rogue/hearth/conjured/Initialize()
	. = ..()
	QDEL_IN(src, SHELTER_DURATION)

/obj/machinery/light/rogue/oven/conjured
	name = "arcyne oven"
	desc = "An oven conjured from arcyne force. It glows with a faint blue heat."
	color = "#6495ED"

/obj/machinery/light/rogue/oven/conjured/Initialize()
	. = ..()
	QDEL_IN(src, SHELTER_DURATION)

#undef SHELTER_DURATION
