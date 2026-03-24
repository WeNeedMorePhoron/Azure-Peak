/obj/item/rogueweapon/huntingknife/idagger/steel/astrata
	name = "dawnbringer"
	desc = "A blade forged in the name of Astrata herself. It glistens under the light reminding your foes what is coming."
	icon = 'icons/roguetown/weapons/templar_daggers32.dmi'
	icon_state = "astrata_dagger"
	force = 22
	max_integrity = 200

/obj/item/rogueweapon/huntingknife/idagger/steel/ravox
	name = "echo of triumph"
	desc = "Once, it was a greatsword wielded by the chosen of Ravox. After centuries of battles, the blade finally broke. However, the remaining pieces were reforged into a dagger that reminds battles of the past."
	icon = 'icons/roguetown/weapons/templar_daggers32.dmi'
	icon_state = "ravox_dagger"
	force = 22
	max_integrity = 200

/obj/item/rogueweapon/huntingknife/idagger/steel/malum
	name = "embertongue"
	desc = "Wavy flamelike blade forged in the name of Malum himself."
	icon = 'icons/roguetown/weapons/templar_daggers32.dmi'
	icon_state = "malum_dagger"
	force = 22
	max_integrity = 200

/obj/item/rogueweapon/huntingknife/idagger/steel/dendor
	name = "maddening thorn"
	desc = "Simple yet wickedly sharp blade fixed to the handle grown whole. The hilt is covered by tiny prickly thorns that slowly madden the wielder."
	icon = 'icons/roguetown/weapons/templar_daggers32.dmi'
	icon_state = "dendor_dagger"
	force = 22
	max_integrity = 200

/obj/item/rogueweapon/huntingknife/idagger/steel/abyssor
	name = "darkwater ripper"
	desc = "Fierce dagger quenched in the abyssal depths. If you listen closely, you can hear the clashing of waves during high tide."
	icon = 'icons/roguetown/weapons/templar_daggers32.dmi'
	icon_state = "abyssor_dagger"
	force = 22
	max_integrity = 200

/obj/item/rogueweapon/huntingknife/idagger/steel/necra_osteotome
	name = "osteotome"
	desc = "A macabre cleaver. The hilt is made from a human spine reinforced with a steel tang."
	icon = 'icons/roguetown/weapons/templar_daggers32.dmi'
	icon_state = "necra_dagger"
	possible_item_intents = list(/datum/intent/dagger/cut, /datum/intent/dagger/chop/necra)
	force = 22
	max_integrity = 200
	smeltresult = /obj/item/ingot/silver
	is_silver = TRUE

/obj/item/rogueweapon/huntingknife/idagger/steel/necra_osteotome/ComponentInitialize()
	AddComponent(\
		/datum/component/silverbless,\
		pre_blessed = BLESSING_NONE,\
		silver_type = SILVER_TENNITE,\
		added_force = 0,\
		added_blade_int = 50,\
		added_int = 50,\
		added_def = 2,\
	)

/obj/item/rogueweapon/huntingknife/throwingknife/steel/noc
	name = "twilight fang"
	desc = "Large tossblade meant for both fighting and throwing. Perfect for striking from the shadows of Noc."
	icon = 'icons/roguetown/weapons/templar_daggers32.dmi'
	icon_state = "noc_dagger"
	item_state = "bone_dagger"
	force = 22
	throwforce = 28
	throw_speed = 4
	max_integrity = 200
	armor_penetration = 40
	embedding = list("embedded_pain_multiplier" = 4, "embed_chance" = 30, "embedded_fall_chance" = 5)

/obj/item/rogueweapon/huntingknife/idagger/steel/parrying/eora
	name = "misericorde"
	desc = "A parrying dagger created to be used in the free hand and deliver mercy to the foes you've bested."
	icon = 'icons/roguetown/weapons/templar_daggers32.dmi'
	icon_state = "eora_dagger"
	sheathe_icon = "spdagger"
	force = 10
	throwforce = 10
	wdefense = 9
	max_integrity = 200

/obj/item/rogueweapon/huntingknife/idagger/steel/devilsknife
	name = "devilsknife"
	desc = "More a sickle than a knife. It is said that Xylix once won these in a game of chance against an archdevil. These are simple reproductions, with jingling bells attached to the blades."
	icon = 'icons/roguetown/weapons/templar_daggers32.dmi'
	icon_state = "devilsknife"
	force = 22
	max_integrity = 200
