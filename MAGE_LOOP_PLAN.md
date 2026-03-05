# Mage Gameplay Loop 2 — Implementation Plan

## Context

Current mage loop is grindy, isolated, and barely produces interaction. This replaces it with a discovery-driven loop: find leylines in the world, draw circles, fight challenging multi-mob encounters, gather materials. High impact, nearly all reuses existing assets.

## Core Design

1. **Leylines are the sites** — reuse existing `/obj/structure/leyline`, add subtypes (Tamed/Normal/Powerful), place many more on the map via generators
2. **Draw a circle at the leyline** — mage scribes an existing summoning rune (T1-T4) near the leyline
3. **Activate** — mage clicks the leyline with a nearby rune → triggers encounter based on rune tier
4. **Charge system** — 1 charge per in-game day (`GLOB.dayspassed + 1`). All tiers cost 1 charge. Tracked per `real_name`.
5. **Day gating** — T1-T2 from day 1, T3 from day 3, T4 from day 4, T5 (Void Dragon) from day 5
6. **No material cost** — summoning is free (charge + time + fight IS the cost). Exception: Void Dragon requires 5 runed artifacts.
7. **Mob deaggro** — high `deaggroprob` so unfinished encounters naturally fade instead of hard despawn
8. **Discovery** — prestidigitation 4th intent (INTENT_GRAB) senses leylines in mega-region
9. **Wrong alignment** — can use any leyline for any realm, but wrong alignment = -1 mob. Neutral leylines (tamed) are never aligned — always -1, giving training-wheel minimum (2 mobs for T1). Powerful leylines (Bog) always give +1 primary independent of alignment penalty.
10. **"Gone wrong"** — 33% chance per ritual of +2 extra mobs spawning. More risk, more reward.

## Leyline Types

| Type | Location | Alignment | Uses/Day | Max Ritual Tier |
|------|----------|-----------|----------|-----------------|
| Tamed | Hamlet, Mage Tower basement | Neutral (always wrong) | 4 | T1 only |
| Normal (Coast) | Coast generator | Elemental | 2 | T4 |
| Normal (Grove) | Azure Grove generator | Fae | 2 | T4 |
| Normal (Decap) | Mount Decapitation generator | Infernal | 2 | T4 |
| Powerful (Bog) | Terrorbog generator | Void/Lycan | 2 | T5 (via T4 circle) |

## Material Economy

### Mob Drops (same-tier only, no cross-tier)

| Mob Tier | Drops | Amount per mob |
|----------|-------|----------------|
| T1 | T1 realm mat (ash/fairydust/mote) | 4 |
| T2 | T2 realm mat (fang/scale/shard) | 2 |
| T3 | T3 realm mat (core/heartwood/fragment) | 1 |
| T4 | T4 realm mat (flame/essence/relic) | 1 |
| Leyline Lycan | Leyline shard | 1 |
| Voidstone Obelisk | Voidstone | 1 |
| Void Dragon | Dragon rings + spellbooks | 3 each |

### Enchanting Costs (realm-aligned, cinnabar + scroll always required)

| Tier | Realm Mat Cost | Extra |
|------|---------------|-------|
| T1 | 4x T1 realm mat | — |
| T2 | 2x T2 realm mat | — |
| T3 | 1x T3 realm mat | + 1 leyline shard |
| T4 | 1x T4 realm mat | + 1 leyline shard |
| Void (T3/T4) | 1x voidstone | + 1 leyline shard |

Each mob = exactly 1 enchantment of that tier. No melds for enchanting.

### Enchantment Realm Classification

**Elemental:** Woodcutting, Mining (T1) | Unbreaking, Longstriding, Smithing (T2) | Lightning, Frostveil (T3) | Freezing (T4)
**Fae:** Xylix's Grace, Holding (T1) | Dark Vision, Feather Step, Spider Movements (T2) | Returning Weapon (T3) | Briar's Curse, Temporal Rewind (T4)
**Infernal:** Unyielding Light, Revealing Light (T1) | Fire Resistance, Thievery (T2) | Lyfestealing, Archery (T3) | Infernal Flame (T4)
**Void:** Voidtouched (T3) | Chaos Storm (T4)

### Binding Costs (realm mat + meld + artifacts)

| Tier | Realm Mat | Meld | Artifacts |
|------|-----------|------|-----------|
| T1 | 4x T1 mat | 1x T1 meld | 1 |
| T2 | 2x T2 mat | 1x T2 meld | 2 |
| T3 | 1x T3 mat | 1x T3 meld | 3 |
| T4 | 1x T4 mat | 1x T4 meld | 4 |
| Void Dragon | — | — | 5 |

Melds gate binding (force realm diversity — need materials from all 3 realms, meaning 3 days or cooperation).

### Sunset Items
- **Obsidian:** Obsoleted entirely
- **Mana Crystal:** Obsoleted entirely
- **Runed Artifact Synthesis:** Removed (artifacts are found, not crafted)

---

## Implementation Status

### DONE

- [x] **Leyline subsystem & charge system** — `leylines.dm`: GLOB.leyline_sites, charge tracking, day gating
- [x] **Leyline subtypes** — `leylines.dm`: tamed/normal(coast,grove,decap)/powerful with alignment, uses, max_tier
- [x] **15 leyline encounter ritual datums** — `summons.dm`: infernal/fae/earthen T1-T4, leyline T2, void T2, void dragon T5
- [x] **Encounter spawning logic** — `summons.dm` on_finished_recipe: charge check, day gate, alignment, gone wrong, chant+do_after, mob spawning
- [x] **Leyline detection** — `prestidigitation.dm`: 4th intent (INTENT_GRAB), senses top 5 leylines with direction/distance/exhaustion
- [x] **Map generator placement** — coast.dm, forest.dm, decap.dm, bog.dm: leyline subtypes in spawnableAtoms
- [x] **Binding Array rune** — `ritualrunes.dm`: T2 + T4 greater binding array, loads binding ritual lists
- [x] **Binding ritual datums** — `binding.dm`: 12 rituals (4 tiers x 3 realms), realm mat + meld + artifacts(tier count)
- [x] **Binding ritual list generators** — `_ritual.dm`: t2/t4 binding list procs, binding excluded from allowed list
- [x] **Enchantment realm-alignment rework** — `enchanting.dm`: all enchantments classified by realm, costs match 1 mob's drops
- [x] **Mob drop normalization** — all 12 mob death() procs: T1=4, T2=2, T3=1, T4=1, no cross-tier, no melds
- [x] **Void dragon artifact requirement** — `summons.dm`: 5 runed artifacts in required_atoms

### TODO

- [ ] **Remove old lab summoning rituals** — delete old `/datum/runeritual/summoning/` datums that used the basement flow (the ones that summoned individual creatures via summon_ritual_mob). These are distinct from the new `/datum/runeritual/summoning/leyline_encounter/` datums.
- [ ] **Remove summon_ritual_mob() proc** — the old proc that spawned a single creature with GODMODE/PACIFISM for the seal-and-release flow
- [ ] **Remove seal-and-release flow** — the `attack_hand` code on summoning runes that removed GODMODE/PACIFISM from summoned creatures
- [ ] **Remove runed artifact synthesis recipe** — find and delete wherever artifacts are craftable
- [ ] **Sunset obsidian from recipes** — remove obsidian requirements from any remaining ritual/enchantment recipes (leave item definition)
- [ ] **Sunset mana crystal from recipes** — remove mana crystal requirements from any remaining recipes (leave item definition)
- [ ] **Hand-place tamed leylines** — place 2x `/obj/structure/leyline/tamed` in DMM (hamlet + mage tower basement)
- [ ] **Chant text** — replace placeholder "LatinChant1" etc. with actual chant lines (owner will do this)

### DEFERRED (Phase 2)

- [ ] Arcyne Fluctuation world events (1-2 per week, large mob spawn at random leyline)
- [ ] Further enchantment rebalancing (stat effects → status effects, T4 nerfs)
- [ ] Synthesis recipe rework (2:1 catch-up ratio for cross-tier trading)

---

## Key Files Modified

| File | What Changed |
|------|-------------|
| `code/modules/roguetown/roguejobs/mages/leylines.dm` | NEW — leyline subsystem, subtypes, charge/gating procs |
| `code/modules/roguetown/roguejobs/mages/rituals/summons.dm` | REWRITTEN — 15 leyline encounter rituals + encounter spawning |
| `code/modules/roguetown/roguejobs/mages/rituals/enchanting.dm` | REWRITTEN — realm-aligned costs |
| `code/modules/roguetown/roguejobs/mages/rituals/binding.dm` | REWRITTEN — 12 binding rituals with artifact+meld+mat costs |
| `code/modules/roguetown/roguejobs/mages/rituals/_ritual.dm` | MODIFIED — binding list generators, exclusion |
| `code/modules/roguetown/roguejobs/mages/ritualrunes.dm` | MODIFIED — binding array rune (T2+T4) |
| `code/modules/spells/spell_types/wizard/utility/prestidigitation.dm` | MODIFIED — 4th intent for leyline sensing |
| `code/modules/roguetown/mapgen/beach.dm` | MODIFIED — coast leyline in generator |
| `code/modules/roguetown/mapgen/forest.dm` | MODIFIED — grove leyline in generator |
| `code/modules/roguetown/mapgen/decap.dm` | MODIFIED — decap leyline in generator |
| `code/modules/roguetown/mapgen/bog.dm` | MODIFIED — powerful leyline in generator |
| `code/modules/mob/living/simple_animal/hostile/retaliate/summons/infernal/*.dm` | MODIFIED — normalized drops |
| `code/modules/mob/living/simple_animal/hostile/retaliate/summons/fae/*.dm` | MODIFIED — normalized drops |
| `code/modules/mob/living/simple_animal/hostile/retaliate/summons/elemental/*.dm` | MODIFIED — normalized drops |
