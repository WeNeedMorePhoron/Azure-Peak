# Econ 4 - The Market and the Royal Stockpile

One step or substep at a time, each of them a human reviewable and committable slice. Details on design can be deferred or parked until later for when it is implemented. Later steps will stay as a short list. Details can change and adapt as necessary.

Modules follow the user's Google Doc "Economy 4 Design & Planning Doc", which is canonical. Built slices keep their old step labels (2a, 2d-1, 3a) so they still match commit history.

Working rules: the PR stays unmerged until largely complete. It won't release until 10 to 15 steps from now, and may take in the underground economy. Decisions don't need to keep the game playable between steps. Each slice compiles and reads on its own so it can be committed one at a time.

## Words used in this plan

| Word | Meaning |
|---|---|
| Market | What every player sells to and buys from at the stockpile machine. Owned by nobody. |
| Royal stock | The Crown's own warehouse. Filled by caravans, tribute and Keep roles' sales. Feeds standing orders, the Royal Subsidy and Steward sales into the Market. |
| Bid | What the Market pays you for one unit. |
| Ask | What the Market charges you for one unit. |
| Stock and target | How many of a good the Market holds, and how many it wants. Both shown on screen. |
| Band | The price step for stock against target: Glut, Overstocked, Abundant, Plentiful, Steady, Low, Scarce, Very Scarce, Shortage. |
| Market dae | Once per IC day, each good's Market stock moves toward its target. Raids slow it, escorts and rented caravans keep it going or speed it up. |
| Route | One of four trade directions: Northern Seaway, Southern Seaway, Ore Road, River Azur. Each has its own trip time. |
| Subroute | One of the two halves of a route, each held by its own raiders. Named near and far, or by direction (north, south). |
| Caravan | The Steward's trip unit, built as a saiga caravan or a ship. Goes down one route and trades with two regions on it. |
| Tribute | Free goods a region gives the first caravan to visit it each dae. Takes no capacity. |
| Raiders | Today's blockade, held on a subroute instead of a single region. |
| Escort | Paid protection that lets caravans and the Market dae through one raided subroute for one dae. |

## Before Module 1 - Leather and ATC bundles (built)

- Cured leather and hide take their price from the engine.
- Bundles keep the ATC seal of what went into them, and sealed goods will not bundle with unsealed ones.
- No Crown mark on stockpile goods. Players may buy and sell the same goods freely.

## Module 1 - Decimal pricing (built)

### Step 1 - Fractional prices

Prices can be 1.5m instead of being forced to whole mammons. Nothing else about the stockpile or the Steward changes in this step.

- Trade good base prices and the pricing engine keep fractions all the way through. Only an item's own sell price, used by vendors, examine and ships, is rounded at the end.
- The stockpile pays and charges fractional prices. The per-player owed balance first built here was replaced by decimal balances in 1c.
- The three separate roundings in the bid and ask maths go away. The spread becomes one ratio define, `STOCKPILE_BID_RATIO` 0.75.
- Steward price inputs accepted one decimal. The inputs themselves were removed in 2d-1.
- Retune once fractions work: fibers below half of cloth, cloth, cured leather, iron. Garment and light armour prices follow through the engine.

Status: built. Fibers lowered to 1. Step 1b: regional trade, Steward imports and exports, and direct import also price in tenths.

Open: the cloth, cured leather and iron numbers.

### Step 1c - Balances hold decimals

- Every account and fund holds its exact balance to the hundredth. Mint, burn and transfer round each movement.
- Coins only come out in whole mammons. Machine coin pouches keep their fraction after a refund.
- Removed: the per-player owed balance, the fractional mint and burn, and their fund variables.
- Vault drill and bash only burn what they pay out in coins. Loan repay accepts the exact remainder.
- Goldface bulk import now charges the same tariff it mints.
- Chat text and TGUI screens show balances with decimals through one formatter each.

### Step 1d - Decimal cleanup

- Exact amounts for taxes and tax exemptions, the Concordat and bathhouse tithes, the brigand debt skim, fine caps, the rural subsidy, loan and ATC interest, standing orders, Goldface and bathhouse pack tariffs, fellowship shares, quest refunds, the innkeeper guild fee and the poll levy.
- Steward grant, fine and payroll inputs accept decimals.
- The stockpile and Vomitorium refund their pouch when destroyed.
- Messages that can now show decimals use the formatter: standing orders, fines, loans, the ATC loan, ship sale quality, blockade defense shares, and the Steward's fine caps.
- Left whole on purpose: the navigator, which pays producers in coins, and the coin changer.
- Not swept: the remaining money text that only ever prints whole amounts.

## Module 2 - The Market and the royal stock (built, 2j to do)

**Decisions (2026-11-06):**
- Two vars per good: `market_stock` and `royal_stock`.
- No market toll. Steward income is redesigned later.
- Royal Custom charter retired. Its volume variables stay until Module 7 decides whether anything still needs them.
- Prices move in steps, not a smooth curve.
- Regional import and export are parked, not removed. The backend and the current Steward trade screens stay as they are, with bug fixes only, until caravans replace them in Module 4.
- Aldermen lose the trade warrant and only issue contracts (2h). The Market restocks itself, so the warrant has nothing left to do.

**Price steps (approved 2026-11-06):**

| Market stock vs target | Price | Label |
|---|---|---|
| 200% or more | 50% | Overstocked |
| 160% to 200% | 65% | Abundant |
| 125% to 160% | 80% | Plentiful |
| 80% to 125% | 100% | Steady |
| 65% to 80% | 125% | Low |
| 50% to 65% | 150% | Scarce |
| under 50% | 200% | Very Scarce |

Glut (25%) and Shortage (300%) are the far ends of the ladder and only exist while their event is active: Glut replaces Overstocked, Shortage replaces Very Scarce. A glut pushes stock to 300% of target and ends with relief once players buy every affected good below 200%. A shortage empties the affected goods to 0 and still ends through the old relief count until Module 6. The Market price ignores the old event multiplier and uses the plain base price. Selling into the Market counts toward relieving a shortage.

Market stock never drops below 0. At 0, goods some region produces still sell at the Very Scarce price. Goods no region produces, or that can't be imported, are out of stock at 0.

**Anti-flip rule (approved):** every unit is priced at the stock it leaves behind. A purchase uses the stock after the unit leaves, a sale the stock after it arrives. A buy-then-sell round trip always loses, so step sizes are free and no guard is needed. The screen shows these exact prices.

**Slices:**
- 2a. Rename the stock count to `royal_stock` and add `market_stock`. No behaviour change. Built 2026-11-06.
- 2b. Market core. Player sales and purchases move `market_stock` at the stepped price. The Market pays sellers by minting and takes buyers' coins out of play. Removes the purchase floor, accept toggles, player limits and the full-stockpile export, with their messages. Built 2026-11-06. Keep roles' sales go to royal stock unpaid, and they draw free from royal stock while it lasts.
- 2c. Moved to Module 5.
- 2d. Steward side, in six sub-slices. Each of the first four removes one family of controls from the DM actions, the TGUI and the Steward policy export.
  - 2d-1. Manual prices and multipliers. Actions `set_buy_price`, `set_sell_price`, `toggle_auto_price`, `autoprice_all`, `autoprice_category`, and the four `multiply_*`. The `automatic_price` var and its checks go, and `snap_auto_prices` folds into `refresh_auto_price`. `payout_price` and `withdraw_price` stay as the automatic reference prices: ledger valuation uses them, and the exotic meats use them as their base price. Built 2026-11-06.
  - 2d-2. Accept toggles and the withdraw lock. Vars `accept_toggle_enabled` and `withdraw_disabled`. Actions `toggle_stockpile_accept`, `accept_category`, `reject_category`, `toggle_withdraw_disabled`, `allow_withdraw_category`, `bar_withdraw_category`. Policy fields `accept_off` and `withdraw_barred`. The stockpile screen loses "Closed" and the Crown official override; never-supplied goods keep "Not available". Built 2026-11-06.
  - 2d-3. Manual limits. Actions `set_stockpile_limit`, `toggle_auto_limit`, `autolimit_all`, `autolimit_category`. The `automatic_limit` var, `set_manual_limit`, `STOCKPILE_LIMIT_MANUAL_MAX`, and the policy `limits` field. `stockpile_limit` stays automatic as the royal stock's surplus threshold for auto-export until Module 4. Built 2026-11-06.
  - 2d-4. Show both stocks. Each Steward market row shows royal stock, and the Market's band label, stock against target, and buy and sell prices. The arbitrage potential readout goes, since the Crown no longer earns the stockpile spread. Built 2026-11-06, along with the market reference price cache and delta tag procs it left with no callers.
  - 2d-5. The Steward sells royal stock into the Market at the Market bid, minted into the Treasury and logged. It counts toward ending a shortage. Refused for never-supplied goods. Built 2026-11-06: up to 50 units a click, ledgered as Stockpile Sales, Steward only.
  - 2d-6. The Steward buys from the Market into royal stock at the Market ask, paid from the Treasury. Built 2026-11-06: up to 50 units a click, ledgered as Stockpile Purchases, ends a glut like a player purchase.
- 2e. Royal Subsidy. Each subsidised person gets 100m a day (`ROYAL_SUBSIDY_DAILY_ALLOWANCE`), counted at the Market buy price. Royal stock is drawn first. Once it runs out, the Treasury buys from the Market for them while it stays above the Steward's purchase floor. Past the allowance they pay in coins. Built 2026-11-06.
- 2f. Retire the Royal Custom charter and direct import. Keep the volume counters. Built 2026-11-06: `economic_output`, `royal_custom_threshold` and the two volume defines stay. The `STATS_STOCKPILE_DIRECT_IMPORTS` chronicle row stays but now always reads 0.
- 2g. Stockpile screen and text. Built 2026-11-06: description and examine line 4 from the user's drafts. The "Next market dae" line was built in 5-1.
- 2h. Remove the Alderman's trade warrant. Aldermen keep the defense warrant and contracts. The trade warrant is their only way into the Stewardry, so they lose all of it, including import, export and standing order fulfilment.
  - 2h-1a. Stewardry DM: `alderman_has_access`, the Alderman `ui_state`/`ui_status` and `user_can_act` paths, the warrant checks on quote, import and export, the `is_alderman_acting` and `alderman_warrant` data, every Alderman guard in `ui_act`, and the trade modal's warrant line. Built 2026-11-06. An Alderman at an unlocked Stewardry is now treated like anyone else there.
  - 2h-1b. Steward TGUI: the greyed-out Alderman states in the market, auto-import, advanced, loan and petition views, the Alderman's Writ banner, and their types. Built 2026-11-06.
  - 2h-2. City Assembly: the trade warrant motion and bracket vote, `trade_daily_cap`, `trade_remaining`, `can_consume_trade`, `consume_trade`, the assembly floor panel, `CityAssembly.tsx`, the admin economic panel, and the book chapter. Built 2026-11-06, along with the Notice Board's Alderman trade button and the Steward book's warrant section.
- 2i (was 3a). Target cleanup. Every good computes its target and seeds its stock when the Treasury creates it, instead of lazily on first read. `get_market_target()` and its callers are gone; everything reads `market_target`. Built 2026-11-07. The 25 to 40 clamp and the rare target of 10 were dropped from this slice and wait for Module 3, which recomputes every region's lists.
- 2j. Resale cap (to do). A unit bought from the Market sets `market_paid` on the item to the bid at the time of purchase. Selling it back pays the lower of the current bid and `market_paid`. Bundles keep the lowest `market_paid`; crafting clears it. Was planned for Market Connection purchases only. Market Connection is only in the first draft, and the doc's Module 2 states the rule for every Market purchase, so it now covers all of them. User's comment for the code:

```
// To prevent anyone from flipping back a goods immediately on market change, resale will always make you back the same price or less, so that shifting a market price point cannot infinitely print money
```

**Target audit (2026-11-06), for the target sizing that follows Module 3:**
- Target used to be the sum of every region's produces and demands for a good. That counts how many regions list the good, not how much players trade in it.
- 74 of 89 goods had a target of 20 or less. Small targets were twitchy: a 40-cabbage harvest into 13 sold mostly at Overstocked. Big targets were a little sticky: one bundle of 10 never moved grain, cloth, wood or ingots.
- The step thresholds are symmetric and fine. Changing them can't fix badly sized targets.

| Target | Goods | Buys to Low / Scarce / Very Scarce | Sells to Plentiful / Abundant / Overstocked |
|---|---|---|---|
| 40 | grain, cloth, wood, iron ingot | 9 / 15 / 21 | 10 / 24 / 40 |
| 36 | meat | 8 / 13 / 19 | 9 / 22 / 36 |
| 26 | coal, fibers, salt | 6 / 10 / 14 | 7 / 16 / 26 |
| 25 | ore, hide, cured leather, apple, cabbage, salmon, garlick | 6 / 9 / 13 | 7 / 15 / 25 |

**Player text (user drafted):**
- Name: "Stockpile". Description: "A magickal device connected to the trade network of the city. You can buy and sell basic goods, crafting materials and other things here with the market of the city."
- Mechanics lines 1 to 3 unchanged. Line 4: "Goods sold here go into the market or the royal stockpile. This change the market price."
- Screen title and subtitle unchanged.
- "Next market dae in 12 minutes". Hover: "Every dae other traders will correct the market and adjust the stocks and price toward the norm, according to regional demand and supply. This will only apply on non-blockaded region" (flag: Module 5 decouples the Market from regional stock, and raids now slow the dae rather than switch it off)
- Royal Subsidy: "All royal subsidy role have a subsidy of 100m and can draw freely from the royal stock, and purchase from the market using treasury fund. This only works so long as the treasury is above the treasury floor"
- Chat: sold and bought lines, same shape as today.

**Silver:** `market_never_supplies` on raw silver and silver ingots. Players can sell them, nobody can buy them. Silver trade goods are not importable and no region produces them. Caravans in Module 4 must keep it that way.

**Price change display (built):** hovering Buy or Sell shows how many more trade at the current price and the next price. Detailed mode shows a bar of the seven stock steps with a marker at the current stock; hovering a segment shows its range and buy price. Hover wording is placeholder for the user to rewrite.

**Parked:** Steward screen wording, Steward book rewrite.

## Module 3 - Regions and regional trade

- Every region in Azuria Lore Update 2.0 becomes a trade region, 17 in all, grouped into four routes.
- Each region belongs to one of its route's two subroutes. Trips use the whole route; raiders hold one subroute (Module 8).
- Regions are built from types instead of hand-set lists. Each type a region has carries its own size (small, medium, large, huge, massive). Overlapping types don't stack. The type list isn't complete.
- A region's stock is independent of the Market and only reachable by caravan. Prices are fixed and quantities limited.
- A region that demands a good pays above its Steady price.
- Each route has one or two unique imports.
- Meat can't be imported. It always comes as livestock.
- Tribute: the first caravan to visit a region each dae collects it, free and without using capacity, scaled by population. It has a useful part, the same value in every region, which the Steward picks from the region's supply (3-4b), and a flavour part, consumables with little resale value (Rosawood wines).

| Route | Subroute 1 | Subroute 2 | Threat region | Trip |
|---|---|---|---|---|
| Northern Seaway | Rossan Coast: Rhu Rosha, Rosawood (doc) | Eastern Shores: Rosawood, Rockhill | Azurean Coast | 20 min |
| Southern Seaway | Kingsfield Circuit: Kingsfield, Saltwick | Southern Shore: South Syons, Kyleness, Bleakisles | Azure Grove | 15 min |
| Ore Road | Syonic Passes: North Syons, Hagenwald | Terrorbog Causeway: Blackholt, Daftsmarch | Underdark | 20 min |
| River Azur | Riverine Azuria: Dalesworth, Avondale | East Bank of Arwin: Heartfelt, Bewmarch, Northmarch (Northfort) | Mount Decapitation | 30 min |

Bug carried here: Bleakcoast's maize demand uses `TG_SUPPLY_LOCAL_GRAIN` instead of `TG_DEMAND_LOCAL_GRAIN`. Moot once Bleakcoast moves onto templates.

### 3-1 - Region types and sizes

Files live in `code/modules/economy/regions/`: `economic_region.dm` (base datum, global list, capacity procs, Lore Primer), `regions.dm` (the regions), and `types/` with one file per group: `_region_type.dm` (base datum with name, description, produces, demands), `population.dm`, `scarcity.dm`, `production.dm`, `fishery.dm`, `mining.dm`, `industry.dm`. Each group is a parent path, such as `/datum/region_type/scarcity/iron_poor`. Sizes are plain multiplier defines (`REGION_SIZE_SMALL` to `REGION_SIZE_MASSIVE`) in `trade_volumes.dm`, which stays the one volume file. Each region stores them against its types in `region_types`.

**Rules (approved 2026-11-07):**
- A region lists its types, each with a size define: Small 0.5, Medium 1, Large 1.5, Huge 2, Massive 3. Medium is today's volume.
- A good's volume is the type's value times that type's size, rounded to nearest, at least 1.
- The same good in two types keeps the higher value. A region never both supplies and demands a good: supply wins.
- `produces` and `demands` stay plain lists, built when the region is created, so nothing that reads them changes. Daily population scaling is unchanged.

**Types:**

| Type | Supplies | Demands | Today in |
|---|---|---|---|
| Settlement | - | grain, cloth, iron ingot | every region |
| Agricultural | grain, oats, rice, maize, cabbage, potato, onion, carrot, turnip, pumpkin | - | Kingsfield |
| Pastoral | meat, pork, ham, pork belly, poultry, rabbit, egg, butter, cheese, fat, tallow | salt | Kingsfield |
| Weaving | cloth | fibers | Kingsfield, Rosawood |
| Forestry | wood, fibers | - | Rosawood |
| Hunting | hide, fur, cured leather | - | Rosawood, Blackholt |
| Orchard | apple, pear, jacksberry | glass batch, clay | Rockhill |
| Herb Gardens | calendula, poppy | - | Rockhill |
| Swamp | silk, viscera, sinew, Dendor essence, calendula, clay | - | Blackholt |
| Minerals (Iron and Steel) | iron ore, coal, cinnabar, gold ore | meat | Daftsmarch |
| Minerals (Copper and Tin) | copper ore, tin ore | meat | Daftsmarch |
| Quarry | stone, salt, glass batch | - | Daftsmarch |
| Refinement | iron, steel, bronze, copper and tin ingots, coal | iron, copper, tin and silver ore, cinnabar, wood, meat | Hagenwald |
| Fishery (East Coastal) | filet, mince, warm water fish: bass, sole, crab, clam, shrimp, lobster | salt, fibers, wood | Saltwick |
| Garrison | - | steel, copper, tin and bronze ingots, hide, fur, cured leather, oats, meats, egg, butter, cheese, vegetables, salt, coal, clay | Northfort, Bleakcoast, Heartfelt |
| Urban | - | iron, copper and tin ore, coal, stone, clay, wood, hide, fur, cured leather, fibers, glass batch, salt, viscera, sinew, cinnabar, filet, mince | Kingsfield |
| Noble Presence | - | silk, silver ingot, gold ore, glass batch, calendula, poppy, Dendor essence, the nine named fish, apple, pear, jacksberry, butter, cheese | Kingsfield, Rockhill, Heartfelt |
| Iron Poor | - | iron ingot | Rosawood |
| Salt Poor | - | salt | Rosawood |

Later types: Fishery (North Coastal) for cold water fish such as cod and salmon (Rosawood, the northern coast), Fishery (Riverine), and anything else 3-3 needs. Until then salmon, cod and carp have no producer.

**Region types:**
- Kingsfield: Settlement, Agricultural, Pastoral, Weaving, Urban, Noble Presence.
- Rosawood: Settlement, Forestry, Hunting, Weaving, Iron Poor, Salt Poor.
- Rockhill: Settlement, Orchard, Herb Gardens, Noble Presence.
- Daftsmarch: Settlement, Minerals (Iron and Steel), Minerals (Copper and Tin), Quarry. Copper and tin move to Northmarch in 3-3 with the rename.
- Blackholt: Settlement, Swamp, Hunting.
- Saltwick: Settlement, Fishery (East Coastal).
- Bleakcoast: Settlement, Garrison.
- Northfort: Settlement, Garrison.
- Heartfelt: Settlement, Garrison, Noble Presence.
- Hagenwald: Settlement, Refinement.

Sizes start wherever they reproduce today's numbers, mostly Medium. A before/after table of every region's lists comes with 3-1b, and the user rescales from there.

**Slices:**
- 3-1a. Move only. The region file moves to the new folder and splits into `economic_region.dm` and `regions.dm`. Built 2026-11-07.
- 3-1b. Types and sizes. `region_type.dm` and new defines (size multipliers, plus pumpkin, Dendor essence and wood demand replacing today's literals), the merge rules, the 10 regions converted. Built 2026-11-07; sizes changed from datums to defines, and types split into group files with a description field, the same day. Every type starts Medium except Rosawood's Weaving and Blackholt's Hunting (Small). Changes from before, by simulating the merge:
  - Kingsfield: + apple, pear, jacksberry demand; - pumpkin demand (it supplies pumpkin).
  - Rosawood: cloth 4 -> 3.
  - Rockhill: + iron ingot, silver ingot, gold ore, Dendor essence, nine named fish, butter, cheese demand.
  - Daftsmarch: + iron ingot demand.
  - Blackholt: + fur 3, cured leather 3 supply, hide 2 -> 3; + grain demand.
  - Saltwick: - salmon, cod, carp supply; + grain demand; - pumpkin demand.
  - Bleakcoast: + fur, butter, cheese, salt, coal, clay demand; - rice, maize, apple, pear, jacksberry demand.
  - Northfort: unchanged.
  - Heartfelt: + copper and tin ingots, fur, oats, pork, ham, pork belly, fat, tallow, five vegetables, salt, coal, silk, gold ore, glass batch, Dendor essence, nine named fish demand; - rabbit, rice, maize, fibers demand.
  - Hagenwald: + cloth demand; - silk demand.
- 3-1c. Daily rolls: seasonal modifiers and Urban's rotating demand (approved). Built 2026-11-09. A season entry is either one number for all of a type's goods or a list per good: Pastoral uses `SEASON_AUTUMN = REGION_SEASON_PEAK` for its supply and a salt-only list for its demand. Urban's goods move to `rotating_demands` with `REGION_URBAN_DAILY_PICKS` (6) active each dae; goods another type already demands never rotate. `SSeconomy.reset_region_capacities()` runs at startup and in the daily tick. Region-level seasonal exceptions wait for 3-3, when Rosawood needs one. Urban gets a pool of goods and draws a few each dae at the same daily reset. Each type can carry `seasonal_produces` and `seasonal_demands`, season to good to multiplier, next to its own lists, keyed by the existing `SEASON_*` defines. When merging, each good takes the seasonal multipliers of the type that won its volume. Example: Pastoral doubles salt demand in Autumn. A region can carry its own seasonal list for exceptions such as Rosawood's short growing season, applied after the merge. The multiplier steps are defines in `trade_volumes.dm`. Applied at the daily reset of each region's daily capacity, so the base `produces` and `demands` lists and the Market targets built from them don't change with the season. A multiplier of 0 takes a good out of season for the dae, so the daily reset's minimum of 1 skips it. Also applied once when the economy starts. A season lasts 12 rounds and never changes mid-round.
- 3-1d. New Market goods for fish the fishing system already catches (items in `modular/Neu_Food/code/raw/raw_fish.dm`): mudskipper, swamp shrimp, swamp mother, eel, black bass, flounder, mackerel, plaice, oyster. Each needs a trade good define, a trade good datum and a stockpile entry. Built 2026-11-10 for all but oyster, with prices from each item's own price tier. Oyster held: opening one rolls a pearl (16% pearl at 20m, 4% blue pearl at 60m, about 5.6m expected), which beats its 5m price, so a Market selling oysters near base price is a pearl lottery that pays out. Options: keep oyster tribute and gift only, price it above the pearl value, or make Market oysters pearl-free. Sturgeon, murkfang, swordfish, anglerfish, clownfish and beaksnapper are prized and stay tribute and gift only.
- 3-1e. The full type list (approved 2026-11-09), replacing today's types. The 25 Market goods no region touches get homes. The 10 regions are reassigned. Built 2026-11-10. `production.dm` is replaced by `agriculture.dm`, `pastoral.dm` and `wilds.dm` (forest, elven forest, hunting, swamp). Group parents carry no data, since DM subtypes would inherit their lists. Every Market good now has a region; nobody supplies black bass (River Azur, 3-3), silver (by design), or sugar, coffee, tea and citrus (demand only until the Statute pseudo-regions). Seasonal samples: Temperate and Orchards high in Autumn, Herb Gardens high in Summer, Northern and Coastal Cold lean in Winter, Hunting fur high in Winter, Riverine salmon peak in Autumn, Swine Herd and Salt Flats peak in Autumn. Rosawood takes General forestry alongside Elven so fibers keep a producer.
  - Population (demand only): Settlement, Urban (rotating pool), Garrison, Noble Presence.
  - Scarcity: Iron Poor, Salt Poor.
  - Agricultural: Temperate (Farm), Northern (Cold Climate), Orchards, Herb Gardens, Aquaculture (Coastal: carp and eel ponds, Kingsfield). Further specialisation (Vineyard, Market Gardens, Citrus Terraces) proposed, not decided.
  - Pastoral: Swine Herd (forest swine on acorns, doubles in Autumn for pannage), Normal (mixed animals), Saiga-Focused (Heartfelt), Goat and Saigas (Syonic).
  - Forestry: Elven (nuts, lumber, Dendor essence), General (wood, fibers, mushrooms).
  - Swamp, Hunting (hide, fur), Herb Gardens. Hunting and Herb Gardens aren't in the doc's latest list but stay.
  - Fishery: Coastal Cold (cod, salmon, lobster), Coastal Temperate (bass, sole, flounder, mackerel, plaice; the plaice item says it comes "from the seas of Bleakisles"), Shellfish Beds (clam, oyster, crab, shrimp), Riverine (carp, eel, black bass, salmon; sturgeon as tribute), Swamp (mudskipper, swamp shrimp, swamp mother, eel). All with filet and mince where fitting.
  - Mining: Minerals (Iron and Steel), Minerals (Copper and Tin), Precious Veins (gold ore, cinnabar), Stone Quarry, Glass Quarry (Isle of Glass), Clay Pits, Salt Mines (steady, demands iron ingot), Salt Flats (doubles in Autumn, little demand).
  - Industry: Weaving (fibers to cloth), Refinement (ores and coal to ingots), Charcoal Burning (wood to coal), Curing (salt, meat and fish to dried fish, sausage, salumoi), Tannery (hide and salt to cured leather), Shipyard (wood, cloth, fibers, tallow, iron ingot), Toolworks (iron and steel ingots, coal, wood), Brewery (wheat, oats, honey), Mint (gold ore to gold ingot). Silver stays unsupplied.
- 3-1e2. Volume tier ladder (approved 2026-11-10). The 55 `TG_SUPPLY_*` and `TG_DEMAND_*` defines use only 9 values, so they become one shared ladder (`TG_VOLUME_RARE` 1, `TRICKLE` 2, `LOW` 3, `MODEST` 4, `STANDARD` 5, `BULK` 6, `HEAVY` 8, `MASS` 10, `STAPLE` 12) used for supply and demand alike. Types pick a tier per good, and region type sizes do the rest. No number changes: the simulated region lists must come out identical. Built 2026-11-10: 246 uses swapped across the eight type files, all 10 regions simulate identical, no old define name left. The old file-top comment went with the category defines it described.
- 3-1f. Demand groups (approved): a group is a shorthand that expands into each member good at the group's volume. Pooling a group into one shared demand is decided in Module 4. Built 2026-11-10: `/datum/trade_good_group` datums in `regions/trade_good_groups.dm` (base ingots, precious metals, leathers, staple meats, dairy, root vegetables, preserved foods, fine fish, orchard fruit, exotic fruit, luxuries, herbs). A type lists a group path with one volume; it expands when the type is created, in supply, demand, rotating and per-good seasonal lists alike. A good listed on its own overrides its group's volume. Garrison, Noble Presence, Urban's leathers, Curing and Herb Gardens use groups; all 10 regions simulate identical. Members are never interchangeable in this slice. Revised the same day: Iron Ingots (iron, steel) and Bronze Ingots (copper, tin, bronze) replace one ingot group; Hides and Furs replaces Leathers, with cured leather listed on its own so the Tannery's output never pools with its input; Preserved Meats (sausage, salumoi) replaces Preserved Foods, with dried fish on its own so fish and meat regions stay distinct (no fast days in game, but the split still matters); Textiles (fibers, cloth) serves the Shipyard and pools, since there is no separate wool.
  - Historical check (2026-11-10): pooling was by fixed equivalence or value, never unit for unit (1690 Victualling Instructions: "three pounds of beefe in liew of two pounds of porke"; the royal spice account was one budget line bought per item by the pound). Fish and flesh never substituted for each other. Iron and steel were separate goods (1549 Act against iron gads passed off as steel); tanners, tawyers, curriers and skinners were barred from each other's work; copper and tin were bought separately and bronze recycled by weight; gold and silver substituted by value at a floating ratio; herb substitution was fixed one-way pairs. "Ferrous" dates from 1865.
  - Recommended for Module 4: pool by value, not units. May pool: staple meats, dairy, preserved meats, fine fish, orchard and exotic fruit, luxuries, pulses (beans and lentils, needs a group), textiles. Never pool: iron ingots, bronze ingots, hides and furs, herbs, precious metals. If Module 4 pools groups, pooling is opt-in per group (user, 2026-11-10): food groups, fine fish, orchard and exotic fruit and luxuries may pool (luxuries ideally by value rather than units, later), leathers and textiles may pool, ferrous and bronze ingots stay separate from each other, and herbs and precious metals never pool. Historical check of these calls requested.
- 3-1g. Standing orders onto types, replacing the per-region mapping in `populate_standing_order_templates()`. The garrison's weapons and Toolworks' tools live here, since finished goods aren't Market goods. Built 2026-11-10. Each type has `standing_orders`; a region collects them with `initial(roll_weight)` while it builds its lists, and the old mapping proc is gone. Mapping: Settlement (construction, birthday gifts), Urban (textiles, smithing, artificery, alchemy, salt), Garrison (rations, armaments, garrison victualling, three equipment orders, frontier gear, prosthetics, alchemy, warband alchemy), Noble Presence (court finery, fine joinery, jewelry, great feast, tournament, trophy heads, arcane commissions, artificed panoply, exotics, orchard), Mariners (fleet victualling), Curing (fishery, salt), Toolworks (smithing, artificery), iron and copper mining (mine victualling). User calls: Kingsfield gets no Garrison (the in-game garrison covers it), mining gets no smithing. New Mariners type (preserved meats, dairy, pulses, dried fish; fleet victualling) on Saltwick, Rosawood and a small one on Rockhill, plus a Pulses group (beans, lentils). Hardtack left out (user, 2026-11-10): it is a merchant bulk pack (5 for 22m), and the codebase keeps merchant-purchasable packs out of trade goods to stop buy-to-sell arbitrage against the Crown.

### 3-2 to 3-4

- 3-2. Routes and subroutes as data, threat region per route. Built 2026-11-10 in `regions/routes.dm`: four `/datum/trade_route` (name, threat region, trip time from `TRADE_ROUTE_TRIP_*` defines: 20, 15, 20, 30 minutes) and eight `/datum/trade_subroute` (name, route). A region sets `subroute`, and its `threat_region_id` is derived from the route at creation, so blockade code is untouched. Blockades stay per region until Module 8. Threat region changes: Rosawood Azure Grove to Azurean Coast, Blackholt Azure Grove to Underdark, Saltwick and Bleakcoast Azurean Coast to Azure Grove, Heartfelt Azure Grove to Mount Decapitation, Hagenwald Mount Decapitation to Underdark. Current regions: Eastern Shores (Rosawood, Rockhill), Kingsfield Circuit (Kingsfield, Saltwick), Southern Shore (Bleakcoast), Syonic Passes (Hagenwald), Terrorbog Causeway (Blackholt, Daftsmarch), East Bank of Arwin (Heartfelt, Northfort). Rossan Coast and Riverine Azuria are empty until 3-3.
- 3-2b. Dropped 2026-11-10 (user): no extra admin view that won't be kept. The Stewardry's Regions tab shows region goods until the Module 4 redesign.
- 3-3. The remaining lore regions, from the lore audit of 2026-11-07. Built 2026-11-10, 17 regions. New: Eveswood and Rhu Rosha (Rossan Coast), South Syons (Southern Shore), North Syons (Syonic Passes), Dalesworth and Avondale (Riverine Azuria), Bewmarch (East Bank of Arwin), all with blank subtitle and description for the user to backfill. Renamed: Bleakcoast to Bleakisles (one region taking in Kyleness and Inishlea; description kept), Northfort to Northmarch (old "economically unproductive" text blanked as false). New Citrus Orchards type (lemon, lime, tangerine) on Rockhill (small) and North Syons. Copper and tin move from Daftsmarch to Northmarch; Heartfelt gains a small Urban for Hartsmouth. Every Market good now has a region; nobody supplies sugar, coffee, tea (demand only) or silver (by design). Player text updated 2026-11-10 (user): Rockhill's description says Bleakisles, the bankruptcy casks are Valmora Blue, the Magna Carta titles read "Protector of Bleakisles, Northmarch, and Heartfelt", and the treasury book says "The Crown trades with dozens of internal regions" rather than naming them, so adding regions never makes it stale. No Bleakcoast or Northfort text remains.
- 3-3b. Market target sizing, now due: with 17 regions the summed targets run to wood 132, grain 122, cloth 93, and 23 of 97 goods over 40. Built 2026-11-10: `compute_market_target()` clamps the regional sum between `MARKET_TARGET_MIN` 25 and `MARKET_TARGET_MAX` 40 (a good no region lists gets 25), and gold ore, gold ingots, silver ore, silver ingots and Dendor essence preset `MARKET_TARGET_RARE` 10. `MARKET_TARGET_DEFAULT` is gone. Result: 28 goods at 40, 36 between, 28 at 25, 5 rare at 10. Everything in `stash@{0}` is now applied, so the stash can be dropped. Committed. Hand-tuning of Market stock and targets per good is parked for the user to do later.
- 3-4. Tribute data: types carry a `tribute` list (the useful part, scaled by size), regions carry `gifts` (flavour item paths, no resale value). Read by caravans (Module 4) and noble estates (Module 10). Built 2026-11-10: 33 production, fishery, mining and industry types carry one or two signature goods at Low, Trickle or Rare (groups allowed); population, scarcity, Shipyard, Toolworks and Brewery carry none. A region merges them like supply (higher value wins, scaled by size) into `region.tribute`, a daily amount of 1 to 5 per good. `region.gifts` is empty for the user to fill with item paths; the resale mark (the existing unsellable component) is applied by whoever hands gifts out (Module 4, Module 10). Population scaling and raids are applied at collection. User 2026-11-10: tribute feels low, it must arrive every dae (no carrying fractions over several daes), and it shouldn't be worth far more in one region than another. The per-type lists were removed again in 3-4b; `region.gifts` stays.
- 3-4a. Values for goods regions listed without a trade good. Built 2026-11-10. Mushroom 2, Bones 3 (the existing `SELLPRICE_BONE`). The shared exotic meat id is split into eight goods, one per stockpile: Lesser Meat 1, Bogmeat 2, Bushmeat 4, Greater Bushmeat 9, Venison 16, Venison Ribs 16, Boar Ham 16 (what the Market charged before, from the old manual prices), Crab Meat 4 (down from 8, because a whole crab is 10 and butchers into crab meat). Manual stockpile prices removed. Hunting supplies a new Game Meats group (venison, ribs, both bushmeats, boar ham); Swamp supplies bogmeat. Honey is a trade good at 5, like sugar, coffee and tea.
- Pack rule (user 2026-11-10): a good any region produces is never sold in unlimited supply, meaning the Goldface and Silverface categories. Realm ships and catalogues (Cultural Stock, the Rosawood Arsenal) are fine because their supply is limited. Removed from the Goldface Consumable group: honey, eggs, butter, eel, carp. Gronn ships keep honey through a new Gronn cultural honey pack. The Raw Materials packs (ore, coal, wood, stone, cloth) are in no Goldface category, so they're already off sale. Spider honey and blacktallow stay: neither is a region good, and both cost more than the honey or tallow stockpile could ever pay. Apply the rule to any new region good.
- 3-4b. Tribute by value. Built 2026-11-10. User calls: every region gives the same value, and the Steward picks the goods from anything the region supplies that dae. `REGION_TRIBUTE_VALUE` 100, times the population multiplier at dawn, into `region.tribute_value` (about 200 at 40 players, 300 at the cap). `tribute_units(good, value)` turns part of the value into whole units at the region's own sell price (`compute_import_unit_price`, first unit), never Azure Peak's Market price. The good must be in the region's supply that dae, so a season that rests a good removes it, but the units may exceed the dae's supply (user 2026-11-10). Read by caravans (Module 4) and estates (Module 10), which own the picking interface. The per-type tribute lists are gone. Local prices equal the base price until Module 4 makes them differ, which is where the arbitrage comes from.

Open: whether Kyleness, Bleakisles and Inishlea are one region or three (the lore puts Inishlea off a Rockhill peninsula, on the Eastern Shores); South Syons has no economic lore; each route's unique imports; whether sugar, coffee and tea are route imports or wait for the Statute pseudo-regions.

## Module 4 - Caravans

- The Steward starts with 2 to 4 caravans by population, mostly 4, all at home and ready to send, and can build up to 8. A new one costs 300 to 500m of goods: saigas and saddles for a caravan, planks and cloth for a ship. Both are the same unit and only the recipe differs.
- Capacity about 100 goods. Tribute takes none.
- A trip goes down one route and trades with two regions on it, with a buy and sell order, collecting both regions' tribute.
- Steward imports become regional: special goods with limited supply, sold by one region and delivered by caravan.
- Direct trade retires: every import and export is a caravan trip, and today's auto-import and auto-export go with it. Automated Caravans (Module 7) is the replacement.
- Owns the redesign of the Steward trade interface: the trade modal, the regions view, and the import and export lines on each market row.
- Reuses the parked backend: regional unit prices, daily capacity, blockade multipliers and the purse floor. `manual_import` and `manual_export` become a trip's arrival and departure.
- Approved 2026-11-10: a trip books its buy and sell orders when it leaves. It reserves the regions' capacity and locks the prices then, and arrival only delivers. A dawn during the trip (Urban's rotation, a new day's capacity) or a raid that starts mid-trip can't strand the cargo.
- `stockpile_limit` is the auto-export surplus threshold until here.
- Local prices (user 2026-11-10): each region has its own prices, which differ from Azure Peak's. Today every region sells at the good's base price. Tribute converts at the local price (3-4b), so taking tribute where a good is cheap and selling it at home is an intended arbitrage. The tribute picker shows local prices and units only, never the Azure Peak Market price.
- Region volumes scale up (user 2026-11-10): daily supply and demand grow to caravan scale (capacity about 100 goods), instead of a few units a good.
- Trade Credit Line (user 2026-11-10). The treasury starts at 1000 to 1500m, which can't fund trade at the scale caravans need. Money that could would go straight into the Keep's gear instead. So the Crown gets a shadow credit line that only caravans can use:
  - Crown caravan purchases draw on the credit line first.
  - Caravan trade proceeds repay what's drawn first. Only the surplus reaches the treasury.
  - It can't be withdrawn or spent on anything else: wages, Keep gear, subsidies or the Market.
  - It's shown as debt or credit. The round reset clears it, so it never needs repaying.
  - Borrowed money can't become profit. Only the trade margin above the credit can.

Decisions (user 2026-11-11):
- Regional supply and demand are inelastic, as Module 3 says ("prices are fixed and quantities limited"): one local price per good per region, and a caravan can't buy past the dae's supply or sell past its demand. 4-1 reused the old escalating prices as a stand-in until 4-3.
- Caravans may buy from and sell into the Market directly, not only through royal stock. Royal stock stays for standing orders, the Royal Subsidy and Keep roles' sales.
- Built in 4-3b as proposed: each buy and tribute line goes to the Market or royal stock, each sell line comes from either, default Market. Selling from the Market buys at the Market ask at departure (locked). Delivering to the Market is paid the Market bid at arrival, at the stock then, so two caravans can't both collect one shortage's price; the one exception to booking at departure. Deliveries count toward ending a shortage and Market purchases toward ending a glut, like the Steward's Market buttons (2d-5, 2d-6). For 4-3's role prices: a producer price at or above the Plentiful bid (60% of base) and a demander price at or below the Low ask (125%) keep Crown trade from pushing the Market out of Steady by itself; outside that band the Crown floods or drains the Market for profit.

Decisions (user 2026-11-10):
- Capacity counts each way: up to 100 goods sold on the way out and up to 100 bought on the way home.
- Local prices by role: a region that produces a good sells it below base, a region that demands it buys above base, by one shared define each. Azure Peak sits in the middle (the gdoc: a region that demands a good buys it above the steady price).

### Slices

- 4-1. Fleet and trips backend. Built 2026-11-10.
  - `SSeconomy.crown_caravans` holds caravans named "Caravan N"; `add_crown_caravan()` stops at `CARAVAN_MAX` 8.
  - Starting fleet (user 2026-11-11: scale with population, mostly 4): `CARAVAN_START_BASE` 2 plus 1 per `CARAVAN_START_POP_STEP` 15 players, up to `CARAVAN_START_MAX` 4. So 2 under 15 players, 3 from 15 to 29, 4 from 30. `grant_crown_caravans()` runs at round start through `SSticker.OnRoundstart()`, since `Initialize()` runs with everyone in the lobby, and again at each dawn so late joins crossing a step add one. `caravans_granted` counts free caravans apart from built ones, so building early is never wasted. The whole fleet starts at home, ready to send; none is on the road at round start (user 2026-11-11).
  - `plan_caravan_trip(route, orders)` prices a trip without committing it, so the planner can quote live: one route, up to `CARAVAN_STOPS_MAX` 2 of its regions, per region a buy, sell and tribute list. It refuses raided regions (until escorts), goods a region doesn't sell or buy, goods the royal stockpile can't hold, more than `CARAVAN_CAPACITY` each way, sales beyond royal stock, tribute over the region's value or already claimed that dae, and trips the Treasury can't afford.
  - `book_caravan_trip()` commits at departure: pays for the buys, takes the sales out of royal stock, reserves the regions' supply and demand for the dae, and claims tribute. Prices are today's regional prices (base price, escalating past the dae's supply).
  - `finish_caravan_trip()` runs after the route's trip time: buys and tribute go into royal stock, sale proceeds are minted into the Treasury, and the Nerve Master says the caravan is back.
  - Regions carry `tribute_claimed`, reset at dawn. `tribute_unit_price()` split out of `tribute_units()`. New `get_subroute_route()` in `routes.dm`.
  - Caravan sales don't count toward ending a shortage (the old direct export did); Module 6 decides what counts.
- 4-2. Steward Caravans tab: the fleet with timers, and a trip planner (route, then up to two regions, then buy and sell lines with local prices, a capacity bar each way, and the tribute picker at local prices only). Workload cuts (user 2026-11-11), none of which picks goods for the Steward, which stays Automated Caravans:
  - Send again: rebook a caravan's last trip at today's prices, trimmed to what the regions still sell and the Treasury can pay, with the quote shown before it confirms. Plus "Send all idle again". Never repeats by itself.
  - The tribute picker remembers the last pick per region.
  - The Clerk can dispatch as well as the Steward.
  - Built 2026-11-11 (all but Send all idle again):
    - New Caravans tab after Market (`StewardTrade/CaravansView.tsx`, `steward/steward_caravans_tgui.dm`). Each caravan card shows At home, or where it went, when it's back, goods each way, money each way, tribute and who sent it.
    - The planner holds the draft trip on the client and asks the server for a quote (`caravan_quote`, debounced, matched by a stamp) on every change and at dawn. The quote runs `plan_caravan_trip()`, so the planner shows the same refusal text the send would. Send (`caravan_send`) books through `book_caravan_trip()`; the planner closes when the caravan is on the road, and stays open with the error if the send fails. `caravan_send` is locked under sequestration; quoting isn't.
    - Region rows now carry each good's next-unit local price, tribute price, the region's tribute value and whether tribute is claimed. Columns per region: Buy here (importable goods with a stockpile entry), Sell here (capped at royal stock), Tribute (running total against the region's value).
    - Plan again loads a caravan's last trip, keeping buys the region still sells, cutting sells to royal stock and fitting tribute to today's value, then quotes it; one more click sends. Treasury trimming is left to the quote's refusal.
    - Adding a region prefills its tribute from the last pick there (`SSeconomy.last_tribute_picks`), fitted to today's value; nothing if the tribute is already claimed.
    - Client orders pass through `sanitize_caravan_orders()`: unknown goods and bad numbers are dropped, buy and sell lines are capped at `CARAVAN_CAPACITY`.
    - The Nerve Master announces departures as well as returns.
    - Clerk: the Nerve Master has no role check on trade, so whoever is at the unlocked machine can send caravans already.
- 4-2b. Send all idle again: one click sends every idle caravan on its last trip, each showing its quote first.
- 4-3. Local prices by role.
  - 4-3a. Fixed prices and hard limits. Built 2026-11-11.
    - A producing region sells at `REGION_PRODUCER_PRICE_MULT` 0.7 and a demanding region pays `REGION_DEMANDER_PRICE_MULT` 1.2 of the good's reference price, the same price the Market's Steady step uses (`trade_good/reference_price()`: the derived sell price, else the base price; `market_base_price()` now calls it). Rounded to the price step. No escalation, no blockade multiplier, no event multiplier. Both sit inside the 60% to 125% band.
    - `caravan_buy_price()` and `caravan_sell_price()` on the region. Tribute converts at `caravan_buy_price()`, so a tribute value buys about 1.4 times the units it did.
    - `plan_caravan_trip()` refuses a buy past what's left of the dae's supply and a sale past what's left of its demand. `quote_region_import()` and `quote_region_export()` are gone.
    - The planner shows the fixed prices, caps each buy at what's left, each sale at the lower of what's wanted and royal stock, and Plan again trims to the same limits.
    - The old direct trade screens, auto-import and auto-export keep the escalating prices until 4-6 retires them.
  - 4-3b. Market or royal stock on each line, per the proposal under Decisions. Built 2026-11-11.
    - A stop carries six lists: `buys_market`, `buys_royal`, `sells_market`, `sells_royal`, `tribute_market`, `tribute_royal`. The order format the planner sends uses the same keys. Supply, demand, capacity and tribute value count both halves of a line together.
    - Selling from the Market: the trip adds up each good's units across both stops and prices them as one purchase at `market_ask()`. At departure the Treasury pays it ("Caravan Market Purchase", Stockpile Purchases), Market stock drops and glut relief is checked. Refused for `market_never_supplies` goods, and past Market stock when no unraided region produces the good.
    - Delivering to the Market (buys and tribute): on return the trip is paid `market_bid()` at the stock then ("Caravan Market Sale", Stockpile Sales), Market stock rises and shortage relief is credited.
    - The quote and caravan cards show an estimate of Market sales: `market_bid()` now takes a starting stock, and the estimate starts from Market stock plus what other caravans on the road will deliver.
    - The planner's region panel is now three stacked tables (Buy here, Sell here, Tribute) with the local price, what's left or wanted, the Market's prices, royal stock, and two boxes per row. Each box caps at what the other leaves. Plan again and remembered tribute keep the split.
    - Royal stock only takes royal deliveries; standing orders, the Royal Subsidy and Keep roles' sales are unchanged.
  - Then the trade interface spec and mockup (region screen, Market screen, shared draft caravan), replacing the 4-2 planner layout.
  - Trade interface, first pass (user 2026-11-11, from in-game screenshots: the inline planner was too long and sparse). Built 2026-11-11:
    - The Caravans tab keeps a short planner: route, regions, a Cargo list of only the chosen lines per region (kind, good, split, value, remove), the capacity bars, the quote and Send.
    - Trade... on a cargo region opens a popup counter over the window: Buy, Sell and Tribute as tabs with counts, sorted Best first (profit per unit against the Market's price now) or By kind.
    - Two boxes per row stay (user's pick over one box plus a destination toggle). Rows are tighter, chosen rows are tinted, headers stick while scrolling.
    - A Profit column: buys and tribute against what the Market pays, sales against what the Market charges (or pays, for goods the Market never sells).
    - Clicking Left fills the Market box; clicking Wanted fills from royal stock first, then the Market.
    - Still to come: the good-first entry point from the Market tab, and the window size.
  - Rethink (user 2026-11-11, after the popup: still overwhelming). Not decided; user is thinking it over.
    - What the screenshots show: one region lists 24 goods to buy, 30 to sell and the same 24 again as tribute. The Tribute tab repeats the Buy tab's goods, prices and profits exactly. Every good whose Market is Steady shows the same profit (+0.05 of base, 70% against the 75% bid), so most rows carry no decision. The only rows worth a choice are goods whose Market is off Steady (gluts to sell abroad, shortages to fill) and royal stock to unload. Typing small numbers into about 100 boxes is the rest of the weight.
    - How other games cut it down: Bannerlord colours prices against the average and shows rumoured prices elsewhere on hover instead of tables; X4's traders rank offers by cargo filled times margin and the player gives orders; Anno 1800 routes list only the goods picked for each stop, with warehouse minimums deciding how much to drop; Manor Lords gives each good one rule (no trade, import, export, both) and a desired surplus; RimWorld uses one count per row with arrows, modifier keys for 10 and 100, and a double arrow for all.
    - Ideas, by impact: a short ranked "worth doing on this trip" list (only goods off Steady or royal stock to unload, ranked by profit times units) with the full list behind "Every good"; tribute as one pick per region instead of a tab; destination by rule instead of two boxes (royal stock takes what open standing orders need, the rest goes to the Market, sales draw on royal stock first), which reverses the two-box pick; +1, +5 and All buttons instead of typing; later, per-good rules in the Manor Lords style as Automated Caravans (Module 7).
    - Design symptom: one shared producer and demander multiplier gives every region the same margin on a good, so choosing a region is only about who has it. Regional price variety (4-9 special imports, or per-region modifiers) is what would make the route choice matter.
  - Was on hold, now redesigned as route trade (see "Redesign: route trade" below). The system itself was too complex, not only the screen. The old trade picked the best region per good automatically; caravans make the Steward choose among 17 regions, two per trip, per good, per destination, which is roughly ten times the decisions. The user is rethinking Module 4 at the system level before more slices. Built so far (trips, timers, fixed prices, hard limits, Market legs, the order sanitizer) is backend that most simpler designs can keep.
- 4-4. Region volumes scaled to caravan size. The Market target must stop reading the scaled volumes, or every good clamps to 40.
- 4-5. Trade Credit Line.
- 4-6. Retire direct trade: manual and automatic import and export, Export Surplus, the trade modal, the import and export lines on market rows, and `stockpile_limit`.
- 4-7. Building new caravans (saigas and saddles, or planks and cloth).
  - Build cost: at 40 players one caravan collects about 475m of tribute a dae, so a 300 to 500m build pays back in about a dae. The build cost, not the starting fleet, is the real limit on fleet size. 8 caravans make about 19 region visits a dae, so `CARAVAN_MAX` 8 is where every tribute gets collected.
- 4-8. Module 8 and 5 leftovers: the escort fee, the raided buy step, rentals, the midday tick. Rentals get a per-caravan "rent out when idle" toggle (user 2026-11-11): a caravan idle at dawn rents itself out for the dae, so a caravan the Steward doesn't want to run still earns and never adds work.
- 4-9. Regional special imports with limited supply.

### Redesign: route trade (proposed 2026-11-11)

The region-level planner asked the Steward for six choices per trip (caravan, route, two of 17 regions, goods per region, Market or royal stock per line, tribute goods) where the old trade asked for one and picked the best region itself. User 2026-11-11: trade with a route, enter from the goods the town needs, and make tribute one pick.

**Core:**
- The route is the trade partner. A caravan goes down one of the four routes. The route's offer is its unraided regions' supply and demand for the dae added together, at the role prices from 4-3a. The Steward never picks a region.
- Each good bought or sold is spread across the route's regions by the backend, which spends their daily supply and demand. Every producer charges the same price, so the order doesn't matter to the Steward.
- Good-first entry: a route's screen lists only the goods the town needs that the route carries: Market goods at Low, Scarce or Shortage to fetch, Market goods at Overstocked or Glut and royal stock to sell. "Every good..." opens the rest.
- Cargo is adjusted with +, - and All, never typed.

**Where goods land (by rule, replacing the two boxes):**
- Deliveries fill royal stock up to what open standing orders still need, and the rest goes to the Market.
- Sales draw on royal stock beyond what open standing orders need first, then on the Market.
- The cargo line says where each good lands. No per-line choice.

**Tribute (user 2026-11-11: one good, one pick):**
- Each route gives tribute once per dae, to the first caravan down it.
- The Steward picks one good from what the route supplies that dae. The whole tribute value turns into units of that good at the producer price. No quantities, no splitting.
- It takes no capacity and lands by the same rule as deliveries. The pick is remembered per route.

**The Steward's decisions per trip:** which route (time, raid exposure, what it carries, tribute) and what to prioritise in 100 out and 100 in, plus when to send. Regions keep standing orders, raid halves, the Lore Primer and the route's special imports.

**Kept from what's built:** trips and timers, fixed role prices, supply and demand limits, Market purchases at departure and deliveries on return, the order sanitizer, Plan again, the fleet by population.

**Changes:** orders become a route plus goods instead of per-region stops; the backend spreads goods across regions; tribute becomes one good per route per dae; `CARAVAN_STOPS_MAX` and the six per-line lists go; the planner and trade popup are replaced.

**Fleet note:** with four route tributes a dae, the tribute cap no longer sets fleet size. More caravans mean more trips and capacity, not more tribute.

**Decided (user 2026-11-11):**
- Raids take half the route: a raided subroute's regions drop out of the route's offer, the other half still trades, and an escort (4-8) reopens the raided half. If both halves are raided the route has nothing to offer.
- Route tribute is flat: `ROUTE_TRIBUTE_VALUE` times the population multiplier, the same for every route, unchanged by raids unless the whole route is raided. Proposed 200 (400m a route at 40 players, 1600m a dae for all four, against about 1400 to 1900 the region fleet collected at 40 players). Replaces `REGION_TRIBUTE_VALUE` for caravans; estates (Module 10) keep their own value.
- The destination rule replaces the two boxes for buys, sales and tribute alike.

**Slices once decided:** R-1 backend (route orders, spreading across regions, the destination rule, single-good route tribute); R-2 route screen (needs-driven list, +/-/All, tribute pick, cargo); R-3 the Market tab entry point (send for a good from its row); then 4-4 volumes, 4-5 credit line, 4-6 retiring direct trade.

**Cleanup and R-1, built 2026-11-11:**
- Removed: per-region stops (`/datum/caravan_stop`), `CARAVAN_STOPS_MAX`, the six per-line lists, region tribute (`tribute_value`, `tribute_claimed`, `tribute_unit_price()`, `tribute_units()`, `REGION_TRIBUTE_VALUE`), the region price procs, the per-region price and tribute fields on the Steward's region rows, the remembered per-region tribute data, and the whole region planner and trade popup in `CaravansView.tsx`. The tab shows only the fleet until R-2. `region.gifts` stays for Module 10.
- Prices moved to the trade good: `producer_price()` and `demander_price()`.
- An order is `route`, `buys`, `sells` (good to units, each line capped at `CARAVAN_CAPACITY`) and one `tribute` good or none, through `sanitize_caravan_order()`.
- `plan_caravan_trip(order)` checks each buy against the route's unraided supply and each sale against its unraided demand (`route_open_regions()`, `route_capacity()`). Booking spreads them across those regions (`spend_route_capacity()`).
- Sales draw on royal stock beyond open standing order needs first (`royal_order_need()`, `royal_spare()`), then buy the rest from the Market at departure. Refused when royal stock can't spare enough and the Market can't supply the rest.
- Deliveries and tribute land by the rule at arrival: royal stock up to what open standing orders still need, the rest into the Market at its bid (`plan_caravan_landing()`, also run at planning for the quote and the Market estimate). Goods with the warehouse route never land in royal stock.
- Route tribute: `ROUTE_TRIBUTE_VALUE` 200 times the population multiplier, set at dawn in `route_tribute_value`; one good the route supplies that dae (unraided half only), turned into whole units at the producer price, claimed per route per dae in `route_tributes_claimed`, last pick remembered per route in `last_tribute_picks`. Raided routes still give tribute from their open half.
- The quote returns costs, revenue, the Market estimate, tribute units and where each good lands or comes from (`royal_deliveries`, `market_deliveries`, `royal_sales`, `market_purchases`). Fleet rows carry the route, tribute and `last_order` for Plan again.
- Removed with it: the region planner's player text. The text sheet now holds the route strings.

**Signature tribute (user 2026-11-11, the original plan):** each region has one signature tribute good (`tribute_good` on the region), given whatever the season. A route's tribute offers its open regions' signature goods (four, five on River Azur) and the Steward picks one per trip. Revised the same day (user): tribute is `REGION_TRIBUTE_VALUE` 100 times the population multiplier, once a dae per region as before (`region.tribute_claimed`, reset at dawn), so a route can give up to four or five tributes a dae to different caravans. `ROUTE_TRIBUTE_VALUE` and the per-route claim are gone; the order's `tribute` is now a region id, and the last pick is remembered per route as a region. Population scaling note (user): 40 players is too generous; scaling should stay about flat and start around 70 to 80 players. Applies to the shared population multiplier; to be adjusted later. Proposed goods, each from the region's own supply, for the user to review: Eveswood rocknut, Rhu Rosha cod, Rosawood cured leather, Rockhill apple; Kingsfield grain, Saltwick salt, Bleakisles plaice, South Syons cheese; Hagenwald steel ingot, North Syons lemon, Daftsmarch iron ore, Blackholt silk; Dalesworth black bass, Avondale oats, Northmarch copper ore, Heartfelt meat, Bewmarch pear. Note: tribute is value at the producer price, so cheap goods come in piles (about 190 grain at 40 players) that mostly glut a Market whose target is 25 to 40, while dear goods (plaice, steel) come as a few dozen.

**R-2 route screen, built 2026-11-11, shelved the same day (see goods groups below):**
- Fleet cards with Plan a trip and Plan again. The planner: route buttons (trip time, a RAIDERS badge, closed when both halves are raided, and a note naming the raided half), the route's tribute as one button per signature good (units and region), then two short tables.
- "The town needs": goods the route sells whose Market is above Steady (Low to Shortage), most urgent first. "The town can spare": goods the route wants whose Market is below Steady (Plentiful to Glut) or that royal stock can spare, best margin first. "Show every good" widens both to everything the route trades. Rows show the Market band (or royal spare), what the route has or wants, the price, the margin per unit against the Market, and -, count, + and All. Goods already in the cargo always stay listed.
- Cargo lists each sale, buy and the tribute with where it comes from or lands (from the quote), with remove. Then the capacity bars, the quote line and Send.
- Server: `caravan_route` sets which route a user is looking at (`caravan_route_view` per ckey); `ui_data` sends a summary of every route (open, raided halves, tribute given) and the full detail only for the viewed route: each good's route supply and demand, both prices, Market step, royal spare and how many the Market can supply, plus the tribute options and last pick. `market_steady_step` goes in static data so the screen compares steps, not labels.
- Plan again loads the last order and trims it to the route's supply, demand and what can be sold once the route's detail arrives; a tribute already given or no longer offered is dropped. Picking a route prefills the last tribute pick there.
- Revised the same day from a screenshot (user): with most goods Steady, "The town needs" was usually empty and "Show every good" dumped every good in one list. The toggle is replaced by sub-tabs: "Town needs" (the two short tables) and one tab per Market category the route trades (Grains, Vegetables, ...), each with "For sale on this route" and "Wanted on this route" sorted by name. Tribute buttons are per region, and regions that gave today are greyed out.
- Trade through, Market first or Royal stock first (user 2026-11-11), replacing the fixed landing rule. Per trip, in the order as `priority` (`CARAVAN_PRIORITY_MARKET` default, `CARAVAN_PRIORITY_ROYAL`), remembered by Plan again.
  - Market first: sales buy from the Market first, then spare royal stock. Deliveries and tribute fill the Market up to its target (counting other caravans' Market deliveries on the road when planning, current stock at arrival), and the rest goes to royal stock. This keeps big tribute piles from glutting the Market.
  - Royal stock first: sales draw on spare royal stock first, then the Market. Deliveries and tribute all go to royal stock.
  - In both, royal stock that open standing orders need is never sold. The old "royal stock up to order needs" landing is gone.
  - The margin column for sales compares against the Market's buy price, or its sell price when the sale will come from royal stock.
- Every goods tab shows how many goods it lists: "Town needs (5)", "Grains (6)".

**Design review and goods groups (2026-11-11):**
- Why: after R-2 the user found route trade complex with less real choice. It added inputs (amounts per line, Trade through, packing 200 slots) and removed tradeoffs: fixed prices made every route alike and All the right answer, and there was no way to set policy and walk away. Two reviews (the code and plan, and other games' trade reworks) agreed: cut quantity inputs and keep the choices about where to trade and under what policy.
- Shelved: the R-2 planner screen, its route detail plumbing (`build_route_rows`, `build_route_detail`, `caravan_route_view`), Trade through and the tab counts. Patches and copies are in `C:/tmp/shelved-econ4-r2/`. The Caravans tab shows only the fleet again.
- Kept: the R-1 route backend, the landing rule (royal stock up to what open standing orders need, the rest into the Market) and signature tribute per region.
- Decided (user): like for like goods group up, stocked and priced in value. Each member trades at the group's price step times its own price, and a withdrawal picks the item. A group never holds a good together with its own input or output. The 2026-11-10 never pool list stands for metals (ferrous and bronze, precious); herbs may group (user 2026-11-11). Groups replace the 3-1f demand groups.
- Decided (user): the Steward picks tribute by hand. It is a genuine gain in agency, and seventeen choices are fine.
- Regions stay authored in named goods. A region's group value is the sum of its members, so lore and seasons carry through, and the named goods show on hover.
- Royal stock and standing orders count value. An order can keep a named good for flavour and fill from the group's value at that good's price.
- Proposed, not decided: the caravan screen becomes a grid of needs against routes. The Steward ticks up to three needs and picks a route column; the system fills amounts and the outbound load (royal surplus the route wants, Market goods above target). A tribute row under each route. Prices follow abundance per route so regions differ.
- Open: caravan capacity counted in value; tribute overlap (cod, plaice and black bass share Common Fish, grain and oats share Grains), so whether to re-pick signature goods; whether withdrawable members can be rare items no one caught; whether to close the region loop (buy at a producer for 0.7, sell to a demander next trip for 1.2), given that Crown profit with friction is accepted.
- G-0 groups sheet, drafted: `docs/design/econ4_goods_groups.dm`. First draft had 55 Market lines; the user found that still too many (2026-11-11): plum and citrus are grown normally, so all fruit is one group, and herbs may group after all. Second draft: 37 lines. Third draft after the user's calls: metals stay separate (iron and copper must never become the same); sausage and salumoi group as Preserved Meats for sanity, an exception to the input and output rule; fibers, cured leather, wood and glass batch stay single; egg leaves Dairy (not a substitute); stone, coal, salt and cinnabar stay separate for now. 103 Market goods become 18 groups (81 members) and 22 single goods, 40 lines.
- G-1a backend, built 2026-11-11: `/datum/goods_group` in `roguestock/goods_groups.dm` (the 18 sheet groups; every other stockpile good becomes a group of one at init, named after the good), `SStreasury.goods_groups`, `build_goods_groups()` after the stockpile datums. Market stock and target live on the group in value (`market_stock`, `market_target`); a good's own `market_target` stays its unit share, and the group's target is the sum of shares times weights. A good's weight is `stockpile_price(market_base_price())`. Goods trade through `market_units()`, `market_target_units()`, `add_market_units()`, `market_label()`; asks and bids walk the group's stock one weight at a time, so the anti-flip rule holds per unit. Steps, zone steps (Glut and Shortage from any member's event), Market dae restock and the open supply share are per group; events shock the whole group of any affected good. Caravans' pending Market deliveries count group value (`pending_market_value()`). The existing screens keep one row per good, showing its group's band and the group's stock in that good's units; G-1b replaces them.
- Slices: G-1 groups and value stock in the Market, with an item picker on withdraw. G-2 royal stock and standing orders by value. G-3 regions and routes expose group value, and tribute counts value. G-4 the caravan grid on groups, with abundance pricing, replacing the R-2 planner; R-3 folds into it.

Open: trip times; the credit line's size (fixed or scaled by population), whether Royal stock sold into the Market also repays it, and whether a Module 7 upgrade raises it; caravan names.

Likely existing bug, outside this PR's scope: `SStreasury/Initialize()` reads the player count while everyone is in the lobby, so `CROWN_PURSE_SEED_PER_PLAYER` and `ROYAL_CUSTOM_VOLUME_PER_POP` add 0. Check the starting treasury stat against pop.

Proposed 2026-11-11, not decided: a Steward's remote scroll that opens the Nerve Master's screens from anywhere in town (areas with `town_area`), so the Steward isn't tied to the counting house. Questions: who can use it (whoever holds it, like the key, or only the Steward and Clerk), whether locking the Nerve Master also locks it, and which actions stay at the machine (anything that moves coins).

## Module 5 - Market dae

- Market stock is decoupled from regional stock. Caravans are the limit on what the Crown moves.
- Each dae, a good's stock moves toward its target by the larger of the rate times the gap or 25% of the target, never past the target.
- Rate is 50%, plus 10% per rented caravan, plus 20% with Tariff Reforms. The 25% floor never changes.
- The whole step shrinks by the share of the good's supplying regions that are raided. An escort cancels its subroute's share for that dae.
- Goods under an active Glut or Shortage are skipped.
- A rate over 100% adds a midday tick: the morning tick closes the whole gap and the midday tick closes the excess share of any gap opened since.
- Renting: a rented caravan earns 200m and adds 10% to the rate each dae, and can't be used. Rentals last at least one dae and can run longer. Recalling a longer rental early loses that dae's income, which is paid at the end of the dae.
- Unraided, a target of 40 reaches Steady in about 3 daes from any band.
- Data for "Next market dae in N minutes" (2g).

### Slices

- 5-1. Market dae core. Built 2026-11-10.
  - `run_market_day()` runs at dawn after raids land and before auto-import. Each good's Market stock moves toward its target by the larger of `MARKET_DAY_RATE` 50% of the gap or `MARKET_DAY_FLOOR` 25% of the target, rounded, never past the target. Royal stock is untouched.
  - The step shrinks by the share of the good's producing regions that are raided, counted by region. Glut and Shortage goods are skipped.
  - A good with no producing region, not importable, or `market_never_supplies` never restocks upward, so the dae can't conjure a good nobody sells. Above target it still sells down at the full step.
  - The Stockpile and Vomitorium screens show "Next market dae in N minutes" with the user's hover text. `seconds_until_dawn()` moved out of the City Assembly panel into `time.dm`.
  - Target 40 reaches Steady in 3 daes from empty and 4 from a 300% glut. Half raided: 5 from empty.
- Waits for Module 4: rented caravans (+10% rate each, 200m a dae), escorts cancelling their subroute's share, and the midday tick once the rate can pass 100%. Tariff Reforms waits for Module 7.

Open: scale targets with population at half strength, or not at all. Whether the raided share should weigh regions by volume instead of count. Whether a raid should also slow the step down from overstock (built: it does, per "the whole step"). Whether a season that rests a good should stop its restock (built: it doesn't, like the out-of-stock check).

## Module 6 - Shortage and glut rework

- Normal trading stops at 0 stock. Only a shortage can push stock below 0.
- A shortage empties the affected goods to 0 and holds one shared debt in mammons for all of them, for example iron ore and iron ingots together. Debt size = today's shortage target in units x the average base price of the affected goods.
- Mitigation: if the Market already holds enough of the affected goods to cover the debt, the shortage is mitigated and only the debt is deducted. Only Market stock counts, never royal stock. Announced like "DAFTSMARCH MINE COLLAPSE ... Thankfully, it is mitigated because of Azure Peak's high stockpile of [STUFFS]".
- The screen shows the debt as negative stock in each good's own units. The bar marker sits left of zero.
- Selling any linked good pays the debt down by its value, at the Shortage price. Caravan deliveries and standing orders that deliver an affected good count too.
- At 0 debt the shortage ends with relief: stock returns to 0 (Very Scarce), the regional price multiplier lifts, imports get cheaper.
- Buying during a shortage costs the Shortage price for goods some region still supplies.
- Standing order premium drops below the Shortage bid.
- Glut stays as built.

## Module 7 - Steward upgrades and automation

- Points come from tribute collected and raids cleared. Never profit or trade volume, so taking a loss to feed the town costs the Steward nothing.
- Upgrades:
  - Better Saigas, Better Sails: 5 minutes off every trip. 500 points.
  - Tariff Reforms: +20% to the Market dae rate. 500 points.
  - Renegotiate the Statute of Monopoly: for the week, caravans can reach Grenzelhoft, Aavnr and Otava as pseudo regions with large supply and demand, special purchases and long trips. 1000 points.
  - Automated Caravans: caravans pick their own imports and exports, and "Priority" goods sell into the Market at a profit. 250 points. Design parked.
  - Let Loose the Dogs of War: raiders can't reconvene for the rest of the week. 500 points.

Open: with the measure decided, whether `economic_output`, `royal_custom_threshold` and the volume defines still have a use.

## Module 8 - Raiders

- Blockades become Raiders, a band that preys on caravans along one subroute. The internal rename is optional.
- While a subroute is raided its regions give no tribute. Tribute returns after clearing. An escort doesn't bring it back.
- Buying from a raided region costs one step more, on top of the escort fee.
- Escort: 100m on the first day of the week and 50m more each day after, for one subroute for one dae. It lets Crown caravans through and lets the Market dae count that route's regions. It doesn't end a shortage.
- Clearing works as today: a quest at a landmark in the route's threat region.
- Round start keeps 2 or 3 raids. Mid-round replenishing works as today, minus Kingsfield's exemption (dropped: other agricultural regions exist now).
- Azure Basin and Terrorbog stay unused on purpose.

Bug carried here (was 3b): the out-of-stock check ignores blockades, so a good whose only producer is blockaded still sells without limit at double price.

### Slices

- 8-1. Raiders on subroutes. Built 2026-11-10.
  - `/datum/blockade` holds a `subroute` instead of a region. Placing one flags every region on it (`is_region_blockaded` stays the per-region flag every consumer reads); clearing unflags them and stamps `day_last_cleared` on each.
  - `roll_blockade()` picks among subroutes: not already raided, not cleared within the cooldown, with an eligible faction and a landmark in the route's threat region. Kingsfield's replenish exemption and `blockade_replenish_eligible` are gone.
  - New helpers `get_subroute_regions()` and `get_subroute_threat_region()` in `routes.dm`; regions derive their threat region through the second.
  - Text: lists and the ledger key on the subroute name; announcements, scroll titles and scout rows name the regions ("cut the trade road to Kingsfield and Saltwick"). The guide's false "rolled only at roundstart" line is deleted and replaced by one line on what a blockade covers.
  - Scout rows (Avisa and Contract Ledger) carry a list of raids per threat region, since both subroutes of one route can be raided at once. The admin panel places and lists by subroute.
  - Raided regions give no tribute (`tribute_units()` returns 0).
  - Bug fixed: `market_has_supply()` skips raided regions, so a good whose only producers are raided goes out of stock at 0.
- 8-2. One-dae warning before a mid-round raid lands. Built 2026-11-10.
  - Replenishing no longer places a raid. It picks the subroute and faction, holds them in `SSeconomy.gathering_blockades` and announces a BLOCKADE WARNING naming the regions. The next dawn lands every gathering raid before the replenish roll runs.
  - The replenish window now reads as the dae the raid lands, so landing days are unchanged and the warning comes a dae earlier.
  - Round start raids and the admin "Fire Blockade Roll" still land at once.
  - A gathering raid shows in the morning report ("Blockades expected at the next dawn"), the scout rows ("massing on the road to", "Strikes at dawn") and the admin panel, which adds "Fire Gathering Roll" and "Land Now". The guide says mid-round blockades are announced a dae early.
  - New helpers `get_subroute_name()` and `get_subroute_region_names()` in `routes.dm`; the blockade datum delegates to them.
- Waits for Module 4: the escort fee and the extra price step on buys from a raided region.

Open: what "one step" means on a fixed regional price; a clearing reward that grows each dae a raid stands (not taken up).

## Module 9 - Divination

- For a moderate price and arcane materials, the Court Magician performs a Ritual of Divination. The Bishop can do the same for a similar cost.
- The omens name 4 coming economic events. Only 2 will happen, and the 4 never contradict each other.

Proposed, not decided:
- Draw 4 events from the eligible pool that don't clash with each other or with active events, then pick 2 at random as real. Decoys pass the same checks so they can't be spotted.
- The 2 real events fire at the next dawn even past the 5-event cap. Other events still roll freely into the remaining slots.
- A second ritual before that dawn repeats the same omens.
- Only the performer hears the omens, so they can sell them.
- A gathering raid can show up among the omens.

## Module 10 - Noble estates (and political factions)

- Nobles pick an estate region at character setup, defaulting to Kingsfield. Foreign and adventurer nobles pick one too.
- Each dae, on top of the stipend, the estate mails a parcel of that region's goods of roughly equal value across regions. Councilors and heirs get double.
- Days 3 and 6 add a flavour gift with no resale value.
- While the estate's subroute is raided nothing arrives. It all arrives once the raid is cleared.
- Political factions: nobles pick one of four or five, or stay neutral, visible to other nobles.

Proposed, not decided:
- The parcel and the gift come from the same region data as caravan tribute: the useful part picked from the region's supply at its tribute value (3-4b), the flavour part from the region's gift list.
- Build after Module 8, which it needs for subroute raids, and after 3-3, so saved character choices point at final region ids.
- HERMES deliveries become one per-player pending list that HERMES hands out. Today's bomb and drug supplies are one-off mind flags with item lists inside `mail.dm`. They move onto it, and estates use it.
- Political factions are a chargen and social feature, not economy, and go in a separate PR.

## Module N - Misc

- Royal Subsidy (built in 2e): 100m of goods a day, free from royal stock or paid by the Treasury at the Market price. Subsidised goods can't be sold back to the stockpile. Open: whether the royal stock draw is capped by the 100m or unlimited.
- Fiber base cost dropped to 1m (built). Cloth, cured leather and iron still to tune.
- Stockpile and Vomitorium refund when destroyed (built in 1d).
- Alderman rework later, if at all.

## Parked from the first draft

Not in the doc's Modules 1 to 9. Kept here until the user decides.
- Buy caps per good, refilling steadily, sized from the visible target.
- Market Connection roles buy their input categories at the bid.
- Steward buy orders above the Market bid, public and quantity-limited.
- A daily limit per good on selling royal stock into the Market.

## Side work, any time

- Goldface light armour pack costs are typed by hand in `merch_armor_light.dm` and need a pass after step 1.
- Decide where ship sales sit relative to the Market.
- Give deer, volf, bear and the other exotic meats their own trade good datums. They share `TRADE_GOOD_MEAT_EXOTIC`, which has no datum, so the Treasury's lookup by trade good only keeps one of them.
- Stale text awaiting the user's wording: the `TRAIT_ROYAL_SUBSIDY` description in `traits.dm`, and the Steward's purchase floor prompt in `steward.dm`.
