/datum/controller/subsystem/treasury/proc/poll_levy_duke_present()
	for(var/mob/living/M in list(SSticker.rulermob, SSticker.regentmob))
		if(!QDELETED(M) && M.stat != DEAD)
			return TRUE
	return FALSE

/datum/controller/subsystem/treasury/proc/get_poll_levy_authority(mob/living/user)
	if(!user)
		return null
	if(user == SSticker.rulermob || user == SSticker.regentmob)
		return "duke"
	if(user.job == "Steward")
		return "steward"
	return null

/datum/controller/subsystem/treasury/proc/get_poll_levy_block_reason(mob/living/user)
	var/authority = get_poll_levy_authority(user)
	if(!authority)
		return "Only the [SSticker.rulertype] or the Steward can levy."
	if(authority == "steward" && poll_levy_duke_present())
		return "The [SSticker.rulertype] is present. Only they can levy."
	var/datum/decree/magna_carta = get_decree(DECREE_MAGNA_CARTA)
	if(magna_carta?.active)
		return "No levies while the Magna Carta is in force."
	if(GLOB.dayspassed < POLL_LEVY_FIRST_DAY)
		return "No levies before day [POLL_LEVY_FIRST_DAY]."
	if(length(poll_levies) >= POLL_LEVY_MAX_PER_ROUND)
		return "No levies left this week."
	if(authority == "steward")
		for(var/list/levy as anything in poll_levies)
			if(levy["authority"] == "steward")
				return "The Steward has already levied this week."
	if(length(poll_levies))
		var/list/last = poll_levies[length(poll_levies)]
		if(GLOB.dayspassed - last["day"] < POLL_LEVY_MIN_GAP_DAYS)
			return "A poll levy was raised today. Try again tomorrow."
	return null

/datum/controller/subsystem/treasury/proc/get_poll_levy_due(mob/living/payer, base)
	var/due = min(base, CHARGE_CAP_FLAT)
	for(var/id in decrees)
		var/datum/decree/D = decrees[id]
		due = D.apply_charge_cap(payer, TAX_CATEGORY_POLL_LEVY, due)
	return max(due, 0)

/datum/controller/subsystem/treasury/proc/charge_poll_levy(mob/living/owner, datum/fund/account, list/levy)
	if(!owner || !account)
		return null
	if(owner.real_name in levy["charged"])
		return null
	var/category = get_poll_tax_category(owner)
	if(!category)
		return null
	var/list/amounts = levy["amounts"]
	var/base = amounts[category]
	if(!base)
		return null
	levy["charged"] |= owner.real_name
	if(is_tax_exempt(owner, TAX_CATEGORY_POLL_LEVY))
		record_tax_exemption(TAX_CATEGORY_POLL_LEVY, base)
		return null
	var/due = get_poll_levy_due(owner, base)
	if(due < base)
		record_tax_exemption(TAX_CATEGORY_POLL_LEVY, base - due)
	if(due <= 0)
		return null
	var/paid = min(due, max(account.balance, 0))
	if(paid > 0 && !transfer(account, discretionary_fund, paid, "Poll levy ([get_poll_tax_category_pretty_name(category)])"))
		paid = 0
	if(paid > 0)
		record_poll_tax_by_category(category, paid)
	var/owed = due - paid
	if(owed > 0)
		poll_tax_owed[owner] = (poll_tax_owed[owner] || 0) + owed
		record_round_statistic(STATS_POLL_LEVY_ARREARS, owed)
		ADD_TRAIT(owner, TRAIT_ARREARS, TRAIT_GENERIC)
		to_chat(owner, span_danger("<b>POLL LEVY:</b> [paid]m taken from your account. You owe the Crown [owed]m in arrears."))
	else
		to_chat(owner, span_notice("<b>POLL LEVY:</b> [paid]m taken from your account."))
	return list(paid, owed)

/datum/controller/subsystem/treasury/proc/enact_poll_levy(mob/living/user, list/raw_amounts, raw_reason)
	var/block = get_poll_levy_block_reason(user)
	if(block)
		to_chat(user, span_warning(block))
		return FALSE
	var/reason = trim(copytext_char(trim(STRIP_HTML_SIMPLE("[raw_reason]", MAX_MESSAGE_LEN)), 1, POLL_LEVY_REASON_MAX + 1))
	if(length_char(reason) < POLL_LEVY_REASON_MIN)
		to_chat(user, span_warning("The reason must be at least [POLL_LEVY_REASON_MIN] characters."))
		return FALSE
	var/list/amounts = list()
	if(islist(raw_amounts))
		for(var/entry in raw_amounts)
			if(!islist(entry))
				continue
			var/category = entry["category"]
			if(!(category in POLL_LEVY_CLASS_ORDER))
				continue
			if(get_poll_levy_exempting_charter(category))
				continue
			var/amount = CLAMP(round(text2num("[entry["amount"]]")), 0, CHARGE_CAP_FLAT)
			if(amount > 0)
				amounts[category] = amount
	if(!length(amounts))
		to_chat(user, span_warning("Set an amount for at least one class."))
		return FALSE

	var/authority = get_poll_levy_authority(user)
	var/list/levy = list(
		"day" = GLOB.dayspassed,
		"authority" = authority,
		"amounts" = amounts,
		"reason" = reason,
		"raised" = 0,
		"arrears" = 0,
		"charged" = list(),
	)
	poll_levies += list(levy)
	record_round_statistic(STATS_POLL_LEVIES_ENACTED, 1)

	for(var/key in bank_accounts)
		var/datum/fund/account = bank_accounts[key]
		if(!account || account.currency != CURRENCY_MAMMON)
			continue
		var/list/result = charge_poll_levy(account.get_owner(), account, levy)
		if(result)
			levy["raised"] += result[1]
			levy["arrears"] += result[2]

	var/list/lines = list()
	var/announcer = authority == "duke" ? "The gracious [SSticker.rulertype]" : "The righteous Steward"
	lines += "[announcer] has enacted a poll levy of:"
	for(var/category in POLL_LEVY_CLASS_ORDER)
		if(!amounts[category])
			continue
		var/list/caps = get_poll_levy_class_caps(category)
		var/shown = min(amounts[category], caps["cap"])
		var/line = "- [get_poll_tax_category_pretty_name(category)]: [shown]m / head"
		if(caps["partial"] && shown > CHARGE_CAP_CHARTER)
			line += " ([CHARGE_CAP_CHARTER]m for [caps["partial"]])"
		lines += line
	lines += ""
	lines += "For reasons of:"
	lines += html_encode(reason)
	lines += ""
	var/tally = "This has raised [levy["raised"]]m in revenue for the realm."
	if(levy["arrears"] > 0)
		tally += " The levy has incurred [levy["arrears"]]m in arrears."
	lines += tally
	priority_announce(jointext(lines, "<br>"), "POLL LEVY", pick('sound/misc/royal_decree.ogg', 'sound/misc/royal_decree2.ogg'), "Captain", user, strip_html = FALSE)

	var/list/log_parts = list()
	for(var/category in amounts)
		log_parts += "[get_poll_tax_category_pretty_name(category)] [amounts[category]]m"
	log_game("POLL LEVY: [key_name(user)] ([authority]) levied [jointext(log_parts, ", ")]; raised [levy["raised"]]m, [levy["arrears"]]m in arrears. Reason: [reason]")
	return TRUE

/datum/controller/subsystem/treasury/proc/apply_past_poll_levies(mob/living/owner)
	if(QDELETED(owner))
		return
	var/datum/fund/account = get_account(owner)
	if(!account)
		return
	for(var/list/levy as anything in poll_levies)
		var/list/result = charge_poll_levy(owner, account, levy)
		if(result)
			levy["raised"] += result[1]
			levy["arrears"] += result[2]

/datum/controller/subsystem/treasury/proc/get_poll_levy_class_caps(category)
	var/list/covers = list()
	switch(category)
		if(POLL_TAX_CAT_BURGHER)
			covers[DECREE_GOLDEN_BULL] = null
			covers[DECREE_NOC_PESTRA_COVENANT] = "Head Physician, Apothecary and Magicians Associate"
		if(POLL_TAX_CAT_COURTIER)
			covers[DECREE_NOC_PESTRA_COVENANT] = "University staff"
		if(POLL_TAX_CAT_MERCENARY)
			covers[DECREE_GUILD_CHARTER_OF_ARMS] = null
	var/cap = CHARGE_CAP_FLAT
	var/partial
	var/list/charters = list()
	for(var/id in covers)
		var/datum/decree/D = get_decree(id)
		if(!D?.active)
			continue
		if(covers[id])
			partial = covers[id]
			charters += "[D.name] - [covers[id]] only"
		else
			cap = min(cap, CHARGE_CAP_CHARTER)
			charters += D.name
	if(cap <= CHARGE_CAP_CHARTER)
		partial = null
	return list("cap" = cap, "partial" = partial, "charters" = charters)

/datum/controller/subsystem/treasury/proc/get_poll_levy_ui_data(mob/living/user)
	var/list/heads = list()
	for(var/key in bank_accounts)
		var/datum/fund/account = bank_accounts[key]
		if(!account || account.currency != CURRENCY_MAMMON)
			continue
		var/category = get_poll_tax_category(account.get_owner())
		if(category)
			heads[category] = (heads[category] || 0) + 1
	var/list/classes = list()
	for(var/category in POLL_LEVY_CLASS_ORDER)
		classes += list(list(
			"category" = category,
			"label" = get_poll_tax_category_pretty_name(category),
			"exempt_charter" = get_poll_levy_exempting_charter(category),
			"heads" = heads[category] || 0,
			"cap_charters" = get_poll_levy_class_caps(category)["charters"],
		))
	return list(
		"authority" = get_poll_levy_authority(user),
		"blocked_reason" = get_poll_levy_block_reason(user),
		"levies_used" = length(poll_levies),
		"levies_max" = POLL_LEVY_MAX_PER_ROUND,
		"classes" = classes,
		"charter_cap" = CHARGE_CAP_CHARTER,
	)
