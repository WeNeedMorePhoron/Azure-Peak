# NPC STATPACK TIERS

This is for documentation on standardization of NPC stats / statpacks for future maintainence and design purpose.

NPC statpacks are sorted by Archetypes and then separated into tiers. Set 10 as the baseline stats for SPD / STR 10.

| Tier | Archetype                           | Con / Wil | STR | SPD | PER | INT | TP                        |
| ---- | ----------------------------------- | --------- | --- | --- | --- | --- | ------------------------- |
| 0    | Goblins. Trash Mobs. Novice Skills. | 4         | 8   | 10  | 9   | 7   | TRASH / LOW (8-10)        |
| 1    | Highwayman. Typical Filler.         | 6         | 10  | 10  | 10  | 8   | MODERATE / HIGH (14-20)   |
| 2    | Mount Reaver. Trained Infantry.     | 8         | 12  | 10  | 11  | 9   | TOUGH / DANGEROUS (25-30) |
| 3    | Road Knight. Champion.              | 10        | 14  | 10  | 12  | 10  | DEADLY (40)               |
| 4    | Sackman. God-Tier.                  | 12        | 14  | 10  | 13  | 11  | ELITE and up (50+)        |

SPD does not scale with Tier. STR, PER and INT do.

STR is hard-capped at 14 and nothing will go pass it.

## Archetype Modifier

Each role is its tier row with a trade in stats, using the conventional statweight of STR / SPD = 2. And the rest = 1.

| Role     | Trade                               |
| -------- | ----------------------------------- |
| line     | none, baseline                      |
| light    | 1 STR -> 2 PER, then 1 STR -> 1 SPD |
| marksman | 2 STR -> 4 PER                      |
| heavy    | 2 SPD, 2 PER -> 1 STR, 2 Con, 2 Wil |
| undead   | Con -> Wil                          |

Archetype:

- Light trade 1 STR for 2 Perception, and then 1 STR for 1 SPD
- Marksman trade 2 STR for 4 Perception, and then 1 STR for 1 SPD.
- Heavy trades 2 SPD, 2 PER, 2 INT for 2 STR, 12 Con, 2 Wil
- Undead trade 2 CON for 2 WIL for better stamina and to make them easier to kill than human counterpart due to their durability.

## Armor & Weapons

In general, for armor:

- At T2 or beyond, full or near full coverage should be expected but with weaknesses
- Line can be whatever, as appropriate for their faction, but should have competent coverage.
- Bulwark should have full if not nearly full coverage, especially at T2 or above.
- Marksmen should possesses an open faced helmet and or non-armored mask, and never a close faced helmet or mask no matter what.
- With very few exceptions, do not get Steel ARMOR on players.
- Steel weapons are occasionally allowed for appropriate factions, leaning toward Azurian one.
- Desirable player weapons of low cost like Longbow can make occasional appearances, but should not be too common

## Faction Archetypes

- Goblins: Shit sucks and their weapons and armor are overwhelmingly disastrous.
- Azurian / Native Bandits (Highwayman, Mount Reavers etc.): Being of native origin means access to better steel weapons but iron armor. "Line" or "Medium" should starts with common, late renaissance ish gears i.e. Gambeson and Cuirass and open-faced helmets. Full iron coverage can be seen
- Bogman: Higher quality gears implying direct desertion from the military, full iron gears for all but their light classes should be expected, with occasional steel and high quality (Brigandine) coverage.
- Sea Raiders: Being of Gronnic origin means steel weapons should be excessively rare and armor should be light. No presence of full face coverage helmet or the combination of Open Face + Mask instead of a full helmet, since that doesn't match their technological level. Mail or Fabric / Leather should be the primary armor and their thematic Banded Iron.
- Orcs: Should overwhelmingly have light armor with iron being rare and full coverage in iron being rare, due to primitiveness, with full iron armor recovered for Warlord. Should trade INT for more STR / CON / WIL
