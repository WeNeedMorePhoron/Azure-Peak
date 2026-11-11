// Caravan text sheet, route trade (R-1, R-2). Edit the strings in place and keep the names on the left so the edits map back.
// [brackets] are filled in by the game. Not compiled.
// [route] is the route's name as data: "Northern Seaway", "Southern Seaway", "The Ore Road", "River Azur". "The Ore Road" keeps its capital mid-sentence.

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

// Trip refusals, shown in the planner and in chat on Send - caravan_trips.dm
var/err_no_route = "Pick a route."
var/err_route_raided = "Raiders block all of [route]."
var/err_doesnt_sell = "[route] doesn't sell [good]."
var/err_left_some = "[route] has only [n] [good] left today."
var/err_left_none = "[route] has no [good] today."
var/err_doesnt_buy = "[route] doesn't buy [good]."
var/err_wanted_some = "[route] wants only [n] more [good] today."
var/err_wanted_none = "[route] wants no [good] today."
var/err_not_enough_to_sell = "Not enough [good] to sell. Royal stock has [n] and the Market has [m]."
var/err_tribute_claimed = "[route] has already given its tribute today."
var/err_tribute_good = "[route] can't give [good] as tribute today."
var/err_tribute_too_dear = "[route]'s tribute can't cover a single [good]."
var/err_capacity_out = "A caravan carries at most [100] goods out."
var/err_capacity_home = "A caravan carries at most [100] goods home."
var/err_empty_trip = "Give the caravan something to buy, sell or collect."
var/err_treasury = "The Treasury can't afford this trip. It has [balance]m and needs [cost]m."

// Tab - TabBar.tsx, StewardTrade.tsx
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
var/btn_plan_again = "Plan again"
var/btn_plan_again_hover = "Load this caravan's last trip, trimmed to what the route has today."
var/btn_plan_trip = "Plan a trip"

// Planner: route and tribute - CaravansView.tsx
var/planner_title = "Planning [caravan]"
var/label_route = "Route"
var/route_button = "[route] · [n] min"
var/route_badge_raided = "RAIDERS"
var/route_hover_closed = "Raiders hold the whole route."
var/route_raided_note = "Raiders hold [subroute]. Its regions are out of reach today."
var/label_tribute = "Tribute · [value]m"
var/tribute_given = "Tribute already given today."
var/tribute_none = "No tribute today."
var/tribute_chip = "[n] [good] · [region]"

// Planner: goods tables - CaravansView.tsx
var/table_needs = "The town needs"
var/table_needs_empty = "Nothing the town needs is for sale on this route."
var/table_spare = "The town can spare"
var/table_spare_empty = "Nothing the town can spare is wanted on this route."
var/head_in_town = "In town"
var/head_on_route = "On the route"
var/head_price = "Price"
var/head_each = "Each"
var/head_each_hover = "Earned per unit against the Market's price now."
var/cell_for_sale = "[n] for sale"
var/cell_wanted = "[n] wanted"
var/cell_spare = "[n] spare"
var/btn_less = "-"
var/btn_more = "+"
var/btn_all = "All"
var/btn_show_all = "Show every good"
var/btn_show_needs = "Show only what the town needs"

// Planner: cargo, totals and buttons - CaravansView.tsx
var/label_cargo = "Cargo"
var/cargo_sell = "Sell"
var/cargo_buy = "Buy"
var/cargo_tribute = "Tribute"
var/cargo_line = "[n] [good]"
var/cargo_to_royal = "[n] to royal stock"
var/cargo_to_market = "[n] to the Market"
var/cargo_from_royal = "[n] from royal stock"
var/cargo_from_market = "[n] from the Market"
var/cargo_remove_hover = "Remove"
var/bar_out = "Goods out"
var/bar_in = "Goods in"
var/quote_pending = "Pricing..."
var/quote_summary = "Cost now [x]m · Paid on return [y]m in sales"
var/quote_summary_market = " and about [z]m from the Market"
var/quote_treasury = " · Treasury after departure [t]m"
var/quote_return = " · Back in [n] minutes"
var/btn_cancel = "Cancel"
var/btn_send = "Send [caravan]"
