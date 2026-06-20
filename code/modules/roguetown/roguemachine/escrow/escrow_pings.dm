// Periodic OOC nudge: while orders sit unclaimed, remind crafters who can claim here
// that work is waiting. Gated by ping_interval and toggleable from the panel.

/obj/structure/roguemachine/escrow/proc/count_open_orders()
	var/n = 0
	for(var/datum/escrow_order/O in orders)
		if(O.status == "open")
			n++
	return n

/// Gentle OOC reminder to crafters who can claim here that work is waiting.
/obj/structure/roguemachine/escrow/proc/ping_crafters(open_count)
	var/msg = "<font color='#002eb8'><b>COMMISSION NOTICE:</b> [open_count] unclaimed commission\s at the [name]. <i>(A guild member can mute these at the machine.)</i></font>"
	for(var/mob/living/carbon/human/H in GLOB.human_list)
		if(!H.client)
			continue
		if(!is_guild_member(H))
			continue
		to_chat(H, msg, type = MESSAGE_TYPE_OOC)

/obj/structure/roguemachine/escrow/process()
	if(obj_broken || !ping_enabled)
		return
	if(world.time < next_ping)
		return
	next_ping = world.time + ping_interval
	var/open_count = count_open_orders()
	if(open_count <= 0)
		return
	ping_crafters(open_count)
