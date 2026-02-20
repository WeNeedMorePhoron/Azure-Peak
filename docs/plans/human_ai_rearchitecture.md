# Plan: Human NPC AI Re-Architecture — Weighted Action System

## Context

The current `_npc.dm` complex NPC AI is a procedural state machine baked into `/mob/living/carbon/human`. While its melee combat is sophisticated (grabs, intents, zone targeting, juking), it has structural limitations:
- 100% melee — no ranged or magic support
- Sequential single-action per tick — NPCs "stutter-stop" to attack
- Perfect-accuracy clicks that don't mimic real behavior
- Extending behavior requires type-inheritance overrides, not data
- State machine strained at 3 modes with increasingly tangled conditionals

This re-architecture ports CM SS13 PVE's **weighted concurrent action scheduler** pattern (ref: [cmss13-pve PR #442](https://github.com/cmss13-devs/cmss13-pve/pull/442)). It runs alongside the existing system via a new subsystem, allowing A/B testing on dedicated test mobs before any migration.

---

## Reference: What We're Porting From (CM PVE Human AI)

The CM system is a **weighted priority action scheduler** with concurrent execution, not a behavior tree or state machine. Key concepts we're adapting:

- **Action datums** — global singletons for weight evaluation, new instances for execution. Each defines `get_weight()` (when/how urgently to activate), `trigger_action()` (the behavior), `action_flags` (body-part exclusivity).
- **Conflict flags** — `ACTION_USING_HANDS`, `ACTION_USING_LEGS`, `ACTION_USING_MOUTH`. Two actions sharing a flag can't run simultaneously. Two actions with different flags CAN run concurrently.
- **Weight-based priority** — higher weight = runs first. Grenade throwback (50) > cover (15) > reload (15) > fire (10) > chase (6) > conversation (1). Priority emerges naturally from numbers.
- **Firearm appraisals** — weapon profile datums holding min/optimal/max range, burst count, reload behavior. We adapt this as "weapon profiles" for bows/crossbows/slings.
- **Same brain, different roles** — all CM AI uses identical brain logic. Role differences come from equipment + weapon profiles. We follow this pattern.

Key CM files for reference (in `cmss13-devs/cmss13-pve` repo):
- `code/datums/components/human_ai.dm` — component attachment
- `code/modules/mob/living/carbon/human/ai/brain/ai_brain.dm` — core decision loop
- `code/modules/mob/living/carbon/human/ai/action_datums/action_datums.dm` — action base + global list
- `code/modules/mob/living/carbon/human/ai/action_datums/fire_at_target.dm` — ranged combat (223 lines)
- `code/modules/mob/living/carbon/human/ai/brain/ai_brain_cover.dm` — cover system with recursive scoring
- `code/modules/mob/living/carbon/human/ai/ai_gun_data/firearm_appraisal.dm` — weapon profiles

---

## Architecture

```
SSnpc_actions (0.2s / 5Hz tick)
  └─ For each /datum/npc_ai_controller:
       1. Skip if incapacitated/dead/has client
       2. If IDLE (no target): only tick idle_wander, skip full evaluation (cheap path)
       3. If COMBAT (has target): full action evaluation (expensive path):
           a. Handle resist/stand (highest implicit priority)
           b. Scan for targets (reuse should_target() logic)
           c. Build eligible action list from GLOB.npc_ai_actions
           d. Call get_weight(controller) on each → filter weight > 0
           e. Sort by weight descending
           f. For each: check body_flags conflicts vs ongoing actions
           g. No conflict → instantiate, add to ongoing_actions
           h. Tick all ongoing_actions → COMPLETED / UNFINISHED / BLOCK
```

**Concurrent actions via conflict flags** — the core improvement. An NPC can:
- Attack (HANDS) while repositioning (LEGS)
- Cast a spell (CONCENTRATION) while fleeing (LEGS)
- Juke/backstep (LEGS) in the same tick as a melee strike (HANDS)

**Performance tiers via spatial grid + combat gating:**
- **SLEEP** — No clients in spatial grid range. Not in subsystem at all. Zero cost.
- **IDLE** — Clients nearby but no target. Cheap path: only `idle_wander` + target scan every ~1-2s. Minimal cost.
- **COMBAT** — Has a target. Full 5Hz action evaluation with weights + conflicts. This is the expensive path.

The 5Hz cost is proportional to **NPCs-in-combat**, not total NPCs. With spatial grid keeping total active pool small, and most active NPCs just wandering in IDLE, the realistic concurrent combat count should stay well under 100. Target: ~5-15 NPCs in full COMBAT evaluation at any given time during normal gameplay, with spikes to ~50-100 during admin events.

---

## Current System Analysis (What We're Working With)

### The `_npc.dm` System (`code/modules/mob/living/carbon/human/npc/_npc.dm`)

Procedural state machine on `/mob/living/carbon/human`, driven by `SShumannpc` (1s tick):

```
process_ai()
  ├─ resist / stand up
  ├─ move_along_path()  (A* pathfinding with Z-level, jumping, climbing)
  ├─ tree climbing / taunts
  └─ handle_combat()
       ├─ NPC_AI_IDLE  → view(7) scan, retaliate()
       ├─ NPC_AI_HUNT  → validate target → flee check → pickup weapon → path → monkey_attack()
       └─ NPC_AI_FLEE  → walk_away()
```

**What's good (preserve this):**
- `do_best_melee_attack()` — weapon/grab/intent selection, zone targeting, offhand grab escalation (~120 lines of battle-tested code). We keep this as a single monolithic action datum.
- `npc_try_backstep()` / juke system — stat-based dodge chance, directional movement. Becomes `juke` action datum.
- Pathfinding — A* with Z-level, jumping, climbing, hazard avoidance. Ports into `pursue_target` action datum.
- `should_target()` — faction checks, sneak detection, stat-based perception. Action datums call this directly on the pawn.
- `npc_detect_sneak()` — stat-based detection with armor/luck modifiers. Called by controller's target scan.
- Spatial grid wake/sleep (`cell_tracker`, `consider_wakeup()`). Moves from mob to controller datum.

**What's bad (replace this):**
- Fixed sequential execution — can't move + attack in same tick
- `handle_combat()` switch/if chain — adding ranged/mage means more spaghetti
- NPC specialization via type overrides — every new behavior needs a subtype
- No priority system — ordering is hardcoded in proc flow

### The Blackboard System (`code/datums/ai/`)

TG-derived behavior tree for simple mobs. **Stays as-is** for simple animals. Not relevant to this rearchitecture. The new system is for `/mob/living/carbon/human` NPCs only.

### Ranged Weapon Mechanics (Critical Constraint)

**Bows** (`code/game/objects/items/rogueweapons/ranged/bows.dm`):
- Charge system runs through `user.client.chargedprog` — **requires a client**
- Charge time: `((10 - (bow_skill * 2)) + 20 - perception) / 10 SECONDS`
- Spread based on charge percentage: full charge = 0 spread
- Accuracy scales with STAPER and bow skill

**Crossbows** (`code/game/objects/items/rogueweapons/ranged/crossbows.dm`):
- Manual cock via `attack_self()`, reload time based on STR + skill
- Less client-dependent but still uses `process_fire()`

**Simple mob ranged** (`code/modules/mob/living/simple_animal/hostile/hostile.dm`):
- `RangedAttack()` → `OpenFire()` → `Shoot()` — spawns projectile directly, no charge
- Skeleton archer uses this pattern (not actually using a bow mechanically)

**Conclusion:** NPC ranged combat MUST bypass the player charge system. We use pseudo-cooldown + direct projectile creation, with stat-scaled accuracy/damage to approximate what a player would get at ~80% charge. This is the accepted compromise.

---

## Files to Create

### 1. `code/__DEFINES/ai/_npc_ai.dm` — Defines

```dm
// Processing flag (add to code/__DEFINES/flags.dm after PROCESSING_ICON_UPDATES)
#define PROCESSING_NPC_ACTIONS (1<<14)

// Action conflict flags (body-part exclusivity)
#define NPC_ACTION_HANDS        (1<<0)
#define NPC_ACTION_LEGS         (1<<1)
#define NPC_ACTION_CONCENTRATION (1<<2)  // for future mage combat

// Action return values
#define NPC_ACTION_COMPLETED    1  // Done, remove action
#define NPC_ACTION_UNFINISHED   2  // Still running, tick again
#define NPC_ACTION_BLOCK        3  // Still running, stop processing further actions this tick
```

### 2. `code/controllers/subsystem/rogue/npc_actions.dm` — Subsystem

```dm
SUBSYSTEM_DEF(npc_actions)
    name = "NPC Actions"
    wait = 0.2 SECONDS  // 5Hz — responsive concurrent combat
    flags = SS_POST_FIRE_TIMING|SS_KEEP_TIMING
    priority = 50
```

- Iterates `GLOB.npc_ai_controllers` (list of active controllers)
- `stat_entry()` displays `A:[active_in_combat]|P:[total_pool]` for stress testing
- `MC_TICK_CHECK` yielding per-controller
- Initializes `GLOB.npc_ai_actions` (action singletons) on world init via `setup_actions()` proc

Reference existing subsystem patterns:
- `code/controllers/subsystem/rogue/humannpc.dm` — current NPC subsystem (pop-from-end iteration, MC_TICK_CHECK, waitfor=FALSE)
- `code/controllers/subsystem/ai_controller.dm` — SSai_controllers (GLOB list iteration, cost tracking, stat_entry)

### 3. `code/datums/npc_ai/_npc_ai_controller.dm` — Controller Datum (The Brain)

Attached to a `/mob/living/carbon/human`. Holds all AI state:

| Field | Purpose |
|---|---|
| `pawn` | The mob we control |
| `ongoing_actions` | Currently executing action instances (list) |
| `action_whitelist` / `blacklist` | Per-controller action filtering (list of typepaths) |
| `target` | Current combat target (mob/living) |
| `enemies` | Enemy tracking list |
| `blackboard` | Assoc list for shared state between actions |
| `cell_tracker` | Spatial grid wake/sleep (moved from mob to controller) |
| `weapon_profile` | Cached `/datum/npc_weapon_profile` for held weapon |
| `ai_status` | SLEEP / IDLE / COMBAT state |
| `interesting_dist` | Spatial grid wake range (default `AI_DEFAULT_INTERESTING_DIST` = 10) |

Key procs:
- `process(delta_time)` — main decision loop (see Architecture above)
- `get_target()` — target scan, delegates to `pawn.should_target()` on mobs in `view(7, pawn)`
- `attach_to_pawn(mob)` / `detach()` — lifecycle + signal registration
- `set_ai_status(new_status)` — SLEEP/IDLE/COMBAT management + subsystem registration
- `get_active_body_flags()` — returns OR'd `action_flags` of all ongoing actions (for conflict check)
- `on_client_enter()` / `on_client_exit()` — spatial grid signals, wake/sleep transitions

Spatial grid integration follows the pattern in `_npc.dm` lines 957-1005:
- `cell_tracker` with `recalculate_cells()` on pawn movement
- Register for `SPATIAL_GRID_CELL_ENTERED/EXITED(SPATIAL_GRID_CONTENTS_TYPE_CLIENTS)` signals
- `consider_wakeup()` checks if any clients in member cells

### 4. `code/datums/npc_ai/_npc_ai_action.dm` — Action Base

Global singletons for weight evaluation, new instances for execution:

```dm
/datum/npc_ai_action
    var/action_flags = NONE  // NPC_ACTION_HANDS | NPC_ACTION_LEGS etc.

    // Called on global singleton — return 0 to skip, >0 for priority
    proc/get_weight(datum/npc_ai_controller/controller)

    // Called on global singleton — return list of incompatible action types
    proc/get_conflicts(datum/npc_ai_controller/controller)

    // Called on new instance when selected
    proc/on_added(datum/npc_ai_controller/controller)

    // Called on instance each tick — return NPC_ACTION_COMPLETED/UNFINISHED/BLOCK
    proc/trigger_action(datum/npc_ai_controller/controller)
```

Action singleton pattern (from CM): `GLOB.npc_ai_actions` is initialized at world start by iterating `subtypesof(/datum/npc_ai_action)` and creating one instance of each. During the decision phase, `get_weight()` and `get_conflicts()` are called on these singletons. When an action is selected, a NEW instance is created with the controller reference and runs until completion.

### 5. Action Datums — `code/datums/npc_ai/actions/`

#### `melee_attack.dm` — Weight ~10, Flags: HANDS
- Wraps existing `do_best_melee_attack()` as one monolithic action
- Requires pawn adjacent to target
- All grab/intent/zone/wielding logic preserved as-is inside `trigger_action()`
- Calls `pawn.monkey_attack(target)` which chains into `do_best_melee_attack()`
- Returns NPC_ACTION_COMPLETED after one attack (re-evaluated next tick for weight)
- Key existing procs used: `_npc.dm:777 do_best_melee_attack()`, `_npc.dm:871 monkey_attack()`

#### `pursue_target.dm` — Weight ~6, Flags: LEGS
- Ports pathfinding: `start_pathing_to()`, `move_along_path()`, `validate_path()`
- Includes jump logic (`npc_try_jump()`, `npc_try_jump_to()`)
- Returns NPC_ACTION_UNFINISHED while pathing, COMPLETED when adjacent or path lost
- Increments frustration on failure, clears path and returns COMPLETED on give-up
- Key existing procs used: `_npc.dm:438 start_pathing_to()`, `_npc.dm:327 move_along_path()`, `_npc.dm:308 validate_path()`, `_npc.dm:210 npc_try_jump()`

#### `keep_distance.dm` — Weight ~8, Flags: LEGS
- Uses weapon profile to determine optimal range
- Steps away if closer than `minimum_range`, approaches if beyond `optimal_range`
- For melee NPCs: only gets weight > 0 briefly after attacking (backstep window)
- For ranged NPCs: maintains optimal firing distance continuously
- Conflicts with `pursue_target` (both use LEGS)

#### `ranged_attack.dm` — Weight ~10, Flags: HANDS
- Bypasses client-dependent charge system entirely
- Creates projectile directly via the `Shoot()` pattern from `simple_animal/hostile`
- Reference: `code/modules/mob/living/simple_animal/hostile/hostile.dm:462 Shoot()`
- Accuracy/damage scaled by NPC's STAPER + bow/crossbow skill to approximate ~80% charge
- Pseudo-cooldown from weapon profile (approximate charge time)
- Checks firing line for walls/friendlies before shooting (trace `get_line()` from shooter to target)
- Returns NPC_ACTION_COMPLETED after firing

#### `flee.dm` — Weight ~15, Flags: LEGS
- Ports existing NPC_AI_FLEE logic from `_npc.dm:670-698`
- Activates when `flee_in_pain` + pain threshold exceeded (`get_complex_pain() >= STAWIL*10*0.9`)
- `walk_away()` from nearest visible threat
- Returns NPC_ACTION_UNFINISHED until safe distance reached

#### `resist.dm` — Weight ~20, Flags: HANDS+LEGS
- Ports `npc_should_resist()` + `resist()` logic from `_npc.dm:86-116`
- On fire, buckled, restrained triggers
- Highest combat priority — always runs first due to weight

#### `pickup_weapon.dm` — Weight ~16 (unarmed) / ~4 (armed), Flags: HANDS+LEGS
- Ports weapon pickup from `handle_combat()` HUNT branch (`_npc.dm:640-649`)
- Very high weight when unarmed (matches CM's pattern: 16 unarmed vs 11 armed)

#### `juke.dm` — Weight ~9, Flags: LEGS
- Ports `npc_try_backstep()` from `_npc.dm:541-584` as reactive post-attack action
- Controller sets a short `juke_window` timer after melee attack lands
- Only gets weight > 0 during that window
- **This is the key "no more stutter" fix** — juke (LEGS) fires same tick as melee (HANDS)

#### `idle_wander.dm` — Weight ~1, Flags: LEGS
- Ports `npc_idle()` wandering + emotes from `_npc.dm:167-185`
- Only when no target, nothing else to do

### 6. `code/datums/npc_ai/_weapon_profile.dm` — Weapon Profiles

```dm
/datum/npc_weapon_profile
    var/minimum_range = 1
    var/optimal_range = 1
    var/maximum_range = 1
    var/cooldown_time = 0       // deciseconds, pseudo-cooldown matching charge time
    var/is_ranged = FALSE
    var/accuracy_mult = 1.0     // base accuracy modifier

    // Behavioral modifiers — weapon dictates fighting style
    var/list/enable_actions = list()    // action types to add to whitelist on equip
    var/list/disable_actions = list()   // action types to blacklist on equip
    var/list/weight_modifiers = list()  // action type → weight multiplier (1.0 = no change)
```

The controller applies weight modifiers in the decision loop:
```dm
// In process(), when evaluating weights:
var/weight = action.get_weight(src)
if(weapon_profile?.weight_modifiers[action.type])
    weight *= weapon_profile.weight_modifiers[action.type]
```

**Equip/drop signal hookup** — weapon profiles activate automatically:
```dm
// In controller attach_to_pawn():
RegisterSignal(pawn, COMSIG_MOB_EQUIPPED_ITEM, PROC_REF(on_weapon_change))
RegisterSignal(pawn, COMSIG_MOB_DROPPED_ITEM, PROC_REF(on_weapon_change))

// Handler recaches profile from held weapon:
/datum/npc_ai_controller/proc/on_weapon_change(datum/source, obj/item/I)
    var/obj/item/weapon = pawn.get_active_held_item()
    weapon_profile = weapon ? get_profile_for(weapon) : null
```

Weapon type → profile mapping via a global assoc list keyed by weapon typepath, or `istype()` chain for broader categories.

**Subtypes — each defines a fighting style, not just stats:**

#### `/melee_default` — generic melee
- min 1, optimal 1, max 1
- No weight modifiers (baseline behavior)

#### `/sword` — aggressive closer
- min 1, optimal 1, max 1
- `weight_modifiers`: pursue_target × 1.3, juke × 0.7 (pressure over evasion)

#### `/dagger` — rogue flanker
- min 1, optimal 1, max 1
- `weight_modifiers`: juke × 2.0, pursue_target × 1.5, flee × 0.5 (constant repositioning, commits hard)

#### `/spear` — mid-range spacer
- min 2, optimal 2, max 2
- `weight_modifiers`: keep_distance × 1.3, juke × 1.4 (backsteps to maintain tip range)

#### `/bow` — kiting archer
- min 3, optimal 6, max 10, cooldown ~20ds (2 seconds)
- `is_ranged = TRUE`
- `enable_actions`: ranged_attack, keep_distance
- `weight_modifiers`: keep_distance × 1.5, pursue_target × 0.3, flee × 1.2 (strongly prefers range)

#### `/crossbow` — shoot-and-relocate
- min 2, optimal 5, max 8, cooldown ~30ds (3 seconds reload)
- `is_ranged = TRUE`
- `enable_actions`: ranged_attack, keep_distance
- `weight_modifiers`: keep_distance × 2.0 (very strong retreat-while-reloading), flee × 0.8 (calculated, not panicky)

#### `/heavy_crossbow` — static sniper
- min 3, optimal 7, max 12, cooldown ~80ds (8 seconds reload)
- `is_ranged = TRUE`
- `enable_actions`: ranged_attack, keep_distance
- `weight_modifiers`: keep_distance × 2.5, pursue_target × 0.1 (barely moves, holds position)

#### `/sling` — mobile skirmisher
- min 2, optimal 4, max 7, cooldown ~15ds (1.5 seconds)
- `is_ranged = TRUE`
- `enable_actions`: ranged_attack, keep_distance
- `weight_modifiers`: juke × 1.3, pursue_target × 0.8 (mobile, repositions frequently)

### Difficulty Tuning via `combat_proficiency`

The controller can carry a `var/combat_proficiency = 1.0` (0.0 to 1.5+) that globally scales behavior quality:

| Behavior | Low Proficiency (0.3) | High Proficiency (1.0+) |
|---|---|---|
| `juke` weight | × 0.3 (rarely jukes) | × 1.0+ (always jukes) |
| `flee` pain threshold | 50% health (coward) | 15% health (fights to death) |
| `pickup_weapon` reaction | weight × 0.3 (slow) | weight × 1.0 (instant) |
| `keep_distance` | weight × 0.3 (bad spacing) | weight × 1.0 (disciplined) |
| ranged cooldown | × 1.5 (fumbles) | × 0.8 (efficient) |

This multiplies with weapon modifiers: `final_weight = base_weight * weapon_modifier * combat_proficiency`. A dumb bandit with a spear still tries to space (weapon says so) but does it badly (proficiency says so).

### 7. Test Mobs — `code/modules/mob/living/carbon/human/npc/soldiers/highwayman_v2.dm`

New highwayman variants using the action system, based on existing highwayman at `code/modules/mob/living/carbon/human/npc/soldiers/highwayman.dm`:

#### Melee Highwayman (baseline A/B test)
- Same stats/gear as existing highwayman
- Uses `npc_ai_controller` instead of SShumannpc
- Should fight identically but with concurrent juke+attack — no more stutter-stop

#### Ranged Highwayman (archer)
- Equipped with bow + arrows, light armor
- Higher STAPER (~12-14) for accuracy
- Bow skill ranks (2-3)
- `ranged_attack` + `keep_distance` actions enabled
- Maintains 5-6 tile distance, fires with pseudo-cooldown

#### Rogue Mage Highwayman (future test placeholder)
- Equipped with a staff/wand
- For now: uses `ranged_attack` with a wand weapon profile as prototype
- Future: `cast_spell` action datums with per-spell weights

---

## Integration — Minimal Changes to Existing Code

| File | Change |
|---|---|
| `code/__DEFINES/flags.dm` | Add `#define PROCESSING_NPC_ACTIONS (1<<14)` after line 33 |
| `code/modules/mob/living/carbon/human/npc/_npc.dm` | Add `var/datum/npc_ai_controller/npc_controller`. In `handle_ai()`: if `npc_controller`, skip `START_PROCESSING(SShumannpc, src)`. In `Destroy()`: `QDEL_NULL(npc_controller)`. |

**Everything else is new files.** The old system is untouched and continues running for all existing NPC types. Action datums **call** existing procs on the pawn (`do_best_melee_attack`, `should_target`, `start_pathing_to`, etc.) — they wrap them, they don't replace them.

A mob uses EITHER the old system (SShumannpc) OR the new one (SSnpc_actions), never both. Controlled by whether `npc_controller` is set.

---

## Implementation Order

### Step 1: Scaffolding
- Defines (`_npc_ai.dm`)
- Processing flag in `flags.dm`
- Subsystem (`npc_actions.dm`) with `stat_entry()` showing `A:|P:`
- Controller datum skeleton (`_npc_ai_controller.dm`) with spatial grid wake/sleep
- Action base datum (`_npc_ai_action.dm`) with singleton pattern
- Mob integration: `npc_controller` var + `handle_ai()` gate

### Step 2: Core Actions (Melee Parity)
- `idle_wander.dm`
- `pursue_target.dm` (port pathfinding — the hard one, ~200 lines of path logic)
- `melee_attack.dm` (wrap `do_best_melee_attack()` — straightforward)
- `juke.dm`
- `resist.dm`
- `pickup_weapon.dm`
- `flee.dm`

### Step 3: Test Mob + Validation
- Melee highwayman v2 mob
- Compile, spawn, verify behavior matches old system
- Stress test: 20x old vs 20x new, compare subsystem costs via stat panel

### Step 4: Ranged Combat
- Weapon profiles (`_weapon_profile.dm`)
- `ranged_attack.dm` action datum
- `keep_distance.dm` action datum (range-aware)
- Archer highwayman test mob
- Firing line checks, stat-scaled accuracy

### Step 5: (Future) Mage Combat
- `cast_spell.dm` action datum base
- Per-spell subtypes with weight functions
- `NPC_ACTION_CONCENTRATION` conflict flag usage
- Mage highwayman test mob

### Step 6: (Future) Full Migration
- Migrate existing NPC subtypes from SShumannpc → SSnpc_actions one at a time
- Eventually deprecate SShumannpc

---

## Verification

1. **Compile**: All new files included in `.dme`, no errors
2. **Stat panel**: `SSnpc_actions` row shows `A:X|P:Y` in MC tab
3. **Melee A/B**: Spawn old highwayman + new highwayman v2, both fight same target — observe combat quality
4. **Concurrency**: New highwayman jukes in the same tick as attacking (no stutter-stop between attack and movement)
5. **Ranged**: Archer highwayman maintains distance, fires arrows with stat-scaled accuracy and pseudo-cooldown
6. **Wake/sleep**: Walk away from NPC → enters SLEEP (drops from A: count). Walk back → wakes to IDLE. Aggro → enters COMBAT.
7. **Performance**: Spawn 40 NPCs (20 old, 20 new). Compare subsystem costs. Target: new system ≤ 1.5x cost of old at 5Hz, with combat-only mobs being the dominant cost.
