/datum/controller/subsystem/economy/proc/run_market_day()
	for(var/datum/goods_group/G as anything in SStreasury.goods_groups)
		G.market_day_step(MARKET_DAY_RATE)
	SStreasury.dirty_market_view()
