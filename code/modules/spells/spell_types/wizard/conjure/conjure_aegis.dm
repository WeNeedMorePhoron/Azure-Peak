// Conjure Aegis - Aegiscraft Minor Aspect
// Conjures an arcyne shield designed to counter projectiles.
// 200 durability, 60 coverage, 9 WDef.

/datum/action/cooldown/spell/conjure_aegis
	button_icon = 'icons/mob/actions/mage_conjure.dmi'
	name = "Conjure Aegis"
	desc = "Conjure an Arcyne Aegis - a projected shield of arcyne energy designed to counter projectiles.\n\
	Less effective against deliberate melee strikes, but excellent against ranged attacks.\n\
	The shield vanishes when broken or when a new one is conjured.\n\
	While channeling this spell, I cannot parry or dodge - my focus is entirely on the conjuration."
	button_icon_state = "conjure_aegis"
	sound = 'sound/magic/whiteflame.ogg'
	spell_color = GLOW_COLOR_ARCANE
	glow_intensity = GLOW_INTENSITY_MEDIUM

	click_to_activate = TRUE
	self_cast_possible = TRUE

	primary_resource_type = SPELL_COST_STAMINA
	primary_resource_cost = SPELLCOST_CONJURE

	invocations = list("Clipeum Arcanum!")
	invocation_type = INVOCATION_SHOUT

	charge_required = TRUE
	charge_time = 3 SECONDS
	charge_drain = 1
	charge_slowdown = CHARGING_SLOWDOWN_HEAVY
	charge_sound = 'sound/magic/charging.ogg'
	cooldown_time = 90 SECONDS
	blocks_defense_while_channeling = TRUE

	associated_skill = /datum/skill/combat/shields
	spell_tier = 2
	spell_impact_intensity = SPELL_IMPACT_NONE

	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC | SPELL_REQUIRES_HUMAN | SPELL_REQUIRES_SAME_Z

	var/obj/item/rogueweapon/shield/arcyne_aegis/conjured_shield

/datum/action/cooldown/spell/conjure_aegis/cast(atom/cast_on)
	. = ..()
	var/mob/living/carbon/human/H = owner
	if(!istype(H))
		return FALSE

	if(H.get_num_arms() <= 0)
		to_chat(H, span_warning("I don't have any usable hands!"))
		return FALSE

	// Destroy previous conjured shield
	if(conjured_shield && !QDELETED(conjured_shield))
		conjured_shield.visible_message(span_warning("[conjured_shield] flickers and fades away!"))
		qdel(conjured_shield)

	var/obj/item/rogueweapon/shield/arcyne_aegis/S = new(H.drop_location())
	S.linked_spell = src
	S.caster_ref = WEAKREF(H)
	S.AddComponent(/datum/component/conjured_item, null, TRUE)
	H.put_in_hands(S)
	conjured_shield = S
	H.visible_message("[H] conjures a shimmering shield of arcyne energy!")
	return TRUE

/datum/action/cooldown/spell/conjure_aegis/Destroy()
	if(conjured_shield && !QDELETED(conjured_shield))
		conjured_shield.visible_message(span_warning("[conjured_shield] flickers and fades away!"))
		qdel(conjured_shield)
	conjured_shield = null
	return ..()

// The conjured shield item
/obj/item/rogueweapon/shield/arcyne_aegis
	name = "arcyne aegis"
	desc = "A rare hunk of arcyne energy projected in front of the caster. Slower and more deliberate movement by blades and melee weapons easily pierce through to the squishy Magi behind."
	icon = 'icons/roguetown/weapons/prismatic_weapons64.dmi'
	icon_state = "moonlight_shield"
	pixel_x = -16
	bigboy = TRUE
	wdefense = 9
	coverage = 60
	max_integrity = 200
	force = 5
	unenchantable = TRUE
	anvilrepair = /datum/skill/magic/arcane
	parrysound = list('sound/combat/parry/shield/magicshield (1).ogg', 'sound/combat/parry/shield/magicshield (2).ogg', 'sound/combat/parry/shield/magicshield (3).ogg')
	associated_skill = /datum/skill/combat/shields
	var/datum/action/cooldown/spell/conjure_aegis/linked_spell
	var/datum/weakref/caster_ref

/obj/item/rogueweapon/shield/arcyne_aegis/obj_break()
	. = ..()
	if(!QDELETED(src))
		dispel()

/obj/item/rogueweapon/shield/arcyne_aegis/attack_hand(mob/living/user)
	. = ..()
	if(!QDELETED(src) && !(user.get_active_held_item() == src || user.get_inactive_held_item() == src))
		dispel()

/obj/item/rogueweapon/shield/arcyne_aegis/dropped(mob/living/user)
	. = ..()
	if(QDELETED(src))
		return
	var/mob/caster = caster_ref?.resolve()
	// Only dispel if dropped on the ground (not held by the caster)
	if(!caster || loc != caster)
		dispel()

/obj/item/rogueweapon/shield/arcyne_aegis/proc/dispel()
	if(QDELETED(src))
		return
	visible_message(span_warning("[src] shatters into motes of arcyne light!"))
	playsound(get_turf(src), 'sound/magic/magic_nulled.ogg', 80)
	if(linked_spell)
		linked_spell.conjured_shield = null
	qdel(src)

/obj/item/rogueweapon/shield/arcyne_aegis/wand
	name = "arcyne aegis"
	desc = "A shield of arcyne energy projected from a wand. It is easily controlled and manipulated by a mage skilled in usage of staves. It vanishes if the wand leaves its wielder."
	wdefense = 10
	coverage = 30
	max_integrity = 120
	associated_skill = /datum/skill/combat/staves
	var/datum/weakref/linked_wand

/obj/item/rogueweapon/shield/arcyne_aegis/wand/greater
	name = "greater arcyne aegis"
	wdefense = 10
	coverage = 40
	max_integrity = 220

/obj/item/rogueweapon/shield/arcyne_aegis/wand/grand
	name = "grand arcyne aegis"
	wdefense = 11
	coverage = 60
	max_integrity = 260

/obj/item/rogueweapon/shield/arcyne_aegis/wand/proc/link_wand(obj/item/rogueweapon/wand/W, mob/living/carbon/human/caster)
	linked_wand = WEAKREF(W)
	caster_ref = WEAKREF(caster)

/obj/item/rogueweapon/shield/arcyne_aegis/wand/proc/valid_wand_link()
	var/mob/caster = caster_ref?.resolve()
	var/obj/item/rogueweapon/wand/W = linked_wand?.resolve()
	return caster && W && caster.is_holding(W)

/obj/item/rogueweapon/shield/arcyne_aegis/wand/dropped(mob/living/user)
	. = ..()
	if(!QDELETED(src) && !valid_wand_link())
		dispel()

/obj/item/rogueweapon/shield/arcyne_aegis/wand/dispel()
	var/obj/item/rogueweapon/wand/W = linked_wand?.resolve()
	if(W && W.conjured_aegis == src)
		W.conjured_aegis = null
	return ..()
