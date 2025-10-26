/// Toreador from Temu.
/datum/clan_leader/eoran
	lord_spells = list(
		/obj/effect/proc_holder/spell/targeted/shapeshift/cabbit,
	)
	lord_verbs = list(
		/mob/living/carbon/human/proc/punish_spawn
	)
	lord_traits = list(TRAIT_HEAVYARMOR, TRAIT_INFINITE_ENERGY)
	lord_title = "Elder"

/datum/clan/eoran
	name = "Vitabella Family"
	desc = "Eora, moved by your relentless pursuit of art and beauty, has bestowed her blessing upon your cursed bloodline. Yet, in her admiration, she has overlooked the darker facets of your nature: your twisted notion of love and your delusions of grandeur. "
	curse = "Obsession with vanity, need to be loved"
	clanicon = "eoran"
	blood_preference = BLOOD_PREFERENCE_ALL
	clane_traits = list(
		TRAIT_BEAUTIFUL,
		TRAIT_EMPATH,
		TRAIT_EXTEROCEPTION,
		TRAIT_STRONGBITE,
		TRAIT_NOHUNGER,
		TRAIT_NOBREATH,
		TRAIT_NOPAIN,
		TRAIT_TOXIMMUNE,
		TRAIT_STEELHEARTED,
		TRAIT_NOSLEEP,
		TRAIT_VAMPMANSION,
		TRAIT_VAMP_DREAMS,
		TRAIT_DARKVISION,
		TRAIT_LIMBATTACHMENT,
		TRAIT_SILVER_WEAK,
		)

	clane_covens = list(
		/datum/coven/presence,
		/datum/coven/bloodheal,
		/datum/coven/eora
	)
	leader = /datum/clan_leader/eoran
	covens_to_select = 0
/datum/clan/eoran/get_blood_preference_string()
	return "Regular blood, blood of your loved ones"

/datum/clan/eoran/get_downside_string()
	return "You are perfect, you do not have any downsides."

/datum/clan/eoran/apply_clan_components(mob/living/carbon/human/H)
	H.AddComponent(/datum/component/vampire_disguise)
