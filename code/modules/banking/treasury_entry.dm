/datum/treasury_entry
	var/world_time
	var/kind
	var/from_name
	var/to_name
	var/amount
	var/currency
	var/reason
	var/count = 1
	var/time_created = 0
	var/day_created = 0
	var/actor_name
	var/actor_rank = FISCAL_RANK_NONE
	var/reversed_amount = 0

/datum/treasury_entry/New(entry_kind, datum/fund/from_fund, datum/fund/to_fund, entry_amount, entry_reason, from_label, mob/actor)
	. = ..()
	world_time = world.time
	kind = entry_kind
	amount = entry_amount
	reason = entry_reason
	from_name = from_fund ? from_fund.name : (from_label || "void")
	to_name = to_fund ? to_fund.name : "void"
	var/datum/fund/source = from_fund || to_fund
	currency = source?.currency
	time_created = world.time
	day_created = GLOB.dayspassed
	count = 1
	if(actor)
		actor_name = actor.real_name
		actor_rank = fiscal_rank(actor)

/datum/treasury_entry/proc/remaining()
	return max(0, amount - reversed_amount)

/datum/treasury_entry/proc/format()
	var/suffix = reason ? " ([reason])" : ""
	switch(kind)
		if("mint")
			return "+[amount] to [to_name][suffix]"
		if("burn")
			return "-[amount] from [from_name][suffix]"
		if("transfer")
			return "[amount] from [from_name] to [to_name][suffix]"
		if("grant")
			return "[amount] granted to [to_name] by [actor_name || "unknown"][suffix]"
	return "[kind] [amount][suffix]"
