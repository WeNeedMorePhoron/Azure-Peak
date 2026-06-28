/obj/item/rogueweapon/wand
	base_implement_name = "lesser wand"
	name = "lesser wand"
	desc = "A slender implement of carved wood tipped with a focus-gem. The gem captures excess energy dissipated into the air when a spell is cast, giving a fraction of it back to the wielder. It can project a temporary arcyne aegis into the wielder's offhand."
	icon = 'icons/obj/items/wands.dmi'
	icon_state = "wand_lesser"
	lefthand_file = 'icons/obj/items/wands.dmi'
	righthand_file = 'icons/obj/items/wands.dmi'
	force = 20
	throwforce = 10
	w_class = WEIGHT_CLASS_SMALL
	slot_flags = ITEM_SLOT_HIP | ITEM_SLOT_BACK_R
	sharpness = IS_BLUNT
	can_parry = FALSE
	wlength = WLENGTH_SHORT
	wdefense = 1
	max_integrity = 80
	resistance_flags = FIRE_PROOF
	associated_skill = /datum/skill/combat/staves
	possible_item_intents = list(/datum/intent/mace/strike/wood)
	sellprice = 34
	implement_tier = IMPLEMENT_TIER_LESSER
	implement_refund = IMPLEMENT_REFUND_LESSER
	var/aegis_energy_cost = 150
	var/aegis_cooldown = 180 SECONDS
	var/obj/item/rogueweapon/shield/arcyne_aegis/wand/conjured_aegis
	COOLDOWN_DECLARE(aegis_cd)

/obj/item/rogueweapon/wand/greater
	base_implement_name = "greater wand"
	name = "greater wand"
	desc = "A well-crafted wand set with a quality focus-gem. The gem captures excess energy dissipated into the air when a spell is cast, giving a generous share of it back to the wielder."
	icon_state = "wand_greater"
	force = 22
	max_integrity = 100
	sellprice = 42
	implement_tier = IMPLEMENT_TIER_GREATER
	implement_refund = IMPLEMENT_REFUND_GREATER

/obj/item/rogueweapon/wand/grand
	base_implement_name = "grand wand"
	name = "grand wand"
	desc = "A masterwork wand crowned with a gem of extraordinary quality. The gem captures excess energy dissipated into the air when a spell is cast, giving most of it back to the wielder - arcyne economy refined to an art."
	icon_state = "wand_grand"
	force = 25
	max_integrity = 120
	sellprice = 121
	implement_tier = IMPLEMENT_TIER_GRAND
	implement_refund = IMPLEMENT_REFUND_GRAND

/obj/item/rogueweapon/wand/attack_self(mob/living/carbon/human/user)
	if(!istype(user))
		return ..()
	conjure_aegis(user)

/obj/item/rogueweapon/wand/dropped(mob/user, silent)
	clear_aegis()
	return ..()

/obj/item/rogueweapon/wand/Destroy()
	clear_aegis()
	return ..()

/obj/item/rogueweapon/wand/proc/get_aegis_type()
	switch(implement_tier)
		if(IMPLEMENT_TIER_GREATER)
			return /obj/item/rogueweapon/shield/arcyne_aegis/wand/greater
		if(IMPLEMENT_TIER_GRAND)
			return /obj/item/rogueweapon/shield/arcyne_aegis/wand/grand
	return /obj/item/rogueweapon/shield/arcyne_aegis/wand

/obj/item/rogueweapon/wand/proc/conjure_aegis(mob/living/carbon/human/user)
	if(!user.is_holding(src))
		return FALSE
	if(user.get_inactive_held_item())
		to_chat(user, span_warning("I need my offhand free to project the Aegis!"))
		return FALSE
	if(!COOLDOWN_FINISHED(src, aegis_cd))
		to_chat(user, span_warning("The [src] is still gathering arcyne force. [round(COOLDOWN_TIMELEFT(src, aegis_cd) / 10, 1)] seconds remain."))
		return FALSE
	if(user.energy < aegis_energy_cost)
		to_chat(user, span_warning("I need [aegis_energy_cost] arcyne energy to project the Aegis!"))
		return FALSE
	clear_aegis()
	var/aegis_type = get_aegis_type()
	var/obj/item/rogueweapon/shield/arcyne_aegis/wand/S = new aegis_type(user.drop_location())
	S.link_wand(src, user)
	S.AddComponent(/datum/component/conjured_item, GLOW_COLOR_ARCANE, TRUE)
	if(!user.put_in_hands(S))
		qdel(S)
		to_chat(user, span_warning("I fail to conjure the Aegis in my offhand."))
		return FALSE
	conjured_aegis = S
	user.energy_add(-aegis_energy_cost)
	COOLDOWN_START(src, aegis_cd, aegis_cooldown)
	user.balloon_alert(user, "<font color = '#9BCCD0'>Aegis!</font>")
	user.visible_message(span_notice("[user] projects a shimmering arcyne shield from [src]!"))
	return TRUE

/obj/item/rogueweapon/wand/proc/clear_aegis()
	if(conjured_aegis && !QDELETED(conjured_aegis))
		conjured_aegis.dispel()
	conjured_aegis = null

/obj/item/rogueweapon/wand/getonmobprop(tag)
	. = ..()
	if(tag)
		switch(tag)
			if("gen")
				return list("shrink" = 0.4,"sx" = -10,"sy" = 0,"nx" = 11,"ny" = 0,"wx" = -4,"wy" = 0,"ex" = 2,"ey" = 0,"northabove" = 0,"southabove" = 1,"eastabove" = 1,"westabove" = 0,"nturn" = 0,"sturn" = 0,"wturn" = 0,"eturn" = 0,"nflip" = 0,"sflip" = 8,"wflip" = 8,"eflip" = 0)
			if("onbelt")
				return list("shrink" = 0.3,"sx" = -2,"sy" = -5,"nx" = 4,"ny" = -5,"wx" = 0,"wy" = -5,"ex" = 2,"ey" = -5,"nturn" = 0,"sturn" = 0,"wturn" = 0,"eturn" = 0,"nflip" = 0,"sflip" = 0,"wflip" = 0,"eflip" = 0,"northabove" = 0,"southabove" = 1,"eastabove" = 1,"westabove" = 0)

/obj/item/rogueweapon/wand/examine(mob/user)
	. = ..()
	if(implement_refund)
		. += span_notice("When held while casting, this implement leaves behind Residual Focus, returning [round(implement_refund * 100)]% of the spell's resource cost as energy over 20 seconds.")
	. += span_notice("Use it in hand to project an Arcane Aegis into your offhand, costing [aegis_energy_cost] energy.")
