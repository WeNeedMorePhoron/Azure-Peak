/*
 * Loot Pool System
 *
 * Provides budget-controlled loot distribution across map-placed spawners.
 * Each pool has a point budget. Spawners register with a pool by ID and are
 * processed after all atoms initialize (via LateInitialize). Guaranteed
 * spawners always fire; remaining budget is distributed to shuffled spawners.
 * Over-budget spawners receive fallback junk so spots aren't empty.
 *
 * Usage:
 *   1. Define a /datum/loot_pool subtype with id and available_points
 *   2. Place /obj/effect/spawner/lootdrop/pooled subtypes on the map with matching pool_id
 *   3. System handles the rest during initialization
 */

GLOBAL_LIST_EMPTY(loot_pools)

/datum/loot_pool
	/// Unique string identifier for this pool, e.g. "tomb", "fishmandungeon"
	var/id
	/// Total point budget available for this pool
	var/available_points = 0
	/// Whether this pool has already been processed
	var/processed = FALSE
	/// Spawners that always fire regardless of budget
	var/list/guaranteed_spawners = list()
	/// Normal spawners that compete for budget
	var/list/known_spawners = list()
	/// Cheap junk items to spawn when a spawner can't afford its real loot
	var/list/fallback_loot = list(
		/obj/item/ash,
		/obj/item/natural/glass_shard,
		/obj/item/natural/stone,
		/obj/item/candle/yellow,
	)

/datum/loot_pool/New()
	..()
	if(!id)
		CRASH("/datum/loot_pool created without an id!")
	if(GLOB.loot_pools[id])
		CRASH("/datum/loot_pool duplicate id: [id]")
	GLOB.loot_pools[id] = src

/datum/loot_pool/Destroy()
	GLOB.loot_pools -= id
	guaranteed_spawners = null
	known_spawners = null
	return ..()

/// Register a pooled spawner with this pool. Called during spawner Initialize().
/datum/loot_pool/proc/register(obj/effect/spawner/lootdrop/pooled/spawner)
	if(spawner.guaranteed)
		guaranteed_spawners += spawner
	else
		known_spawners += spawner

/// Check if the pool can afford a given point cost
/datum/loot_pool/proc/can_afford(cost)
	return available_points >= cost

/// Deduct points from the pool budget
/datum/loot_pool/proc/consume(cost)
	available_points -= cost

/// Process all spawners in this pool. Called once after all atoms LateInitialize.
/datum/loot_pool/proc/process_pool()
	if(processed)
		return
	processed = TRUE

	var/total_spawners = length(guaranteed_spawners) + length(known_spawners)
	var/funded_count = 0
	var/fallback_count = 0
	var/starting_budget = available_points

	// Phase 1: guaranteed spawners always fire
	for(var/obj/effect/spawner/lootdrop/pooled/spawner as anything in guaranteed_spawners)
		spawner.do_pool_spawn()
		consume(spawner.point_cost)
		funded_count++
		qdel(spawner)
	guaranteed_spawners.Cut()

	// Phase 2: shuffle remaining for fair distribution
	shuffle_inplace(known_spawners)

	// Phase 3: spend budget on remaining spawners
	for(var/obj/effect/spawner/lootdrop/pooled/spawner as anything in known_spawners)
		if(can_afford(spawner.point_cost))
			spawner.do_pool_spawn()
			consume(spawner.point_cost)
			funded_count++
		else
			spawner.spawn_fallback(fallback_loot)
			fallback_count++
		qdel(spawner)
	known_spawners.Cut()

	log_game("Loot Pool '[id]': budget [starting_budget], [total_spawners] spawners, [funded_count] funded, [fallback_count] fallback, [available_points] points remaining")

/// Global proc to instantiate all loot pool subtypes. Called early in initialization.
/proc/initialize_loot_pools()
	for(var/pool_type in subtypesof(/datum/loot_pool))
		new pool_type()

/// Global proc to process all registered loot pools. Called after all atoms LateInitialize.
/proc/process_all_loot_pools()
	for(var/pool_id in GLOB.loot_pools)
		var/datum/loot_pool/pool = GLOB.loot_pools[pool_id]
		pool.process_pool()
