#define AB_MAX_COLUMNS 12

/atom/movable/screen/movable/action_button
	var/datum/action/linked_action
	var/datum/hud/our_hud
	var/actiontooltipstyle = ""
	screen_loc = null
	nomouseover = FALSE

	/// The icon state of our active overlay, used to prevent re-applying identical overlays
	var/active_overlay_icon_state
	/// The icon state of our active underlay, used to prevent re-applying identical underlays
	var/active_underlay_icon_state

	var/mutable_appearance/button_overlay

	/// Where we are currently placed on the hud. SCRN_OBJ_DEFAULT asks the linked action what it thinks
	var/location = SCRN_OBJ_DEFAULT
	locked = TRUE
	/// A unique bitflag, combined with the name of our linked action this lets us persistently remember any user changes to our position
	var/id
	/// A weakref of the last thing we hovered over
	var/datum/weakref/last_hovored_ref

	/// AP: maptext holder for cooldown display on old proc_holder spells
	var/atom/movable/screen/maptext_holder/maptext_holder

	var/atom/movable/screen/hotkey_label_holder/hotkey_label_holder

/atom/movable/screen/movable/action_button/Destroy()
	if(our_hud)
		var/mob/viewer = our_hud.mymob
		viewer?.client?.screen -= src
		linked_action?.viewers -= our_hud
		viewer?.update_action_buttons()
		our_hud = null
	linked_action = null
	QDEL_NULL(maptext_holder)
	QDEL_NULL(hotkey_label_holder)
	return ..()

/atom/movable/screen/movable/action_button/proc/can_use(mob/user)
	if (linked_action)
		return linked_action.owner == user
	else if (isobserver(user))
		var/mob/dead/observer/O = user
		return !O.observetarget
	else
		return TRUE

/atom/movable/screen/movable/action_button/MouseDrop(over_object)
	if(!can_use(usr))
		return
	if(istype(over_object, /atom/movable/screen/movable/action_button))
		if(locked)
			to_chat(usr, span_warning("Action button \"[name]\" is locked, unlock it first."))
			return
		var/atom/movable/screen/movable/action_button/B = over_object
		if(B == src)
			return
		moved = FALSE
		B.moved = FALSE
		if(!usr.mind?.reorder_spell(src.linked_action, B.linked_action))
			var/list/actions = usr.actions
			actions -= src.linked_action
			var/target_idx = actions.Find(B.linked_action)
			if(!target_idx)
				return
			actions.Insert(target_idx, src.linked_action)
			usr.update_action_buttons()
	else
		return ..()

/atom/movable/screen/movable/action_button/Click(location,control,params)
	if (!can_use(usr))
		return

	var/list/modifiers = params2list(params)
	if(modifiers["alt"])
		if(locked)
			to_chat(usr, span_warning("Action button \"[name]\" is locked, unlock it first."))
			return TRUE
		moved = 0
		usr.update_action_buttons() //redraw buttons that are no longer considered "moved"
		return TRUE
	if(modifiers["ctrl"])
		locked = !locked
		to_chat(usr, span_notice("Action button \"[name]\" [locked ? "" : "un"]locked."))
		return TRUE
	if(modifiers["shift"])
		var/datum/action/spell_action/SA = linked_action
		if(istype(SA))
			SA.examine(usr)
		else
			var/datum/action/cooldown/spell/v2_spell = linked_action
			if(istype(v2_spell))
				v2_spell.examine(usr)
			else
				examine_ui(usr)
		return TRUE
	if(usr.next_click > world.time)
		return
	usr.next_click = world.time + 1
	if(ismob(usr))
		var/mob/M = usr
		M.playsound_local(M, 'sound/misc/click.ogg', 100)
	linked_action.Trigger()
	return TRUE

/atom/movable/screen/movable/action_button/MouseExited()
	..()

/datum/hud/proc/get_action_buttons_icons()
	. = list()
	.["bg_icon"] = ui_style
	.["bg_state"] = "template"

	//TODO : Make these fit theme
	.["toggle_icon"] = 'icons/mob/actions.dmi'
	.["toggle_hide"] = "hide"
	.["toggle_show"] = "show"

//see human and alien hud for specific implementations.

/// Updates all action button icons for this mob.
/mob/proc/update_mob_action_buttons(update_flags = ALL, force = FALSE)
	for(var/datum/action/current_action as anything in actions)
		current_action.build_all_button_icons(update_flags, force)

//This is the proc used to update all the action buttons.
/mob/proc/update_action_buttons(reload_screen)
	if(!hud_used || !client)
		return

	if(hud_used.hud_shown != HUD_STYLE_STANDARD)
		return

	var/button_number = 0

	if(hud_used.action_buttons_hidden)
		for(var/datum/action/A as anything in actions)
			A.build_all_button_icons()
			var/atom/movable/screen/movable/action_button/B = A.viewers[hud_used]
			if(!B)
				continue
			B.screen_loc = null
			B.set_hotkey_label(null)
			if(reload_screen)
				client.screen += B
	else
		for(var/datum/action/A as anything in actions)
			A.build_all_button_icons()
			var/atom/movable/screen/movable/action_button/B = A.viewers[hud_used]
			if(!B)
				continue
			if(B.moved)
				B.screen_loc = B.moved
				B.set_hotkey_label(null)
			else
				button_number++
				B.screen_loc = hud_used.ButtonNumberToScreenCoords(button_number)
				B.set_hotkey_label(button_number <= 9 ? button_number : null)
			if(reload_screen)
				client.screen += B

/datum/hud/proc/ButtonNumberToScreenCoords(number) // TODO : Make this zero-indexed for readabilty
	var/row = round((number - 1)/AB_MAX_COLUMNS)
	var/col = ((number - 1)%(AB_MAX_COLUMNS)) + 1

	var/coord_col = "+[col-1]"
	var/coord_col_offset = 4 + 2 * col

	var/coord_row = "[row ? "+[row]" : "+0"]"

	return "WEST[coord_col]:[coord_col_offset],SOUTH[coord_row]:3"

/atom/movable/screen/movable/action_button/proc/update_maptext(cd_time_deciseconds, color_cd = "#800000", color_neutral = "#ffffff")
	if(!istype(maptext_holder))
		maptext_holder = new /atom/movable/screen/maptext_holder/cooldown(src)
		vis_contents.Add(maptext_holder)

	maptext_holder.update_maptext(cd_time_deciseconds, color_cd, color_neutral)

/atom/movable/screen/movable/action_button/proc/set_hotkey_label(number)
	if(isnull(number))
		if(hotkey_label_holder)
			hotkey_label_holder.maptext = null
		return
	if(!istype(hotkey_label_holder))
		hotkey_label_holder = new(src)
		vis_contents.Add(hotkey_label_holder)
	hotkey_label_holder.maptext = MAPTEXT("<span style='color: #ffe14d; -dm-text-outline: 1 #000000; font-weight: bold;'>[number]</span>")

/atom/movable/screen/hotkey_label_holder
	layer = ABOVE_HUD_LAYER
	maptext_x = 1
	maptext_y = 20
	maptext_width = 12
	maptext_height = 11

/atom/movable/screen/maptext_holder
	layer = ABOVE_HUD_LAYER
	maptext_x = 8
	maptext_y = 4

/atom/movable/screen/maptext_holder/cooldown
	maptext_x = 0
	maptext_y = 0
	maptext_width = 32
	maptext_height = 32

/atom/movable/screen/maptext_holder/proc/update_maptext(cd_time_deciseconds, color_cd = "#800000", color_neutral = "#ffffff")
	if(cd_time_deciseconds <= 0)
		maptext = null
		color = color_neutral
		return
	var/seconds_left = round(cd_time_deciseconds / (1 SECONDS), 0.1)
	var/cd_text
	if(seconds_left >= 60)
		var/mins = round(seconds_left / 60)
		var/secs = round(seconds_left) % 60
		cd_text = "[mins]:[secs < 10 ? "0[secs]" : "[secs]"]"
	else
		cd_text = "[seconds_left]s"
	maptext = "<div align='center' valign='middle' class='maptext'>[cd_text]</div>"
	color = color_cd

#undef AB_MAX_COLUMNS
