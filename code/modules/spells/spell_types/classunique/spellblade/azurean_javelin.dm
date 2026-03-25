/datum/action/cooldown/spell/projectile/azurean_javelin
	name = "Azurean Javelin"
	desc = "The ancient art of skirmishers in arcyne form - conjure a phantom spear and hurl it. \
		Armor-piercing (20 AP), slows the target on hit for 4 seconds regardless of armor. \
		At 3+ momentum: consumes 3 to double damage. \
		Toggle arc mode (Ctrl+G) to arc the javelin over allies."
	button_icon = 'icons/mob/actions/classuniquespells/spellblade.dmi'
	button_icon_state = "azurean_javelin"
	sound = 'sound/combat/wooshes/bladed/wooshsmall (1).ogg'
	spell_color = GLOW_COLOR_ARCANE
	glow_intensity = GLOW_INTENSITY_LOW

	projectile_type = /obj/projectile/energy/azurean_javelin
	projectile_type_arc = /obj/projectile/energy/azurean_javelin/arc
	cast_range = 15

	primary_resource_type = SPELL_COST_STAMINA
	primary_resource_cost = SPELLCOST_MINOR_PROJECTILE

	invocations = list("Pilum Azureum!")
	invocation_type = INVOCATION_SHOUT

	charge_required = TRUE
	weapon_cast_penalized = FALSE
	charge_time = CHARGETIME_POKE
	charge_drain = 1
	charge_slowdown = CHARGING_SLOWDOWN_NONE
	charge_sound = 'sound/magic/charging.ogg'
	cooldown_time = 10 SECONDS

	associated_skill = /datum/skill/magic/arcane
	spell_tier = 2
	spell_impact_intensity = SPELL_IMPACT_MEDIUM
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC | SPELL_REQUIRES_HUMAN

	var/base_damage = 25
	var/empowered_mult = 2
	var/momentum_cost = 3
	var/cached_damage = 0
	var/cached_empowered = FALSE

/datum/action/cooldown/spell/projectile/azurean_javelin/cast(atom/cast_on)
	var/mob/living/carbon/human/H = owner
	if(!istype(H))
		return FALSE

	if(!arcyne_get_weapon(H))
		to_chat(H, span_warning("I need my bound weapon in hand!"))
		return FALSE

	cached_empowered = FALSE
	var/datum/status_effect/buff/arcyne_momentum/M = H.has_status_effect(/datum/status_effect/buff/arcyne_momentum)
	if(M && M.stacks >= momentum_cost)
		M.consume_stacks(momentum_cost)
		cached_empowered = TRUE
		to_chat(H, span_notice("[momentum_cost] momentum released - empowered javelin!"))

	cached_damage = cached_empowered ? (base_damage * empowered_mult) : base_damage

	if(cached_empowered)
		projectile_type = /obj/projectile/energy/azurean_javelin/empowered
		projectile_type_arc = /obj/projectile/energy/azurean_javelin/empowered/arc
	else
		projectile_type = /obj/projectile/energy/azurean_javelin
		projectile_type_arc = /obj/projectile/energy/azurean_javelin/arc

	. = ..()

/datum/action/cooldown/spell/projectile/azurean_javelin/ready_projectile(obj/projectile/to_fire, atom/target, mob/user, iteration)
	..()
	to_fire.damage = cached_damage

/obj/projectile/energy/azurean_javelin
	name = "Azurean Javelin"
	icon_state = "air_blade_stab"
	damage = 25
	woundclass = BCLASS_STAB
	nodamage = FALSE
	speed = 1.5
	armor_penetration = PEN_LIGHT
	hitsound = 'sound/combat/hits/bladed/genthrust (1).ogg'

/obj/projectile/energy/azurean_javelin/on_hit(target)
	. = ..()
	if(isliving(target))
		var/mob/living/L = target
		if(L.anti_magic_check())
			visible_message(span_warning("[src] disperses on contact with [L]!"))
			playsound(get_turf(L), 'sound/magic/magic_nulled.ogg', 100)
			return BULLET_ACT_BLOCK
		L.apply_status_effect(/datum/status_effect/debuff/azurean_javelin_slow)
		to_chat(L, span_danger("An arcyne javelin pierces through - my movements are sluggish!"))
		if(firer)
			log_combat(firer, L, "javelin-struck")

/obj/projectile/energy/azurean_javelin/empowered
	name = "Empowered Azurean Javelin"
	icon_state = "youreyesonly"
	armor_penetration = PEN_MEDIUM

/obj/projectile/energy/azurean_javelin/arc
	name = "Arced Azurean Javelin"
	arcshot = TRUE

/obj/projectile/energy/azurean_javelin/empowered/arc
	name = "Empowered Arced Azurean Javelin"
	arcshot = TRUE

/datum/status_effect/debuff/azurean_javelin_slow
	id = "azurean_javelin_slow"
	duration = 4 SECONDS
	effectedstats = list(STATKEY_SPD = -3)
	alert_type = null
