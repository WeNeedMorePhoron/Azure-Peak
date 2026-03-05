/*
 * ========== Leyline Encounter Rituals ==========
 *
 * The core mage gameplay loop. Mages find leylines out in the world, draw summoning
 * circles near them, and fight whatever comes through the veil. This forces mages out
 * of the tower and into dangerous territory where other players can see and interact
 * with the ritual (the chanting is loud and visible).
 *
 * Flow: find leyline -> draw circle -> click circle -> pick ritual -> chant -> fight.
 * No material cost — the circle tier, veil attunement, and the fight itself IS the cost.
 * Exception: the Void Dragon ritual requires 5 runed artifacts (the only summoning with a material gate).
 * Since charges are limited, you are expected to go out to the good leylines, not camp tamed ones.
 *
 * Attunement: mages gain dayspassed + 1 charges per week (max 5), each ritual costs 1.
 * Day gate: T1-T2 always available, T3 from day 3, T4 from day 4, T5 from day 5.
 * See leylines.dm for charge and gating implementation.
 *
 * Alignment:
 *   Each ritual and leyline has an alignment. Matching = full mob count.
 *   Wrong alignment = -1 mob (primary reduced first, then secondary if primary is already 1).
 *   Neutral leylines (tamed) are not aligned with anything — always wrong, always -1.
 *   This means tamed leylines give the guaranteed minimum (2 mobs for T1) as training wheels.
 *   Powerful leylines (Bog) always give +1 primary independent of alignment penalty,
 *   so wrong alignment in Bog nets to the same as a normal aligned leyline.
 *
 * Composition: T1-T2 = 3 base primary. T3 = 2 primary + 2 secondary. T4 = 1 primary + 3 secondary.
 * Gone wrong: flat 33% chance, +2 extra mobs. More risk, more reward. Bring friends.
 *
 * Chants: Latin/English alternating pairs, 2 seconds per line, tier scales the count.
 *   T4/T5 add secondary chants — other nearby invokers respond (call and response).
 *   Final line is always realm-specific "Evoca et [verb]!"
 *   Chanting is loud (range 14) and visible, drawing attention from other players.
 */

/datum/runeritual/summoning/leyline_encounter
	name = "leyline encounter parent"
	blacklisted = TRUE
	required_atoms = list()
	var/alignment = "neutral"
	var/list/primary_mobs = list()
	var/list/secondary_mobs = list()
	var/base_primary_count = 3
	var/base_secondary_count = 0
	var/list/gone_wrong_mobs = list()
	var/gone_wrong_extra = 2
	var/list/chants = list("Evoca!")
	var/list/secondary_chants = list() // T4/T5 only — other invokers respond in Latin (call and response)

// ----- Infernal -----

/datum/runeritual/summoning/leyline_encounter/infernal_t1
	name = "Lesser Ritual of Infernal Intrusion"
	desc = "Breach the veil and summon imps." 
	blacklisted = FALSE
	tier = 1
	alignment = "infernal"
	primary_mobs = list(/mob/living/simple_animal/hostile/retaliate/rogue/infernal/imp)
	base_primary_count = 3
	gone_wrong_mobs = list(/mob/living/simple_animal/hostile/retaliate/rogue/infernal/imp)
	chants = list("Aperio portam ignis.", "Break free! Come to me!")

/datum/runeritual/summoning/leyline_encounter/infernal_t2
	name = "Ordinary Ritual of Infernal Incursion"
	desc = "Reach deeper into the infernal realm and summon hellhounds!"
	blacklisted = FALSE
	tier = 2
	alignment = "infernal"
	primary_mobs = list(/mob/living/simple_animal/hostile/retaliate/rogue/infernal/hellhound)
	base_primary_count = 3
	gone_wrong_mobs = list(/mob/living/simple_animal/hostile/retaliate/rogue/infernal/imp)
	chants = list("Aperio portam ignis.", "Break free! Come to me!", "Sanguis ardet, vincula franguntur.", "Burn hotter! Strain against the veil!")

/datum/runeritual/summoning/leyline_encounter/infernal_t3
	name = "Greater Ritual of Infernal Invasion"
	desc = "Tear open the veil of the infernal realm, and summon infernal watchers!"
	blacklisted = FALSE
	tier = 3
	alignment = "infernal"
	primary_mobs = list(/mob/living/simple_animal/hostile/retaliate/rogue/infernal/watcher)
	secondary_mobs = list(/mob/living/simple_animal/hostile/retaliate/rogue/infernal/hellhound)
	base_primary_count = 2
	base_secondary_count = 2
	gone_wrong_mobs = list(/mob/living/simple_animal/hostile/retaliate/rogue/infernal/imp)
	chants = list("Aperio portam ignis.", "Break free! Come to me!", "Sanguis ardet, vincula franguntur.", "Burn hotter! Strain against the veil!", "Voluntas mea lex est.", "Submit! You are bound to me!")

/datum/runeritual/summoning/leyline_encounter/infernal_t4
	name = "Grand Ritual of Infernal Inversion"
	desc = "Inverse the veil that holds the plane apart, summoning an archfiend!"
	blacklisted = FALSE
	tier = 4
	alignment = "infernal"
	primary_mobs = list(/mob/living/simple_animal/hostile/retaliate/rogue/infernal/fiend)
	secondary_mobs = list(/mob/living/simple_animal/hostile/retaliate/rogue/infernal/watcher)
	base_primary_count = 1
	base_secondary_count = 3
	gone_wrong_mobs = list(/mob/living/simple_animal/hostile/retaliate/rogue/infernal/hellhound)
	chants = list("Aperio portam ignis.", "Break free! Come to me!", "Sanguis ardet, vincula franguntur.", "Burn hotter! Strain against the veil!", "Voluntas mea lex est.", "Submit! You are bound to me!", "Infernus obedit.", "Kneel before my flame!")
	secondary_chants = list("Ignis!", "Ignis!", "Furor!", "Furor!", "Burn! Submit to my will!", "Evoca et Incende!")

// ----- Fae -----

/datum/runeritual/summoning/leyline_encounter/fae_t1
	name = "Lesser Ritual of Fae Frolic" // was: "Lesser Ritual of Fae Flourishing"
	desc = "Lure fae sprites through the veil."
	blacklisted = FALSE
	tier = 1
	alignment = "fae"
	primary_mobs = list(/mob/living/simple_animal/hostile/retaliate/rogue/fae/sprite)
	base_primary_count = 3
	gone_wrong_mobs = list(/mob/living/simple_animal/hostile/retaliate/rogue/fae/sprite)
	chants = list("Flores aperiuntur.", "Come! Playful fae!")

/datum/runeritual/summoning/leyline_encounter/fae_t2
	name = "Ordinary Ritual of Fae Fluttering"
	desc = "Flutter the arcyne leyline to lure playful glimmerwings through the veil."
	blacklisted = FALSE
	tier = 2
	alignment = "fae"
	primary_mobs = list(/mob/living/simple_animal/hostile/retaliate/rogue/fae/glimmerwing)
	base_primary_count = 3
	gone_wrong_mobs = list(/mob/living/simple_animal/hostile/retaliate/rogue/fae/sprite)
	chants = list("Flores aperiuntur.", "Come! Playful fae!", "Silva cantat, folia tremunt.", "Faster! Spin and flutter!")

/datum/runeritual/summoning/leyline_encounter/fae_t3
	name = "Greater Ritual of Fae Frenzy"
	desc = "Disrupts the veil to lure dryads through the veil to defeat you." 
	blacklisted = FALSE
	tier = 3
	alignment = "fae"
	primary_mobs = list(/mob/living/simple_animal/hostile/retaliate/rogue/fae/dryad)
	secondary_mobs = list(/mob/living/simple_animal/hostile/retaliate/rogue/fae/glimmerwing)
	base_primary_count = 2
	base_secondary_count = 2
	gone_wrong_mobs = list(/mob/living/simple_animal/hostile/retaliate/rogue/fae/sprite)
	chants = list("Flores aperiuntur.", "Come! Playful fae!", "Silva cantat, folia tremunt.", "Faster! Spin and flutter!", "Natura ipsa furit.", "No more games! Show your fury!")

/datum/runeritual/summoning/leyline_encounter/fae_t4
	name = "Grand Ritual of Fae Fury"
	desc = "Rend the balanace of the fae realm asunder with uncontrolled arcyne energy, attracting the wrath of a sylph and their followers!"
	blacklisted = FALSE
	tier = 4
	alignment = "fae"
	primary_mobs = list(/mob/living/simple_animal/hostile/retaliate/rogue/fae/sylph)
	secondary_mobs = list(/mob/living/simple_animal/hostile/retaliate/rogue/fae/dryad)
	base_primary_count = 1
	base_secondary_count = 3
	gone_wrong_mobs = list(/mob/living/simple_animal/hostile/retaliate/rogue/fae/glimmerwing)
	chants = list("Flores aperiuntur.", "Come! Playful fae!", "Silva cantat, folia tremunt.", "Faster! Spin and flutter!", "Natura ipsa furit.", "No more games! Show your fury!", "Furor silvae descendit.", "Unleash the wrath of the wild!")
	secondary_chants = list("Florete!", "Florete!", "Furiae!", "Furiae!", "No more games! Show your wrath!", "Evoca et Cresce!")

// ----- Earthen -----

/datum/runeritual/summoning/leyline_encounter/earthen_t1
	name = "Lesser Ritual of Earthen Emergence"
	desc = "Imbue energy into the earthen realm, summoning elemental crawlers."
	blacklisted = FALSE
	tier = 1
	alignment = "elemental"
	primary_mobs = list(/mob/living/simple_animal/hostile/retaliate/rogue/elemental/crawler)
	base_primary_count = 3
	gone_wrong_mobs = list(/mob/living/simple_animal/hostile/retaliate/rogue/elemental/crawler)
	chants = list("Terra audit vocem meam.", "Stir! Rise from the deep!")

/datum/runeritual/summoning/leyline_encounter/earthen_t2
	name = "Ordinary Ritual of Earthen Eruption"
	desc = "Pour forth arcyne energy into the earthen realm, summoning wardens."
	blacklisted = FALSE
	tier = 2
	alignment = "elemental"
	primary_mobs = list(/mob/living/simple_animal/hostile/retaliate/rogue/elemental/warden)
	base_primary_count = 3
	gone_wrong_mobs = list(/mob/living/simple_animal/hostile/retaliate/rogue/elemental/crawler)
	chants = list("Terra audit vocem meam.", "Stir! Rise from the deep!", "Fundamenta tremunt.", "Crack open! Shatter the stone!")

/datum/runeritual/summoning/leyline_encounter/earthen_t3
	name = "Greater Ritual of Earthen Earthquake"
	desc = "Shatters the veil with a surge of arcyne energy, summoning behemoths from the earthen realm!"
	blacklisted = FALSE
	tier = 3
	alignment = "elemental"
	primary_mobs = list(/mob/living/simple_animal/hostile/retaliate/rogue/elemental/behemoth)
	secondary_mobs = list(/mob/living/simple_animal/hostile/retaliate/rogue/elemental/warden)
	base_primary_count = 2
	base_secondary_count = 2
	gone_wrong_mobs = list(/mob/living/simple_animal/hostile/retaliate/rogue/elemental/crawler)
	chants = list("Terra audit vocem meam.", "Stir! Rise from the deep!", "Fundamenta tremunt.", "Crack open! Shatter the stone!", "Mons ipse obedit.", "Erupt! Swallow the ground whole!")

/datum/runeritual/summoning/leyline_encounter/earthen_t4
	name = "Grand Ritual of Earthen Engulfment"
	desc = "Rend the veil asunder and summon a colossi and its followers!"
	blacklisted = FALSE
	tier = 4
	alignment = "elemental"
	primary_mobs = list(/mob/living/simple_animal/hostile/retaliate/rogue/elemental/colossus)
	secondary_mobs = list(/mob/living/simple_animal/hostile/retaliate/rogue/elemental/behemoth)
	base_primary_count = 1
	base_secondary_count = 3
	gone_wrong_mobs = list(/mob/living/simple_animal/hostile/retaliate/rogue/elemental/warden)
	chants = list("Terra audit vocem meam.", "Stir! Rise from the deep!", "Fundamenta tremunt.", "Crack open! Shatter the stone!", "Mons ipse obedit.", "Erupt! Swallow the ground whole!", "Ruina totalis.", "Crush everything beneath you!")
	secondary_chants = list("Ruina!", "Ruina!", "Surgite!", "Surgite!", "Shatter! Break the world open!", "Evoca et Surge!")

// ----- Leyline (Fixed T2) -----

/datum/runeritual/summoning/leyline_encounter/leyline_t2
	name = "Ordinary Ritual of Lycan Luring"
	desc = "Channel raw leyline energy to lure the lycans that dwell within"
	blacklisted = FALSE
	tier = 2
	alignment = "leyline"
	primary_mobs = list(/mob/living/simple_animal/hostile/retaliate/rogue/leylinelycan)
	base_primary_count = 3
	gone_wrong_mobs = list(/mob/living/simple_animal/hostile/retaliate/rogue/leylinelycan)
	chants = list("Nexus patet.", "Come forth! Show yourselves!", "Vis cruda fluit.", "Hunt! The veil is thin!")

// ----- Void (Fixed T2) — spawns mob form directly, no dormant obelisk phase -----

/datum/runeritual/summoning/leyline_encounter/void_t2
	name = "Ordinary Ritual of Void Vexation"
	desc = "Peer into the void and provoke what lurks beyond. KNOWLEDGE KNOWLEDGE KNOWLEDGE."
	blacklisted = FALSE
	tier = 2
	alignment = "void"
	primary_mobs = list(/mob/living/simple_animal/hostile/retaliate/rogue/voidstoneobelisk)
	base_primary_count = 3
	gone_wrong_mobs = list(/mob/living/simple_animal/hostile/retaliate/rogue/voidstoneobelisk)
	chants = list("Vacuum spectat.", "See me! Turn your gaze!", "Nihil respondet.", "Answer me! I know you hear!")

// ----- Void Dragon (Fixed T5, requires Powerful leyline) -----

/datum/runeritual/summoning/leyline_encounter/void_dragon
	name = "Supreme Ritual of Void Dragon Calling"
	desc = "Tear open the deepest layer of the veil, reaching beyond all planes. There is only one thing that dwells there."
	blacklisted = FALSE
	tier = 5
	alignment = "void"
	required_atoms = list(/obj/item/magic/artifact = 5)
	primary_mobs = list(/mob/living/simple_animal/hostile/retaliate/rogue/voiddragon)
	base_primary_count = 1
	gone_wrong_extra = 0
	chants = list("Vacuum spectat.", "See me! Turn your gaze!", "Nihil respondet.", "Answer me! I know you hear!", "Ultra omnia voco.", "Beyond every plane! Past every boundary!", "Draco vacui surgit.", "RISE! Devour the world!")
	secondary_chants = list("Vacuitas!", "Vacuitas!", "Finis!", "Finis!", "Nihil!", "Nihil!", "Beyond all things! Rise and devour!", "Evoca et Devora!")

/datum/runeritual/summoning/leyline_encounter/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	var/obj/structure/leyline/leyline
	for(var/obj/structure/leyline/L in range(5, loc))
		leyline = L
		break
	if(!leyline)
		to_chat(user, span_warning("There is no leyline nearby. Draw your circle closer to a leyline."))
		return FALSE
	if(!leyline.has_uses_remaining())
		to_chat(user, span_warning("This leyline has been exhausted for todae."))
		return FALSE
	if(get_leyline_charges(user) <= 0)
		to_chat(user, span_boldwarning("You've reached into the veil too many times this week. Rest, or you will be annihilated."))
		return FALSE
	if(tier > get_max_leyline_tier())
		to_chat(user, span_warning("Tis too early in the week. The power of the leylines grows and waxes. Wait until later for such powerful summoning.")) // was: "
		return FALSE
	if(leyline.max_tier && tier > leyline.max_tier)
		to_chat(user, span_warning("This leyline is too weak for a ritual of this circle"))
		return FALSE

	var/primary_count = base_primary_count
	var/secondary_count = base_secondary_count
	var/aligned = (leyline.alignment == alignment)

	// Bog always gives +1 primary, independent of alignment penalty
	if(leyline.leyline_type == "powerful")
		primary_count += 1

	// Wrong alignment: -1 mob, reduce primary first then secondary
	if(!aligned)
		if(primary_count > 1)
			primary_count -= 1
		else
			secondary_count = max(secondary_count - 1, 0)

	var/gone_wrong = gone_wrong_extra > 0 && prob(33)
	var/extra_count = gone_wrong ? gone_wrong_extra : 0

	// Chant — loud and visible, this is what draws attention from other players
	user.visible_message(span_danger("You begin to chant, channeling energy into the leyline!"))
	playsound(loc, 'sound/magic/teleport_diss.ogg', 100, TRUE, 14)

	for(var/line in chants)
		user.say(line, language = /datum/language/common, ignore_spam = TRUE, forced = "cult invocation")
		if(!do_after(user, 2 SECONDS, target = leyline))
			to_chat(user, span_warning("The ritual is interrupted!"))
			return FALSE

	// T4/T5 call and response — other invokers chant back
	if(length(secondary_chants))
		var/list/other_invokers = list()
		for(var/mob/living/M in range(3, leyline))
			if(M == user)
				continue
			if(isarcyne(M) && M.stat == CONSCIOUS && M.can_speak())
				other_invokers += M
		for(var/line in secondary_chants)
			for(var/mob/living/invoker in other_invokers)
				invoker.say(line, language = /datum/language/common, ignore_spam = TRUE, forced = "cult invocation")
			if(!do_after(user, 2 SECONDS, target = leyline))
				to_chat(user, span_warning("The ritual is interrupted!"))
				return FALSE

	spend_leyline_charge(user)
	leyline.use_charge()

	var/list/spawn_turfs = get_encounter_turfs(loc, primary_count + secondary_count + extra_count)
	var/spawned = 0

	var/mob_type
	for(var/i in 1 to primary_count)
		if(spawned >= length(spawn_turfs))
			break
		spawned++
		mob_type = pick(primary_mobs)
		new mob_type(spawn_turfs[spawned])

	for(var/i in 1 to secondary_count)
		if(spawned >= length(spawn_turfs))
			break
		spawned++
		mob_type = pick(secondary_mobs)
		new mob_type(spawn_turfs[spawned])

	if(gone_wrong)
		user.visible_message(span_boldwarning("The ritual spirals out of control! More creatures pour through the breach!"))
		for(var/i in 1 to extra_count)
			if(spawned >= length(spawn_turfs))
				break
			spawned++
			mob_type = pick(gone_wrong_mobs)
			new mob_type(spawn_turfs[spawned])

	playsound(loc, 'sound/magic/cosmic_expansion.ogg', 100, TRUE, 14)
	user.visible_message(span_boldwarning("The veil tears open and creatures surge forth from beyond!"))
	return TRUE

/datum/runeritual/summoning/leyline_encounter/proc/get_encounter_turfs(turf/center, count)
	var/list/valid_turfs = list()
	for(var/turf/open/T in range(3, center))
		if(T.density)
			continue
		if(T == center)
			continue
		valid_turfs += T
	shuffle_inplace(valid_turfs)
	return valid_turfs.Copy(1, min(count + 1, length(valid_turfs) + 1))
