// Global list for all learnable spells.
// Maybe one day we'll have different schools of spells etc. and a system tied to them but this is fine for now.

GLOBAL_LIST_INIT(learnable_spells, (list(/datum/action/cooldown/spell/projectile/fireball,
		/datum/action/cooldown/spell/projectile/lightning_bolt,
		/datum/action/cooldown/spell/projectile/fetch,
		/datum/action/cooldown/spell/projectile/spitfire,
		/obj/effect/proc_holder/spell/invoked/forcewall,
		/obj/effect/proc_holder/spell/invoked/ensnare,
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
		/obj/effect/proc_holder/spell/invoked/projectile/acidsplash,
		/datum/action/cooldown/spell/projectile/fireball/greater,
//		/obj/effect/proc_holder/spell/invoked/frostbite,
		/datum/action/cooldown/spell/guidance,
		/datum/action/cooldown/spell/fortitude,
		/datum/action/cooldown/spell/snap_freeze,
		/datum/action/cooldown/spell/projectile/frost_bolt,
		/datum/action/cooldown/spell/frost_stream,
		/datum/action/cooldown/spell/hailstorm,
		/datum/action/cooldown/spell/projectile/arcynebolt,
		/obj/effect/proc_holder/spell/invoked/projectile/arcynestrike,
		/datum/action/cooldown/spell/gravity,
		/datum/action/cooldown/spell/projectile/repel,

		/obj/effect/proc_holder/spell/targeted/touch/lesserknock,

		/datum/action/cooldown/spell/enlarge,
		/datum/action/cooldown/spell/leap,
		/obj/effect/proc_holder/spell/invoked/blink,
		/obj/effect/proc_holder/spell/invoked/mirror_transform,
		/obj/effect/proc_holder/spell/invoked/mindlink,
		/datum/action/cooldown/spell/stoneskin,
		/datum/action/cooldown/spell/hawks_eyes,
		/datum/action/cooldown/spell/giants_strength,
		/obj/effect/proc_holder/spell/invoked/create_campfire,
		/obj/effect/proc_holder/spell/invoked/mending,
		/obj/effect/proc_holder/spell/self/light,
		/datum/action/cooldown/spell/arcyne_forge,
		/obj/effect/proc_holder/spell/self/conjure_armor,
		/obj/effect/proc_holder/spell/self/conjure_armor/dragonhide,
		/obj/effect/proc_holder/spell/self/conjure_armor/crystalhide,
		/obj/effect/proc_holder/spell/self/magicians_brick,
		/datum/action/cooldown/spell/thunderstrike,
		/obj/effect/proc_holder/spell/invoked/sundering_lightning,
		/obj/effect/proc_holder/spell/invoked/meteor_storm,
		/obj/effect/proc_holder/spell/invoked/forcewall/arcyne_prison,
		/obj/effect/proc_holder/spell/invoked/forcewall/greater,
		/obj/effect/proc_holder/spell/invoked/wither,
		/datum/action/cooldown/spell/projectile/fireball/artillery,
		/obj/effect/proc_holder/spell/invoked/conjure_primordial,
		/obj/effect/proc_holder/spell/invoked/raise_deadite,
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
		/obj/effect/proc_holder/spell/self/light,
		/obj/effect/proc_holder/spell/invoked/mending,
		/obj/effect/proc_holder/spell/self/message,
		/obj/effect/proc_holder/spell/invoked/mindlink,
		/obj/effect/proc_holder/spell/self/findfamiliar,
		/obj/effect/proc_holder/spell/invoked/create_campfire,
		/obj/effect/proc_holder/spell/invoked/projectile/lesser_fetch,
		/obj/effect/proc_holder/spell/invoked/projectile/lesser_repel,
		/obj/effect/proc_holder/spell/targeted/touch/lesserknock,
		/datum/action/cooldown/spell/nondetection,
		/datum/action/cooldown/spell/darkvision, // Buff but it is fine to also put it in this list
		/obj/effect/proc_holder/spell/self/magicians_brick,
		/obj/effect/proc_holder/spell/invoked/mirror_transform 
		)
))

