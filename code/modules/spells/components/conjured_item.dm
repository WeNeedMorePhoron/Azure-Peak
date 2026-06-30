/* Component for adding a generic magical outline to a component, make it disappear if not held / worn
by Arcyne user after a duration
*/

/datum/component/conjured_item
	var/outline_color = GLOW_COLOR_ARCANE
	var/noglow = FALSE
	var/dispel_time = 0
	var/dispel_timer

/datum/component/conjured_item/Initialize(outline_color_override, no_glow = FALSE, dispel_after = 0)
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE

	noglow = no_glow
	if(outline_color_override)
		outline_color = outline_color_override
	dispel_time = dispel_after

	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, PROC_REF(on_examine))

	var/obj/item/I = parent
	if(!noglow)
		I.filters += filter(type = "drop_shadow", x=0, y=0, size=1, offset = 2, color = outline_color)
	I.smeltresult = null
	I.salvage_result = null
	I.fiber_salvage = FALSE
	I.craft_blocked = TRUE
	I.sellprice = 0
	I.static_price = TRUE

	if(dispel_time)
		RegisterSignal(parent, COMSIG_ITEM_DROPPED, PROC_REF(on_moved))
		RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, PROC_REF(on_moved))
		refresh_dispel()

/datum/component/conjured_item/Destroy()
	deltimer(dispel_timer)
	dispel_timer = null
	return ..()

/datum/component/conjured_item/proc/on_examine(datum/source, mob/user, list/examine_list)
	examine_list += "This item crackles with faint arcyne energy. It seems to be conjured."
	if(dispel_time)
		examine_list += "Out of hand, it dissipates in about [dispel_time / 10] seconds."

/datum/component/conjured_item/proc/on_moved(datum/source, mob/user, slot)
	SIGNAL_HANDLER
	refresh_dispel()

/datum/component/conjured_item/proc/refresh_dispel()
	var/obj/item/I = parent
	if(QDELETED(I))
		return
	var/mob/holder = isliving(I.loc) ? I.loc : null
	if(holder?.is_holding(I))
		deltimer(dispel_timer)
		dispel_timer = null
	else if(!dispel_timer)
		dispel_timer = addtimer(CALLBACK(src, PROC_REF(dispel)), dispel_time, TIMER_STOPPABLE)

/datum/component/conjured_item/proc/dispel()
	dispel_timer = null
	var/obj/item/I = parent
	if(QDELETED(I))
		return
	I.visible_message(span_warning("[I] shimmers and fades away!"))
	I.balloon_alert_to_viewers("fades away")
	playsound(get_turf(I), 'sound/magic/magic_nulled.ogg', 80)
	qdel(I)
