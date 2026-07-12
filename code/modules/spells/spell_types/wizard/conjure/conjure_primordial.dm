/datum/action/cooldown/spell/conjure_summon/primordial
	name = "Conjure Primordial"
	desc = "Conjure a pair of Primordials to fight at your side. Toggle their element with Shift+G while the spell is selected: Flame, Water, or Air. \
	They grow mightier with your skill at Arcyne Armament - upgrading at Expert, and further at Master. You maintain two at a time - recast to replace the pair, or to raise a fallen one anew; use Dismiss Conjuration to release them safely. Losing one wracks you with exhaustion rather than the deeper backlash of your greater servants."
	button_icon_state = "primetriangle"
	invocations = list("Exsurge, primordiale!")
	summon_noun = "primordial"
	recoil_energy_floor = 150
	recoil_severity = CONJURE_RECOIL_PARTIAL
	recoil_stamina_only = TRUE
	max_summons = 2
	summons_per_cast = 2
	modes = list(
		list("name" = "Flame", "tag" = "FIRE", "path" = /mob/living/simple_animal/hostile/retaliate/rogue/primordial/fire, "color" = GLOW_COLOR_FIRE, "invocation" = "Exsurge, ignis!"),
		list("name" = "Water", "tag" = "WATER", "path" = /mob/living/simple_animal/hostile/retaliate/rogue/primordial/water, "color" = GLOW_COLOR_ICE, "invocation" = "Exsurge, unda!"),
		list("name" = "Air", "tag" = "AIR", "path" = /mob/living/simple_animal/hostile/retaliate/rogue/primordial/air, "color" = "#cfe8ff", "invocation" = "Exsurge, ventus!"),
	)

/datum/action/cooldown/spell/conjure_summon/primordial/spawn_summon(turf/T, mob/living/user)
	var/turf/dest = T
	var/list/open = list()
	for(var/turf/open/candidate in range(1, T))
		if(!candidate.is_blocked_turf())
			open += candidate
	if(length(open))
		dest = pick(open)
	var/mob_path = modes[current_mode]["path"]
	var/mob/living/simple_animal/hostile/retaliate/rogue/primordial/conjured = new mob_path(dest, user)
	scale_primordial(conjured, user)
	return conjured

/datum/action/cooldown/spell/conjure_summon/primordial/proc/scale_primordial(mob/living/simple_animal/hostile/retaliate/rogue/primordial/P, mob/living/user)
	var/tier = get_summon_tier(user)
	var/mult = 1 + (tier - 1) * 0.2
	P.maxHealth = round(P.maxHealth * mult)
	P.health = P.maxHealth
	P.melee_damage_lower = round(P.melee_damage_lower * mult)
	P.melee_damage_upper = round(P.melee_damage_upper * mult)
