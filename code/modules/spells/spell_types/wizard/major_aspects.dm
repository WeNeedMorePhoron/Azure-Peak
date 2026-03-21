// Major Aspect definitions. See magic_aspect.dm for the base datum.

/datum/magic_aspect/pyromancy
	name = "Pyromancy"
	latin_name = "Maior Aspectus Ignis"
	desc = "The school of Pyromancy. Pyromancers open up with the raw destructive power of spitfire - burning one single target, using Fireball to strike multiple foes, and uses Fire Blast to push opponents off them and leave a lingering flame on the ground. Fire Curtain might be hard to score, but it can block off an entire place and melt anyone trying to go through it. It countersynergizes with Cryomancy and is incompatible - casting fire spell heat one's body up and having fire spells hit someone frozen will cause them to warm up."
	aspect_type = ASPECT_MAJOR
	attuned_name = ASPECT_NAME_PYROMANCY
	school_color = GLOW_COLOR_FIRE
	countersynergy = list(/datum/magic_aspect/cryomancy)
	// Latin 1: "I call upon the eternal flame" | English suggestions: "I implore the flame within to burn bright, rise!" / "I call the fire that sleeps in my soul, awaken!"
	// Latin 2: "Fire, bind yourself to me"
	binding_chants = list(
		"Invoco flammam aeternam!",
		"I implore the flame within to burn bright, rise!",
		"Ignis, in me ligare!",
	)
	// Latin 1: "I release the bound flame" | English suggestions: "I becalm the flame that dwells within, rest." / "I still the fire that burns in my heart, sleep."
	// Latin 2: "Fire, depart from me"
	unbinding_chants = list(
		"Solvo flammam vinctam!",
		"I becalm the flame that dwells within, rest.",
		"Ignis, a me discedere!",
	)
	fixed_spells = list(
		/datum/action/cooldown/spell/projectile/spitfire,
		/datum/action/cooldown/spell/projectile/fireball,
		/datum/action/cooldown/spell/fire_blast,
		/datum/action/cooldown/spell/fire_curtain,
	)
	variants = list(
		"mastery" = list(
			VARIANT_ADDITIVE =/datum/action/cooldown/spell/projectile/fireball/greater,
		),
		"grenzelhoftian" = list(
			/datum/action/cooldown/spell/projectile/fireball = /datum/action/cooldown/spell/projectile/fireball/artillery,
		),
	)

/datum/magic_aspect/cryomancy
	name = "Cryomancy"
	latin_name = "Maior Aspectus Glaciei"
	desc = "The school of Cryomancy relies on slowing its opponent with every single strike - going up to -3 SPD from 3 consecutive strike. Frost Bolt is quick and efficient, though lacking in pure damage. Snap Freeze burns everyone in a wide area through their chest. Frost Stream - Cryomancer's counterpart to the Fire Blast, burns everyone in a long line and slow them down. Hailstorm is the ultimate expression of Cryomancy - making a mage stand still as they bombard an area far away with endless hailstones. Cryomancy countersynergizes with Pyromancy and is incompatible - casting cryo spell chills one's body from fire and having cryo spells will help extinguish flames."
	aspect_type = ASPECT_MAJOR
	attuned_name = ASPECT_NAME_CRYOMANCY
	school_color = GLOW_COLOR_ICE
	countersynergy = list(/datum/magic_aspect/pyromancy)
	// Latin 1: "I call upon the eternal frost" | English suggestions: "I invoke the cold that lingers deep, come forth!" / "I summon the frost that sleeps beneath, crystallize!"
	// Latin 2: "Ice, bind yourself to me"
	binding_chants = list(
		"Invoco glaciem aeternam!",
		"I invoke the cold that lingers deep, come forth!",
		"Glacies, in me ligare!",
	)
	// Latin 1: "I release the bound frost" | English suggestions: "I release the chill that grips my veins, thaw." / "I dismiss the frost that dwells within, melt away."
	// Latin 2: "Ice, depart from me"
	unbinding_chants = list(
		"Solvo glaciem vinctam!",
		"I release the chill that grips my veins, thaw.",
		"Glacies, a me discedere!",
	)
	fixed_spells = list(
		/datum/action/cooldown/spell/projectile/frost_bolt,
		/datum/action/cooldown/spell/frost_stream,
		/datum/action/cooldown/spell/snap_freeze,
		/datum/action/cooldown/spell/hailstorm,
	)
	variants = list(
		"mastery" = list(
			VARIANT_ADDITIVE =/datum/action/cooldown/spell/frozen_mist,
		),
	)

/datum/magic_aspect/fulgurmancy
	name = "Fulgurmancy"
	latin_name = "Maior Aspectus Fulminis"
	desc = "TODO"
	aspect_type = ASPECT_MAJOR
	attuned_name = ASPECT_NAME_FULGURMANCY
	school_color = GLOW_COLOR_LIGHTNING
	// Latin 1: "I call upon the storm's fury" | English suggestions: "I beckon the storm that churns above, strike!" / "I call the thunder that roars unseen, descend!"
	// Latin 2: "Lightning, bind yourself to me"
	binding_chants = list(
		"Invoco furorem tempestatis!",
		"I beckon the storm that churns above, strike!",
		"Fulmen, in me ligare!",
	)
	// Latin 1: "I release the bound storm" | English suggestions: "I quiet the storm that rages within, be still." / "I calm the thunder that echoes in me, silence."
	// Latin 2: "Lightning, depart from me"
	unbinding_chants = list(
		"Solvo tempestatem vinctam!",
		"I quiet the storm that rages within, be still.",
		"Fulmen, a me discedere!",
	)
	fixed_spells = list(
		/datum/action/cooldown/spell/projectile/shock,
		/datum/action/cooldown/spell/projectile/lightning_bolt,
		/datum/action/cooldown/spell/heavens_strike,
		/datum/action/cooldown/spell/thunderstrike,
	)
	variants = list(
		"mastery" = list(
			VARIANT_ADDITIVE =/datum/action/cooldown/spell/greater_thunderstrike,
		),
	)

/datum/magic_aspect/geomancy
	name = "Geomancy"
	latin_name = "Maior Aspectus Terrae"
	desc = "TODO"
	aspect_type = ASPECT_MAJOR
	attuned_name = ASPECT_NAME_GEOMANCY
	school_color = GLOW_COLOR_EARTHEN
	// Latin 1: "I call upon the enduring earth" | English suggestions: "I entreat the stone that stands unyielding, answer!" / "I rouse the earth that sleeps below, rise!"
	// Latin 2: "Earth, bind yourself to me"
	binding_chants = list(
		"Invoco terram perennem!",
		"I entreat the stone that stands unyielding, answer!",
		"Terra, in me ligare!",
	)
	// Latin 1: "I release the bound earth" | English suggestions: "I relinquish the stone that fortifies me, crumble." / "I release the earth that steadies my hand, scatter."
	// Latin 2: "Earth, depart from me"
	unbinding_chants = list(
		"Solvo terram vinctam!",
		"I relinquish the stone that fortifies me, crumble.",
		"Terra, a me discedere!",
	)
	fixed_spells = list(
		/datum/action/cooldown/spell/projectile/gravel_blast,
		/datum/action/cooldown/spell/projectile/boulder_strike,
		/datum/action/cooldown/spell/ensnare,
		/datum/action/cooldown/spell/earthen_wall,
	)
	variants = list(
		"mastery" = list(
			VARIANT_ADDITIVE =/datum/action/cooldown/spell/meteor_strike,
		),
	)

/datum/magic_aspect/kinesis
	name = "Kinesis"
	latin_name = "Maior Aspectus Vis"
	desc = "TODO"
	aspect_type = ASPECT_MAJOR
	attuned_name = ASPECT_NAME_KINESIS
	school_color = GLOW_COLOR_KINESIS
	// Latin 1: "I call upon the unseen force" | English suggestions: "I summon the force that bends all things, obey!" / "I command the invisible hand, manifest!"
	// Latin 2: "Force, bind yourself to me"
	binding_chants = list(
		"Invoco vim invisibilem!",
		"I summon the force that bends all things, obey!",
		"Vis, in me ligare!",
	)
	// Latin 1: "I release the bound force" | English suggestions: "I unshackle the force that moves through me, disperse." / "I release the grip upon the unseen, dissolve."
	// Latin 2: "Force, depart from me"
	unbinding_chants = list(
		"Solvo vim vinctam!",
		"I unshackle the force that moves through me, disperse.",
		"Vis, a me discedere!",
	)
	fixed_spells = list(
		/datum/action/cooldown/spell/projectile/soulshot,
		/datum/action/cooldown/spell/projectile/fetch,
		/datum/action/cooldown/spell/projectile/repel,
		/datum/action/cooldown/spell/repulse,
		/datum/action/cooldown/spell/gravity,
	)
	variants = list(
		"mastery" = list(
			VARIANT_ADDITIVE =/datum/action/cooldown/spell/mass_gravity,
		),
	)

/datum/magic_aspect/augmentation
	name = "Augmentation"
	latin_name = "Maior Aspectus Augmenti"
	desc = "TODO"
	aspect_type = ASPECT_MAJOR
	attuned_name = ASPECT_NAME_AUGMENTATION
	school_color = GLOW_COLOR_BUFF
	// Latin 1: "I call upon the power of perfection" | English suggestions: "I beseech the arcyne to hone my form, sharpen!" / "I invoke the art that refines the self, empower!"
	// Latin 2: "Enhancement, bind yourself to me"
	binding_chants = list(
		"Invoco potentiam perfectionis!",
		"I beseech the arcyne to hone my form, sharpen!",
		"Augmentum, in me ligare!",
	)
	// Latin 1: "I release the bound enhancement" | English suggestions: "I forfeit the strength bestowed upon me, diminish." / "I shed the power that tempers my flesh, wane."
	// Latin 2: "Enhancement, depart from me"
	unbinding_chants = list(
		"Solvo augmentum vinctum!",
		"I forfeit the strength bestowed upon me, diminish.",
		"Augmentum, a me discedere!",
	)
	fixed_spells = list(
		/datum/action/cooldown/spell/projectile/soulshot,
	)
	variants = list(
		"mastery" = list(
			VARIANT_ADDITIVE =/datum/action/cooldown/spell/apotheosis,
		),
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
	aspect_type = ASPECT_MAJOR
	attuned_name = ASPECT_NAME_FERRAMANCY
	school_color = GLOW_COLOR_METAL
	// Latin 1: "I call upon the unyielding steel" | English suggestions: "I call upon the forge within, create!" / "I wake the anvil-song that rings in my blood, resound!"
	// Latin 2: "Steel, obey my command"
	binding_chants = list(
		"Invoco chalybem indomitum!",
		"I call upon the forge within, create!",
		"Chalybs, imperio meo parere!",
	)
	// Latin 1: "I quench the forge within" | English suggestions: "I silence the ring of hammer and steel, grow cold." / "I quench the forge-fire that shapes my craft, darken."
	// Latin 2: "Steel, return to stillness"
	unbinding_chants = list(
		"Exstinguo fornacem internam!",
		"I silence the ring of hammer and steel, grow cold.",
		"Chalybs, ad quietem redire!",
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
	variants = list(
		"mastery" = list(
			VARIANT_ADDITIVE =/datum/action/cooldown/spell/steel_barrage,
		),
	)
