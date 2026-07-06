/datum/action/cooldown/spell/graggar
	background_icon = 'icons/mob/actions/graggarmiracles.dmi'
	button_icon = 'icons/mob/actions/graggarmiracles.dmi'
	spell_color = GLOW_COLOR_GRAGGAR

	ignore_armor_penalty = TRUE

	attunement_school = null

	primary_resource_type = SPELL_COST_DEVOTION

	secondary_resource_type = SPELL_COST_STAMINA

	has_visual_effects = FALSE
	spell_impact_intensity = SPELL_IMPACT_NONE
	associated_stat = null
	associated_skill = /datum/skill/magic/holy
	spell_tier = 0

	point_cost = 0

	required_items = list(/obj/item/clothing/neck/roguetown/psicross)

/////////////////////
// T0 - Blood Rush //
/////////////////////

/datum/action/cooldown/spell/graggar/strenght
	name = "Vicious Strenght"
	desc = "PLACEHOLDER"
	button_icon_state = "breakchains"
	sound = 'sound/magic/graggar_bloodrush.ogg'

	click_to_activate = FALSE
	cast_range = SPELL_RANGE_ADJACENT
	self_cast_possible = TRUE

	primary_resource_cost = SPELLCOST_MIRACLE + 10

	secondary_resource_cost = SPELLCOST_CANTRIP

	invocation_type = INVOCATION_SHOUT
	invocations = list("Slaughter resumed!")

	charge_required = FALSE
	cooldown_time = 2 MINUTES

	spell_requirements =  SPELL_REQUIRES_HUMAN | SPELL_REQUIRES_SAME_Z

/datum/action/cooldown/spell/graggar/strenght/cast(atom/cast_on)
	. = ..()
	var/mob/living/carbon/human/user = owner
	if(!isliving(user))
		return FALSE
	var/skill = user.get_skill_level(/datum/skill/magic/holy)
	user.apply_status_effect(/datum/status_effect/buff/adrenaline_rush/graggar)
	if(skill >= 3)
		if(user.handcuffed || user.legcuffed)
			user.visible_message(span_danger("[user]'s restraints loosen under inhumen pressure!"))
			user.uncuff()
	if(skill >= 5)
		user.apply_status_effect(/datum/status_effect/buff/unholy_rage)
	return TRUE

/datum/status_effect/buff/unholy_rage
	id = "unholy_rage"
	alert_type = /atom/movable/screen/alert/status_effect/buff/unholy_rage
	duration = 30 SECONDS

/atom/movable/screen/alert/status_effect/buff/unholy_rage
	name = "Boiling Blood"
	desc = "My blood is boiling with rage!"
	icon_state = "buff"

/datum/status_effect/buff/unholy_rage/on_apply()
	. = ..()
	ADD_TRAIT(owner, TRAIT_GRABIMMUNE, TRAIT_MIRACLE)
	ADD_TRAIT(owner, TRAIT_NOPAIN, TRAIT_MIRACLE)

/datum/status_effect/buff/unholy_rage/on_remove()
	REMOVE_TRAIT(owner, TRAIT_GRABIMMUNE, TRAIT_MIRACLE)
	REMOVE_TRAIT(owner, TRAIT_NOPAIN, TRAIT_MIRACLE)
	. = ..()

///////////////////////////////////////////////////////////////////////////////////////////
// T1 - Hamstring - This will get reworked alongside Ravox later so more so temporary T1 //
///////////////////////////////////////////////////////////////////////////////////////////

/datum/action/cooldown/spell/graggar/hamstring
	name = "Hamstring"
	desc = "Curse your next strike to slow the target."
	button_icon_state = "hamstring"
	sound = 'sound/magic/break_chains.ogg'
	glow_intensity = GLOW_INTENSITY_LOW

	click_to_activate = FALSE
	cast_range = SPELL_RANGE_ADJACENT
	self_cast_possible = TRUE

	primary_resource_cost = SPELLCOST_MIRACLE

	secondary_resource_cost = SPELLCOST_CANTRIP

	invocation_type = INVOCATION_SHOUT
	invocations = list("Heel, mutt!")

	charge_required = FALSE
	cooldown_time = 1 MINUTES

	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC | SPELL_REQUIRES_HUMAN | SPELL_REQUIRES_SAME_Z

/datum/action/cooldown/spell/graggar/hamstring/cast(atom/cast_on)
	. = ..()
	var/mob/living/carbon/human/user = owner
	if(!isliving(user))
		return FALSE
	user.apply_status_effect(/datum/status_effect/hamstring, user.get_active_held_item())
	return TRUE

/atom/movable/screen/alert/status_effect/buff/hamstring
	name = "Hamstring"
	desc = "Your next attack slows your target and SPD."
	icon_state = "hamstring"

/datum/status_effect/hamstring
	id = "hamstring"
	status_type = STATUS_EFFECT_UNIQUE
	duration = 15 SECONDS
	alert_type = /atom/movable/screen/alert/status_effect/buff/hamstring
	on_remove_on_mob_delete = TRUE
	var/datum/weakref/buffed_item

/datum/status_effect/hamstring/on_creation(mob/living/new_owner, obj/item/I)
	. = ..()
	if(!.)
		return
	if(istype(I) && !(I.item_flags & ABSTRACT))
		buffed_item = WEAKREF(I)
		if(!I.light_outer_range && I.light_system == STATIC_LIGHT)
			I.set_light(1)
		RegisterSignal(I, COMSIG_ITEM_AFTERATTACK, PROC_REF(item_afterattack))
	else
		RegisterSignal(owner, COMSIG_MOB_ATTACK_HAND, PROC_REF(hand_attack))

/datum/status_effect/hamstring/on_remove()
	. = ..()
	UnregisterSignal(owner, COMSIG_MOB_ATTACK_HAND)
	if(buffed_item)
		var/obj/item/I = buffed_item.resolve()
		if(istype(I))
			I.set_light(0)
		UnregisterSignal(I, COMSIG_ITEM_AFTERATTACK)

/datum/status_effect/hamstring/proc/item_afterattack(obj/item/source, atom/target, mob/user, proximity_flag, click_parameters)
	if(!proximity_flag)
		return
	if(!isliving(target))
		return
	var/mob/living/living_target = target
	living_target.apply_status_effect(/datum/status_effect/debuff/hamstring)
	living_target.visible_message(span_warning("The strike from [user]'s weapon causes [living_target] to go stiff!"), vision_distance = COMBAT_MESSAGE_RANGE)
	qdel(src)

/datum/status_effect/hamstring/proc/hand_attack(datum/source, mob/living/carbon/human/M, mob/living/carbon/human/H, datum/martial_art/attacker_style)
	if(!istype(M))
		return
	if(!istype(H))
		return
	if(!istype(M.used_intent, INTENT_HARM))
		return
	H.apply_status_effect(/datum/status_effect/debuff/hamstring)
	H.visible_message(span_warning("The strike from [M]'s fist causes [H] to go stiff!"), vision_distance = COMBAT_MESSAGE_RANGE)
	qdel(src)

/atom/movable/screen/alert/status_effect/debuff/hamstring
	name = "Graggar's Burden"
	desc = "My arms and legs are restrained by unholy force!"
	icon_state = "restrained"

/datum/status_effect/debuff/hamstring
	id = "hamstring_debuff"
	alert_type = /atom/movable/screen/alert/status_effect/debuff/hamstring
	effectedstats = list(STATKEY_SPD = -2)
	duration = 30 SECONDS

/datum/status_effect/debuff/hamstring/on_apply()
		. = ..()
		var/mob/living/carbon/C = owner
		C.add_movespeed_modifier(MOVESPEED_ID_DAMAGE_SLOWDOWN, multiplicative_slowdown = 1.5)

/datum/status_effect/debuff/hamstring/on_remove()
	. = ..()
	if(iscarbon(owner))
		var/mob/living/carbon/C = owner
		C.remove_movespeed_modifier(MOVESPEED_ID_DAMAGE_SLOWDOWN)

///////////////////////////////
// T2 - Vicious Entanglement //
///////////////////////////////

/datum/action/cooldown/spell/projectile/graggar_net
	name = "Vicious Entanglement"
	desc = "Unleashes a snare of external blood and guts. The viscera winds around the legs of mortals... \
	Though has little effect on simple creatures. Mortals cannot remove the net, but it decays ten seconds after landing."
	background_icon = 'icons/mob/actions/graggarmiracles.dmi'
	button_icon = 'icons/mob/actions/graggarmiracles.dmi'
	sound = 'sound/magic/blood_net.ogg'
	button_icon_state = "graggarnet"
	spell_color = GLOW_COLOR_GRAGGAR
	glow_intensity = GLOW_INTENSITY_LOW

	projectile_type = /obj/projectile/magic/unholy_grasp
	cast_range = 7

	primary_resource_type = SPELL_COST_DEVOTION
	primary_resource_cost = SPELLCOST_MIRACLE

	secondary_resource_type = SPELL_COST_STAMINA
	primary_resource_cost = SPELLCOST_MINOR_PROJECTILE
	invocation_type = INVOCATION_SHOUT
	invocations = list("Be still!")

	charge_required = TRUE
	weapon_cast_penalized = FALSE
	charge_time = CHARGETIME_POKE
	charge_slowdown = CHARGING_SLOWDOWN_NONE
	charge_sound = 'sound/magic/chargingold.ogg'
	cooldown_time = 1 MINUTES

	associated_stat = null
	associated_skill = /datum/skill/magic/holy
	spell_requirements = SPELL_REQUIRES_HUMAN

	ignore_armor_penalty = TRUE
	attunement_school = null

	spell_tier = 0
	point_cost = 0

	required_items = list(/obj/item/clothing/neck/roguetown/psicross)

/datum/action/cooldown/spell/projectile/graggar_net/cast(atom/cast_on)
	var/mob/living/carbon/human/H = owner
	if(!ishuman(H))
		return
	. = ..()

// ---- Projectile ----

/obj/projectile/magic/unholy_grasp
	name = "visceral organ net"
	icon_state = "tentacle_end"
	nodamage = TRUE
	range = 7
	speed = 1.6
	hitsound = 'sound/magic/slimesquish.ogg'
	guard_deflectable = TRUE

/obj/projectile/magic/unholy_grasp/on_hit(target)
	. = ..()
	if(!iscarbon(target))
		return
	if(out_of_effective_range())
		return
	if(target)
		ensnare(target)

/obj/projectile/magic/unholy_grasp/proc/ensnare(mob/living/carbon/carbon)
	carbon.visible_message(span_warning("[src] ensnares [carbon] around their legs in a horrid cacophany of blood and guts!"), span_warning("I AM ENCAPTURED BY BLOOD AND GUTS! THERES A NET ON MY LEGS!"))
	carbon.apply_status_effect(/datum/status_effect/debuff/netted/vile)
	playsound(src, 'sound/combat/caught.ogg', 50, TRUE)

////////////////////////////
// T2 - Call to Slaughter //
////////////////////////////

/datum/action/cooldown/spell/graggar/graggar_battlecry
	name = "Call to Slaughter"
	desc = "Grants you and all allies nearby a buff to their strength, willpower, and constitution. Debuffs followers of the Ten, but not Psydonites."
	fluff_desc = "The battlefield quakes with your roar! Shaken to their core, they will prove easy pickings for a worthy champion such as yourself; the power of the Sinistar, unleashed.\
	SLAUGHTER THE LAMBS - DRINK THEIR MARROW - FEAST UPON THEIR FLESH - LEAVE NO TRACE OF THEIR PATHETIC EXISTENCE! - THE SINISTAR HUNGERS!"
	button_icon_state = "call_to_slaughter"
	sound = 'sound/magic/battle_cry_graggar.ogg'
	glow_intensity = 0

	click_to_activate = FALSE
	cast_range = SPELL_RANGE_AURA

	primary_resource_cost = SPELLCOST_MIRACLE_MAJOR

	secondary_resource_cost = SPELLCOST_UTILITY_BUFF

	invocations = list("Kneel before the might of the Sinistar!")
	invocation_type = INVOCATION_SHOUT

	charge_required = FALSE
	cooldown_time = 5 MINUTES

	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC | SPELL_REQUIRES_HUMAN | SPELL_REQUIRES_SAME_Z

/datum/action/cooldown/spell/graggar/graggar_battlecry/cast(atom/cast_on)
	. = ..()
	var/mob/living/carbon/human/H = owner
	if(!istype(H))
		return FALSE

	for(var/mob/living/carbon/target in view(cast_range, get_turf(owner)))
		if(istype(target.patron, /datum/patron/inhumen))
			target.apply_status_effect(/datum/status_effect/buff/call_to_slaughter)	//Buffs inhumens
			continue
		if(istype(target.patron, /datum/patron/old_god))
			to_chat(target, span_danger("You feel a surge of cold wash over you; leaving your body as quick as it hit.."))	//No effect on Psydonians!
			continue
		if(!owner.faction_check_mob(target))
			continue
		if(target.mob_biotypes & MOB_UNDEAD)
			continue
		target.apply_status_effect(/datum/status_effect/debuff/call_to_slaughter)	//Debuffs non-inhumens/psydonians
	return TRUE

/atom/movable/screen/alert/status_effect/buff/call_to_slaughter
	name = "Call to Slaughter"
	desc = span_bloody("LAMBS TO THE SLAUGHTER!")
	icon_state = "call_to_slaughter"

/datum/status_effect/buff/call_to_slaughter
	id = "call_to_slaughter"
	alert_type = /atom/movable/screen/alert/status_effect/buff/call_to_slaughter
	duration = 2.5 MINUTES
	effectedstats = list(STATKEY_STR = 1, STATKEY_WIL = 2, STATKEY_CON = 1)

/datum/status_effect/buff/call_to_slaughter/on_remove()
	. = ..()
	if(owner.cmode && !owner.has_status_effect(/datum/status_effect/buff/bloodrage))	//No cmode, no point - More Gigajank for combat music if we lack bloodrage but got the tune from it
		owner.toggle_cmode()
		owner.toggle_cmode()

/atom/movable/screen/alert/status_effect/debuff/call_to_slaughter
	name = "Call to Slaughter"
	desc = "Your blood runs cold, teeth clatter with fear - this is to be your end."
	icon_state = "call_to_slaughter_negative"

/datum/status_effect/debuff/call_to_slaughter
	id = "call_to_slaughter"
	alert_type = /atom/movable/screen/alert/status_effect/debuff/call_to_slaughter
	effectedstats = list(STATKEY_WIL = -2, STATKEY_CON = -2)
	duration = 2.5 MINUTES

//T3: Revel in Death - Increase bleeding and pain of a target.
/obj/effect/proc_holder/spell/invoked/revel_in_slaughter
	name = "Revel in Death"
	desc = "Increases the bleeding and pain of a target. Their blood-loss amount scales with every point of constitution over ten. \
	Those with ten or less constituion will instead have a flat rate (x1.25)."
	action_icon = 'icons/mob/actions/graggarmiracles.dmi'
	overlay_icon = 'icons/mob/actions/graggarmiracles.dmi'
	overlay_state = "bloodsteal"
	recharge_time = 1 MINUTES
	chargetime = 10
	chargedrain = 0
	chargedloop = /datum/looping_sound/invokeevil
	invocations = list("SINISTAR, MAKE THEM BLEED!")
	invocation_type = "shout"
	sound = 'sound/magic/bleed_out.ogg'
	releasedrain = 30
	miracle = TRUE
	devotion_cost = 70
	human_req = TRUE

/obj/effect/proc_holder/spell/invoked/revel_in_slaughter/cast(list/targets, mob/living/user = usr)
	var/mob/living/carbon/human/human = targets[1]

	if(!istype(human) || human == user)
		to_chat(user, span_danger("THAT WONT WORK!"))
		revert_cast()
		return FALSE

	if(spell_guard_check(human, TRUE))
		human.visible_message(span_warning("[human] resists the bloodlust!"))
		return TRUE
	
	human.apply_status_effect(/datum/status_effect/debuff/bloody_mess)
	human.apply_status_effect(/datum/status_effect/debuff/sensitive_nerves)

	return TRUE

//T0: Bloodrage  -- Uncapped STR buff.
/obj/effect/proc_holder/spell/self/graggar_bloodrage
	name = "Bloodrage"
	desc = "Tap into Graggar's wellspring of strength and knowledge, granting unbound power at the cost of temporary insanity and physical exhaustion." 		//reflavored into "graggar grants you some of the strength he got from stealing the souls of miscellaneous ravoxians"
	action_icon = 'icons/mob/actions/graggarmiracles.dmi'
	overlay_icon = 'icons/mob/actions/graggarmiracles.dmi'
	overlay_state = "bloodrage"
	recharge_time = 5 MINUTES
	invocations = list("SINISTAR, SHATTER MY BINDS!!", // VERY CLEAR that you are a heretic and VERY clear you've popped
						"GRAGGAR, GRAGGAR, GRAGGAR!!", // your anti-stun Im Going to Kill You Now spell
						"I EMBODY THE MOTIVE FORCE!!") // DO NOT add any ambiguious invocations
	invocation_type = "shout"
	sound = 'sound/magic/bloodrage.ogg'
	releasedrain = 10
	miracle = TRUE
	devotion_cost = 80
	antimagic_allowed = FALSE
	range = 0
	var/static/list/purged_effects = list(
	/datum/status_effect/incapacitating/immobilized,
	/datum/status_effect/incapacitating/paralyzed,
	/datum/status_effect/incapacitating/stun,
	/datum/status_effect/incapacitating/knockdown,)

/obj/effect/proc_holder/spell/self/graggar_bloodrage/cast(list/targets, mob/user)
	. = ..()
	if(!ishuman(user))
		revert_cast()
		return FALSE
	var/mob/living/carbon/human/H = user
	if(H.resting)
		H.set_resting(FALSE, FALSE)
	H.emote("warcry")
	for(var/effect in purged_effects)
		H.remove_status_effect(effect)
	H.apply_status_effect(/datum/status_effect/buff/bloodrage)
	H.visible_message(span_danger("[H] rises upward, boiling with immense rage!"))
	return TRUE
