
#define TRAIT_FISH_TOXIN_IMMUNE "fish_toxin_immune"
/**
 * This fish has been fed teslium without the electrogenesis having trait.
 * Gives the electrogenesis, but at halved output, and it hurts the fish over time.
 */

/// Use in fish tables to denote miss chance.
#define FISHING_DUD "dud"

// Baseline fishing difficulty levels
#define FISHING_DEFAULT_DIFFICULTY 15
/**
 * The minimum value of the difficulty of the minigame (unless it reaches 0 than it's auto-win)
 * Any lower than this and the fish will be way too lethargic for the minigame to be engaging in the slightest.
 */
#define FISHING_MINIMUM_DIFFICULTY 6

/// Difficulty modifier when bait is fish's favorite
#define FAV_BAIT_DIFFICULTY_MOD -5
/// Difficulty modifier when bait is fish's disliked
#define DISLIKED_BAIT_DIFFICULTY_MOD 15
/// Difficulty modifier when our fisherman has the trait TRAIT_EXPERT_FISHER
#define EXPERT_FISHER_DIFFICULTY_MOD -5

#define FISH_TRAIT_MINOR_DIFFICULTY_BOOST 5

#define ADDITIVE_FISHING_MOD "additive"
#define MULTIPLICATIVE_FISHING_MOD "multiplicative"

// These defines are intended for use to interact with fishing hooks when going
// through the fishing rod, and not the hook itself. They could probably be
// handled differently, but for now that's how they work. It's grounds for
// a future refactor, however.
/// Fishing hook trait that lessens the bounce from hitting the edges of the minigame bar.
#define FISHING_HOOK_WEIGHTED (1 << 0)
///See FISHING_MINIGAME_RULE_BIDIRECTIONAL
#define FISHING_HOOK_BIDIRECTIONAL (1 << 1)
///Prevents the user from losing the game by letting the fish get away.
#define FISHING_HOOK_NO_ESCAPE (1 << 2)
///Limits the completion loss of the minigame when the fsh is not on the bait area.
#define FISHING_HOOK_ENSNARE (1 << 3)
///Automatically kills the fish after a while, at the cost of killing it.
#define FISHING_HOOK_KILL (1 << 4)

///Reduces the difficulty of the minigame
#define FISHING_LINE_CLOAKED (1 << 0)
/// Much like FISHING_HOOK_ENSNARE but for the fishing line.
#define FISHING_LINE_BOUNCY (1 << 1)
/// The sorta opposite of FISHING_LINE_BOUNCY. It makes it slower to gain completion and faster to lose it.
#define FISHING_LINE_STIFF (1 << 2)
///Skip the biting phase and go straight to the fishing phase.
#define FISHING_LINE_AUTOREEL (1 << 3)
///if fishing in "deep water" gives a bonus
#define FISHING_LINE_SINKER (1 << 4)
///if fishing in "shallow water" gives a bonus
#define FISHING_LINE_BOBBER (1 << 5)

///Keeps the bait from falling from gravity, instead allowing the player to move the bait down with right click.
#define FISHING_MINIGAME_RULE_BIDIRECTIONAL (1 << 0)
///Prevents the player from losing the minigame when the completion reaches 0
#define FISHING_MINIGAME_RULE_NO_ESCAPE (1 << 1)
///Automatically kills the fish after a while, at the cost of killing it
#define FISHING_MINIGAME_RULE_KILL (1 << 2)
///Prevents the fishing skill from having an effect on the minigame and experience from being awarded
#define FISHING_MINIGAME_RULE_NO_EXP (1 << 3)
///If enabled, the minigame will occasionally screw around and invert the velocity of the bait
#define FISHING_MINIGAME_RULE_ANTIGRAV (1 << 4)
///Will filp the minigame hud for the duration of the effect
#define FISHING_MINIGAME_RULE_FLIP (1 << 5)
///Skip the biting phase and go straight to the minigame, avoiding the penalty for having slow reflexes.
#define FISHING_MINIGAME_AUTOREEL (1 << 6)
///The fish will fade in and out at intervals
#define FISHING_MINIGAME_RULE_CAMO (1 << 7)

///all the effects that are active and will last for a few seconds before triggering a cooldown
#define FISHING_MINIGAME_ACTIVE_EFFECTS (FISHING_MINIGAME_RULE_ANTIGRAV|FISHING_MINIGAME_RULE_FLIP|FISHING_MINIGAME_RULE_CAMO)

/// The default additive value for fishing hook catch weight modifiers.
#define FISHING_DEFAULT_HOOK_BONUS_ADDITIVE 0
/// The default multiplicative value for fishing hook catch weight modifiers.
#define FISHING_DEFAULT_HOOK_BONUS_MULTIPLICATIVE 1

//Fish icon defines, used by fishing minigame
#define FISH_ICON_DEF "fish"

///Fish size thresholds for w_class, in hands.
#define FISH_SIZE_TINY_MAX 3
#define FISH_SIZE_SMALL_MAX 5
#define FISH_SIZE_NORMAL_MAX 8
#define FISH_SIZE_BULKY_MAX 12

///Size and weight are rolled to this precision.
#define FISH_MEASURE_PRECISION 0.1

///The coefficient for maximum weight/size divergence relative to the averages.
#define MAX_FISH_DEVIATION_COEFF 2.5

//IF YOU ADD ANY NEW FLAG, ADD IT TO THE RESPECTIVE BITFIELD in _globalvars/bitfields.dm TOO!

///This fish is shown in the catalog and on the wiki (this only matters as an initial, compile-time value)
#define FISH_FLAG_SHOW_IN_CATALOG (1<<0)

///Aquarium fluid variables. The fish' required fluid has to match this, or it'll slowly die.
#define FISH_FLUID_FRESHWATER "Freshwater"
#define FISH_FLUID_SALTWATER "Saltwater"
#define FISH_FLUID_ANY_WATER "Any Fluid"

//Minigame defines
/// The height of the minigame slider. Not in pixels, but minigame units.
#define FISHING_MINIGAME_AREA 1000

///Defines for fish properties from the collect_fish_properties proc
#define FISH_PROPERTIES_FAV_BAIT "fav_bait"
#define FISH_PROPERTIES_BAD_BAIT "bad_bait"
#define FISH_PROPERTIES_TRAITS "fish_traits"

///Define for favorite and disliked baits that aren't just item typepaths.
#define FISH_BAIT_TYPE "Type"
#define FISH_BAIT_FOODTYPE "Foodtype"
#define FISH_BAIT_REAGENT "Reagent"
#define FISH_BAIT_VALUE "Value"
#define FISH_BAIT_AMOUNT "Amount"

///We multiply the weight of fish inside the loot table by this value if we are goofy enough to fish without a bait.
#define FISH_WEIGHT_MULT_WITHOUT_BAIT 0.15

/**
 * Flag for fish sources. It makes large explosions less efficient at spawning fish.
 * Meant for lazy fishing spots that cover multiple turfs (rivers, oceans etc.)
 */

/**
 * A macro to ensure the wikimedia filenames of fish icons are unique, especially since there're a couple fish that have
 * quite ambiguous names/icon_states like "checkered" or "pike"
 */

/// You won't catch duds while fishing with this rod.
#define TRAIT_ROD_REMOVE_FISHING_DUD "rod_remove_fishing_dud"
/// If the item can be used as a bit.
#define TRAIT_FISHING_BAIT "fishing_bait"
/// This bait will kill any fish that doesn't have it on its favorite_bait list
#define TRAIT_POISONOUS_BAIT "poisonous_bait"
/// The quality of the bait. It influences odds of catching fish
#define TRAIT_BASIC_QUALITY_BAIT "baic_quality_bait"
#define TRAIT_GOOD_QUALITY_BAIT "good_quality_bait"
#define TRAIT_GREAT_QUALITY_BAIT "great_quality_bait"
/// Baits with this trait will ignore bait preferences and related fish traits.
#define TRAIT_OMNI_BAIT "omni_bait"
/// The bait won't be consumed when used
#define TRAIT_BAIT_UNCONSUMABLE "bait_unconsumable"
/**
 * This bait won't apply TRAIT_ROD_REMOVE_FISHING_DUD to the rod it's attached on,
 * instead, it'll allow the fishing dud to be there unless there's at least one fish that likes the bait
 */
#define TRAIT_BAIT_ALLOW_FISHING_DUD "bait_dont_affect_fishing_dud"
/**
 * This location has the aquarium component. Not much different than a GetComponent()
 * disguised as an 'is_x' macro, but I don't have to hide anything here.
 * I just don't want a confusing 'is_aquarium(A)' macro which people think it's interchangable with
 * an 'istype(A, /obj/structure/aquarium)' when it's the component what truly matters.
 */
///Trait given to turfs or objects that can be fished from
#define TRAIT_FISHING_SPOT "fishing_spot"
///This trait gets you a list of fishes that can be caught when examining a fishing spot.
#define TRAIT_EXAMINE_FISHING_SPOT "examine_fishing_spot"

#define TRAIT_EXPERT_FISHER "Expert Fisherman"

// Aquarium related signals

// Fish signals
#define COMSIG_FISH_STATUS_CHANGED "fish_status_changed"

#define COMSIG_FISH_CAUGHT "fish_caught"

///From /datum/fishing_challenge/New: (datum/fishing_challenge/challenge)
#define COMSIG_ROD_BEGIN_FISHING "rod_begin_fishing"
///From /datum/fishing_challenge/New: (datum/fishing_challenge/challenge)
#define COMSIG_MOB_BEGIN_FISHING "mob_begin_fishing"
///From /datum/fishing_challenge/start_minigame_phase: (datum/fishing_challenge/challenge)
#define COMSIG_MOB_BEGIN_FISHING_MINIGAME "mob_begin_fishing_minigame"
///From /datum/fishing_challenge/completed: (datum/fishing_challenge/challenge, win)
#define COMSIG_MOB_COMPLETE_FISHING "mob_complete_fishing"

/// Rolling a reward path for a fishing challenge
#define COMSIG_FISHING_CHALLENGE_ROLL_REWARD "fishing_roll_reward"
/// Adjusting the difficulty of a rishing challenge, often based on the reward path
#define COMSIG_FISHING_CHALLENGE_GET_DIFFICULTY "fishing_get_difficulty"
/// From /datum/fishing_challenge/start_minigame_phase, called after the fish movement datum is spawned: (datum/fish_movement/mover)
#define COMSIG_FISHING_CHALLENGE_MOVER_INITIALIZED "fishing_mover_initialized"
/// Fishing challenge completed
/// Sent to the fisherman when the reward is dispensed: (reward)
#define COMSIG_FISH_SOURCE_REWARD_DISPENSED "fish_source_reward_dispensed"

/// Sent by the target of the fishing rod cast
#define COMSIG_FISHING_ROD_CAST "fishing_rod_cast"
	#define FISHING_ROD_CAST_HANDLED (1 << 0)

/// From /datum/fish_source/proc/dispense_reward(), not set if the reward is a dud: (reward, user)
#define COMSIG_FISHING_ROD_CAUGHT_FISH "fishing_rod_caught_fish"
/// From /obj/item/fishing_rod/proc/hook_item(): (reward, user)
#define COMSIG_FISHING_ROD_HOOKED_ITEM "fishing_rod_hooked_item"

/// From /obj/item/fishing_rod/set_slot: (obj/item/fishing_rod/rod, slot)
#define COMSIG_ITEM_FISHING_ROD_SLOTTED "item_fishing_rod_slotted"
/// From /obj/item/fishing_rod/Exited: (obj/item/fishing_rod/rod, slot)
#define COMSIG_ITEM_FISHING_ROD_UNSLOTTED "item_fishing_rod_unslotted"

/// Sent when the challenge is to be interrupted: (reason)
#define COMSIG_FISHING_SOURCE_INTERRUPT_CHALLENGE "fishing_spot_interrupt_challenge"

