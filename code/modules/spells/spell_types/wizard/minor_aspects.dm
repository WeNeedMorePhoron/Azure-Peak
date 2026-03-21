// Minor Aspect definitions. See magic_aspect.dm for the base datum.

/datum/magic_aspect/artifice
	name = "Artifice"
	latin_name = "Minor Aspectus Artificii"
	desc = "TODO"
	aspect_type = ASPECT_MINOR
	school_color = GLOW_COLOR_METAL
	binding_chants = list(
		"TODO",
	)
	unbinding_chants = list(
		"TODO",
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
	binding_chants = list(
		"TODO",
	)
	unbinding_chants = list(
		"TODO",
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
	binding_chants = list(
		"TODO",
	)
	unbinding_chants = list(
		"TODO",
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
	binding_chants = list(
		"TODO",
	)
	unbinding_chants = list(
		"TODO",
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
	binding_chants = list(
		"TODO",
	)
	unbinding_chants = list(
		"TODO",
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
	binding_chants = list(
		"TODO",
	)
	unbinding_chants = list(
		"TODO",
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
	binding_chants = list(
		"TODO",
	)
	unbinding_chants = list(
		"TODO",
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
	binding_chants = list(
		"TODO",
	)
	unbinding_chants = list(
		"TODO",
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
	binding_chants = list(
		"TODO",
	)
	unbinding_chants = list(
		"TODO",
	)
	fixed_spells = list(
		/datum/action/cooldown/spell/wither,
	)
