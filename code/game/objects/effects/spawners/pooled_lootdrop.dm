/*
 * Pooled Loot Spawner
 *
 * A lootdrop spawner that defers spawning to a /datum/loot_pool budget system.
 * Instead of spawning immediately on Initialize, these register with their pool
 * and wait. After all atoms initialize, the pool distributes budget and tells
 * funded spawners to spawn. Over-budget spawners get fallback junk.
 *
 * Set pool_id to match a /datum/loot_pool subtype's id.
 * Set point_cost to the budget this spawner consumes.
 * Set guaranteed = TRUE for spawners that must always fire.
 */

/obj/effect/spawner/lootdrop/pooled
	icon_state = "cot"
	/// The loot pool id this spawner belongs to
	var/pool_id
	/// How many points this spawner costs from the pool budget
	var/point_cost = 1
	/// If TRUE, this spawner always fires regardless of remaining budget
	var/guaranteed = FALSE
	/// Internal flag — blocks spawn_loot() during Initialize so the pool controls when we spawn
	var/pool_ready = FALSE

/obj/effect/spawner/lootdrop/pooled/Initialize(mapload)
	if(!pool_id)
		CRASH("[type] has no pool_id set!")
	var/datum/loot_pool/pool = GLOB.loot_pools[pool_id]
	if(!pool)
		CRASH("[type] references unknown pool_id '[pool_id]'! Define a /datum/loot_pool subtype with this id.")
	pool.register(src)
	..() // Calls parent chain (sets INITIALIZED_1 flag, etc.) — spawn_loot() is blocked by pool_ready check
	return INITIALIZE_HINT_LATELOAD

/// Blocked during init — pool calls spawn_loot() directly when it's time
/obj/effect/spawner/lootdrop/pooled/spawn_loot()
	if(!pool_ready)
		return // Not yet — pool will call us when budget is distributed
	..() // Run the real loot spawn logic from parent

/obj/effect/spawner/lootdrop/pooled/LateInitialize()
	return // Pool handles us in process_all_loot_pools()

/// Called by the pool to actually trigger loot spawning
/obj/effect/spawner/lootdrop/pooled/proc/do_pool_spawn()
	pool_ready = TRUE
	spawn_loot()

/// Spawn fallback junk when this spawner can't afford its real loot
/obj/effect/spawner/lootdrop/pooled/proc/spawn_fallback(list/fallback_items)
	if(!fallback_items || !length(fallback_items))
		return
	var/turf/T = loc
	if(T)
		var/junk_type = pick(fallback_items)
		new junk_type(T)
