SUBSYSTEM_DEF(ping)
	name = "Ping"
	priority = FIRE_PRIORITY_PING
	wait = 3 SECONDS
	flags = SS_NO_INIT
	runlevels = RUNLEVEL_LOBBY | RUNLEVEL_SETUP | RUNLEVEL_GAME | RUNLEVEL_POSTGAME

	var/list/currentrun = list()

/datum/controller/subsystem/ping/stat_entry()
	..("P:[GLOB.clients.len]")


/datum/controller/subsystem/ping/fire(resumed = 0)
	if (!resumed)
		src.currentrun = GLOB.clients.Copy()

	//cache for sanic speed (lists are references anyways)
	var/list/currentrun = src.currentrun

	while (currentrun.len)
		var/client/client = currentrun[currentrun.len]
		currentrun.len--

		if (client?.tgui_panel?.is_ready())
			// Send a soft ping
			client.tgui_panel.window.send_message("ping/soft", list(
				// Slightly less than the subsystem timer (somewhat arbitrary)
				// to prevent incoming pings from resetting the afk state
				"afk" = client.is_afk(3.5 SECONDS),
			))

		if (MC_TICK_CHECK)
			return
