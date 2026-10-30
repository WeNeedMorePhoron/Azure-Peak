
// Raw Shellfish. Separate folder due to sprites
/obj/item/reagent_containers/food/snacks/fish/crab
	name = "crab"
	desc = "A defensive shellfish that's a real hassle to crack open, they taste great when made into cakes with butterdough slice."
	icon_state = "crab"
	fish_id = "crab"
	average_size = 2
	average_weight = 1
	required_fluid_type = FISH_FLUID_SALTWATER
	fish_movement_type = /datum/fish_movement/choppy
	favorite_bait = list(
		list(
			FISH_BAIT_TYPE = FISH_BAIT_FOODTYPE,
			FISH_BAIT_VALUE = DISH_MEAT,
		),
	)
	sellprice = 10
	fried_type = /obj/item/reagent_containers/food/snacks/rogue/fryfish/crab
	cooked_type = /obj/item/reagent_containers/food/snacks/rogue/fryfish/crab
	slice_path = /obj/item/reagent_containers/food/snacks/rogue/meat/crab
	cooked_smell = /datum/pollutant/food/fried_crab

/obj/item/reagent_containers/food/snacks/fish/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Chopping fish on a table with a knife, cleaver, or dagger turns it into mince. Mince can be used for advanced recipes, or used to make 'more out of less' in a stew's broth.")

/obj/item/reagent_containers/food/snacks/fish/clam
	name = "clam"
	desc = "A beastye built by Abyssor in the image of a knight. Hard shell, squishy interior."
	icon_state = "clam"
	fish_id = "clam"
	average_size = 0.8
	average_weight = 0.2
	required_fluid_type = FISH_FLUID_SALTWATER
	fishing_difficulty_modifier = -10
	fish_movement_type = /datum/fish_movement/slow
	fish_traits = list(/datum/fish_trait/vegan)
	faretype = FARE_NEUTRAL
	no_rarity_sprite = TRUE
	sellprice = 15
	fried_type = /obj/item/reagent_containers/food/snacks/rogue/fryfish/clam
	cooked_type = /obj/item/reagent_containers/food/snacks/rogue/fryfish/clam
	cooked_smell = /datum/pollutant/food/fried_shellfish

/obj/item/reagent_containers/food/snacks/fish/lobster
	name = "lobster"
	desc = "A hard-shelled cretin, barely fit for eating."
	icon_state = "lobster"
	fish_id = "lobster"
	average_size = 4
	average_weight = 3
	required_fluid_type = FISH_FLUID_SALTWATER
	fishing_difficulty_modifier = 5
	fish_movement_type = /datum/fish_movement/slow
	favorite_bait = list(
		list(
			FISH_BAIT_TYPE = FISH_BAIT_FOODTYPE,
			FISH_BAIT_VALUE = DISH_MEAT,
		),
	)
	fish_traits = list(/datum/fish_trait/heavy)
	faretype = FARE_NEUTRAL
	no_rarity_sprite = TRUE
	sellprice = 5
	fried_type = /obj/item/reagent_containers/food/snacks/rogue/fryfish/lobster
	cooked_type = /obj/item/reagent_containers/food/snacks/rogue/fryfish/lobster
	slice_path = /obj/item/reagent_containers/food/snacks/rogue/meat/shellfish
	cooked_smell = /datum/pollutant/food/fried_shellfish

/obj/item/reagent_containers/food/snacks/fish/shrimp
	name = "shrimp"
	desc = "A tiny shellfish, little bigger than your thumb. Often nicknamed butterflies of the sea."
	icon_state = "shrimp"
	fish_id = "shrimp"
	average_size = 0.5
	average_weight = 0.01
	required_fluid_type = FISH_FLUID_SALTWATER
	fishing_difficulty_modifier = -5
	fish_movement_type = /datum/fish_movement/slow
	favorite_bait = list(
		list(
			FISH_BAIT_TYPE = FISH_BAIT_FOODTYPE,
			FISH_BAIT_VALUE = DISH_VEGETABLE,
		),
		/obj/item/fishing/lure/dough,
		/obj/item/fishing/lure/gray,
	)
	fish_traits = list(/datum/fish_trait/vegan)
	sellprice = 5
	fried_type = /obj/item/reagent_containers/food/snacks/rogue/fryfish/shrimp
	cooked_type = /obj/item/reagent_containers/food/snacks/rogue/fryfish/shrimp
	cooked_smell = /datum/pollutant/food/fried_shellfish

/obj/item/reagent_containers/food/snacks/fish/oyster
	name = "oyster"
	desc = "A stubborn shellfish that MIGHT hide a prize within, can be opened with a knife to reveal the flesh within."
	icon_state = "oyster"
	fish_id = "oyster"
	average_size = 0.8
	average_weight = 0.2
	required_fluid_type = FISH_FLUID_SALTWATER
	fishing_difficulty_modifier = -10
	fish_movement_type = /datum/fish_movement/slow
	fish_traits = list(/datum/fish_trait/vegan)
	sellprice = 5
	var/closed
	var/obj/item/pearl
	slice_path = /obj/item/reagent_containers/food/snacks/rogue/meat/shellfish
	trash = /obj/item/oystershell
	cooked_smell = /datum/pollutant/food/fried_shellfish

/obj/item/reagent_containers/food/snacks/fish/oyster/Initialize(mapload)
	. = ..()
	closed = TRUE

// Pearl distribution is based on rarity. This helper make it roll when it is opened after its rarity is settled after fishing minigame
/obj/item/reagent_containers/food/snacks/fish/oyster/proc/roll_pearl()
	var/pearl_weight
	switch(rarity_rank)
		if(FISH_RARITY_LEGENDARY)
			pearl_weight = pickweight(list("bpearl" = 200, "pearl" =15, "nopearl"=15))
		if(FISH_RARITY_ULTRA)
			pearl_weight = pickweight(list("bpearl" = 60, "pearl" =120, "nopearl"=35))
		if(FISH_RARITY_RARE)
			pearl_weight = pickweight(list("bpearl" = 40, "pearl" =80, "nopearl"=150))
		else
			pearl_weight = pickweight(list("bpearl" = 10, "pearl" =40, "nopearl"=200))
	switch(pearl_weight)
		if("pearl")
			pearl = new /obj/item/pearl(src)
		if("bpearl")
			pearl = new /obj/item/pearl/blue(src)

/obj/item/reagent_containers/food/snacks/fish/oyster/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/rogueweapon/huntingknife))
		if(closed)
			user.visible_message("<span class='notice'>[user] opens the oyster with the knife.</span>")
			closed = FALSE
			roll_pearl()
			icon_state = "[icon_state]_open"
			update_icon()
		else
			if(slice(src, user))
				new /obj/item/oystershell(user.loc)
				new /obj/item/oystershell(user.loc)
	else
		. = ..()

/obj/item/reagent_containers/food/snacks/fish/oyster/attack_right(mob/user)
	if(user.get_active_held_item())
		return
	else
		if(pearl)
			user.put_in_hands(pearl)
			pearl = null
			update_icon()
	. = ..()

/obj/item/reagent_containers/food/snacks/fish/oyster/update_icon()
	cut_overlays()
	if(!closed && pearl)
		var/mutable_appearance/pearl = mutable_appearance(icon, "pearl")
		add_overlay(pearl)

/obj/item/oystershell
	name = "oyster shell"
	icon = 'modular/Neu_food/icons/raw/raw_fish.dmi'
	icon_state = "oyster_shell"
	desc = ""
	dropshrink = 0.5
	w_class = WEIGHT_CLASS_TINY
	sellprice = 3
	grid_height = 32
	grid_width = 32

// Close enough crab cake is raw shellfish
/obj/item/reagent_containers/food/snacks/rogue/foodbase/crabcakeraw
	cuisine = CUISINE_SOUTH_IMPERIAL
	dish_type = DISH_SEAFOOD|DISH_DAIRY
	name = "raw crab cake"
	desc = "A variant of the handpie filled with buttery, savory shellfish meat and made with a buttered slice of dough."
	icon = 'modular/Neu_Food/icons/raw/raw_fish.dmi' // I guess it is a raw fish meal
	icon_state = "crab_cake_raw"
	cooked_type = /obj/item/reagent_containers/food/snacks/rogue/crabcake
	fried_type = /obj/item/reagent_containers/food/snacks/rogue/crabcake
	cooked_smell = /datum/pollutant/food/fried_crab_cake
	w_class = WEIGHT_CLASS_NORMAL
	dropshrink = 0.8
