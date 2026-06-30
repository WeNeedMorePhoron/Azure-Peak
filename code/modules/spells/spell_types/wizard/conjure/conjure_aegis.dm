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
	sellprice = 0
	static_price = TRUE
	anvilrepair = /datum/skill/magic/arcane
	parrysound = list('sound/combat/parry/shield/magicshield (1).ogg', 'sound/combat/parry/shield/magicshield (2).ogg', 'sound/combat/parry/shield/magicshield (3).ogg')
	associated_skill = /datum/skill/combat/shields
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
	qdel(src)

/obj/item/rogueweapon/shield/arcyne_aegis/tome
	name = "arcyne aegis"
	desc = "A shield of arcyne energy projected from a tome. It is easily controlled by a mage skilled in the arcyne arts and vanishes if the tome leaves its wielder."
	wdefense = 10
	coverage = 30
	max_integrity = 120
	associated_skill = /datum/skill/combat/arcyne
	var/datum/weakref/linked_tome

/obj/item/rogueweapon/shield/arcyne_aegis/tome/greater
	name = "greater arcyne aegis"
	wdefense = 10
	coverage = 40
	max_integrity = 220

/obj/item/rogueweapon/shield/arcyne_aegis/tome/grand
	name = "grand arcyne aegis"
	wdefense = 11
	coverage = 60
	max_integrity = 260

/obj/item/rogueweapon/shield/arcyne_aegis/tome/proc/link_tome(obj/item/rogueweapon/spellbook/T, mob/living/carbon/human/caster)
	linked_tome = WEAKREF(T)
	caster_ref = WEAKREF(caster)

/obj/item/rogueweapon/shield/arcyne_aegis/tome/proc/valid_tome_link()
	var/mob/caster = caster_ref?.resolve()
	var/obj/item/rogueweapon/spellbook/T = linked_tome?.resolve()
	return caster && T && caster.is_holding(T)

/obj/item/rogueweapon/shield/arcyne_aegis/tome/dropped(mob/living/user)
	. = ..()
	if(!QDELETED(src) && !valid_tome_link())
		dispel()

/obj/item/rogueweapon/shield/arcyne_aegis/tome/dispel()
	var/obj/item/rogueweapon/spellbook/T = linked_tome?.resolve()
	if(T && T.conjured_aegis == src)
		T.conjured_aegis = null
	return ..()
