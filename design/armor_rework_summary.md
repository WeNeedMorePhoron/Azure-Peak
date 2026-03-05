# ARMOR REWORK SUMMARY

## Remove:
- Armor integrity system (`code/__DEFINES/armor_defines.dm` — all `ARMOR_INT_*`, `ARMOR_INTEG_FAILURE`)
- Layer shredding (`code/datums/components/layer_armor.dm`)
- Coverage peeling (`code/game/objects/items.dm:1625-1683`)
- Regenerating armor (`code/modules/clothing/rogueclothes/armor/regenerating.dm`, `code/modules/clothing/rogueclothes/armor/manual.dm`)
- Armor break/fix cycle (`code/game/objects/obj_defense.dm:233-250`)
- Blade sharpness degradation (`code/game/objects/items/rogueweapons/integrity.dm`) — design call

## DR System:
- Formula: `damage_taken = damage * 100 / (100 + DR)`
- Armor = matrix of 4 values: cut, stab, blunt, fire
- Rewrite `checkarmor()` in `code/modules/mob/living/carbon/human/human_defense.dm`

## Armor Classes & Triangle:

| Class | Type | Trades best vs | Trades well vs | Vulnerable to |
|-------|------|---------------|----------------|---------------|
| Heavy | Plate | Cut | Stab | Blunt |
| Medium | Mail/Brigandine | Stab | Cut | Cut (less so) |
| Light | Leather | Cut (light-on-light) | Ranged | Cut, Stab |
| Light | Cloth/Gambeson | Blunt, Ranged | Light-on-light | Cut, Stab |

- Light armor is generally inferior vs cut and stab — it mitigates within its niche, not "shrugs off"
- Heavy/medium have the privilege of truly blocking damage types

## Armor Tiers:
- Each class: BiS, Budget, Antag variant (~9-12 items total)
- Cloth vs Leather is a lateral choice within Light, not a tier difference

## Layering:
- Outermost layer = base DR per type
- Same class underlayer → +5
- Different class underlayer with higher DR for that type → +10
- Otherwise → nothing
- Max 3 layers, cap 100 DR (50% reduction)

## Health Budget:
- Increase limb HP significantly to compensate for DR% system
- Fights should last ~8-12 exchanges (light-vs-light baseline)
- Heavy armor extends to ~15-20 exchanges against wrong damage type, right damage type brings it back to baseline
- More HP budget = bleed/crit thresholds (50%/75%) are meaningful milestones
- More room for physician gameplay and regen buffer healing model
- Tune by feel via NPC testing, not theorycrafting

## Thresholds:
- Bleed rolls suppressed until 50% global HP
- Crit rolls suppressed until 75% global HP
- Crits ignore armor once threshold met
- No projectile/embed can crit before thresholds
- Global maxHP forces hard crit

## NPC Thresholds:
- NPCs use same bleed/crit threshold system but halved (25% bleed, 37.5% crit)
- Hard-tier NPCs use full player thresholds (50%/75%)
- Prevents NPCs from being trivially easy under the new system

## Healing Rework:
- Red potions → regeneration buffer (1 min delay, interrupted by damage)
- Miracles → 0.5 direct heal + regen buffer
- Surgery/wound healing bypasses buffer
- Fortify multiplies buffer accumulation
- Defensive spells: Barkskin (+DR, +fire vuln), Ironskin (+DR, +weight), Stoneskin

## Sound Design:
- Always play impact sounds regardless of DR absorption
- Cloth/leather tear for light hits, metal clang for heavy
- Distinct "penetrated" sound when damage gets through

## Bleed Rate Scaling:
- Bleed rate scales inversely with remaining blood: `amt *= max(blood_volume / BLOOD_VOLUME_NORMAL, 0.25)`
- At full blood: 100% bleed rate. At half blood: 50%. Floor at 25%.
- Bad wounds still kill if untreated, just slower as blood drains
- Gives physicians a wider window as patient condition worsens
- Modify in `bleed()` proc in `code/modules/mob/living/blood.dm`

## Blunt Weapons:
- No code changes needed
