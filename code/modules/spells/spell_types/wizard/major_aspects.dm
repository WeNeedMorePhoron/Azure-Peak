// Major Aspect definitions. See magic_aspect.dm for the base datum.

/datum/magic_aspect/pyromancy
	name = "Pyromancy"
	latin_name = "Maior Aspectus Ignis"
	desc = "TODO"
	fluff_desc = "TODO"
	aspect_type = ASPECT_MAJOR
	attuned_name = ASPECT_NAME_PYROMANCY
	school_color = GLOW_COLOR_FIRE
	countersynergy = list(/datum/magic_aspect/cryomancy)
	binding_chants = list(
		"TODO",
	)
	unbinding_chants = list(
		"TODO",
	)
	fixed_spells = list(
		/datum/action/cooldown/spell/projectile/spitfire,
		/datum/action/cooldown/spell/projectile/fireball,
		/datum/action/cooldown/spell/fire_blast,
		/datum/action/cooldown/spell/fire_curtain,
	)
	variants = list(
		"mastery" = list(
			/datum/action/cooldown/spell/projectile/fireball = /datum/action/cooldown/spell/projectile/fireball/greater,
		),
		"grenzelhoftian" = list(
			/datum/action/cooldown/spell/projectile/fireball = /datum/action/cooldown/spell/projectile/fireball/artillery,
		),
	)

/datum/magic_aspect/cryomancy
	name = "Cryomancy"
	latin_name = "Maior Aspectus Glaciei"
	desc = "TODO"
	fluff_desc = "TODO"
	aspect_type = ASPECT_MAJOR
	attuned_name = ASPECT_NAME_CRYOMANCY
	school_color = GLOW_COLOR_ICE
	countersynergy = list(/datum/magic_aspect/pyromancy)
	binding_chants = list(
		"TODO",
	)
	unbinding_chants = list(
		"TODO",
	)
	fixed_spells = list(
		/datum/action/cooldown/spell/projectile/frost_bolt,
		/datum/action/cooldown/spell/frost_stream,
		/datum/action/cooldown/spell/snap_freeze,
		/datum/action/cooldown/spell/hailstorm,
	)

/datum/magic_aspect/fulgurmancy
	name = "Fulgurmancy"
	latin_name = "Maior Aspectus Fulminis"
	desc = "TODO"
	fluff_desc = "TODO"
	aspect_type = ASPECT_MAJOR
	attuned_name = ASPECT_NAME_FULGURMANCY
	school_color = GLOW_COLOR_LIGHTNING
	binding_chants = list(
		"TODO",
	)
	unbinding_chants = list(
		"TODO",
	)
	fixed_spells = list(
		/datum/action/cooldown/spell/projectile/shock,
		/datum/action/cooldown/spell/projectile/lightning_bolt,
		/datum/action/cooldown/spell/heavens_strike,
		/datum/action/cooldown/spell/thunderstrike,
	)

/datum/magic_aspect/geomancy
	name = "Geomancy"
	latin_name = "Maior Aspectus Terrae"
	desc = "TODO"
	fluff_desc = "TODO"
	aspect_type = ASPECT_MAJOR
	attuned_name = ASPECT_NAME_GEOMANCY
	school_color = GLOW_COLOR_EARTHEN
	binding_chants = list(
		"TODO",
	)
	unbinding_chants = list(
		"TODO",
	)
	fixed_spells = list(
		/datum/action/cooldown/spell/projectile/gravel_blast,
		/datum/action/cooldown/spell/projectile/boulder_strike,
		/datum/action/cooldown/spell/ensnare,
		/datum/action/cooldown/spell/earthen_wall,
	)

/datum/magic_aspect/kinesis
	name = "Kinesis"
	latin_name = "Maior Aspectus Vis"
	desc = "TODO"
	fluff_desc = "TODO"
	aspect_type = ASPECT_MAJOR
	attuned_name = ASPECT_NAME_KINESIS
	school_color = GLOW_COLOR_KINESIS
	binding_chants = list(
		"TODO",
	)
	unbinding_chants = list(
		"TODO",
	)
	fixed_spells = list(
		/datum/action/cooldown/spell/projectile/soulshot,
		/datum/action/cooldown/spell/projectile/fetch,
		/datum/action/cooldown/spell/projectile/repel,
		/datum/action/cooldown/spell/repulse,
		/datum/action/cooldown/spell/gravity,
	)

/datum/magic_aspect/augmentation
	name = "Augmentation"
	latin_name = "Maior Aspectus Augmenti"
	desc = "TODO"
	fluff_desc = "TODO"
	aspect_type = ASPECT_MAJOR
	attuned_name = ASPECT_NAME_AUGMENTATION
	school_color = GLOW_COLOR_BUFF
	binding_chants = list(
		"TODO",
	)
	unbinding_chants = list(
		"TODO",
	)
	fixed_spells = list(
		/datum/action/cooldown/spell/projectile/soulshot,
	)
	pointbuy_budget = 12
	pointbuy_spells = list(
		/datum/action/cooldown/spell/haste,
		/datum/action/cooldown/spell/darkvision,
		/datum/action/cooldown/spell/stoneskin,
		/datum/action/cooldown/spell/hawks_eyes,
		/datum/action/cooldown/spell/giants_strength,
		/datum/action/cooldown/spell/fortitude,
		/datum/action/cooldown/spell/guidance,
		/datum/action/cooldown/spell/featherfall,
		/datum/action/cooldown/spell/enlarge,
		/datum/action/cooldown/spell/leap,
		/datum/action/cooldown/spell/nondetection,
		// 1-cost utility filler
		/datum/action/cooldown/spell/light,
		/datum/action/cooldown/spell/mending,
		/datum/action/cooldown/spell/create_campfire,
		/obj/effect/proc_holder/spell/self/message,
	)

/datum/magic_aspect/ferramancy
	name = "Ferramancy"
	latin_name = "Maior Aspectus Ferri"
	desc = "TODO"
	fluff_desc = "TODO"
	aspect_type = ASPECT_MAJOR
	attuned_name = ASPECT_NAME_FERRAMANCY
	school_color = GLOW_COLOR_METAL
	binding_chants = list(
		"TODO",
	)
	unbinding_chants = list(
		"TODO",
	)
	fixed_spells = list(
		/datum/action/cooldown/spell/projectile/iron_tempest,
		/datum/action/cooldown/spell/blade_burst,
		/datum/action/cooldown/spell/iron_skin,
		/datum/action/cooldown/spell/arcyne_forge,
	)
	choice_spells = list(
		/datum/action/cooldown/spell/projectile/stygian_efflorescence,
		/datum/action/cooldown/spell/projectile/arcyne_lance,
	)
