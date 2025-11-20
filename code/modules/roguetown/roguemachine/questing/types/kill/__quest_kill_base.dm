// Base for kill quests
/datum/quest/kill
	var/list/mob_types_to_spawn = list()
	var/count_min = 1
	var/count_max = 3
	var/mobs_spawned = FALSE

/datum/quest/kill/proc/spawn_kill_mobs(obj/effect/landmark/quest_spawner/landmark)
	target_mob_type = pick(mob_types_to_spawn)
	progress_required = rand(count_min, count_max)
	target_spawn_area = get_area_name(get_turf(landmark))

	// Spawn mobs
	for(var/i in 1 to progress_required)
		var/turf/spawn_turf = landmark.get_safe_spawn_turf()
		if(!spawn_turf)
			continue

		var/mob/living/new_mob = new target_mob_type(spawn_turf)
		new_mob.faction |= "quest"
		new_mob.AddComponent(/datum/component/quest_object/kill, src)
		add_tracked_atom(new_mob)
		landmark.add_quest_faction_to_nearby_mobs(spawn_turf)

/datum/quest/kill/onProximity(mob/living/triggerer)
	var/mob/receiver = quest_receiver_reference?.resolve()
	if(triggerer != receiver)
		return FALSE
	if(mobs_spawned)
		return FALSE
	spawn_kill_mobs(quest_landmark)
	mobs_spawned = TRUE

/datum/quest/kill/get_additional_reward()
	..()
	// Additional reward based on mob difficulty and number required
	var/mob_type_difficulty = QUEST_KILL_MOBS_LIST[target_mob_type]
	return progress_required * mob_type_difficulty
