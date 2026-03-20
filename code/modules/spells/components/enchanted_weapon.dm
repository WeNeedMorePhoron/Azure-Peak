#define DEFAULT_DURATION 10 MINUTES
#define ENCHANT_REFRESH_INTERVAL 1 MINUTES
#define ENCHANT_PROXIMITY_RANGE 10

// I nuked the former Searing Blade. Leaving 1 open for a future replacement

/* Component used for adding enchantment from the enchant weapon spell
 Two types of enchantments are available:
 1. Force Blade: Increases the force of the weapon by 5.
 2. Durability: Increases the integrity and max integrity of the weapon by 100.
 The enchantment lasts for 10 minutes, and will automatically refresh while within 10 tiles of the original caster.
 A beam is drawn between caster and holder on refresh (same z-level only).
 There used to be a concept for a blade to set people on fire - but it was too broken if people didn't insta pat
*/

/datum/component/enchanted_weapon
	dupe_mode = COMPONENT_DUPE_UNIQUE // To avoid weird filter override this is the way..
	var/endtime = null // How long till the conjured item disappear (Don't use duration it is messed up)
	var/allow_refresh = TRUE // If TRUE, the item will refresh its duration when within range of the caster
	var/overridden_duration = null
	var/enchant_type = FORCE_BLADE_ENCHANT // The type of enchantment
	var/datum/weakref/caster_ref = null // Weakref to the original caster for proximity refresh
	var/datum/weakref/last_known_mob = null // Cached mob weakref for when weapon is in nullspace (e.g. holster)

/datum/component/enchanted_weapon/Initialize(duration_override, allow_refresh_override, caster, enchant_type_override)
	if(!istype(parent, /obj/item/rogueweapon))
		return COMPONENT_INCOMPATIBLE
	var/obj/item/I = parent

	if(duration_override)
		endtime = world.time + duration_override
		overridden_duration = duration_override
	else
		endtime = world.time + DEFAULT_DURATION
	if(!isnull(allow_refresh_override))
		allow_refresh = allow_refresh_override
	if(enchant_type_override)
		enchant_type = enchant_type_override
	if(caster)
		caster_ref = WEAKREF(caster)
	apply_enchant(I)

	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, PROC_REF(on_examine))
	RegisterSignal(parent, COMSIG_ITEM_OBJFIX, PROC_REF(on_fix))
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, PROC_REF(on_moved))

	addtimer(CALLBACK(src, PROC_REF(refresh_check)), ENCHANT_REFRESH_INTERVAL)

/datum/component/enchanted_weapon/proc/on_moved(datum/source, atom/old_loc, dir, forced)
	SIGNAL_HANDLER
	// Cache the mob when the weapon leaves someone's hands (e.g. into a holster nullspace)
	var/atom/check = old_loc
	while(check && !isturf(check))
		if(isliving(check))
			last_known_mob = WEAKREF(check)
			return
		check = check.loc
	last_known_mob = null

/datum/component/enchanted_weapon/proc/get_holder_mob()
	var/obj/item/I = parent
	var/atom/itemloc = I.loc
	if(isnull(itemloc))
		var/mob/living/cached_mob = last_known_mob?.resolve()
		if(cached_mob)
			return cached_mob
		return null
	while(itemloc && !isturf(itemloc))
		if(isliving(itemloc))
			return itemloc
		itemloc = itemloc.loc
	return null

/datum/component/enchanted_weapon/proc/refresh_check()
	if(!allow_refresh || !caster_ref)
		qdel(src)
		return
	var/mob/living/caster = caster_ref.resolve()
	if(!caster || caster.stat == DEAD)
		qdel(src)
		return
	var/mob/living/holder = get_holder_mob()
	if(!holder)
		qdel(src)
		return
	var/turf/caster_turf = get_turf(caster)
	var/turf/holder_turf = get_turf(holder)
	if(!caster_turf || !holder_turf)
		qdel(src)
		return
	if(get_dist(caster_turf, holder_turf) > ENCHANT_PROXIMITY_RANGE)
		qdel(src)
		return
	// Refresh the duration
	if(overridden_duration)
		endtime = world.time + overridden_duration
	else
		endtime = world.time + DEFAULT_DURATION
	// Draw beam if on the same z-level and holder is not the caster
	if(holder != caster && caster_turf.z == holder_turf.z)
		caster.Beam(holder, icon_state = "b_beam", time = 5, maxdistance = ENCHANT_PROXIMITY_RANGE)
	addtimer(CALLBACK(src, PROC_REF(refresh_check)), ENCHANT_REFRESH_INTERVAL)

/datum/component/enchanted_weapon/proc/apply_enchant(var/obj/item/I, is_fix = FALSE)
	if(enchant_type == FORCE_BLADE_ENCHANT)
		I.force += FORCE_BLADE_FORCE
		I.force_wielded += FORCE_BLADE_FORCE
		I.update_force_dynamic()
		var/force_blade_filter = I.get_filter(FORCE_FILTER)
		if(!force_blade_filter)
			I.add_filter(FORCE_FILTER, 2, list("type" = "outline", "color" = GLOW_COLOR_DISPLACEMENT, "alpha" = 200, "size" = 1))
	else if(enchant_type == DURABILITY_ENCHANT)
		if(!is_fix) // Obj fix already increase durability.
			I.max_integrity += DURABILITY_INCREASE
			I.obj_integrity += DURABILITY_INCREASE
		var/durability_filter = I.get_filter(DURABILITY_FILTER)
		if(!durability_filter)
			I.add_filter(DURABILITY_FILTER, 2, list("type" = "outline", "color" = GLOW_COLOR_METAL, "alpha" = 200, "size" = 1))

// Called when the enchantment is removed
/datum/component/enchanted_weapon/proc/remove()
	var/obj/item/I = parent
	if(enchant_type == FORCE_BLADE_ENCHANT)
		I.force -= FORCE_BLADE_FORCE
		I.force_wielded -= FORCE_BLADE_FORCE
		I.remove_filter(FORCE_FILTER)
	else if(enchant_type == DURABILITY_ENCHANT)
		if(I.max_integrity != initial(I.max_integrity))
			I.max_integrity -= DURABILITY_INCREASE // Jank ass "temporary" fix I sure hope no one else modify max integrity
		I.obj_integrity = min(I.obj_integrity, I.max_integrity - DURABILITY_INCREASE)
		I.remove_filter(DURABILITY_FILTER)
	else
		return

/datum/component/enchanted_weapon/Destroy()
	remove()
	caster_ref = null
	last_known_mob = null
	. = ..()

/datum/component/enchanted_weapon/proc/on_examine(datum/source, mob/user, list/examine_list)
	if(enchant_type == FORCE_BLADE_ENCHANT)
		examine_list += "This weapon is enchanted with a force blade enchantment."
	else if(enchant_type == DURABILITY_ENCHANT)
		examine_list += "This weapon is enchanted with a durability enchantment."
	var/remaining_minutes = round((endtime - world.time) / 600)
	examine_list += "The enchantment will last for [remaining_minutes] more minutes."

// This is called right after the object is fixed and all of its force / wdefense values are reset to initial. We re-apply the relevant bonuses.
/datum/component/enchanted_weapon/proc/on_fix()
	var/obj/item/I = parent
	apply_enchant(I, TRUE)

#undef DEFAULT_DURATION
#undef ENCHANT_REFRESH_INTERVAL
#undef ENCHANT_PROXIMITY_RANGE
