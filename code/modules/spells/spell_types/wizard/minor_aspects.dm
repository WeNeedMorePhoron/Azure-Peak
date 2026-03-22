/datum/magic_aspect/artifice
	name = "Artifice"
	latin_name = "Minor Aspectus Artificii"
	desc = "TODO"
	aspect_type = ASPECT_MINOR
	school_color = GLOW_COLOR_METAL
	// English: "Grant me the craftsman's eye." | Latin: "Craft, attend me" (Artificium, mihi adesse)
	binding_chants = list(
		"Grant me the craftsman's eye.",
		"Artificium, mihi adesse!",
	)
	// English: "I set down the craftsman's tools." | Latin: "Craft, leave me" (Artificium, me relinquere)
	unbinding_chants = list(
		"I set down the craftsman's tools.",
		"Artificium, me relinquere!",
	)
	fixed_spells = list(
		/datum/action/cooldown/spell/arcyne_forge,
	)

/datum/magic_aspect/exowardry
	name = "Exowardry"
	latin_name = "Minor Aspectus Exotutelae"
	desc = "TODO"
	aspect_type = ASPECT_MINOR
	school_color = GLOW_COLOR_ARCANE
	// English: "Let me raise walls against my foes." | Latin: "Outer ward, attend me" (Exotutela, mihi adesse)
	binding_chants = list(
		"Let me raise walls against my foes.",
		"Exotutela, mihi adesse!",
	)
	// English: "I lower the walls I have raised." | Latin: "Outer ward, leave me" (Exotutela, me relinquere)
	unbinding_chants = list(
		"I lower the walls I have raised.",
		"Exotutela, me relinquere!",
	)
	fixed_spells = list(
		/datum/action/cooldown/spell/forcewall,
	)

/datum/magic_aspect/aegiscraft
	name = "Aegiscraft"
	latin_name = "Minor Aspectus Aegidis"
	desc = "TODO"
	aspect_type = ASPECT_MINOR
	school_color = GLOW_COLOR_ARCANE
	// English: "Let me bear the arcyne shield." | Latin: "Aegis, attend me" (Aegis, mihi adesse)
	binding_chants = list(
		"Let me bear the arcyne shield.",
		"Aegis, mihi adesse!",
	)
	// English: "I set aside the shield." | Latin: "Aegis, leave me" (Aegis, me relinquere)
	unbinding_chants = list(
		"I set aside the shield.",
		"Aegis, me relinquere!",
	)
	fixed_spells = list(
		/datum/action/cooldown/spell/conjure_aegis,
	)

/datum/magic_aspect/displacement
	name = "Displacement"
	latin_name = "Minor Aspectus Translationis"
	desc = "TODO"
	aspect_type = ASPECT_MINOR
	school_color = GLOW_COLOR_DISPLACEMENT
	// English: "Let me step between the spaces." | Latin: "Passage, attend me" (Translatio, mihi adesse)
	binding_chants = list(
		"Let me step between the spaces.",
		"Translatio, mihi adesse!",
	)
	// English: "I close the paths I have opened." | Latin: "Passage, leave me" (Translatio, me relinquere)
	unbinding_chants = list(
		"I close the paths I have opened.",
		"Translatio, me relinquere!",
	)
	choice_spells = list(
		/datum/action/cooldown/spell/blink,
		/datum/action/cooldown/spell/repulse,
	)

/datum/magic_aspect/autowardry
	name = "Autowardry"
	latin_name = "Minor Aspectus Autotutelae"
	desc = "TODO"
	aspect_type = ASPECT_MINOR
	school_color = GLOW_COLOR_METAL
	// English: "Let me clad myself in arcyne." | Latin: "Inner ward, attend me" (Autotutela, mihi adesse)
	binding_chants = list(
		"Let me clad myself in arcyne.",
		"Autotutela, mihi adesse!",
	)
	// English: "I shed the arcyne mantle." | Latin: "Inner ward, leave me" (Autotutela, me relinquere)
	unbinding_chants = list(
		"I shed the arcyne mantle.",
		"Autotutela, me relinquere!",
	)
	choice_spells = list(
		/datum/action/cooldown/spell/conjure_armor/dragonhide,
		/datum/action/cooldown/spell/conjure_armor/crystalhide,
	)

/datum/magic_aspect/lesser_augmentation
	name = "Lesser Augmentation"
	latin_name = "Minor Aspectus Augmenti"
	desc = "TODO"
	aspect_type = ASPECT_MINOR
	school_color = GLOW_COLOR_BUFF
	// English: "Let me refine what is given." | Latin: "Enhancement, attend me" (Augmentum, mihi adesse)
	binding_chants = list(
		"Let me refine what is given.",
		"Augmentum, mihi adesse!",
	)
	// English: "I release the refinements upon me." | Latin: "Enhancement, leave me" (Augmentum, me relinquere)
	unbinding_chants = list(
		"I release the refinements upon me.",
		"Augmentum, me relinquere!",
	)
	pointbuy_budget = 4
	// Budget: 1x 3-cost or 2x 2-cost or 1x 2-cost + fillers
	pointbuy_spells = list(
		/datum/action/cooldown/spell/haste,
		/datum/action/cooldown/spell/darkvision,
		/datum/action/cooldown/spell/stoneskin,
		/datum/action/cooldown/spell/hawks_eyes,
		/datum/action/cooldown/spell/giants_strength,
		/datum/action/cooldown/spell/guidance,
		/datum/action/cooldown/spell/featherfall,
		/datum/action/cooldown/spell/leap,
		/datum/action/cooldown/spell/nondetection,
		// 1-cost utility filler
		/datum/action/cooldown/spell/light,
		/datum/action/cooldown/spell/mending,
		/datum/action/cooldown/spell/create_campfire,
	)

/datum/magic_aspect/illusion
	name = "Illusion"
	latin_name = "Minor Aspectus Illusio"
	desc = "TODO"
	aspect_type = ASPECT_MINOR
	school_color = GLOW_COLOR_ILLUSION
	// English: "Let me weave what is not there." | Latin: "Illusion, attend me" (Illusio, mihi adesse)
	binding_chants = list(
		"Let me weave what is not there.",
		"Illusio, mihi adesse!",
	)
	// English: "I unravel the veil I have spun." | Latin: "Illusion, leave me" (Illusio, me relinquere)
	unbinding_chants = list(
		"I unravel the veil I have spun.",
		"Illusio, me relinquere!",
	)
	fixed_spells = list(
		/obj/effect/proc_holder/spell/invoked/invisibility,
	)

/datum/magic_aspect/hearthcraft
	name = "Hearthcraft"
	latin_name = "Minor Aspectus Domus"
	desc = "TODO"
	aspect_type = ASPECT_MINOR
	school_color = GLOW_COLOR_HEARTH
	// English: "Let me tend the hearth and home." | Latin: "Hearth, attend me" (Domus, mihi adesse)
	binding_chants = list(
		"Let me tend the hearth and home.",
		"Domus, mihi adesse!",
	)
	// English: "I let the hearthfire fade." | Latin: "Hearth, leave me" (Domus, me relinquere)
	unbinding_chants = list(
		"I let the hearthfire fade.",
		"Domus, me relinquere!",
	)
	fixed_spells = list(
		/datum/action/cooldown/spell/great_shelter,
		/datum/action/cooldown/spell/create_campfire,
	)

/datum/magic_aspect/hex
	name = "Hex"
	latin_name = "Minor Aspectus Maleficii"
	desc = "TODO"
	aspect_type = ASPECT_MINOR
	school_color = GLOW_COLOR_HEX
	// English: "Let me speak the crooked word." | Latin: "Hex, attend me" (Maleficium, mihi adesse)
	binding_chants = list(
		"Let me speak the crooked word.",
		"Maleficium, mihi adesse!",
	)
	// English: "I unsay the crooked word." | Latin: "Hex, leave me" (Maleficium, me relinquere)
	unbinding_chants = list(
		"I unsay the crooked word.",
		"Maleficium, me relinquere!",
	)
	fixed_spells = list(
		/datum/action/cooldown/spell/wither,
	)
