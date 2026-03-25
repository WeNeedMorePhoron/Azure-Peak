/obj/item/rogueweapon/huntingknife/idagger/steel/astrata
	name = "dawnbringer"
	desc = "A blade forged in the name of the Sun Tyrant. Radiant, sharp, and imbued with a glimmering sheen.\
	For when Her order demands it."
	icon = 'icons/roguetown/weapons/templar_daggers32.dmi'
	icon_state = "astrata_dagger"
	force = 22
	max_integrity = 200

/obj/item/rogueweapon/huntingknife/idagger/steel/ravox
	name = "echo of triumph"
	desc = "It is said that when Ravox killed Graggar, thousands of swords were broken into pieces,\
	and the Warrior-God himself reforged them into smaller blades to be wielded by his most honorable followers.\
	This dagger is reforged in the same manner - reforged from the blade of a broken greatsword, and then tempered with holy steel\n\n\
	Broken, Reforged, Tempered."
	icon = 'icons/roguetown/weapons/templar_daggers32.dmi'
	icon_state = "ravox_dagger"
	force = 22
	max_integrity = 200

/obj/item/rogueweapon/huntingknife/idagger/steel/malum
	name = "embertongue"
	desc = "A wavy dagger forged with an unnatural curve. Such curve is hard to maintain and keep right on a dagger -\
	a true sign of the mastery of the smith. Surely, Malum looks favorably upon such a blade."
	icon = 'icons/roguetown/weapons/templar_daggers32.dmi'
	icon_state = "malum_dagger"
	force = 22
	max_integrity = 200

/obj/item/rogueweapon/huntingknife/idagger/steel/dendor
	name = "briarfang"
	desc = "A dagger formed out of a piece of heartwood extracted from a sylph, coupled with the remnants of a mad elemental.\
	Neither of these materials should make a sharp or proper blade, yet the handle is as strong as ebony, its edge sharp as obsidian\
	and its blade sturdy as steel. There might be a method to madness, after all."
	icon = 'icons/roguetown/weapons/templar_daggers32.dmi'
	icon_state = "dendor_dagger"
	force = 22
	max_integrity = 200

/obj/item/rogueweapon/huntingknife/idagger/steel/abyssor
	name = "riptide fang"
	desc = "A fierce, curved dagger quenched in the blood of an abyssal creechur, with its handles forged out of steel wrapped\
	around its bone. Sharp, and curved, able to butcher and flense with ease. A practical tool, and deadly weapon at once."
	icon = 'icons/roguetown/weapons/templar_daggers32.dmi'
	icon_state = "abyssor_dagger"
	force = 22
	max_integrity = 200

/obj/item/rogueweapon/huntingknife/idagger/steel/necra_osteotome
	name = "osteotome"
	desc = "A macabre cleaver. The hilt is made from a human spine reinforced with a steel tang.\
	A reminder of mortality."
	icon = 'icons/roguetown/weapons/templar_daggers32.dmi'
	icon_state = "necra_dagger"
	possible_item_intents = list(/datum/intent/dagger/cut, /datum/intent/dagger/chop/necra)
	force = 17
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
	desc = "A large tossblade with the profile of a rondel dagger. A rondel is not oft thrown, but this blade is unnaturally light when hurled, yet heavy and stiff when wielded.\
	Noc's faithful find it suits them well"
	icon = 'icons/roguetown/weapons/templar_daggers32.dmi'
	icon_state = "noc_dagger"
	item_state = "bone_dagger"
	force = 22
	throwforce = 28
	throw_speed = 4
	max_integrity = 200
	armor_penetration = PEN_MEDIUM
	embedding = list("embedded_pain_multiplier" = 4, "embed_chance" = 30, "embedded_fall_chance" = 5)

/obj/item/rogueweapon/huntingknife/idagger/steel/parrying/eora
	name = "misericorde"
	desc = "A parrying dagger created to be used in the free hand and deliver mercy to the foes you've bested.\
	Eora's love protects; her grace absolves."
	icon = 'icons/roguetown/weapons/templar_daggers32.dmi'
	icon_state = "eora_dagger"
	sheathe_icon = "spdagger"
	force = 10
	throwforce = 10
	wdefense = 9
	max_integrity = 200

/obj/item/rogueweapon/huntingknife/idagger/steel/devilsknife
	name = "devilsknife"
	desc = "More a sickle than a knife. It is said that Xylix once won these in a game of chance against an archdevil.\
	These are simple reproductions, with jingling bells attached to the blades."
	icon = 'icons/roguetown/weapons/templar_daggers32.dmi'
	icon_state = "devilsknife"
	force = 22
	max_integrity = 200
