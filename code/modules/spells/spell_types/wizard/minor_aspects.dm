// Minor Aspect definitions. See magic_aspect.dm for the base datum.

/datum/magic_aspect/artifice
	name = "Artifice"
	desc = "TODO"
	fluff_desc = "TODO"
	aspect_type = ASPECT_MINOR
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
	desc = "TODO"
	fluff_desc = "TODO"
	aspect_type = ASPECT_MINOR
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
	desc = "TODO"
	fluff_desc = "TODO"
	aspect_type = ASPECT_MINOR
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
	desc = "TODO"
	fluff_desc = "TODO"
	aspect_type = ASPECT_MINOR
	binding_chants = list(
		"TODO",
	)
	unbinding_chants = list(
		"TODO",
	)
	pointbuy_budget = 3
	pointbuy_spells = list(
		/obj/effect/proc_holder/spell/invoked/blink,
		/datum/action/cooldown/spell/repulse,
	)

/datum/magic_aspect/autowardry
	name = "Autowardry"
	desc = "TODO"
	fluff_desc = "TODO"
	aspect_type = ASPECT_MINOR
	binding_chants = list(
		"TODO",
	)
	unbinding_chants = list(
		"TODO",
	)
	pointbuy_budget = 4
	pointbuy_spells = list(
		/obj/effect/proc_holder/spell/self/conjure_armor/dragonhide,
		/obj/effect/proc_holder/spell/self/conjure_armor/crystalhide,
	)

/datum/magic_aspect/lesser_augmentation
	name = "Lesser Augmentation"
	desc = "TODO"
	fluff_desc = "TODO"
	aspect_type = ASPECT_MINOR
	binding_chants = list(
		"TODO",
	)
	unbinding_chants = list(
		"TODO",
	)
	pointbuy_budget = 4
	pointbuy_spells = list(
		/datum/action/cooldown/spell/haste,
		/datum/action/cooldown/spell/darkvision,
		/datum/action/cooldown/spell/longstrider,
		/datum/action/cooldown/spell/stoneskin,
		/datum/action/cooldown/spell/hawks_eyes,
		/datum/action/cooldown/spell/giants_strength,
		/datum/action/cooldown/spell/guidance,
		/datum/action/cooldown/spell/featherfall,
		/datum/action/cooldown/spell/leap,
		/datum/action/cooldown/spell/nondetection,
		// 1-cost utility filler
		/obj/effect/proc_holder/spell/self/light,
		/obj/effect/proc_holder/spell/invoked/mending,
		/obj/effect/proc_holder/spell/invoked/create_campfire,
	)

/datum/magic_aspect/illusion
	name = "Illusion"
	desc = "TODO"
	fluff_desc = "TODO"
	aspect_type = ASPECT_MINOR
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
	desc = "TODO"
	fluff_desc = "TODO"
	aspect_type = ASPECT_MINOR
	binding_chants = list(
		"TODO",
	)
	unbinding_chants = list(
		"TODO",
	)
	fixed_spells = list(
		/datum/action/cooldown/spell/great_shelter,
		/obj/effect/proc_holder/spell/invoked/create_campfire,
	)

/datum/magic_aspect/hex
	name = "Hex"
	desc = "TODO"
	fluff_desc = "TODO"
	aspect_type = ASPECT_MINOR
	binding_chants = list(
		"TODO",
	)
	unbinding_chants = list(
		"TODO",
	)
	fixed_spells = list(
		/datum/action/cooldown/spell/wither,
	)
