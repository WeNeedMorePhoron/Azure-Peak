// Major Aspect definitions. See magic_aspect.dm for the base datum.

/datum/magic_aspect/pyromancy
	name = "Pyromancy"
	desc = "TODO"
	fluff_desc = "TODO"
	aspect_type = ASPECT_MAJOR
	attuned_name = "Fire"
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
	prestige_upgrades = list(
		// TODO: Fireball -> Greater Fireball at T4
	)

/datum/magic_aspect/cryomancy
	name = "Cryomancy"
	desc = "TODO"
	fluff_desc = "TODO"
	aspect_type = ASPECT_MAJOR
	attuned_name = "Frost"
	school_color = GLOW_COLOR_ICE
	countersynergy = list(/datum/magic_aspect/pyromancy)
	binding_chants = list(
		"TODO",
	)
	unbinding_chants = list(
		"TODO",
	)
	fixed_spells = list(
		/obj/effect/proc_holder/spell/invoked/projectile/frostbolt,
		/obj/effect/proc_holder/spell/invoked/snap_freeze,
		// TODO: Ice Wall - Forcewall variant. Blocks LOS.
		// TODO: Frost Ball Bombardment?
	)

/datum/magic_aspect/fulgurmancy
	name = "Fulgurmancy"
	desc = "TODO"
	fluff_desc = "TODO"
	aspect_type = ASPECT_MAJOR
	attuned_name = "Storms"
	school_color = GLOW_COLOR_LIGHTNING
	binding_chants = list(
		"TODO",
	)
	unbinding_chants = list(
		"TODO",
	)
	fixed_spells = list(
		/datum/action/cooldown/spell/projectile/zap,
		/datum/action/cooldown/spell/projectile/lightning_bolt,
		/datum/action/cooldown/spell/heavens_strike,
		/datum/action/cooldown/spell/thunderstrike,
	)

/datum/magic_aspect/geomancy
	name = "Geomancy"
	desc = "TODO"
	fluff_desc = "TODO"
	aspect_type = ASPECT_MAJOR
	attuned_name = "Stone"
	school_color = GLOW_COLOR_METAL
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
	desc = "TODO"
	fluff_desc = "TODO"
	aspect_type = ASPECT_MAJOR
	attuned_name = "Force"
	school_color = GLOW_COLOR_ARCANE
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
	)

/datum/magic_aspect/augmentation
	name = "Augmentation"
	desc = "TODO"
	fluff_desc = "TODO"
	aspect_type = ASPECT_MAJOR
	attuned_name = "Enhancement"
	school_color = GLOW_COLOR_BUFF
	binding_chants = list(
		"TODO",
	)
	unbinding_chants = list(
		"TODO",
	)
	fixed_spells = list(
		/datum/action/cooldown/spell/projectile/arcynebolt,
	)
	pointbuy_budget = 12
	pointbuy_spells = list(
		/obj/effect/proc_holder/spell/invoked/haste,
		/obj/effect/proc_holder/spell/invoked/darkvision,
		/obj/effect/proc_holder/spell/invoked/longstrider,
		/obj/effect/proc_holder/spell/invoked/stoneskin,
		/obj/effect/proc_holder/spell/invoked/hawks_eyes,
		/obj/effect/proc_holder/spell/invoked/giants_strength,
		/obj/effect/proc_holder/spell/invoked/fortitude,
		/obj/effect/proc_holder/spell/invoked/guidance,
		/obj/effect/proc_holder/spell/invoked/featherfall,
		/obj/effect/proc_holder/spell/invoked/enlarge,
	)
