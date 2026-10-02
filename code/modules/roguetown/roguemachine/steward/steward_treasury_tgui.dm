GLOBAL_LIST_INIT(steward_treasury_tabs, list())

GLOBAL_LIST_INIT(steward_treasury_actions, list(
	"treasury_tab_open",
	"treasury_tab_close",
))

/obj/structure/roguemachine/steward
	var/list/treasury_view = list()
	var/list/requested_tab = list()

/obj/structure/roguemachine/steward/proc/treasury_can_act(mob/user)
	if(!user || locked)
		return FALSE
	return user.canUseTopic(src, BE_CLOSE)

/obj/structure/roguemachine/steward/proc/treasury_can_view(mob/user)
	return user && !locked && in_range(src, user)

/obj/structure/roguemachine/steward/proc/open_steward_tgui(mob/user, tab)
	if(!treasury_can_act(user))
		return
	if(tab in GLOB.steward_treasury_tabs)
		requested_tab[user.ckey] = tab
	open_trade_tgui(user)

/obj/structure/roguemachine/steward/proc/append_treasury_data(list/data, mob/user)
	var/can_view = treasury_can_view(user)
	data["treasury_access"] = can_view ? TRUE : FALSE
	data["requested_tab"] = requested_tab[user.ckey]
	requested_tab -= user.ckey
	data["treasury_tab_data"] = can_view ? build_treasury_tab_data(user) : null

/obj/structure/roguemachine/steward/proc/build_treasury_tab_data(mob/user)
	var/tab = treasury_view[user.ckey]
	if(!(tab in GLOB.steward_treasury_tabs))
		return null
	return list("key" = tab)

/obj/structure/roguemachine/steward/proc/handle_treasury_act(action, list/params, mob/user)
	if(action == "treasury_tab_close")
		if(treasury_view[user.ckey] == params["tab"])
			treasury_view -= user.ckey
		return TRUE
	if(!treasury_can_act(user))
		return TRUE
	switch(action)
		if("treasury_tab_open")
			var/tab = params["tab"]
			if(tab in GLOB.steward_treasury_tabs)
				treasury_view[user.ckey] = tab
			return TRUE
	return TRUE

/obj/structure/roguemachine/steward/ui_close(mob/user)
	. = ..()
	treasury_view -= user.ckey
	requested_tab -= user.ckey
