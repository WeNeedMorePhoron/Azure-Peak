# Econ 4 rescope (proposal, 2026-11-12)

Not decided. Once the user picks, the decisions move into `econ4_market_plan.md` and this file can go.

## Where this starts

- Caravans are tribute only, for good (user 2026-11-12). Trade is the Market's job.
- Goods grouping is shelved. Pooled prices remove the per crop price signal the agricultural overhaul needs, and its main job was keeping the caravan screen short.
- Noble estates ship. Fifteen to twenty players with an estate on a route care about its raid, where today one or two do.
- Open questions: what replaces direct trade's levers, what shortages need, and what standing orders are for.

## What the code says

These facts change the picture. File references are in the code trace of 2026-11-12.

1. **The Market already is a daily import capacity.** At each dawn the Market dae moves every good's stock toward its target by the larger of half the gap or a quarter of the target, slowed by raids. At 0 stock the Market still sells at Very Scarce (200%), or Shortage (300%) during a shortage, as long as an unraided region produces the good. The Steward can buy from it into royal stock (2d-6), and each band makes the next unit dearer. That is what direct import's escalation did.
2. **Shortages never needed direct trade to end.** Relief counts goods sold into the Market by players, the Steward's sales of royal stock into the Market, and royal stock consumed by standing orders. Exports also counted, a leftover from when shortages were regional. Imports never counted.
3. **Standing orders are the Crown's real export** and its largest trade income. Up to 13 are open, each pays 2.5 times the reference price, minted. Raw goods come from royal stock; equipment and potions come through the dock. A region on a raided subroute can't take delivery.
4. **Orders beat everything right now.** 2.5x is above the Shortage bid (2.25x), so filling an order always pays more than relieving the town's shortage. That is the perverse incentive the gdoc flags. Even buying from the Market at Very Scarce (2x) fills an order at a profit, so "buy from the Market and fill every order" is a loop with no decision in it.
5. **Direct trade is the only automatic refill and drain of royal stock** (auto-import and autoexport), the only feeder of the Export Sales ledger line, the only reader of seasons and Urban's rotating demand, and the backbone of bankruptcy's forced restock and liquidation.
6. **Five events are active almost all the time.** Three fire at round start and the count tops back up to five each dawn. About 60% are shortages. The Market is rarely all Steady.

## The Steward's job without direct trade

The Crown is a warehouse that sits between the regions and the town.

- In: tribute (free), Keep roles' deposits (free), Market purchases (paid at the band price).
- Out: standing orders (at a premium), sales into the Market (at the band bid), the Royal Subsidy.
- Profit comes from timing. Buy in gluts and at Steady, hold, sell into scarcity and to orders. Divination (Module 9) feeds this.
- Decisions each dae: which region to send a tribute caravan to, which orders to fill or let lapse, what to hold for the next shortage, when to release it, whether to pay an escort.

The Market correcting itself doesn't take the job away. With five events running, raids slowing the dae and the Crown's own buying, the Market is off target most of the time. The Steward earns by being faster than the dae.

## Alternatives

### A. The Market desk (recommended)

Retire direct trade. The Market tab becomes the Steward's trade desk.

- Buying and selling stay instant: the existing buy from and sell into the Market.
- Two standing policies per good replace auto-import and autoexport:
  - **Keep N:** at dawn, buy from the Market until royal stock holds N, while the ask is at or below a band the Steward picks.
  - **Release above M:** at dawn, sell royal stock above M into the Market while the Market is Low or worse.
- Bankruptcy's forced restock and liquidation move onto the same two policies.
- The Market dae reads seasons, so a season that rests a good slows its restock. Region detail then reaches every player through the Market, not only the Steward.
- Exports are standing orders (retuned, see below).

What it gains:
- Every Crown purchase raises the Market price and pays whoever sells next. That is the gdoc's "high value player interaction" premise.
- One price system instead of two.
- The trade modal, escalating regional prices and blockade multipliers all go.

What it loses:
- Cheap supply when the Market is already short. In scarcity the Steward pays band prices, so stocking up ahead matters more.

Build: one large removal slice (split DM and TGUI), then three small ones (policies, Market dae seasons, order retune).

Risk: the Crown's buying drains the town's Market. The bands limit it, since each unit costs more. Orders below 2x (see below) stop paying once the Market reaches Very Scarce.

### A+. Crown bids (optional add to A)

Parked from the first draft. The Steward posts a public bid above the Market bid for N units of a good. Deposits fill the bid first: the seller gets the Crown's price from the Treasury, and the goods go to royal stock.

- Turns Crown demand straight into player income: a miner sees "The Crown buys iron ore at 9m, 40 left".
- A walk away option: a standing bid for essentials is the old auto-import, routed through players.
- Risk: a bid diverts deposits from the Market, so the town's Market can stay short while the Crown buys. Cap it by quantity, and consider only filling bids while the Market for that good is Steady or better.

### B. Trade charter (the user's proposal, made safe)

A, plus a capped daily import and export with the regions at fixed prices, instant, into and out of royal stock.

- Capacity per good is the regions' daily supply or demand: seasons, Urban rotation, raided regions removed. No escalation, no blockade multiplier.
- Prices decide what it is:
  - **Closed:** import at the base price times the event modifier, export at the Steady bid (75%). Cheaper than the Market only when the Market is Low or worse, so it acts as a relief valve.
  - **Open** ("deliberately arbitrage-able"): producers sell below base, demanders pay above (0.7 and 1.2). Import from one region and export to another for about 70% a unit, every dae, limited only by capacity. This is an income line with no decision in it. The best play is to max it every dae, which is a chore. The caravan review found the same loop.

What it gains:
- Seasons and rotation stay directly in play.
- Closest to today's feel.

What it loses:
- Two price systems side by side.
- Crown demand bypasses players: the charter beats the Market whenever the Market isn't Plentiful, so most Crown buying leaves the Market alone.
- Charter imports into orders is a second loop next to A's.

Build: medium. Rework the parked backend (strip escalation and blockade multipliers) and a new screen.

### C. Keep direct trade as it is

Cut caravans to tribute and leave manual and automatic import and export as they are.

What it gains: least work, ships fastest.

What it loses:
- Two overlapping trade systems: the Market's buy and sell, and region import and export at escalating prices.
- Blockade multipliers, the trade modal and the Export Sales line stay.
- The escort and Module 6 have to fit around both systems.

### D. Regional deals (added 2026-11-12)

Regions trade with the Crown through discrete deals instead of a price curve. Exports are standing orders, which already exist. Imports become offers, the mirror of an order.

- An **offer** is a region selling the Crown a set amount of one good at a set price until it expires: "Daftsmarch offers 40 iron ore at 6m each, today and tomorrow". Accepting it pays the Treasury and puts the goods in royal stock at once.
- Offers roll each dawn from the region's types, seasons and events, the way orders roll from its demand. A region on a raided subroute can't deliver.
- Prices vary around the base price. An offer is a good deal only against the Market's band, an open order or a coming shortage, so taking it is a judgement, not a reflex.
- Goods no region supplies through the Market (sugar, coffee, tea, a route's unique imports) come only through offers. That is the gdoc's Module 4 "Steward Import is now regional ... special imports ... limited supplies", without the caravan.
- Walk away option: Keep N can draw on open offers before the Market.
- Build: offers reuse the standing order framework (region, goods, price, expiry, raid check, the Orders tab).

Why it beats direct trade on decisions: the old trade's real decisions were which good and how many, at a rising price, and both survive in buying from the Market. Its region choice was bookkeeping, because the game always routed to the cheapest region. Deals make the region the decision: this region, this good, this price, until this dae.

User 2026-11-12: liked. Offers are the counterpart of standing orders and give the Steward a large, changing pool of "there's a good deal" moments with urgency.

### D2. Reactive caravans (decided 2026-11-12)

Caravans come back as the way deals travel. The Steward never packs cargo; the deals are the cargo. User 2026-11-12: orders and offers both travel; it revamps the caravan idea and is far simpler.

- Accepting an offer or committing royal stock to an order books the deal with that region. It waits there until a caravan goes.
- **Send** a caravan to a region: one click. It carries every booked deal with that region, delivering order goods and fetching offer goods.
- Tribute is its own run (proposed 2026-11-12): a send either runs the region's deals or collects its tribute, never both. User 2026-11-12 shelved giving deal visits extra tribute: Daftsmarch and Hagenwald will be busy with iron and steel deals, and tribute riding along would make them the default destination. Kept separate, tribute stays a deliberate pick that competes with deals for the fleet, once per region per dae.
- The trip takes its route's time. Deals book when the caravan leaves (approved 4-1 rule), so a dawn or a raid mid-trip can't strand them. Offer goods reach royal stock and order payouts are paid when it returns.
- A deal must leave before it expires. With 4 caravans at start, 8 at most, and 15 to 30 minute trips against a dae of about 29 minutes, the Crown gets about 6 to 12 sends a dae against 17 tribute picks plus every region holding a deal. The fleet is the limit: which regions to visit, and which deals to batch into one trip, are the decisions. User 2026-11-12: more caravans, since each send is a click or two. Caravans stay free; past about 12 sends a dae nearly every tribute gets collected and the choice goes.
- Raided subroutes: no tribute and no deals, unless an escort is paid for that dae (the escort also lets the Market dae count the subroute).
- Cross-region trade is allowed and is the Crown's middleman role: buy a region's offer, carry it home, sell it to another region's order or into the Market. Same region round trips are ruled out at the roll: a region never has an offer and an order open for the same good.
- No cargo capacity. Deals are already bounded, and the fleet and trip time do the limiting.
- Salvage from the shelf: the fleet (start size, dawn top up), trip timers, booking at departure, route trip times, signature tribute per region.

### Recommendation

A, with D's offers as the Crown's import, in place of a trade charter. Add Crown bids (A+) later if playtests show players short of reasons to sell. Keep B closed in reserve. Avoid B open.

## Standing orders

Their place: the export. They're the only way goods leave town for profit, the reason royal stock exists, and the Crown's main trade income.

Changes:
1. **Premium below the Shortage bid**, the Module 6 rule: 2x instead of 2.5x, as a define. Filling an order then pays from the Market until Very Scarce and stops there, and relieving a town shortage always beats an order.
2. **Drop urgent orders.** They pay at or below regular orders, and the Shortage bid already rewards relief.
3. **Equipment and potion orders** through the dock are the high value player transaction the gdoc wants: the Crown buys a smith's or apothecary's work to fill them. Worth more of them in the roll weights.
4. Optional: order sizes from the region's seasonal daily demand, so seasons also reach play through orders.

Keep: petitions, partial fills, pairs, raided regions refusing delivery.

## Shortages

- Nothing needs reworking to retire direct trade. The export's relief credit goes with export.
- Ship as built: stock to 0, the Shortage price, relief by goods entering the Market or consumed by orders.
- Without direct trade a shortage ends when players sell at the Shortage bid, or the Steward releases stock held ahead. Both are the intended play.
- Module 6 (shortage debt, mitigation) is polish and can follow the ship.
- Tuning to consider: five active events may be too many once the Steward can't import out of them. Three or four.

## Ship scope

### Phase 0. Reset (the user runs git)

1. Copy `docs/design/` out first. The plan, the text sheet and the groups sheet are staged as new files, and a hard reset deletes staged new files.
2. A shelf branch at the current HEAD, and the working tree saved as a patch (caravans, signature tribute, G-1a goods groups).
3. Reset `tiny-econ` to "Implement Market Day" (`6ce5ed05b0d`). The 3-4b region tribute data is there. With reactive caravans, "Caravan - Part 1" (`336b7ea6912`) is the alternative target: it keeps the fleet and trip backend (4-1), though its trip contents get rewritten around deals.

### Phase 1. The Market desk

- M1. Retire direct trade, DM: manual import and export, autoexport, auto-import, the export price column on the Stockpile and Vomitorium, `stockpile_limit`, the Export Sales and Imports ledger lines, bankruptcy's hooks.
- M2. Retire direct trade, TGUI: the trade modal, region import and export lines, the auto-import tab, the autoexport controls. The Regions tab becomes read only.
- M3. Keep and Release policies, with bankruptcy on them.
- M4. The Market dae reads seasons.
- M5. Order retune: premium define, urgent orders removed.
- M6. Crown bids (optional).

### Phase 2. Regional deals, caravans and estates

- D-1. Offers: rolled per region at dawn from types, seasons and events; never alongside an order for the same good in the same region; booked against the region; shown beside orders.
- D-2. Reactive caravans: fleet, booked deals per region, Send to a region for its deals or for its tribute, trip time, payouts and goods on return. Orders deliver by caravan.
- D-3. Escort: one subroute for one dae, for caravans and the Market dae.
- D-4. Estates: region pick at character setup, a daily parcel through a HERMES pending list, councilors and heirs double, gifts on days 3 and 6, stalled while raided. Shares the signature good and value curve (flat until 70 to 80 players) with tribute.

### Phase 3. Before release

- 2j resale cap.
- Steward screen text and guide pass.
- Optional: Divination (Module 9).

### Cut, or after the ship

Route trade, goods groups, caravan building, rentals, the credit line, region volume scaling, Statute pseudo regions, Module 7 upgrades (parking a tribute caravan can be the first one later), the Module 6 shortage debt, political factions (separate PR).

## Decisions for the user

1. A, B or C. If B, closed or open.
2. Crown bids in the ship, or after.
3. Order premium (2x or another number), and whether urgent orders go.
4. Event count: keep five or lower it.
5. The escort's cost from the gdoc (100m on the first day of the week, 50m more each day after): keep it?
6. Decided 2026-11-12: orders travel by caravan too.
7. When an order pays: when the caravan leaves (simplest, money now) or when it returns (time matters for money).
8. Order premium once offers exist: offer then order is a deliberate profit, so the premium may want to sit lower than 2x.
9. Tribute value against fleet size: a tribute run should be worth about an average deal run so the pick stays a tradeoff, which makes the fleet cap the knob for total tribute income a dae.
