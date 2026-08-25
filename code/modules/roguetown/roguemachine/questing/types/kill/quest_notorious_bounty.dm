/datum/quest/kill/notorious_bounty
	quest_type = QUEST_NOTORIOUS_BOUNTY
	quest_difficulty = QUEST_DIFFICULTY_NOTORIOUS
	tp_budget = QUEST_TP_BUDGET_NOTORIOUS_GOONS
	threat_bands_cleared = QUEST_BANDS_NOTORIOUS
	required_fellowship_size = 2
	var/boss_name
	var/datum/weakref/boss_ref
	var/turf/leash_origin

/datum/quest/kill/notorious_bounty/preview(obj/effect/landmark/quest_spawner/landmark)
	if(!landmark)
		return FALSE
	pending_landmark_ref = WEAKREF(landmark)
	target_spawn_area = get_area_name(get_turf(landmark))
	region = landmark.region
	var/datum/threat_region/TR = SSregionthreat.get_region(region)
	if(!TR)
		return FALSE
	faction = pick_region_faction_for(TR)
	if(!faction)
		return FALSE
	faction_id = faction.id
	var/list/boss_pool = faction.get_playable_boss_types()
	if(!length(boss_pool))
		return FALSE
	target_mob_type = pickweight(boss_pool)
	boss_name = faction.generate_boss_name()
	progress_required = 1
	finalize_preview_title()
	return TRUE

/datum/quest/kill/notorious_bounty/get_named_target()
	return boss_name

/datum/quest/kill/notorious_bounty/get_title()
	if(title)
		return title
	if(!boss_name)
		return "Bring down a notorious outlaw"
	return "Bring down [boss_name]"

/datum/quest/kill/notorious_bounty/get_objective_text()
	return "Slay the target, but be warned! They are rumored to be a truly formidable opponent!"

/datum/quest/kill/notorious_bounty/get_additional_reward(turf/origin_turf, turf/target_turf)
	if(!target_mob_type)
		return 0
	var/boss_threat = initial(target_mob_type.threat_point) || 0
	var/goon_threat = (total_spawned_tp > 0) ? total_spawned_tp : tp_budget
	return (boss_threat * QUEST_NOTORIOUS_BOUNTY_THREAT_MULT) + (goon_threat * QUEST_KILL_THREAT_MULT)

/datum/quest/kill/notorious_bounty/estimate_mob_count()
	return 1

/datum/quest/kill/notorious_bounty/materialize(obj/effect/landmark/quest_spawner/landmark)
	if(!landmark)
		return FALSE
	if(!faction)
		return FALSE
	spawn_boss(landmark)
	spawn_goons(landmark, tp_budget, NOTORIOUS_BOUNTY_GOON_CAP)
	progress_required = 1
	// Rename after a delay so subtype after_creation() timers don't clobber it.
	addtimer(CALLBACK(src, PROC_REF(apply_boss_name)), 2 SECONDS)
	return TRUE

/datum/quest/kill/notorious_bounty/proc/spawn_boss(obj/effect/landmark/quest_spawner/landmark)
	var/turf/spawn_turf = landmark.get_safe_spawn_turf()
	if(!spawn_turf)
		return
	var/obj/effect/quest_spawn/notorious/spawn_effect = new /obj/effect/quest_spawn/notorious(spawn_turf)
	var/mob/living/boss = new target_mob_type(spawn_effect)
	boss.faction |= "quest"
	if(faction?.faction_tag)
		boss.faction |= faction.faction_tag
	boss.mark_contract_spawned()
	boss.AddComponent(/datum/component/quest_object/kill, src)
	ADD_TRAIT(boss, TRAIT_FRESHSPAWN, "[type]")
	addtimer(TRAIT_CALLBACK_REMOVE(boss, TRAIT_FRESHSPAWN, "[type]"), 60 SECONDS)
	spawn_effect.contained_atom = boss
	spawn_effect.AddComponent(/datum/component/quest_object/mob_spawner, src)
	register_spawner(spawn_effect)
	add_tracked_atom(boss)
	boss_ref = WEAKREF(boss)

/datum/quest/kill/notorious_bounty/proc/spawn_goons(obj/effect/landmark/quest_spawner/landmark, budget, cap, immediate = FALSE)
	var/saved_budget = tp_budget
	tp_budget = budget
	var/list/to_spawn = compose_warband()
	tp_budget = saved_budget
	if(length(to_spawn) > cap)
		to_spawn.Cut(cap + 1)
	for(var/goon_type in to_spawn)
		var/turf/spawn_turf = landmark.get_safe_spawn_turf()
		if(!spawn_turf)
			continue
		var/mob/living/goon
		if(immediate)
			goon = new goon_type(spawn_turf)
		else
			var/obj/effect/quest_spawn/spawn_effect = new /obj/effect/quest_spawn(spawn_turf)
			goon = new goon_type(spawn_effect)
			spawn_effect.contained_atom = goon
			spawn_effect.AddComponent(/datum/component/quest_object/mob_spawner, src)
			register_spawner(spawn_effect)
		goon.faction |= "quest"
		if(faction?.faction_tag)
			goon.faction |= faction.faction_tag
		goon.mark_contract_spawned()
		ADD_TRAIT(goon, TRAIT_FRESHSPAWN, "[type]")
		addtimer(TRAIT_CALLBACK_REMOVE(goon, TRAIT_FRESHSPAWN, "[type]"), 60 SECONDS)
		total_spawned_tp += initial(goon.threat_point) || 0

/datum/quest/kill/notorious_bounty/proc/spawn_reinforcements()
	var/obj/effect/landmark/quest_spawner/landmark = pending_landmark_ref?.resolve()
	if(QDELETED(landmark))
		return
	spawn_goons(landmark, NOTORIOUS_BOUNTY_REINFORCE_TP, NOTORIOUS_BOUNTY_REINFORCE_CAP, immediate = TRUE)
	announce_to_bearer("<b>The outlaw's gang closes ranks.</b>.")

/datum/quest/kill/notorious_bounty/proc/apply_boss_name()
	var/mob/living/M = boss_ref?.resolve()
	if(QDELETED(M))
		return
	M.real_name = boss_name
	M.name = boss_name

/datum/quest/kill/notorious_bounty/proc/offer_boss_control(mob/living/carbon/human/boss)
	if(QDELETED(boss) || boss.stat == DEAD || boss.client || complete || failed)
		return
	var/list/candidates = pollGhostCandidates("A hunting party stalks [boss_name || "a notorious bounty"]! Will you take up the mantle of the hunted and defend yourself?", ROLE_NOTORIOUS_BOUNTY, null, null, NOTORIOUS_BOUNTY_POLL_TIME, POLL_IGNORE_NOTORIOUS_BOUNTY)
	if(QDELETED(boss) || boss.stat == DEAD || boss.client || complete || failed)
		return
	// Only true dead mobs (observers, lobby) - a spirit's key belongs to a body elsewhere.
	var/list/eligible = list()
	for(var/mob/dead/M in candidates)
		if(M.key)
			eligible += M
	if(!length(eligible))
		spawn_reinforcements()
		return
	var/mob/dead/chosen = pick(eligible)
	if(istype(chosen, /mob/dead/new_player))
		var/mob/dead/new_player/N = chosen
		N.close_spawn_windows()
	boss.key = chosen.key
	// Prevent the mob from getting instaambushed
	boss.ambushable = FALSE
	REMOVE_TRAIT(boss, TRAIT_NPC_EXAMINE, TRAIT_GENERIC)
	ADD_TRAIT(boss, TRAIT_TEMPO, TRAIT_GENERIC)
	boss.adjust_skillrank(/datum/skill/misc/tracking, 6, TRUE) //You should be able to hunt your hunters back!
	boss.adjust_skillrank(/datum/skill/misc/climbing, 4, TRUE)
	boss.adjust_skillrank(/datum/skill/misc/swimming, 4, TRUE)
	boss.adjust_skillrank(/datum/skill/misc/reading, 1, TRUE)
	// Signals to hunters that a player has taken the reins.
	boss.add_filter("notorious_bounty_outline", 1, list("type" = "drop_shadow", "color" = "#ffee00", "size" = 0.1))
	leash_origin = get_turf(boss)
	reward_amount += NOTORIOUS_BOUNTY_PLAYER_BONUS
	quest_scroll?.update_quest_text()
	announce_to_bearer("<b>Your quarry's eyes glows with unusual intelligence.</b> The bounty on [boss_name] grows by [NOTORIOUS_BOUNTY_PLAYER_BONUS] mammons.")
	to_chat(boss, span_boldnotice("You are [boss_name], a notorious outlaw. A hunting party is closing in on you. Stand your ground and make them earn their mammons. Do not round-remove any of your targets, but you are free to kill them and fight as hard as you need to within reason. Make them earn their bounty. You can join in attacking anyone your NPCs are already attacking. Follow our escalation rules. You cannot flee them, and if the hunters never come, the pact releases you in [NOTORIOUS_BOUNTY_CONTROL_TIME / (1 MINUTES)] minutes."))
	var/turf/boss_turf = get_turf(boss)
	var/mob/living/bearer = quest_receiver_reference?.resolve()
	var/datum/fellowship/F = bearer?.current_fellowship
	var/mob/living/party_leader = F?.get_leader()
	message_admins("[key_name_admin(boss)] has taken over notorious bounty '[boss_name]' at [ADMIN_COORDJMP(boss_turf)] ([region]), fighting a fellowship led by [party_leader ? key_name_admin(party_leader) : "an unknown party"].")
	addtimer(CALLBACK(src, PROC_REF(release_boss)), NOTORIOUS_BOUNTY_CONTROL_TIME)
	leash_boss()

/// Drags a straying boss back to its spawn point, then reschedules itself while the boss lives.
/datum/quest/kill/notorious_bounty/proc/leash_boss()
	var/mob/living/boss = boss_ref?.resolve()
	if(QDELETED(boss) || boss.stat == DEAD)
		return
	var/turf/T = get_turf(boss)
	if(T && leash_origin && (T.z != leash_origin.z || get_dist(T, leash_origin) > NOTORIOUS_BOUNTY_LEASH_RANGE))
		boss.forceMove(leash_origin)
		to_chat(boss, span_userdanger("Mammon's pact drags you back to your hunting grounds!"))
	addtimer(CALLBACK(src, PROC_REF(leash_boss)), NOTORIOUS_BOUNTY_LEASH_INTERVAL)

/// Control timer expiry: the hunters never finished the job, so the ghost is released and AI resumes.
/datum/quest/kill/notorious_bounty/proc/release_boss()
	var/mob/living/boss = boss_ref?.resolve()
	if(QDELETED(boss) || boss.stat == DEAD || !boss.client)
		return
	to_chat(boss, span_warning("The pact wanes. The borrowed flesh returns to instinct, and your spirit slips free."))
	boss.ghostize(FALSE)
	boss.remove_filter("notorious_bounty_outline")
	ADD_TRAIT(boss, TRAIT_NPC_EXAMINE, TRAIT_GENERIC)
