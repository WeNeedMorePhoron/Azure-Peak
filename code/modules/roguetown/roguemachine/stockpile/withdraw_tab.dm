/datum/withdraw_tab
	var/budget = 0
	var/compact = TRUE
	var/current_category = "Raw Materials"
	var/list/categories = list("Raw Materials", "Refined", "Alchemy", "Fruit", "Vegetable", "Animal", "Seafood")
	var/obj/structure/roguemachine/parent_structure = null

/datum/withdraw_tab/New(obj/structure/roguemachine/structure_param)
	. = ..()
	parent_structure = structure_param

/datum/withdraw_tab/proc/insert_coins(obj/item/roguecoin/C)
	budget += C.get_real_price()
	qdel(C)
	parent_structure.update_icon()
	playsound(parent_structure.loc, 'sound/misc/coininsert.ogg', 100, TRUE, -1)

/datum/withdraw_tab/proc/refund_budget(mob/user)
	if(budget <= 0)
		return FALSE
	if(floor(mammon_round(budget)) < 1)
		return FALSE
	budget = refund_pouch(budget, user)
	return TRUE

/datum/withdraw_tab/proc/get_direct_import_quote(datum/roguestock/D)
	if(!D || !D.trade_good_id)
		return null
	var/list/best = SSeconomy.get_best_import_region(D.trade_good_id)
	if(!best || !best["region_id"])
		return null
	var/datum/economic_region/region = GLOB.economic_regions[best["region_id"]]
	if(!region)
		return null
	var/daily_pace = region.produces[D.trade_good_id] || 0
	var/produces_today = region.produces_today[D.trade_good_id] || 0
	if(daily_pace <= 0 || produces_today <= 0)
		return null
	var/starting_index = max(0, daily_pace - produces_today)
	var/unit_cost = SSeconomy.compute_import_unit_price(D.trade_good_id, region, starting_index + 1)
	var/margin = (SStreasury.royal_custom_active && SStreasury.royal_custom_unlocked) ? SStreasury.royal_custom_margin : ROYAL_CUSTOM_DEFAULT_MARGIN
	var/price = stockpile_price(unit_cost * (100 + margin) / 100)
	return list("region" = region, "unit_cost" = unit_cost, "price" = price)

/datum/withdraw_tab/proc/direct_import_price(datum/roguestock/D)
	var/list/quote = get_direct_import_quote(D)
	return quote ? quote["price"] : 0

/datum/withdraw_tab/proc/do_withdraw(datum/roguestock/D, mob/user)
	if(!D || !parent_structure)
		return FALSE
	if(get_dist(parent_structure, user) > 1)
		return FALSE
	D.refresh_auto_price()
	D.get_market_target()
	if(D.market_never_supplies)
		parent_structure.say("Not available.")
		return FALSE
	var/food_stipend = ishuman(user) && HAS_TRAIT(user, TRAIT_ROYAL_SUBSIDY) && D.royal_stock > 0
	if(food_stipend)
		D.royal_stock--
		var/actor_suffix = user ? " by [user.real_name]" : ""
		SStreasury.log_fund_entry(new /datum/treasury_entry(null, SStreasury.discretionary_fund, SStreasury.discretionary_fund, 0, "Subsidy Withdraw: [D.name][actor_suffix]"))
	else
		if(D.market_stock <= 0 && !D.market_has_supply())
			parent_structure.say("Out of stock.")
			return FALSE
		var/total_price = D.market_ask(1)
		if(total_price > mammon_round(budget))
			parent_structure.say("You haven't put in enough mammon.")
			return FALSE
		budget = max(0, mammon_round(budget - total_price))
		D.market_stock = max(0, D.market_stock - 1)
		D.check_glut_relief()
		record_round_statistic(STATS_STOCKPILE_REVENUE, total_price)
	SStreasury.dirty_market_view()
	var/obj/item/I = new D.item_type(parent_structure.loc)
	if(food_stipend)
		to_chat(user, span_info("[parent_structure] chitters and squeaks. Your food stipend pays from the Treasury."))
	if(!user.put_in_hands(I))
		I.forceMove(get_turf(user))
	playsound(parent_structure.loc, 'sound/misc/hiss.ogg', 100, FALSE, -1)
	return TRUE

/datum/withdraw_tab/proc/do_direct_import(datum/roguestock/D, mob/user)
	if(!D || !ishuman(user) || !parent_structure)
		return FALSE
	if(!D.trade_good_id || D.market_never_supplies)
		parent_structure.say("Not available.")
		return FALSE
	var/list/quote = get_direct_import_quote(D)
	if(!quote)
		parent_structure.say("No region currently supplies [D.name].")
		return FALSE
	var/datum/economic_region/region = quote["region"]
	var/unit_cost = quote["unit_cost"]
	var/price = quote["price"]
	var/surcharge = max(0, round(price - unit_cost, STOCKPILE_PRICE_STEP))
	var/food_stipend = HAS_TRAIT(user, TRAIT_ROYAL_SUBSIDY)
	var/using_stipend = food_stipend && price > budget
	if(using_stipend)
		if(SStreasury.discretionary_fund.balance < unit_cost)
			parent_structure.say("The Treasury can't cover the import cost.")
			return FALSE
	else
		if(price > budget)
			parent_structure.say("You haven't put in enough mammon.")
			return FALSE
		if(SStreasury.discretionary_fund.balance < unit_cost)
			parent_structure.say("The Treasury can't cover the import cost.")
			return FALSE
	var/spent = SSeconomy.manual_import(user, region.region_id, D.trade_good_id, 1, using_stipend)
	if(!spent)
		return FALSE
	if(using_stipend)
		record_treasury_expense(TREASURY_FLOW_SUBSIDY, treasury_role_of(user), spent)
	else
		budget = mammon_round(budget - price)
	D.royal_stock = max(0, D.royal_stock - 1)
	SStreasury.dirty_market_view()
	var/chartered = SStreasury.royal_custom_active && SStreasury.royal_custom_unlocked
	if(!using_stipend)
		SStreasury.mint(SStreasury.discretionary_fund, unit_cost, "Direct import reimbursement: [D.name] from [region.name]", null, LEDGER_CROWN_REV_STOCKPILE_SALES)
	record_round_statistic(STATS_STOCKPILE_DIRECT_IMPORTS, price)
	record_material_flow(MATERIAL_FLOW_IN, MATERIAL_SOURCE_LOCAL_IMPORT, D.item_type, 1, price)
	if(!using_stipend && chartered && surcharge > 0)
		SStreasury.mint(SStreasury.discretionary_fund, surcharge, "Royal Custom: direct import of [D.name]", null, LEDGER_CROWN_REV_STOCKPILE_SALES)
		record_round_statistic(STATS_STOCKPILE_REVENUE, surcharge)
	var/obj/item/I = new D.item_type(parent_structure.loc)
	if(!user.put_in_hands(I))
		I.forceMove(get_turf(user))
	playsound(parent_structure.loc, 'sound/misc/hiss.ogg', 100, FALSE, -1)
	if(using_stipend)
		var/waived = max(0, surcharge)
		to_chat(user, span_info("[parent_structure] chitters and squeaks. Your food stipend pays from the Treasury."))
		if(waived > 0)
			to_chat(user, span_notice("[D.name] imported from [region.name] for [unit_cost]m. Your food stipend paid for it. The [waived]m markup is waived."))
		else
			to_chat(user, span_notice("[D.name] imported from [region.name] for [unit_cost]m."))
	else
		var/flavor = chartered ? "The markup goes to the Treasury." : "The markup pays for shipping."
		to_chat(user, span_notice("[D.name] imported from [region.name] for [price]m. [flavor]"))
	return TRUE

/proc/stock_announce(message)
	for(var/obj/structure/roguemachine/stockpile/S in SSroguemachine.stock_machines)
		S.say(message, spans = list("info"))
