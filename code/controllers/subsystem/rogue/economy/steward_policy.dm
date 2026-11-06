/datum/controller/subsystem/treasury/proc/export_steward_policy()
	var/list/autoexport_barred = list()
	for(var/datum/roguestock/D as anything in stockpile_datums)
		if(!D.trade_good_id)
			continue
		if(D.autoexport_disabled)
			autoexport_barred += D.trade_good_id
	var/list/standing = list()
	for(var/good_id in auto_import_standing)
		standing += good_id
	var/list/auto_import_off = list()
	for(var/good_id in auto_import_disabled)
		auto_import_off += good_id
	return json_encode(list(
		"version" = STEWARD_POLICY_EXPORT_VERSION,
		"autoexport_barred" = autoexport_barred,
		"auto_import_standing" = standing,
		"auto_import_off" = auto_import_off,
		"autoexport_percentage" = round(autoexport_percentage * 100),
		"auto_import_purse_floor" = auto_import_purse_floor,
	))

/datum/controller/subsystem/treasury/proc/import_steward_policy(blob)
	if(!istext(blob) || length(blob) > STEWARD_POLICY_IMPORT_MAX_LEN)
		return null
	var/list/data = safe_json_decode(blob)
	if(!islist(data) || !isnum(data["version"]) || data["version"] > STEWARD_POLICY_EXPORT_VERSION)
		return null
	for(var/field in list("autoexport_barred", "auto_import_standing", "auto_import_off"))
		var/list/entries = data[field]
		if(!isnull(entries) && (!islist(entries) || length(entries) > length(stockpile_datums)))
			return null
	var/list/tally = list("applied" = 0, "skipped" = 0)
	for(var/datum/roguestock/D in import_policy_goods(data["autoexport_barred"], tally))
		D.autoexport_disabled = TRUE
		tally["applied"]++
	for(var/datum/roguestock/D in import_policy_goods(data["auto_import_standing"], tally))
		set_auto_import(D.trade_good_id, TRUE)
		tally["applied"]++
	for(var/datum/roguestock/D in import_policy_goods(data["auto_import_off"], tally))
		set_auto_import(D.trade_good_id, FALSE)
		tally["applied"]++
	var/pct = data["autoexport_percentage"]
	if(isnum(pct))
		autoexport_percentage = clamp(round(pct), 0, 100) * 0.01
		tally["applied"]++
	var/purse_floor = data["auto_import_purse_floor"]
	if(isnum(purse_floor))
		set_auto_import_purse_floor(purse_floor)
		tally["applied"]++
	dirty_market_view()
	return tally

/datum/controller/subsystem/treasury/proc/import_policy_goods(list/ids, list/tally)
	. = list()
	if(!islist(ids))
		return
	for(var/good_id in ids)
		var/datum/roguestock/D = istext(good_id) ? SSeconomy.find_stockpile_by_trade_good(good_id) : null
		if(!D)
			tally["skipped"]++
			continue
		. += D
