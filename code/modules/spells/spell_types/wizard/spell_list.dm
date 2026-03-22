
GLOBAL_LIST_INIT(learnable_spells, (list(/datum/action/cooldown/spell/projectile/fireball,
		/datum/action/cooldown/spell/projectile/lightning_bolt,
		/datum/action/cooldown/spell/projectile/fetch,
		/datum/action/cooldown/spell/projectile/spitfire,
		/datum/action/cooldown/spell/forcewall,
		/datum/action/cooldown/spell/ensnare,
		/obj/effect/proc_holder/spell/self/message,
		/datum/action/cooldown/spell/repulse,
		/datum/action/cooldown/spell/projectile/soulshot,
		/datum/action/cooldown/spell/blade_burst,
		/datum/action/cooldown/spell/nondetection,
//  	/obj/effect/proc_holder/spell/invoked/knock,
		/datum/action/cooldown/spell/haste,
		/datum/action/cooldown/spell/featherfall,
		/datum/action/cooldown/spell/darkvision,
		/obj/effect/proc_holder/spell/invoked/invisibility,
		/datum/action/cooldown/spell/projectile/fireball/greater,
//		/obj/effect/proc_holder/spell/invoked/frostbite,
		/datum/action/cooldown/spell/guidance,
		/datum/action/cooldown/spell/fortitude,
		/datum/action/cooldown/spell/snap_freeze,
		/datum/action/cooldown/spell/projectile/frost_bolt,
		/datum/action/cooldown/spell/frost_stream,
		/datum/action/cooldown/spell/hailstorm,
		/datum/action/cooldown/spell/gravity,
		/datum/action/cooldown/spell/projectile/repel,

		/datum/action/cooldown/spell/lesser_knock,

		/datum/action/cooldown/spell/enlarge,
		/datum/action/cooldown/spell/leap,
		/datum/action/cooldown/spell/blink,
		/datum/action/cooldown/spell/mirror_transform,
		/datum/action/cooldown/spell/mindlink,
		/datum/action/cooldown/spell/stoneskin,
		/datum/action/cooldown/spell/hawks_eyes,
		/datum/action/cooldown/spell/giants_strength,
		/datum/action/cooldown/spell/create_campfire,
		/datum/action/cooldown/spell/mending,
		/datum/action/cooldown/spell/light,
		/datum/action/cooldown/spell/arcyne_forge,
		/datum/action/cooldown/spell/conjure_armor,
		/datum/action/cooldown/spell/conjure_armor/dragonhide,
		/datum/action/cooldown/spell/conjure_armor/crystalhide,
		/datum/action/cooldown/spell/magicians_brick,
		/datum/action/cooldown/spell/thunderstrike,
		/datum/action/cooldown/spell/projectile/fireball/artillery,
		/obj/effect/proc_holder/spell/invoked/conjure_primordial,
		/datum/action/cooldown/spell/raise_deadite,
		/obj/effect/proc_holder/spell/invoked/bonechill,
		/obj/effect/proc_holder/spell/invoked/silence,
		/obj/effect/proc_holder/spell/self/findfamiliar,
		/datum/action/cooldown/spell/projectile/stygian_efflorescence
		)
))

/* Utility spells - non-combat support magic or very niche in combat spells meant to be freely available
to all mage classes.
*/
GLOBAL_LIST_INIT(utility_spells, (list(
		/datum/action/cooldown/spell/light,
		/datum/action/cooldown/spell/mending,
		/obj/effect/proc_holder/spell/self/message,
		/datum/action/cooldown/spell/mindlink,
		/obj/effect/proc_holder/spell/self/findfamiliar,
		/datum/action/cooldown/spell/create_campfire,
		/datum/action/cooldown/spell/projectile/lesser_fetch,
		/datum/action/cooldown/spell/projectile/lesser_repel,
		/datum/action/cooldown/spell/lesser_knock,
		/datum/action/cooldown/spell/nondetection,
		/datum/action/cooldown/spell/darkvision, // Buff but it is fine to also put it in this list
		/datum/action/cooldown/spell/magicians_brick,
		/datum/action/cooldown/spell/mirror_transform
		)
))

