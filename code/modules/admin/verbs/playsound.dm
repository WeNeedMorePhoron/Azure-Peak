/client/proc/play_sound(S as sound)
	set category = "-Fun-"
	set name = "Sound - Global"
	if(!check_rights(R_SOUND))
		return

	var/freq = 1
	var/vol = input(usr, "What volume would you like the sound to play at?",, 100) as null|num
	if(!vol)
		return
	vol = CLAMP(vol, 1, 100)

	var/sound/admin_sound = new()
	admin_sound.file = S
	admin_sound.priority = 250
	admin_sound.channel = CHANNEL_ADMIN
	admin_sound.frequency = freq
	admin_sound.wait = 1
	admin_sound.repeat = 0
	admin_sound.status = SOUND_STREAM
	admin_sound.volume = vol

	var/res = alert(usr, "Show the title of this song to the players?",, "Yes","No", "Cancel")
	switch(res)
		if("Yes")
			to_chat(world, span_boldannounce("An admin played: [S]"))
		if("Cancel")
			return

	log_admin("[key_name(src)] played sound [S]")
	message_admins("[key_name_admin(src)] played sound [S]")

	for(var/mob/M in GLOB.player_list)
		if(M.client.prefs.toggles & SOUND_MIDI)
			var/user_vol = M.client.prefs.musicvol
			if(user_vol)
				admin_sound.volume = vol * (user_vol / 100)
			SEND_SOUND(M, admin_sound)

	SSblackbox.record_feedback("tally", "admin_verb", 1, "Play Global Sound") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/verb/change_music_vol()
	set category = "Options"
	set name = "ChangeMusicPower"

	if(prefs)
/*		if(blacklisted() == 1)
			var/vol = input(usr, "Current music power: [prefs.musicvol]",, 100) as null|num
			vol = 100
			prefs.musicvol = vol
			prefs.save_preferences()
			mob.update_music_volume(CHANNEL_MUSIC, prefs.musicvol)
			mob.update_music_volume(CHANNEL_LOBBYMUSIC, prefs.musicvol)
			mob.update_music_volume(CHANNEL_ADMIN, prefs.musicvol)
		else*/
		var/vol = input(usr, "Current music power: [prefs.musicvol]",, 100) as null|num
		if(!vol)
			if(vol != 0)
				return
		vol = min(vol, 100)
		prefs.musicvol = vol
		prefs.save_preferences()

		mob.update_music_volume(CHANNEL_MUSIC, prefs.musicvol)
		mob.update_music_volume(CHANNEL_LOBBYMUSIC, prefs.musicvol)
		mob.update_music_volume(CHANNEL_ADMIN, prefs.musicvol)


/client/verb/show_rolls()
	set category = "Options"
	set name = "ShowRolls"

	if(prefs)
		prefs.showrolls = !prefs.showrolls
		prefs.save_preferences()
		if(prefs.showrolls)
			to_chat(src, "ShowRolls Enabled")
		else
			to_chat(src, "ShowRolls Disabled")

/client/verb/change_master_vol()
	set category = "Options"
	set name = "ChangeVolPower"

	if(prefs)
		var/vol = input(usr, "Current volume power: [prefs.mastervol]",, 100) as null|num
		if(!vol)
			if(vol != 0)
				return
		vol = min(vol, 100)
		prefs.mastervol = vol
		prefs.save_preferences()

		mob.update_channel_volume(CHANNEL_AMBIENCE, prefs.mastervol)
/*
/client/verb/help_rpguide()
	set category = "Options"
	set name = "zHelp-RPGuide"

	src << link("https://cdn.discordapp.com/attachments/844865105040506891/938971395445112922/rpguide.jpg")

/client/verb/help_uihelp()
	set category = "Options"
	set name = "zHelp-UIGuide"

	src << link("https://cdn.discordapp.com/attachments/844865105040506891/938275090414579762/unknown.png")
*/

/client/proc/play_local_sound(S as sound)
	set category = "-Fun-"
	set name = "Sound - Local"
	if(!check_rights(R_SOUND))
		return

	log_admin("[key_name(src)] played a local sound [S]")
	message_admins("[key_name_admin(src)] played a local sound [S]")
	playsound(get_turf(src.mob), S, 50, FALSE, FALSE)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Play Local Sound") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/play_local_sound_variable(S as sound)
	set category = "-Fun-"
	set name = "Sound - Variable Dist"
	if(!check_rights(R_SOUND))
		return

	var/dist = input(usr, "How far do you want this sound to extend?",, 50) as null|num
	if(!dist)
		return
	dist = CLAMP(dist, 1, 100)

	log_admin("[key_name(src)] played a local sound [S]")
	message_admins("[key_name_admin(src)] played a local sound [S]")
	playsound(get_turf(src.mob), S, dist, FALSE, FALSE)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Play Local Sound") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/play_web_sound()
	set category = "-Fun-"
	set name = "Sound - Internet"
	if(!check_rights(R_SOUND))
		return

	var/ytdl = CONFIG_GET(string/invoke_youtubedl)
	if(!ytdl)
		to_chat(src, span_boldwarning("Youtube-dl was not configured, action unavailable")) //Check config.txt for the INVOKE_YOUTUBEDL value
		return

	var/web_sound_input = input("Enter content URL (supported sites only, leave blank to stop playing)", "Play Internet Sound via youtube-dl") as text|null
	if(istext(web_sound_input))
		var/web_sound_url = ""
		var/stop_web_sounds = FALSE
		var/list/music_extra_data = list()
		if(length(web_sound_input))

			web_sound_input = trim(web_sound_input)
			if(findtext(web_sound_input, ":") && !findtext(web_sound_input, GLOB.is_http_protocol))
				to_chat(src, span_boldwarning("Non-http(s) URIs are not allowed."))
				to_chat(src, span_warning("For youtube-dl shortcuts like ytsearch: please use the appropriate full url from the website."))
				return
			var/shell_scrubbed_input = shell_url_scrub(web_sound_input)
			var/list/output = world.shelleo("[ytdl] --geo-bypass --format \"bestaudio\[ext=mp3]/best\[ext=mp4]\[height<=360]/bestaudio\[ext=m4a]/bestaudio\[ext=aac]\" --dump-single-json --no-playlist -- \"[shell_scrubbed_input]\"")
			var/errorlevel = output[SHELLEO_ERRORLEVEL]
			var/stdout = output[SHELLEO_STDOUT]
			var/stderr = output[SHELLEO_STDERR]
			if(!errorlevel)
				var/list/data
				try
					data = json_decode(stdout)
				catch(var/exception/e)
					to_chat(src, span_boldwarning("Youtube-dl JSON parsing FAILED:"))
					to_chat(src, span_warning("[e]: [stdout]"))
					return

				if (data["url"])
					web_sound_url = data["url"]
					var/title = "[data["title"]]"
					var/webpage_url = title
					if (data["webpage_url"])
						webpage_url = "<a href=\"[data["webpage_url"]]\">[title]</a>"
					music_extra_data["start"] = data["start_time"]
					music_extra_data["end"] = data["end_time"]

					var/res = alert(usr, "Show the title of and link to this song to the players?\n[title]",, "No", "Yes", "Cancel")
					switch(res)
						if("Yes")
							to_chat(world, span_boldannounce("An admin played: [webpage_url]"))
						if("Cancel")
							return

					SSblackbox.record_feedback("nested tally", "played_url", 1, list("[ckey]", "[web_sound_input]"))
					log_admin("[key_name(src)] played web sound: [web_sound_input]")
					message_admins("[key_name(src)] played web sound: [web_sound_input]")
			else
				to_chat(src, span_boldwarning("Youtube-dl URL retrieval FAILED:"))
				to_chat(src, span_warning("[stderr]"))

		else //pressed ok with blank
			log_admin("[key_name(src)] stopped web sound")
			message_admins("[key_name(src)] stopped web sound")
			web_sound_url = null
			stop_web_sounds = TRUE

		if(web_sound_url && !findtext(web_sound_url, GLOB.is_http_protocol))
			to_chat(src, span_boldwarning("BLOCKED: Content URL not using http(s) protocol"))
			to_chat(src, span_warning("The media provider returned a content URL that isn't using the HTTP or HTTPS protocol"))
			return
		if(web_sound_url || stop_web_sounds)
			for(var/m in GLOB.player_list)
				var/mob/M = m
				var/client/C = M.client
				if(C.prefs.toggles & SOUND_MIDI)
					// Stops playing lobby music and admin loaded music automatically.
					SEND_SOUND(C, sound(null, channel = CHANNEL_LOBBYMUSIC))
					SEND_SOUND(C, sound(null, channel = CHANNEL_ADMIN))
					if(!stop_web_sounds)
						C.tgui_panel?.play_music(web_sound_url, music_extra_data)
					else
						C.tgui_panel?.stop_music()

	SSblackbox.record_feedback("tally", "admin_verb", 1, "Play Internet Sound")

/client/proc/set_round_end_sound(S as sound)
	set category = "-Fun-"
	set name = "Sound - Round End"
	if(!check_rights(R_SOUND))
		return

	SSticker.SetRoundEndSound(S)

	log_admin("[key_name(src)] set the round end sound to [S]")
	message_admins("[key_name_admin(src)] set the round end sound to [S]")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Set Round End Sound") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/stop_sounds()
	set category = "-Fun-"
	set name = "Sound - Stop All Playing"
	if(!src.holder)
		return

	log_admin("[key_name(src)] stopped all currently playing sounds.")
	message_admins("[key_name_admin(src)] stopped all currently playing sounds.")
	for(var/mob/M in GLOB.player_list)
		SEND_SOUND(M, sound(null))
		var/client/C = M.client
		C?.tgui_panel?.stop_music()
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Stop All Playing Sounds") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

GLOBAL_LIST_INIT(ambience_files, list(
	'sound/music/area/bath.ogg',
	'sound/music/area/bog.ogg',
	'sound/music/area/catacombs.ogg',
	'sound/music/area/caves.ogg',
	'sound/music/area/church.ogg',
	'sound/music/area/decap.ogg',
	'sound/music/area/dungeon.ogg',
	'sound/music/area/dwarf.ogg',
	'sound/music/area/field.ogg',
	'sound/music/area/forest.ogg',
	'sound/music/area/magiciantower.ogg',
	'sound/music/area/manorgarri.ogg',
	'sound/music/area/sargoth.ogg',
	'sound/music/area/septimus.ogg',
	'sound/music/area/sewers.ogg',
	'sound/music/area/shop.ogg',
	'sound/music/area/spidercave.ogg',
	'sound/music/area/towngen.ogg',
	'sound/music/area/townstreets.ogg'
	))

/client/verb/preload_sounds()
	set category = "Options"
	set name = "Preload Ambience"

	for(var/music in GLOB.ambience_files)
		mob.playsound_local(mob, music, 0.1)
		sleep(10)
