// Caravan text sheet, route trade (R-1 and signature tribute). Edit the strings in place and keep the names on the left so the edits map back.
// [brackets] are filled in by the game. Not compiled.
// [route] is the route's name as data: "Northern Seaway", "Southern Seaway", "The Ore Road", "River Azur". "The Ore Road" keeps its capital mid-sentence.
// The R-2 planner was shelved on 2026-11-11 for the goods groups redesign; its strings live in C:/tmp/shelved-econ4-r2/.

// Nerve Master speech - caravan_trips.dm
var/caravan_name = "Caravan [n]"
var/say_departs = "[caravan] sets out on [route]."
var/say_returns = "[caravan] returns from [route]."

// Ledger lines - caravan_trips.dm
var/ledger_purchase = "Caravan Purchase: [caravan] on [route]"
var/ledger_market_purchase = "Caravan Market Purchase: [caravan] on [route]"
var/ledger_sale = "Caravan Sale: [caravan] on [route]"
var/ledger_market_sale = "Caravan Market Sale: [caravan] from [route]"

// Chat warning on Send - caravan_trips.dm
var/warn_on_road = "That caravan is already on the road."

// Trip refusals - caravan_trips.dm
var/err_no_route = "Pick a route."
var/err_route_raided = "Raiders block all of [route]."
var/err_doesnt_sell = "[route] doesn't sell [good]."
var/err_left_some = "[route] has only [n] [good] left today."
var/err_left_none = "[route] has no [good] today."
var/err_doesnt_buy = "[route] doesn't buy [good]."
var/err_wanted_some = "[route] wants only [n] more [good] today."
var/err_wanted_none = "[route] wants no [good] today."
var/err_not_enough_to_sell = "Not enough [good] to sell. Royal stock has [n] and the Market has [m]."
var/err_tribute_claimed = "[region] has already given its tribute today."
var/err_tribute_region = "[region] can't give tribute to a caravan on [route] today."
var/err_tribute_too_dear = "[region]'s tribute can't cover a single [good]."
var/err_capacity_out = "A caravan carries at most [100] goods out."
var/err_capacity_home = "A caravan carries at most [100] goods home."
var/err_empty_trip = "Give the caravan something to buy, sell or collect."
var/err_treasury = "The Treasury can't afford this trip. It has [balance]m and needs [cost]m."

// Tab - TabBar.tsx, CaravansView.tsx
var/tab_label = "Caravans"
var/section_header = "Caravans"

// Fleet list - CaravansView.tsx
var/card_home = "At home."
var/card_on_road = "On [route]. Back in [N minutes]."
var/card_back_soon = "a minute"
var/card_detail = "[n] out, [n] in · paid [x]m · brings [y]m in sales"
var/card_detail_market = " and about [z]m from the Market"
var/card_detail_tribute = " · tribute: [n] [good]"
var/card_detail_sender = " · sent by [name]"
