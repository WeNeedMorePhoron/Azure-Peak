// GENERIC
/datum/intent/sword/bash
	name = "pommel bash"
	blade_class = BCLASS_BLUNT
	icon_state = "inbash"
	attack_verb = list("bashes", "strikes")
	penfactor = BLUNT_DEFAULT_PENFACTOR
	damfactor = NONBLUNT_BLUNT_DAMFACTOR
	item_d_type = "blunt"
	intent_intdamage_factor = BLUNT_DEFAULT_INT_DAMAGEFACTOR


// GREATSWORDS
/datum/intent/sword/cut/zwei
	damfactor = 1.2 // Higher damfactor to represent the power of two handed sword but lose range in comparison to polearms.

/datum/intent/sword/cut/zwei/cleave
	name = "cleaving cut"
	icon_state = "incleave"
	desc = "A cut that cleaves into a second target behind the first."
	attack_verb = list("cleaves", "carves through")
	clickcd = CLICK_CD_CHARGED
	swingdelay = 2
	damfactor = 1.0
	cleave = /datum/cleave_pattern/forward_cleave

/datum/intent/sword/cut/zwei/sweep
	name = "sweeping cut"
	icon_state = "insweep"
	desc = "A broad, brutal horizontal sweep that cuts across everything in front of you."
	attack_verb = list("sweeps through", "cuts across")
	reach = 1
	clickcd = CLICK_CD_HEAVY
	swingdelay = 4
	damfactor = 0.9
	cleave = /datum/cleave_pattern/horizontal_sweep

/datum/intent/sword/thrust/zwei
	reach = 2

// ESTOC

/datum/intent/sword/thrust/estoc
	name = "thrust"
	penfactor = 57	//At 57 pen + 25 base (82 total), you will always pen 80 stab armor, but you can't do it at range unlike a spear.
	swingdelay = 8

/datum/intent/sword/lunge
	name = "lunge"
	icon_state = "inimpale"
	attack_verb = list("lunges")
	animname = "stab"
	blade_class = BCLASS_STAB
	hitsound = list('sound/combat/hits/bladed/genstab (1).ogg', 'sound/combat/hits/bladed/genstab (2).ogg', 'sound/combat/hits/bladed/genstab (3).ogg')
	reach = 2
	damfactor = 1.3	//Zwei will still deal ~7-10 more damage at the same range, depending on user's STR.
	swingdelay = 8

