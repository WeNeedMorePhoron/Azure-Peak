#define RUNE_WARD_IMMUNITY_DURATION (3 SECONDS)
#define RUNE_WARD_IMMUNITY_KEY "rune_ward_immunity"

/obj/structure/trap/rune_ward
	name = "arcyne rune"
	desc = "A faintly glowing symbol etched into the ground."
	icon = 'icons/roguetown/misc/rune_wards.dmi'
	icon_state = "rune"
	alpha = 180
	charges = 1
	checks_antimagic = TRUE
	time_between_triggers = 0

	var/datum/weakref/owner_ref
	var/datum/weakref/spell_ref
	var/owner_name = "unknown"
	var/owner_ckey = "unknown"

/obj/structure/trap/rune_ward/Crossed(atom/movable/AM)
	if(!armed)
		return
	if(is_type_in_typecache(AM, ignore_typecache))
		return
	if(ismob(AM))
		var/mob/M = AM
		var/mob/owner = owner_ref?.resolve()
		if(M == owner)
			return
		var/datum/action/cooldown/spell/touch/rune_ward/spell = spell_ref?.resolve()
		if(spell && (M.real_name in spell.allowed_names))
			return
		if(M.mind in immune_minds)
			return
		if(checks_antimagic && M.anti_magic_check())
			flare()
			return
		if(HAS_TRAIT(AM, TRAIT_LIGHT_STEP))
			return
		// Prevent chaining multiple runes via knockback/fetch/repel
		if(isliving(AM))
			var/mob/living/L = AM
			if(L.mob_timers[RUNE_WARD_IMMUNITY_KEY] && world.time < L.mob_timers[RUNE_WARD_IMMUNITY_KEY])
				return
	if(charges <= 0)
		return
	flare()
	if(isliving(AM))
		var/mob/living/L = AM
		L.mob_timers[RUNE_WARD_IMMUNITY_KEY] = world.time + RUNE_WARD_IMMUNITY_DURATION
		log_combat(AM, src, "triggered [name] placed by [owner_name] ([owner_ckey]) at [AREACOORD(src)]")
		trap_effect(L)

/obj/structure/trap/rune_ward/Destroy()
	owner_ref = null
	spell_ref = null
	return ..()

/obj/structure/trap/rune_ward/examine(mob/user)
	. = ..()
	. += span_info("This rune was inscribed by a mage. It must be scrubbed to remove it.")

// Stun - Pure hard CC, no damage. Locks them down for followup.
/obj/structure/trap/rune_ward/stun
	name = "shock rune"
	icon_state = "rune_stun"

/obj/structure/trap/rune_ward/stun/trap_effect(mob/living/L)
	to_chat(L, span_danger("<B>The rune locks your muscles in place!</B>"))
	playsound(src, 'sound/magic/lightning.ogg', 80, TRUE)
	L.electrocute_act(10, src, flags = SHOCK_NOGLOVES)
	L.Paralyze(120)
	L.Knockdown(60)

// Fire - Damage over time. Ignites, no CC. They burn while they run.
/obj/structure/trap/rune_ward/fire
	name = "flame rune"
	icon_state = "rune_fire"

/obj/structure/trap/rune_ward/fire/trap_effect(mob/living/L)
	to_chat(L, span_danger("<B>The rune erupts in flames!</B>"))
	new /obj/effect/hotspot(get_turf(src))
	L.adjust_fire_stacks(5)
	L.ignite_mob()

// Chill - Slow and cripple. Brief freeze into heavy frost stacks.
/obj/structure/trap/rune_ward/chill
	name = "frost rune"
	icon_state = "rune_chill"

/obj/structure/trap/rune_ward/chill/trap_effect(mob/living/L)
	to_chat(L, span_danger("<B>Frost erupts from the rune and seizes your limbs!</B>"))
	new /obj/effect/temp_visual/trapice(get_turf(src))
	L.Paralyze(20)
	apply_frost_stack(L, 4)

// Damage - One big hit through armor. No CC.
/obj/structure/trap/rune_ward/damage
	name = "force rune"
	icon_state = "rune_damage"
	var/rune_damage = 80

/obj/structure/trap/rune_ward/damage/trap_effect(mob/living/L)
	to_chat(L, span_danger("<B>The rune detonates with arcyne force!</B>"))
	playsound(src, 'sound/magic/fireball.ogg', 80, TRUE)
	var/mob/living/carbon/human/owner = owner_ref?.resolve()
	if(ishuman(owner) && ishuman(L))
		arcyne_strike(owner, L, null, rune_damage, BODY_ZONE_CHEST, \
			BCLASS_BURN, armor_penetration = PEN_HEAVY, spell_name = "Force Rune", \
			damage_type = BURN, skip_animation = TRUE)
	else
		L.adjustBruteLoss(rune_damage)

/obj/structure/trap/rune_ward/alarm
	name = "alarm rune"
	icon_state = "rune_alarm"
	alpha = 40

/obj/structure/trap/rune_ward/alarm/trap_effect(mob/living/L)
	to_chat(L, span_danger("<B>The rune chimes loudly!</B>"))
	playsound(src, 'sound/magic/charging.ogg', 80, TRUE)
	var/mob/owner = owner_ref?.resolve()
	if(owner)
		var/area/A = get_area(src)
		var/area_name = A ? A.name : "an unknown location"
		to_chat(owner, span_warning("One of my alarm runes has been triggered at [area_name]!"))
		if(owner.client)
			SEND_SOUND(owner, sound('sound/magic/charging.ogg', volume = 40))

#undef RUNE_WARD_IMMUNITY_DURATION
#undef RUNE_WARD_IMMUNITY_KEY
