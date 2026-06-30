//LESS COPYPASTE -> RANDOM NPC VOICELINE COLORS//

/mob/living/carbon/human/proc/random_voice_NPC()
	//Random voices, this can probably be more random-ish but it'll do for now
	var/voice_choice = rand(1, 30)
	switch(voice_choice)
		if(1)
			src.voice_color = "0bb1e4"
		if(2)
			src.voice_color = "d30c0c"
		if(3)
			src.voice_color = "4d4afc"
		if(4)
			src.voice_color = "da40c0"
		if(5)
			src.voice_color = "51e251"
		if(6)
			src.voice_color = "a059cf"
		if(7)
			src.voice_color = "8700c5"
		if(8)
			src.voice_color = "cfc886"
		if(9)
			src.voice_color = "ff9100"
		if(10)
			src.voice_color = "a0a0a0"
		if(11)
			src.voice_color = "797979"
		if(12)
			src.voice_color = "ff5e00"
		if(13)
			src.voice_color = "cf855a"
		if(14)
			src.voice_color = "50b854"
		if(15)
			src.voice_color = "575ec5"
		if(16)
			src.voice_color = "9b51ad"
		if(17)
			src.voice_color = "ad4b79"
		if(18)
			src.voice_color = "a5ac46"
		if(19)
			src.voice_color = "aaaaaa"
		if(20)
			src.voice_color = "727272"
		if(21)
			src.voice_color = "c98f8f"
		if(22)
			src.voice_color = "fff9a4"
		if(23)
			src.voice_color = "c389d1"
		if(24)
			src.voice_color = "6b88da"
		if(25)
			src.voice_color = "ffffff"
		if(26)
			src.voice_color = "7bbb40"
		if(27)
			src.voice_color = "ff7627"
		if(28)
			src.voice_color = "c7c7c7"
		if(29)
			src.voice_color = "6e77aa"
		if(30)
			src.voice_color = "b3ae72"

//BEARDED HAIR VERSION//

/mob/living/carbon/human/proc/random_hair_NPC()
	var/hairf = pick(list(
						/datum/sprite_accessory/hair/head/lowbraid,
						/datum/sprite_accessory/hair/head/countryponytailalt,
						/datum/sprite_accessory/hair/head/gloomy,
						/datum/sprite_accessory/hair/head/zone,
						/datum/sprite_accessory/hair/head/hime,
						/datum/sprite_accessory/hair/head/stacy,
						/datum/sprite_accessory/hair/head/sabitsuki,
						/datum/sprite_accessory/hair/head/sabitsuki_ponytail, 
						/datum/sprite_accessory/hair/head/kusanagi_alt,
						/datum/sprite_accessory/hair/head/fluffy,
						/datum/sprite_accessory/hair/head/fluffylong))
	var/hairm = pick(list(
						/datum/sprite_accessory/hair/head/ponytailwitcher,
						/datum/sprite_accessory/hair/head/bowlcut, 
						/datum/sprite_accessory/hair/head/bowlcut2,
						/datum/sprite_accessory/hair/head/lowbraid,
						/datum/sprite_accessory/hair/head/emo,
						/datum/sprite_accessory/hair/head/sabitsuki,
						/datum/sprite_accessory/hair/head/sabitsuki_ponytail, 
						/datum/sprite_accessory/hair/head/rogue))
	var/beard = pick(list(/datum/sprite_accessory/hair/facial/stubble,
						/datum/sprite_accessory/hair/facial/manly,
						/datum/sprite_accessory/hair/facial/fiveoclockmoustache,
						/datum/sprite_accessory/hair/facial/sevenoclockm,
						/datum/sprite_accessory/hair/facial/chinlessbeard,
						/datum/sprite_accessory/hair/facial/fullbeard,
						/datum/sprite_accessory/hair/facial/chinstrap,
						/datum/sprite_accessory/hair/facial/longbeard))
	//Next up, we add hair
	var/datum/bodypart_feature/hair/head/new_hair = new()
	var/datum/bodypart_feature/hair/facial/new_facial = new()

	if(gender == FEMALE)
		new_hair.set_accessory_type(hairf, null, src)
	else
		new_hair.set_accessory_type(hairm, null, src)
		new_facial.set_accessory_type(beard, null, src)

	var/haircolor_choice = rand(1, 6)
	switch(haircolor_choice)
		if(1) //Blond-Brown
			new_hair.accessory_colors = "#C1A287"
			new_hair.hair_color = "#C1A287"
			new_facial.accessory_colors = "#C1A287"
			new_facial.hair_color = "#C1A287"
			hair_color = "#C1A287"
		if(2) //Ginger-ish
			new_hair.accessory_colors = "#A56B3D"
			new_hair.hair_color = "#A56B3D"
			new_facial.accessory_colors = "#A56B3D"
			new_facial.hair_color = "#A56B3D"
			hair_color = "#A56B3D"
		if(3) //Black
			new_hair.accessory_colors = "#0d0c2e"
			new_hair.hair_color = "#0d0c2e"
			new_facial.accessory_colors = "#0d0c2e"
			new_facial.hair_color = "#0d0c2e"
			hair_color = "#0d0c2e"
		if(4) //Red
			new_hair.accessory_colors = "#a53d3d"
			new_hair.hair_color = "#a53d3d"
			new_facial.accessory_colors = "#a53d3d"
			new_facial.hair_color = "#a53d3d"
			hair_color = "#a53d3d"
		if(5) //Olive
			new_hair.accessory_colors = "#767c3f"
			new_hair.hair_color = "#767c3f"
			new_facial.accessory_colors = "#767c3f"
			new_facial.hair_color = "#767c3f"
			hair_color = "#767c3f"
		if(6) //Dark Brown
			new_hair.accessory_colors = "#503516"
			new_hair.hair_color = "#503516"
			new_facial.accessory_colors = "#503516"
			new_facial.hair_color = "#503516"
			hair_color = "#503516"
		if(7) //Dull Blond
			new_hair.accessory_colors = "#bdbb6b"
			new_hair.hair_color = "#bdbb6b"
			new_facial.accessory_colors = "#bdbb6b"
			new_facial.hair_color = "#bdbb6b"
			hair_color = "#bdbb6b"
		if(8) //Dull Brown
			new_hair.accessory_colors = "#7e6d53"
			new_hair.hair_color = "#7e6d53"
			new_facial.accessory_colors = "#7e6d53"
			new_facial.hair_color = "#7e6d53"
			hair_color = "#7e6d53"

//BEARDLESS VERSION//

/mob/living/carbon/human/proc/random_hair_no_beard_NPC()
	var/obj/item/bodypart/head/head = get_bodypart(BODY_ZONE_HEAD)
	var/hairf = pick(list(
						/datum/sprite_accessory/hair/head/lowbraid,
						/datum/sprite_accessory/hair/head/countryponytailalt,
						/datum/sprite_accessory/hair/head/gloomy,
						/datum/sprite_accessory/hair/head/zone,
						/datum/sprite_accessory/hair/head/hime,
						/datum/sprite_accessory/hair/head/stacy,
						/datum/sprite_accessory/hair/head/sabitsuki,
						/datum/sprite_accessory/hair/head/sabitsuki_ponytail, 
						/datum/sprite_accessory/hair/head/kusanagi_alt,
						/datum/sprite_accessory/hair/head/fluffy,
						/datum/sprite_accessory/hair/head/fluffylong))
	var/hairm = pick(list(
						/datum/sprite_accessory/hair/head/ponytailwitcher,
						/datum/sprite_accessory/hair/head/bowlcut, 
						/datum/sprite_accessory/hair/head/bowlcut2,
						/datum/sprite_accessory/hair/head/lowbraid,
						/datum/sprite_accessory/hair/head/emo,
						/datum/sprite_accessory/hair/head/sabitsuki,
						/datum/sprite_accessory/hair/head/sabitsuki_ponytail, 
						/datum/sprite_accessory/hair/head/rogue))
	//Next up, we add hair
	var/datum/bodypart_feature/hair/head/new_hair = new()
	var/datum/bodypart_feature/hair/facial/new_facial = new()

	if(gender == FEMALE)
		new_hair.set_accessory_type(hairf, null, src)
	else
		new_hair.set_accessory_type(hairm, null, src)

	var/haircolor_choice = rand(1, 6)
	switch(haircolor_choice)
		if(1) //Blond-Brown
			new_hair.accessory_colors = "#C1A287"
			new_hair.hair_color = "#C1A287"
			new_facial.accessory_colors = "#C1A287"
			new_facial.hair_color = "#C1A287"
			hair_color = "#C1A287"
		if(2) //Ginger-ish
			new_hair.accessory_colors = "#A56B3D"
			new_hair.hair_color = "#A56B3D"
			new_facial.accessory_colors = "#A56B3D"
			new_facial.hair_color = "#A56B3D"
			hair_color = "#A56B3D"
		if(3) //Black
			new_hair.accessory_colors = "#0d0c2e"
			new_hair.hair_color = "#0d0c2e"
			new_facial.accessory_colors = "#0d0c2e"
			new_facial.hair_color = "#0d0c2e"
			hair_color = "#0d0c2e"
		if(4) //Red
			new_hair.accessory_colors = "#a53d3d"
			new_hair.hair_color = "#a53d3d"
			new_facial.accessory_colors = "#a53d3d"
			new_facial.hair_color = "#a53d3d"
			hair_color = "#a53d3d"
		if(5) //Olive
			new_hair.accessory_colors = "#767c3f"
			new_hair.hair_color = "#767c3f"
			new_facial.accessory_colors = "#767c3f"
			new_facial.hair_color = "#767c3f"
			hair_color = "#767c3f"
		if(6) //Dark Brown
			new_hair.accessory_colors = "#503516"
			new_hair.hair_color = "#503516"
			new_facial.accessory_colors = "#503516"
			new_facial.hair_color = "#503516"
			hair_color = "#503516"
		if(7) //Dull Blond
			new_hair.accessory_colors = "#bdbb6b"
			new_hair.hair_color = "#bdbb6b"
			new_facial.accessory_colors = "#bdbb6b"
			new_facial.hair_color = "#bdbb6b"
			hair_color = "#bdbb6b"
		if(8) //Dull Brown
			new_hair.accessory_colors = "#7e6d53"
			new_hair.hair_color = "#7e6d53"
			new_facial.accessory_colors = "#7e6d53"
			new_facial.hair_color = "#7e6d53"
			hair_color = "#7e6d53"
	//Add our hair bodypart features
	head.add_bodypart_feature(new_hair)
	head.add_bodypart_feature(new_facial)

	dna.update_ui_block(DNA_HAIR_COLOR_BLOCK)
