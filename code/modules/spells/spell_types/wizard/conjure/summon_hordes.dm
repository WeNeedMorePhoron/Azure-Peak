/datum/action/cooldown/spell/conjure_summon/hordes
	name = "Summon Horde"
	desc = "Call forth a pack of three phantasmal goblins to swarm your foes. Individually weak and lightly armored - each one killed exacts a partial recoil, but not as much as a true champion. Recast to reinforce the pack up to three, or replace it once full; use Dismiss Conjuration to release them safely."
	button_icon_state = "primetriangle"
	invocations = list("Exsurgite, cohors!")
	summon_noun = "goblin"
	max_summons = 3
	summons_per_cast = 3
	recoil_energy_floor = 700
	recoil_severity = CONJURE_RECOIL_PARTIAL

/datum/action/cooldown/spell/conjure_summon/hordes/spawn_summon(turf/T, mob/living/user)
	var/turf/dest = T
	var/list/open = list()
	for(var/turf/open/candidate in range(1, T))
		if(!candidate.is_blocked_turf())
			open += candidate
	if(length(open))
		dest = pick(open)
	var/mob/living/carbon/human/species/goblin/npc/conjured/goblin = new(dest)
	goblin.summoner_ref = WEAKREF(user)
	goblin.arcane_scale = clamp(user.get_skill_level(/datum/skill/combat/arcyne), 1, 6)
	goblin.gear_tier = get_summon_tier(user)
	return goblin
