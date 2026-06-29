/datum/intent/sword/cut/ferramancy/sabre
	name = "sabre slash"
	clickcd = 8
	damfactor = 1.1
	penfactor = PEN_LIGHT

/datum/intent/sword/cut/ferramancy/sabre/sweep
	name = "stygian sweep"
	icon_state = "insweep"
	attack_verb = list("sweeps through", "carves across")
	clickcd = CLICK_CD_HEAVY
	damfactor = 1.4
	swingdelay = 0.6 SECONDS
	swingdelay_type = SWINGDELAY_PENALTY
	cleave = /datum/cleave_pattern/horizontal_sweep

/datum/intent/sword/cut/ferramancy/greatsword
	name = "greatsword cut"
	clickcd = 12
	reach = 2
	damfactor = 1.05
	penfactor = PEN_LIGHT

/datum/intent/sword/cut/ferramancy/greatsword/sweep
	name = "rending arc"
	icon_state = "incleave"
	attack_verb = list("cleaves", "carves through")
	clickcd = CLICK_CD_MASSIVE
	reach = 1
	damfactor = 1.5
	swingdelay = 0.8 SECONDS
	swingdelay_type = SWINGDELAY_PENALTY
	cleave = /datum/cleave_pattern/frontal_arc

/datum/alt_grip/ferramancy
	two_handed = TRUE

/datum/alt_grip/ferramancy/is_two_handed(obj/item/source)
	if(istype(source, /obj/item/rogueweapon/spellbook))
		return FALSE
	return two_handed

/datum/alt_grip/ferramancy/sabre
	name = "sabre"
	grip_intents = list(
		/datum/intent/sword/cut/ferramancy/sabre,
		/datum/intent/sword/cut/ferramancy/sabre/sweep,
		SPEAR_BASH,
		MACE_SMASH_WOOD,
	)
	var_overrides = list(
		"force" = 14,
		"force_wielded" = 16,
		"sharpness" = IS_SHARP,
		"max_blade_int" = 200,
		"blade_int" = 200,
		"icon" = 'icons/roguetown/weapons/prismatic_weapons64.dmi',
		"icon_state" = "moonlight_saber",
		"item_state" = "moonlight_saber",
	)

/datum/alt_grip/ferramancy/greatsword
	name = "greatsword"
	grip_intents = list(
		/datum/intent/sword/cut/ferramancy/greatsword,
		/datum/intent/sword/cut/ferramancy/greatsword/sweep,
		SPEAR_BASH,
		MACE_SMASH_WOOD,
	)
	var_overrides = list(
		"force" = 20,
		"force_wielded" = 26,
		"sharpness" = IS_SHARP,
		"max_blade_int" = 200,
		"blade_int" = 200,
		"icon" = 'icons/roguetown/weapons/prismatic_weapons64.dmi',
		"icon_state" = "moonlight_hammer",
		"item_state" = "moonlight_hammer",
	)
