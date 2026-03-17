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
		/obj/effect/proc_holder/spell/invoked/projectile/spitfire,
		/datum/action/cooldown/spell/projectile/fireball,
		// TODO: Hellish Rebuke - Close range, charged projectile, repel 2 tiles, burn damage
		// TODO: 4th spell - possibly 5x5 AOE on ultra-high CD and stamina cost
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
		/obj/effect/proc_holder/spell/invoked/projectile/lightningbolt,
		/obj/effect/proc_holder/spell/invoked/thunderstrike,
		// TODO: Zap! - Hitscan, lowest burn efficiency, but instant
		// TODO: Heaven's Strike - Single tile, head-targeted, PVE powerhouse
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
		// TODO: Rock Sling - 7 tiles, 20*5 projectiles, first hit sets mob timer so subsequent hits deal half. Anti-group staple.
		/obj/effect/proc_holder/spell/invoked/ensnare,
		// TODO: Boulder Strike - Always arced, 2.5 speed, 120 center / 40 scatter, 20-30s CD
		// TODO: Earthen Wall - Durable forcewall, blocks caster too
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
		// TODO: Soulshot - Hitscan, 8s CD, 60-80 brute, no AP, no displacement. Raw eldritch blast.
		/obj/effect/proc_holder/spell/invoked/projectile/fetch,
		/obj/effect/proc_holder/spell/invoked/projectile/repel,
		/obj/effect/proc_holder/spell/invoked/repulse,
		// Fetch/Repel/Repulse on unified cooldown (~20s for Repulse)
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
