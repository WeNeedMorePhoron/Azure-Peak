/datum/action/cooldown/spell/ferramancy_form
	button_icon = 'icons/mob/actions/mage_ferramancy.dmi'
	spell_color = GLOW_COLOR_METAL
	glow_intensity = GLOW_INTENSITY_LOW
	attunement_school = ASPECT_NAME_FERRAMANCY
	sound = 'sound/combat/weaponr1.ogg'

	click_to_activate = FALSE
	self_cast_possible = TRUE

	primary_resource_type = SPELL_COST_STAMINA
	primary_resource_cost = SPELLCOST_FERRAMANCY_FORM

	invocations = list()
	invocation_type = INVOCATION_NONE

	charge_required = FALSE
	cooldown_time = 30 SECONDS
	shared_cooldown = "ferramancy_form"

	associated_skill = /datum/skill/magic/arcane
	spell_tier = 1
	spell_impact_intensity = SPELL_IMPACT_NONE
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC | SPELL_REQUIRES_HUMAN

	var/grip_type
	var/form_balloon = "form shifted!"

/datum/action/cooldown/spell/ferramancy_form/proc/get_implement(mob/living/carbon/human/H)
	if(!istype(H))
		return null
	for(var/obj/item/I in list(H.get_active_held_item(), H.get_inactive_held_item()))
		if(istype(I, /obj/item/rogueweapon/woodstaff) || istype(I, /obj/item/rogueweapon/spellbook))
			return I
	return null

/datum/action/cooldown/spell/ferramancy_form/can_cast_spell(feedback = TRUE)
	. = ..()
	if(!.)
		return FALSE
	if(!get_implement(owner))
		if(feedback)
			to_chat(owner, span_warning("I need a staff or tome in hand to shift its form."))
		return FALSE
	return TRUE

/datum/action/cooldown/spell/ferramancy_form/cast(atom/cast_on)
	. = ..()
	var/mob/living/carbon/human/H = owner
	var/obj/item/implement = get_implement(H)
	if(!implement)
		return FALSE
	if(istype(implement.current_alt_grip, grip_type))
		to_chat(H, span_warning("My implement already holds this form."))
		return FALSE
	if(!apply_form(H, implement))
		to_chat(H, span_warning("I need a free hand to shape it into this form."))
		return FALSE
	H.balloon_alert(H, form_balloon)
	return TRUE

/datum/action/cooldown/spell/ferramancy_form/proc/apply_form(mob/living/carbon/human/H, obj/item/I)
	var/datum/alt_grip/grip = new grip_type()
	var/two_h = grip.is_two_handed(I)
	if(two_h && !I.can_wield_two_handed(H))
		qdel(grip)
		return FALSE
	if(!two_h && I.wielded)
		I.clear_grip_state()
	else
		I.clear_altgrip_state()
	I.current_alt_grip = grip
	I.current_alt_grip_index = 0
	grip.apply_to(I)
	I.wielded = two_h
	I.altgripped = TRUE
	I.clear_altgrip_onmob()
	I.update_force_dynamic()
	I.update_wdefense_dynamic()
	I.update_transform()
	H.update_inv_hands()
	if(H.get_active_held_item() == I || H.get_inactive_held_item() == I)
		H.update_a_intents()
	return TRUE

/datum/action/cooldown/spell/ferramancy_form/sabre
	name = "Form: Sabre"
	desc = "Shape the implement into a sabre - a quick slashing blade. Its special is a heavy, delayed sweep that cleaves a line of foes."
	button_icon_state = "form_sabre"
	grip_type = /datum/alt_grip/ferramancy/sabre
	form_balloon = "sabre form!"

/datum/action/cooldown/spell/ferramancy_form/greatsword
	name = "Form: Greatsword"
	desc = "Shape the implement into a greatsword - a reaching cut, slightly weaker than a true zweihander. Its special is a heavy, delayed arc that rends everything ahead."
	button_icon_state = "form_greatsword"
	grip_type = /datum/alt_grip/ferramancy/greatsword
	form_balloon = "greatsword form!"
