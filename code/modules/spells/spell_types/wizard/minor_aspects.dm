// Minor Aspect definitions. See magic_aspect.dm for the base datum.

/datum/magic_aspect/arcyne_forge
	name = "Arcyne Forge"
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
		/obj/effect/proc_holder/spell/invoked/conjure_weapon,
		/obj/effect/proc_holder/spell/invoked/enchant_weapon,
	)

/datum/magic_aspect/exowarding
	name = "Exowarding"
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
		/obj/effect/proc_holder/spell/invoked/forcewall,
		/obj/effect/proc_holder/spell/invoked/forcewall/greater,
	)

/datum/magic_aspect/autowarding
	name = "Autowarding"
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
		/obj/effect/proc_holder/spell/self/conjure_armor,
		// TODO: Conjure Force Ward - 150 dura, 6 WDef, 80 coverage shield
	)

/datum/magic_aspect/displacement
	name = "Displacement"
	desc = "TODO"
	fluff_desc = "TODO"
	aspect_type = ASPECT_MINOR
	school_color = GLOW_COLOR_DISPLACEMENT
	binding_chants = list(
		"TODO",
	)
	unbinding_chants = list(
		"TODO",
	)
	fixed_spells = list(
		/obj/effect/proc_holder/spell/invoked/blink,
		// TODO: Second displacement spell TBD
	)

/datum/magic_aspect/physicalwarding
	name = "Physicalwarding"
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
		/obj/effect/proc_holder/spell/invoked/haste,
		/obj/effect/proc_holder/spell/invoked/darkvision,
		/obj/effect/proc_holder/spell/invoked/longstrider,
		/obj/effect/proc_holder/spell/invoked/stoneskin,
		/obj/effect/proc_holder/spell/invoked/hawks_eyes,
		/obj/effect/proc_holder/spell/invoked/giants_strength,
		/obj/effect/proc_holder/spell/invoked/guidance,
		/obj/effect/proc_holder/spell/invoked/featherfall,
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
		/obj/effect/proc_holder/spell/invoked/wither,
		// TODO: Wither 2.0 rework
	)
