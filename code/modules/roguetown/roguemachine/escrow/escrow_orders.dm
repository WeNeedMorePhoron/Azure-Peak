// Order lifecycle: building a manifest cart, posting it as an escrow order, and the
// claim -> deliver -> complete -> collect flow, plus cancel/reject/release/settle/expiry.

/obj/structure/roguemachine/escrow/proc/manifest_change(mob/user, datum/R, delta)
	var/key = escrow_key(user)
	if(!key || !R)
		return
	if(!manifests[key])
		manifests[key] = list()
	var/list/cart = manifests[key]
	var/newval = (cart[R] || 0) + delta
	if(newval <= 0)
		cart -= R
	else
		cart[R] = min(newval, 50)

/obj/structure/roguemachine/escrow/proc/manifest_total(mob/user)
	var/total = 0
	var/key = escrow_key(user)
	var/list/cart = key ? manifests[key] : null
	if(!cart)
		return 0
	for(var/k in cart)
		total += recipe_price(k) * cart[k]
	return total

/obj/structure/roguemachine/escrow/proc/has_active_order(key)
	if(!key)
		return FALSE
	for(var/datum/escrow_order/O in orders)
		if(O.commissioner_name == key && (O.status == "open" || O.status == "claimed"))
			return TRUE
	return FALSE

/obj/structure/roguemachine/escrow/proc/manifest_item_count(key)
	var/total = 0
	if(!key)
		return 0
	var/list/cart = manifests[key]
	if(!cart)
		return 0
	for(var/k in cart)
		total += cart[k]
	return total

/obj/structure/roguemachine/escrow/proc/submit_manifest(mob/user, note = "")
	var/key = escrow_key(user)
	if(!key)
		return
	var/list/cart = manifests[key]
	if(!length(cart))
		return
	if(has_active_order(key))
		to_chat(user, span_warning("You already have an active commission here - finish or cancel it before posting another."))
		return
	if(manifest_item_count(key) > item_cap_per_order)
		to_chat(user, span_warning("This commission asks for more than [item_cap_per_order] item\s - trim the manifest or raise the cap."))
		return
	var/total = manifest_total(user)
	var/deposit = manifest_deposits[key] || 0
	if(deposit < total)
		to_chat(user, span_warning("Not enough deposited. Need [total]mm, have [deposit]mm."))
		return
	var/datum/escrow_order/O = new()
	O.commissioner_name = key
	O.commissioner_ref = WEAKREF(user)
	O.day_posted = GLOB.dayspassed
	if(note)
		O.commissioner_note = copytext(sanitize(note), 1, 200)
	for(var/k in cart)
		O.recipe_quantities[k] = cart[k]
	O.deposited = total
	orders += O
	budget += total
	manifest_deposits[key] = deposit - total
	manifests -= key
	playsound(loc, 'sound/misc/beep.ogg', 100, FALSE, -1)
	to_chat(user, span_notice("Your commission has been posted."))
	update_icon()

/obj/structure/roguemachine/escrow/proc/refund_deposit(mob/user)
	var/key = escrow_key(user)
	if(!key)
		return
	var/deposit = manifest_deposits[key] || 0
	if(deposit <= 0)
		return
	manifest_deposits[key] = 0
	budget2change(deposit, user)
	playsound(loc, 'sound/misc/coindispense.ogg', 100, FALSE, -1)

/obj/structure/roguemachine/escrow/proc/cancel_order(datum/escrow_order/O, mob/user)
	if(!O || O.status != "open" || escrow_key(user) != O.commissioner_name)
		return
	orders -= O
	var/payout = O.deposited
	O.deposited = 0
	budget -= payout
	budget2change(payout, user)
	playsound(loc, 'sound/misc/coindispense.ogg', 100, FALSE, -1)
	update_icon()

/obj/structure/roguemachine/escrow/proc/claim_order(datum/escrow_order/O, mob/user)
	if(!O || O.status != "open")
		return
	if(!is_guild_member(user))
		to_chat(user, span_warning("Only a member of the crafter's guild may claim a commission."))
		return
	O.status = "claimed"
	O.smith_name = escrow_key(user)
	O.day_claimed = GLOB.dayspassed
	to_chat(user, span_notice("You claim [O.commissioner_name]'s commission."))
	notify_commissioner(O, "[user.real_name] has claimed your commission at [src].")

/obj/structure/roguemachine/escrow/proc/release_order(datum/escrow_order/O, mob/user, forced = FALSE)
	if(!O || O.status != "claimed")
		return
	if(!forced && escrow_key(user) != O.smith_name)
		return
	var/turf/T = get_turf(src)
	for(var/obj/item/I in O.delivered_items)
		I.forceMove(T)
	O.delivered_items.Cut()
	O.delivered_counts.Cut()
	O.delivered_volume.Cut()
	O.status = "open"
	O.smith_name = null
	O.day_claimed = 0
	if(forced)
		notify_commissioner(O, "The guildmaster has released the stalled claim on your commission at [src].")

/obj/structure/roguemachine/escrow/proc/settle_partial_order(datum/escrow_order/O, mob/user)
	if(!O || O.status != "claimed" || escrow_key(user) != O.smith_name)
		return
	var/list/needed = O.required_result_counts()
	var/done_count = 0
	var/needed_count = 0
	for(var/path in needed)
		var/want = needed[path]
		var/have = O.delivered_counts[path] || 0
		done_count += min(have, want)
		needed_count += want
	var/list/needed_vol = O.required_reagent_volumes()
	for(var/rtype in needed_vol)
		var/want = needed_vol[rtype]
		var/have = O.delivered_volume[rtype] || 0
		done_count += min(have, want)
		needed_count += want
	if(done_count <= 0)
		to_chat(user, span_warning("Nothing has been delivered yet. Release the claim instead."))
		return
	if(done_count >= needed_count)
		complete_order(O, user)
		return
	var/progress_ratio = done_count / needed_count
	var/smith_payout = round(O.deposited * progress_ratio * (100 - ESCROW_PARTIAL_HAIRCUT_PERCENT) / 100)
	var/commissioner_refund = O.deposited - smith_payout
	var/turf/T = get_turf(src)
	for(var/obj/item/I in O.delivered_items)
		I.forceMove(T)
	O.delivered_items.Cut()
	O.delivered_volume.Cut()
	orders -= O
	budget -= O.deposited
	O.deposited = 0
	if(smith_payout > 0)
		budget2change(smith_payout, user)
	if(commissioner_refund > 0 && O.commissioner_name)
		manifest_deposits[O.commissioner_name] = (manifest_deposits[O.commissioner_name] || 0) + commissioner_refund
	playsound(loc, 'sound/misc/coindispense.ogg', 100, FALSE, -1)
	to_chat(user, span_notice("Settled partial commission: you collect [smith_payout]m. [commissioner_refund]m has been returned to [O.commissioner_name]'s deposit."))
	notify_commissioner(O, "Your commission at [src] was partially fulfilled ([done_count]/[needed_count]). Items have been left at the docks; [commissioner_refund]m has been returned to your deposit.")
	update_icon()

/obj/structure/roguemachine/escrow/proc/complete_order(datum/escrow_order/O, mob/user)
	if(!O || O.status != "claimed" || escrow_key(user) != O.smith_name)
		return
	if(!O.is_fulfilled())
		to_chat(user, span_warning("The order is not yet complete."))
		return
	O.status = "complete"
	var/payout = O.deposited
	O.deposited = 0
	budget -= payout
	budget2change(payout, user)
	playsound(loc, 'sound/misc/coindispense.ogg', 100, FALSE, -1)
	notify_commissioner(O, "Your commission at [src] is ready for collection: [O.label()].")
	update_icon()

/obj/structure/roguemachine/escrow/proc/collect_order(datum/escrow_order/O, mob/user)
	if(!O || O.status != "complete" || escrow_key(user) != O.commissioner_name)
		return
	var/turf/T = get_turf(src)
	for(var/obj/item/I in O.delivered_items)
		I.forceMove(T)
	O.delivered_items.Cut()
	orders -= O
	update_icon()

/obj/structure/roguemachine/escrow/proc/reject_order(datum/escrow_order/O, mob/user, reason = "")
	if(!O || O.status == "complete")
		return
	var/key = escrow_key(user)
	if(O.status == "claimed" && key != O.smith_name && !is_guild_member(user))
		return
	if(O.status == "open" && !is_guild_member(user))
		return
	orders -= O
	var/payout = O.deposited
	O.deposited = 0
	budget -= payout
	var/turf/T = get_turf(src)
	for(var/obj/item/I in O.delivered_items)
		I.forceMove(T)
	O.delivered_items.Cut()
	if(payout > 0 && O.commissioner_name)
		manifest_deposits[O.commissioner_name] = (manifest_deposits[O.commissioner_name] || 0) + payout
	playsound(loc, 'sound/misc/beep.ogg', 100, FALSE, -1)
	var/clean_reason = reason ? copytext(sanitize(reason), 1, 200) : ""
	var/say_msg = "[user.real_name] rejects [O.commissioner_name]'s commission ([O.label()])"
	if(clean_reason)
		say_msg += ": \"[clean_reason]\""
	say_msg += "."
	say(say_msg)
	var/notify_msg = "[user.real_name] has rejected your commission at [src]. [payout]m has been returned to your deposit."
	if(clean_reason)
		notify_msg += " Reason: \"[clean_reason]\""
	notify_commissioner(O, notify_msg)
	update_icon()

/obj/structure/roguemachine/escrow/proc/prune_expired_orders()
	var/turf/T = get_turf(src)
	for(var/datum/escrow_order/O in orders.Copy())
		if(O.status == "open" && GLOB.dayspassed - O.day_posted >= ESCROW_OPEN_EXPIRY_DAYS)
			orders -= O
			budget -= O.deposited
			if(O.deposited > 0 && O.commissioner_name)
				manifest_deposits[O.commissioner_name] = (manifest_deposits[O.commissioner_name] || 0) + O.deposited
			notify_commissioner(O, "Your unclaimed commission at [src] has expired. [O.deposited]m has been returned to your deposit.")
			O.deposited = 0
		else if(O.status == "claimed" && O.day_claimed && GLOB.dayspassed - O.day_claimed >= ESCROW_CLAIM_EXPIRY_DAYS)
			for(var/obj/item/I in O.delivered_items)
				I.forceMove(T)
			O.delivered_items.Cut()
			O.delivered_counts.Cut()
			O.delivered_volume.Cut()
			O.status = "open"
			O.smith_name = null
			O.day_claimed = 0
			notify_commissioner(O, "The claim on your commission at [src] has expired; the order is open again for new smiths.")

/obj/structure/roguemachine/escrow/proc/notify_commissioner(datum/escrow_order/O, message)
	if(!O || !O.commissioner_ref)
		return
	var/mob/M = O.commissioner_ref.resolve()
	if(!M)
		return
	to_chat(M, span_notice("<b>[message]</b>"))
