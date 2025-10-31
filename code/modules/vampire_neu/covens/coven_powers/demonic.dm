/datum/coven/demonic
	name = "Demonic"
	desc = "Get a help from the Hell creatures, resist THE FIRE, transform into an imp. Violates Masquerade."
	icon_state = "daimonion"
	clan_restricted = FALSE
	power_type = /datum/coven_power/demonic

/datum/coven_power/demonic
	name = "Demonic power name"
	desc = "Demonic power description"

//SENSE THE SIN
/datum/coven_power/demonic/sense_the_sin
	name = "Sense the Sin"
	desc = "Become supernaturally resistant to fire."

	level = 1
	research_cost = 0
	cancelable = TRUE
	duration_length = 20 SECONDS
	cooldown_length = 10 SECONDS

/datum/coven_power/demonic/sense_the_sin/activate()
	. = ..()
	owner.physiology.burn_mod /= 100
	ADD_TRAIT(owner, TRAIT_NOFIRE, VAMPIRE_TRAIT)
	owner.color = "#884200"

/datum/coven_power/demonic/sense_the_sin/deactivate()
	. = ..()
	owner.color = initial(owner.color)
	REMOVE_TRAIT(owner, TRAIT_NOFIRE, VAMPIRE_TRAIT)
	owner.physiology.burn_mod *= 100

/datum/coven_power/demonic/fear_of_the_void_below
	name = "Fear of the Void"
	desc = "Short burst of speed and resilience."

	level = 2
	research_cost = 1
	check_flags = COVEN_CHECK_CONSCIOUS | COVEN_CHECK_CAPABLE | COVEN_CHECK_LYING | COVEN_CHECK_IMMOBILE

	violates_masquerade = TRUE

	cancelable = TRUE
	duration_length = 15 SECONDS
	cooldown_length = 1 MINUTES

/datum/coven_power/demonic/fear_of_the_void_below/activate()
	. = ..()
	owner.add_movespeed_modifier(MOVESPEED_ID_FOTV, multiplicative_slowdown = -0.2)
	owner.apply_status_effect(/datum/status_effect/buff/fotv)

/datum/coven_power/demonic/fear_of_the_void_below/deactivate()
	. = ..()
	owner.remove_movespeed_modifier(MOVESPEED_ID_FOTV)
	owner.remove_status_effect(/datum/status_effect/buff/fotv)

//CONFLAGRATION
/datum/coven_power/demonic/conflagration
	name = "Conflagration"
	desc = "Turn your hands into deadly claws."

	level = 3
	research_cost = 2
	check_flags = COVEN_CHECK_CONSCIOUS | COVEN_CHECK_CAPABLE
	vitae_cost = 250

	violates_masquerade = TRUE

	cancelable = TRUE
	duration_length = 40 SECONDS
	cooldown_length = 1 MINUTES

/datum/coven_power/demonic/conflagration/activate()
	. = ..()
	owner.drop_all_held_items()
	owner.put_in_r_hand(new /obj/item/rogueweapon/gangrel(owner))
	owner.put_in_l_hand(new /obj/item/rogueweapon/gangrel(owner))

/datum/coven_power/demonic/conflagration/deactivate()
	. = ..()
	for(var/obj/item/rogueweapon/gangrel/claws in owner)
		qdel(claws)

//PSYCHOMACHIA
/datum/coven_power/demonic/psychomachia
	name = "Psychomachia"
	desc = "Set your foes on fire with a fireball."

	level = 4
	research_cost = 3
	check_flags = COVEN_CHECK_CONSCIOUS | COVEN_CHECK_CAPABLE | COVEN_CHECK_IMMOBILE | COVEN_CHECK_LYING

/datum/coven_power/demonic/psychomachia/post_gain()
	. = ..()
	owner.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/projectile/fireball/baali)

/obj/effect/proc_holder/spell/invoked/projectile/fireball/baali
	name = "Infernal Fireball"
	desc = "This spell fires an explosive fireball at a target."
	school = "evocation"
	recharge_time = 60 SECONDS
	invocation_type = "whisper"
	projectile_type = /obj/projectile/magic/aoe/fireball/rogue
	associated_skill = /datum/skill/magic/blood
	sound = 'sound/magic/fireball.ogg'

//CONDEMNTATION
/datum/coven_power/demonic/wall_of_fire
	name = "Wall of Fire"
	desc = "Firebolt? Fireball? No. Wall of Fire!"
	level = 5
	research_cost = 4
	check_flags = COVEN_CHECK_CONSCIOUS | COVEN_CHECK_CAPABLE | COVEN_CHECK_IMMOBILE
	range = 10
	vitae_cost = 250
	cooldown_length = 120 SECONDS
	violates_masquerade = TRUE
	research_cost = 4
	minimal_generation = GENERATION_ANCILLAE
	var/initialized_curses = FALSE
	var/list/curse_names = list()
	var/list/curses = list()

/datum/coven_power/demonic/wall_of_fire/activate(atom/target)
	. = ..()
	playsound(get_turf(owner), list('sound/misc/explode/incendiary (1).ogg', 'sound/misc/explode/incendiary (2).ogg'), 100, -1, 0)
	INVOKE_ASYNC(src, PROC_REF(wall_of_fire))

/datum/coven_power/demonic/wall_of_fire/proc/wall_of_fire()
	var/turf/initial_turf = get_turf(owner)
	var/list/burnt_turfs = list()
	for(var/i = 1, i < range, ++i)
		var/list/turfs = border_diamond_range_turfs(initial_turf, i)
		for(var/turf/T in turfs)
			if(!isopenturf(T) || (T in burnt_turfs))
				continue
			new /obj/effect/hotspot/vampiric(T, 125, 100+T0C, owner.clan)
			for(var/mob/living/L in T.contents)
				if(L.clan == owner.clan)
					continue
				L.adjustFireLoss(20)
				L.adjust_fire_stacks(4)
				L.ignite_mob()
			burnt_turfs |= T
		sleep(0.5 SECONDS)

/obj/item/rogueweapon/gangrel
	name = "claws"
	desc = ""
	item_state = null
	lefthand_file = null
	righthand_file = null
	icon = 'icons/roguetown/weapons/special/claws.dmi'
	lefthand_file = 'icons/mob/inhands/weapons/claws_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/claws_righthand.dmi'
	icon_state = "claws"
	max_blade_int = 900
	max_integrity = 900
	force = 6
	wdefense = 9
	armor_penetration = 100
	block_chance = 20
	associated_skill = /datum/skill/combat/unarmed
	wlength = WLENGTH_NORMAL
	wbalance = WBALANCE_NORMAL
	w_class = WEIGHT_CLASS_BULKY
	can_parry = TRUE
	sharpness = IS_SHARP
	parrysound = "bladedmedium"
	swingsound = BLADEWOOSH_MED
	possible_item_intents = list(/datum/intent/simple/werewolf)
	parrysound = list('sound/combat/parry/parrygen.ogg')
	embedding = list("embedded_pain_multiplier" = 0, "embed_chance" = 0, "embedded_fall_chance" = 0)
	item_flags = DROPDEL
	//masquerade_violating = TRUE

/obj/item/rogueweapon/gangrel/afterattack(atom/target, mob/living/carbon/user, proximity)
	if(!proximity)
		return
	if(isliving(target))
		var/mob/living/L = target
		L.apply_damage(30, BURN)
	. = ..()
