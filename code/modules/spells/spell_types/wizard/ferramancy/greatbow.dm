/datum/intent/shoot/bow/ferramancy
	charging_slowdown = 4

/datum/intent/shoot/bow/ferramancy/lance
	charging_slowdown = 5

/obj/item/ammo_casing/caseless/rogue/arrow/iron/ferramancy
	name = "arcyne broadhead"
	color = GLOW_COLOR_ARCANE
	projectile_type = /obj/projectile/bullet/reusable/arrow/iron/ferramancy

/obj/projectile/bullet/reusable/arrow/iron/ferramancy
	color = GLOW_COLOR_ARCANE

/obj/projectile/bullet/reusable/arrow/iron/ferramancy/on_hit()
	. = ..()
	QDEL_NULL(dropped)

/obj/projectile/bullet/reusable/arrow/iron/ferramancy/handle_drop()
	QDEL_NULL(dropped)
	return

/obj/item/ammo_box/magazine/internal/shot/bow/ferramancy
	ammo_type = /obj/item/ammo_casing/caseless/rogue/arrow/iron/ferramancy
	start_empty = FALSE

/obj/item/gun/ballistic/revolver/grenadelauncher/bow/greatbow
	name = "arcyne greatbow"
	desc = "A longbow of condensed arcyne light. It draws on the wielder's own energy in place of arrows, looses with a heavy and deliberate pull, and is far too unwieldy to fire on the move."
	color = GLOW_COLOR_ARCANE
	minstr = 0
	damfactor = 0.8
	mag_type = /obj/item/ammo_box/magazine/internal/shot/bow/ferramancy
	possible_item_intents = list(
		/datum/intent/shoot/bow/ferramancy,
		/datum/intent/shoot/bow/ferramancy/lance,
		INTENT_GENERIC,
		)
	var/reload_cost = 60
	var/lance_energy = 150
	var/held_slowdown = 2
	var/reload_time = 2 SECONDS
	var/reloading = FALSE

/obj/item/gun/ballistic/revolver/grenadelauncher/bow/greatbow/Initialize()
	. = ..()
	chamber_round()

/obj/item/gun/ballistic/revolver/grenadelauncher/bow/greatbow/equipped(mob/user, slot)
	. = ..()
	if(user.is_holding(src))
		user.add_movespeed_modifier("ferramancy_greatbow", TRUE, 100, override = TRUE, multiplicative_slowdown = held_slowdown)
	else
		user.remove_movespeed_modifier("ferramancy_greatbow")

/obj/item/gun/ballistic/revolver/grenadelauncher/bow/greatbow/dropped(mob/user)
	. = ..()
	if(user)
		user.remove_movespeed_modifier("ferramancy_greatbow")

/obj/item/gun/ballistic/revolver/grenadelauncher/bow/greatbow/process_fire(atom/target, mob/living/user, message = TRUE, params = null, zone_override = "", bonus_spread = 0)
	if(istype(user.used_intent, /datum/intent/shoot/bow/ferramancy/lance))
		if(user.energy < lance_energy)
			to_chat(user, span_warning("I haven't the arcyne energy to loose the lance!"))
			return FALSE
		user.energy_add(-lance_energy)
		fire_lance(target, user)
		return TRUE
	if(!chambered)
		to_chat(user, span_warning("My greatbow has not yet conjured its next arrow!"))
		return FALSE
	. = ..()
	if(!chambered && !reloading)
		start_reload()
	return .

/obj/item/gun/ballistic/revolver/grenadelauncher/bow/greatbow/proc/fire_lance(atom/target, mob/living/user)
	user.Immobilize(1 SECONDS)
	playsound(get_turf(user), 'sound/magic/scrapeblade.ogg', 80, TRUE)
	var/obj/projectile/magic/arcyne_lance/P = new(get_turf(user))
	P.armor_penetration = PEN_HEAVY
	P.max_hits = 5
	P.firer = user
	P.preparePixelProjectile(target, user)
	P.fire()

/obj/item/gun/ballistic/revolver/grenadelauncher/bow/greatbow/proc/start_reload()
	if(reloading)
		return
	reloading = TRUE
	addtimer(CALLBACK(src, PROC_REF(finish_reload)), reload_time)

/obj/item/gun/ballistic/revolver/grenadelauncher/bow/greatbow/proc/finish_reload()
	if(QDELETED(src) || !magazine)
		reloading = FALSE
		return
	var/mob/living/holder = isliving(loc) ? loc : null
	if(holder && holder.energy < reload_cost)
		addtimer(CALLBACK(src, PROC_REF(finish_reload)), reload_time)
		return
	reloading = FALSE
	if(holder)
		holder.energy_add(-reload_cost)
	if(!chambered && !magazine.ammo_count())
		magazine.give_round(new /obj/item/ammo_casing/caseless/rogue/arrow/iron/ferramancy(magazine))
	chamber_round()
	update_icon()
	if(holder)
		playsound(loc, 'sound/foley/nockarrow.ogg', 50, TRUE)

/datum/action/cooldown/spell/ferramancy_form/greatbow
	name = "Form: Greatbow"
	desc = "Conjure an arcyne greatbow. Its draw spends your own arcyne energy in place of arrows and roots you while you hold it - a siege engine, not a skirmisher. Its special looses a piercing, armor-rending lance."
	button_icon_state = "arcyne_lance"
	weapon_type = /obj/item/gun/ballistic/revolver/grenadelauncher/bow/greatbow
	form_balloon = "greatbow!"
