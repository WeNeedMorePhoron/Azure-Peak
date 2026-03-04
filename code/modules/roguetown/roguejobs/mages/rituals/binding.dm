/*
 * ========== Binding Rituals ==========
 *
 * The payoff for leyline encounters. Mages spend realm materials gathered from
 * killing summoned creatures to bind a single creature to their service.
 * Drawn on a Binding Array (T2) or Greater Binding Array (T4).
 *
 * Material costs are set so that binding requires roughly two successful
 * leyline encounters' worth of drops from the same tier. This means you
 * need to actually go out and fight before you can bind anything.
 *
 * The bound creature spawns pacified, godmoded, paralyzed, and red-tinted
 * via bind_ritual_mob — the summoning circle's "seal and release" flow
 * handles the rest (removing godmode, giving orders, etc).
 */

/datum/runeritual/binding
	name = "binding ritual parent"
	desc = "binding parent rituals."
	category = "Binding"
	blacklisted = TRUE
	var/mob_to_bind

/datum/runeritual/binding/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	if(!mob_to_bind)
		return FALSE
	var/mob/living/bound = bind_ritual_mob(user, loc, mob_to_bind)
	if(!bound)
		return FALSE
	to_chat(user, span_notice("The binding array flares with power as [bound] is pulled through the veil, shackled to your will."))
	playsound(loc, 'sound/magic/cosmic_expansion.ogg', 100, TRUE, 7)
	return TRUE

/datum/runeritual/binding/proc/bind_ritual_mob(mob/living/user, turf/loc, mob/living/mob_to_bind)
	var/mob/living/simple_animal/binded
	if(isliving(mob_to_bind))
		binded = mob_to_bind
	else
		binded = new mob_to_bind(loc)
		ADD_TRAIT(binded, TRAIT_PACIFISM, TRAIT_GENERIC)
		binded.status_flags += GODMODE
		binded.candodge = FALSE
		animate(binded, color = "#ff0000",time = 5)
		binded.move_resist = MOVE_FORCE_EXTREMELY_STRONG
		binded.binded = TRUE
		binded.SetParalyzed(900)
		return binded

// ----- Infernal Binding -----

/datum/runeritual/binding/infernal_t1
	name = "Bind Imp"
	desc = "Bind an infernal imp to your service."
	blacklisted = FALSE
	tier = 1
	mob_to_bind = /mob/living/simple_animal/hostile/retaliate/rogue/infernal/imp
	required_atoms = list(/obj/item/magic/infernal/ash = 12)

/datum/runeritual/binding/infernal_t2
	name = "Bind Hellhound"
	desc = "Bind an infernal hellhound to your service."
	blacklisted = FALSE
	tier = 2
	mob_to_bind = /mob/living/simple_animal/hostile/retaliate/rogue/infernal/hellhound
	required_atoms = list(/obj/item/magic/infernal/fang = 8)

/datum/runeritual/binding/infernal_t3
	name = "Bind Watcher"
	desc = "Bind an infernal watcher to your service."
	blacklisted = FALSE
	tier = 3
	mob_to_bind = /mob/living/simple_animal/hostile/retaliate/rogue/infernal/watcher
	required_atoms = list(/obj/item/magic/infernal/core = 4)

/datum/runeritual/binding/infernal_t4
	name = "Bind Fiend"
	desc = "Bind an infernal fiend to your service."
	blacklisted = FALSE
	tier = 4
	mob_to_bind = /mob/living/simple_animal/hostile/retaliate/rogue/infernal/fiend
	required_atoms = list(/obj/item/magic/infernal/flame = 2)

// ----- Fae Binding -----

/datum/runeritual/binding/fae_t1
	name = "Bind Sprite"
	desc = "Bind a fae sprite to your service."
	blacklisted = FALSE
	tier = 1
	mob_to_bind = /mob/living/simple_animal/hostile/retaliate/rogue/fae/sprite
	required_atoms = list(/obj/item/magic/fae/fairydust = 12)

/datum/runeritual/binding/fae_t2
	name = "Bind Glimmerwing"
	desc = "Bind a fae glimmerwing to your service."
	blacklisted = FALSE
	tier = 2
	mob_to_bind = /mob/living/simple_animal/hostile/retaliate/rogue/fae/glimmerwing
	required_atoms = list(/obj/item/magic/fae/iridescentscale = 8)

/datum/runeritual/binding/fae_t3
	name = "Bind Dryad"
	desc = "Bind a fae dryad to your service."
	blacklisted = FALSE
	tier = 3
	mob_to_bind = /mob/living/simple_animal/hostile/retaliate/rogue/fae/dryad
	required_atoms = list(/obj/item/magic/fae/heartwoodcore = 4)

/datum/runeritual/binding/fae_t4
	name = "Bind Sylph"
	desc = "Bind a fae sylph to your service."
	blacklisted = FALSE
	tier = 4
	mob_to_bind = /mob/living/simple_animal/hostile/retaliate/rogue/fae/sylph
	required_atoms = list(/obj/item/magic/fae/sylvanessence = 2)

// ----- Elemental Binding -----

/datum/runeritual/binding/elemental_t1
	name = "Bind Crawler"
	desc = "Bind an elemental crawler to your service."
	blacklisted = FALSE
	tier = 1
	mob_to_bind = /mob/living/simple_animal/hostile/retaliate/rogue/elemental/crawler
	required_atoms = list(/obj/item/magic/elemental/mote = 12)

/datum/runeritual/binding/elemental_t2
	name = "Bind Warden"
	desc = "Bind an elemental warden to your service."
	blacklisted = FALSE
	tier = 2
	mob_to_bind = /mob/living/simple_animal/hostile/retaliate/rogue/elemental/warden
	required_atoms = list(/obj/item/magic/elemental/shard = 8)

/datum/runeritual/binding/elemental_t3
	name = "Bind Behemoth"
	desc = "Bind an elemental behemoth to your service."
	blacklisted = FALSE
	tier = 3
	mob_to_bind = /mob/living/simple_animal/hostile/retaliate/rogue/elemental/behemoth
	required_atoms = list(/obj/item/magic/elemental/fragment = 4)

/datum/runeritual/binding/elemental_t4
	name = "Bind Colossus"
	desc = "Bind an elemental colossus to your service."
	blacklisted = FALSE
	tier = 4
	mob_to_bind = /mob/living/simple_animal/hostile/retaliate/rogue/elemental/colossus
	required_atoms = list(/obj/item/magic/elemental/relic = 2)
