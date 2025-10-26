/datum/coven/siren
	name = "Siren Blessing"
	desc = "Typically found in vampires who frequent the seas of Enigma, they've developed the ability to adapt much like sirens."
	icon_state = "melpominee"
	power_type = /datum/coven_power/siren

/datum/coven_power/siren
	name = "Siren Blessing power name"
	desc = "Siren Blessing power description"

//THE MISSING VOICE
/datum/coven_power/siren/the_missing_voice
	name = "The Missing Voice"
	desc = "Throw your voice to any place you can see."

	level = 1
	research_cost = 0
	check_flags = COVEN_CHECK_CONSCIOUS | COVEN_CHECK_CAPABLE | COVEN_CHECK_SPEAK
	target_type = TARGET_OBJ | TARGET_LIVING
	range = 7

	cooldown_length = 30 SECONDS

/datum/coven_power/siren/the_missing_voice/activate(atom/movable/target)
	. = ..()
	var/new_say = input(owner, "What will [target] say?") as null|text
	if(!new_say)
		return

	//prevent forceful emoting and whatnot
	new_say = trim(copytext_char(sanitize(new_say), 1, MAX_MESSAGE_LEN))
	if (findtext(new_say, "*"))
		to_chat(owner, span_danger("You can't force others to perform emotes!"))
		return

	if (CHAT_FILTER_CHECK(new_say))
		to_chat(owner, span_warning("That message contained a word prohibited in IC chat! Consider reviewing the server rules.\n<span replaceRegex='show_filtered_ic_chat'>\"[new_say]\"</span>"))
		SSblackbox.record_feedback("tally", "ic_blocked_words", 1, lowertext(config.ic_filter_regex.match))
		return

	target.say(message = new_say, forced = "melpominee 1")

	if (!isliving(target))
		return

	//viewers are able to detect if a person's words aren't their own
	var/base_difficulty = 10
	var/difficulty_malus = 0
	var/masked = FALSE
	if (ishuman(target)) //apply a malus and different text if victim's mouth isn't visible, and a malus if they're already typing
		var/mob/living/carbon/human/victim = target
		if ((victim.wear_mask?.flags_inv & HIDEFACE) && (victim.head?.flags_inv & HIDEFACE))
			masked = TRUE
			base_difficulty += 4
		if (victim.typing_indicator_current) //ugly way to check for if the victim is currently typing
			base_difficulty += 4

	for (var/mob/living/hearer in (oviewers(7, target) - owner))
		if (!hearer.client)
			continue
		difficulty_malus = 0
		if (get_dist(hearer, target) > 3)
			difficulty_malus += 2
		if (hearer.stat_roll(STATKEY_PER, 20 -( base_difficulty + difficulty_malus)))
			if (masked)
				to_chat(hearer, span_warning("[target]'s jaw isn't moving to match [target.p_their()] words."))
			else
				to_chat(hearer, span_warning("[target]'s lips aren't moving to match [target.p_their()] words."))

//PHANTOM SPEAKER
/datum/coven_power/siren/phantom_speaker
	name = "Phantom Speaker"
	desc = "Project your voice to anyone you've met, speaking to them from afar."

	level = 2
	research_cost = 1
	vitae_cost = 100
	check_flags = COVEN_CHECK_CONSCIOUS | COVEN_CHECK_SPEAK

	cooldown_length = 10 SECONDS

/datum/coven_power/siren/phantom_speaker/activate()
	. = ..()
	var/mob/living/target = input(owner, "Who will you project your voice to?") as null|mob in (GLOB.player_list - owner)
	if(!target)
		return

	var/input_message = input(owner, "What message will you project to them?") as null|text
	if (!input_message)
		return

	//sanitisation!
	input_message = trim(copytext_char(sanitize(input_message), 1, MAX_MESSAGE_LEN))
	if(CHAT_FILTER_CHECK(input_message))
		to_chat(owner, span_warning("That message contained a word prohibited in IC chat! Consider reviewing the server rules.\n<span replaceRegex='show_filtered_ic_chat'>\"[input_message]\"</span>"))
		SSblackbox.record_feedback("tally", "ic_blocked_words", 1, lowertext(config.ic_filter_regex.match))
		return

	var/language = owner.get_random_understood_language()
	var/message = owner.compose_message(owner, language, input_message, , list())
	to_chat(target, "<span class='purple'><i>You hear someone's voice in your head...</i></span>")
	target.Hear(message, target, language, input_message, , , )
	to_chat(owner, span_notice("You project your voice to [target]'s ears."))

//MADRIGAL
/datum/coven_power/siren/madrigal
	name = "Madrigal"
	desc = "Sing a siren song, calling all nearby to you."

	level = 3
	research_cost = 2
	vitae_cost = 200
	check_flags = COVEN_CHECK_CONSCIOUS | COVEN_CHECK_CAPABLE | COVEN_CHECK_IMMOBILE | COVEN_CHECK_SPEAK
	cooldown_length = 1 MINUTES
	duration_length = 2 SECONDS

/datum/coven_power/siren/madrigal/activate()
	. = ..()
	var/list/mobs_in_view = oviewers(4, owner)
	if(!LAZYLEN(mobs_in_view))
		deactivate()
		return

	for(var/mob/living/carbon/human/listener in mobs_in_view)
		if(listener.clan == owner.clan)
			continue

		listener.create_walk_to(2 SECONDS, owner)

		listener.remove_overlay(MUTATIONS_LAYER)
		var/mutable_appearance/song_overlay = mutable_appearance('icons/effects/clan.dmi', "song", -MUTATIONS_LAYER)
		listener.overlays_standing[MUTATIONS_LAYER] = song_overlay
		listener.apply_overlay(MUTATIONS_LAYER)

		addtimer(CALLBACK(src, PROC_REF(remove_effects), listener), 2 SECONDS)

/datum/coven_power/siren/madrigal/proc/remove_effects(mob/living/carbon/human/target)
	target?.remove_overlay(MUTATIONS_LAYER)

//SIREN'S BECKONING
/datum/coven_power/siren/sirens_beckoning
	name = "Siren's Beckoning"
	desc = "Sing an unearthly song to stun those around you."

	level = 4
	research_cost = 3
	vitae_cost = 250
	check_flags = COVEN_CHECK_CONSCIOUS | COVEN_CHECK_CAPABLE | COVEN_CHECK_IMMOBILE | COVEN_CHECK_SPEAK
	duration_length = 2 SECONDS
	cooldown_length = 2 MINUTES

/datum/coven_power/siren/sirens_beckoning/activate()
	. = ..()
	var/list/mobs_in_view = oviewers(4, owner)
	if(!LAZYLEN(mobs_in_view))
		deactivate()
		return

	for(var/mob/living/carbon/human/listener in mobs_in_view)
		if(listener.clan == owner.clan)
			continue

		listener.Stun(duration_length)

		listener.remove_overlay(MUTATIONS_LAYER)
		var/mutable_appearance/song_overlay = mutable_appearance('icons/effects/clan.dmi', "song", -MUTATIONS_LAYER)
		listener.overlays_standing[MUTATIONS_LAYER] = song_overlay
		listener.apply_overlay(MUTATIONS_LAYER)

		addtimer(CALLBACK(src, PROC_REF(remove_effects), listener), duration_length)

/datum/coven_power/siren/sirens_beckoning/proc/remove_effects(mob/living/carbon/human/target)
	target?.remove_overlay(MUTATIONS_LAYER)

//SHATTERING CRESCENDO
/datum/coven_power/siren/shattering_crescendo
	name = "Shattering Crescendo"
	desc = "Scream at an unnatural pitch, shattering the bodies of your enemies."

	level = 5
	research_cost = 4
	minimal_generation = GENERATION_ANCILLAE
	check_flags = COVEN_CHECK_CONSCIOUS | COVEN_CHECK_CAPABLE | COVEN_CHECK_IMMOBILE | COVEN_CHECK_SPEAK
	duration_length = 3 SECONDS
	cooldown_length = 30 SECONDS

/datum/coven_power/siren/shattering_crescendo/activate()
	. = ..()
	var/list/mobs_in_view = oviewers(7, owner)
	if(!LAZYLEN(mobs_in_view))
		deactivate()
		return

	for(var/mob/living/carbon/human/listener in mobs_in_view)
		if(listener.clan == owner.clan)
			continue

		listener.Stun(duration_length)
		listener.apply_damage(50, BRUTE, BODY_ZONE_HEAD)

		listener.remove_overlay(MUTATIONS_LAYER)
		var/mutable_appearance/song_overlay = mutable_appearance('icons/effects/clan.dmi', "song", -MUTATIONS_LAYER)
		listener.overlays_standing[MUTATIONS_LAYER] = song_overlay
		listener.apply_overlay(MUTATIONS_LAYER)

		addtimer(CALLBACK(src, PROC_REF(remove_effects), listener), duration_length)

/datum/coven_power/siren/shattering_crescendo/proc/remove_effects(mob/living/carbon/human/target)
	target?.remove_overlay(MUTATIONS_LAYER)
