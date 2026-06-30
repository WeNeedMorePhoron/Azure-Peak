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
	var/offhand_dispel_time = 10 SECONDS
	var/dispel_timer

/obj/item/rogueweapon/shield/arcyne_aegis/examine(mob/user)
	. = ..()
	. += span_notice("Out of hand, it dissipates in about [offhand_dispel_time / 10] seconds.")

/obj/item/rogueweapon/shield/arcyne_aegis/obj_break()
	. = ..()
	if(!QDELETED(src))
		dispel()

/obj/item/rogueweapon/shield/arcyne_aegis/Destroy()
	cancel_dispel_timer()
	return ..()

/obj/item/rogueweapon/shield/arcyne_aegis/attack_hand(mob/living/user)
	. = ..()
	refresh_dispel_state()

/obj/item/rogueweapon/shield/arcyne_aegis/equipped(mob/user, slot, initial = FALSE)
	. = ..()
	refresh_dispel_state()

/obj/item/rogueweapon/shield/arcyne_aegis/dropped(mob/living/user)
	. = ..()
	refresh_dispel_state()

/obj/item/rogueweapon/shield/arcyne_aegis/proc/refresh_dispel_state()
	if(QDELETED(src))
		return
	var/mob/holder = isliving(loc) ? loc : null
	if(holder?.is_holding(src))
		cancel_dispel_timer()
	else
		start_dispel_timer()

/obj/item/rogueweapon/shield/arcyne_aegis/proc/start_dispel_timer()
	if(QDELETED(src) || dispel_timer)
		return
	dispel_timer = addtimer(CALLBACK(src, PROC_REF(dispel)), offhand_dispel_time, TIMER_STOPPABLE)

/obj/item/rogueweapon/shield/arcyne_aegis/proc/cancel_dispel_timer()
	if(dispel_timer)
		deltimer(dispel_timer)
		dispel_timer = null

/obj/item/rogueweapon/shield/arcyne_aegis/proc/dispel()
	if(QDELETED(src))
		return
	cancel_dispel_timer()
	visible_message(span_warning("[src] shatters into motes of arcyne light!"))
	balloon_alert_to_viewers("aegis fades")
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

/obj/item/rogueweapon/shield/arcyne_aegis/tome/dispel()
	var/obj/item/rogueweapon/spellbook/T = linked_tome?.resolve()
	if(T && T.conjured_aegis == src)
		T.conjured_aegis = null
	return ..()
