// Central cuisine registry. Cuisine is deliberately NOT stored on items - food typepaths (salami, ham, cheese)
// are shared across cultures via the merchant packs, so a per-item tag would bleed between cuisines.
// Instead each foreign cuisine lists the drinks and dishes that belong to it (drawn from that realm's merchant
// wares plus its distinctly-named dishes), compiled into reverse-lookups at init. Anything not registered is
// treated as Azurian home fare (Azurian is the default cuisine). A shared item can belong to several cuisines;
// the Fine/Nice quality gate at consume time keeps low fare from ever counting.
// Each source entry is list(cuisine_flag, list(typepaths...)); typepaths expand to include their subtypes.

GLOBAL_LIST_INIT(cuisine_drinks, build_cuisine_map(cuisine_drink_sources()))
GLOBAL_LIST_INIT(cuisine_foods, build_cuisine_map(cuisine_food_sources()))

/proc/build_cuisine_map(list/entries)
	var/list/out = list()
	for(var/list/entry in entries)
		var/cuisine_flag = entry[1]
		for(var/base in entry[2])
			for(var/expanded in typesof(base))
				out[expanded] |= cuisine_flag
	return out

/proc/food_cuisine(food_type)
	return GLOB.cuisine_foods[food_type] || CUISINE_AZURIAN

/proc/drink_cuisine(drink_type)
	return GLOB.cuisine_drinks[drink_type] || CUISINE_AZURIAN

/proc/cuisine_drink_sources()
	return list(
		list(CUISINE_ETRUSCAN, list(
			/datum/reagent/consumable/ethanol/limoncello,
		)),
		list(CUISINE_SOUTHEAST, list(
			/datum/reagent/consumable/ethanol/ricewine,
			/datum/reagent/consumable/ethanol/ricespirit,
			/datum/reagent/consumable/ethanol/huangjiu,
			/datum/reagent/consumable/ethanol/baijiu,
			/datum/reagent/consumable/ethanol/yaojiu,
			/datum/reagent/consumable/ethanol/shejiu,
			/datum/reagent/consumable/ethanol/truewhipwine,
			/datum/reagent/consumable/ethanol/kgunsake,
			/datum/reagent/consumable/ethanol/kgunshochu,
			/datum/reagent/consumable/ethanol/kgunlager,
			/datum/reagent/consumable/ethanol/kgunplum,
			/datum/reagent/consumable/caffeine/tea,
			/datum/reagent/consumable/tea,
		)),
		list(CUISINE_GRENZELHOFTIAN, list(
			/datum/reagent/consumable/ethanol/apfelweinheim,
			/datum/reagent/consumable/ethanol/jagdtrunk,
			/datum/reagent/consumable/ethanol/sourwine,
		)),
		list(CUISINE_DWARVEN, list(
			/datum/reagent/consumable/ethanol/stonebeards,
			/datum/reagent/consumable/ethanol/butterhairs,
		)),
		list(CUISINE_ELVEN, list(
			/datum/reagent/consumable/ethanol/elfred,
			/datum/reagent/consumable/ethanol/elfblue,
			/datum/reagent/consumable/ethanol/aurorian,
			/datum/reagent/consumable/ethanol/fireleaf,
		)),
		list(CUISINE_NORTHERN, list(
			/datum/reagent/consumable/ethanol/gronnmead,
			/datum/reagent/consumable/ethanol/avarmead,
			/datum/reagent/consumable/ethanol/avarrice,
			/datum/reagent/consumable/ethanol/saigamilk,
		)),
	)

/proc/cuisine_food_sources()
	return list(
		list(CUISINE_ETRUSCAN, list(
			/obj/item/reagent_containers/food/snacks/rogue/lasagna,
			/obj/item/reagent_containers/food/snacks/rogue/lasagna_pesto,
			/obj/item/reagent_containers/food/snacks/rogue/lasagna_white,
			/obj/item/reagent_containers/food/snacks/rogue/lasagna_redwhite,
			/obj/item/reagent_containers/food/snacks/rogue/spaghetti,
			/obj/item/reagent_containers/food/snacks/rogue/spaghetti_pesto,
			/obj/item/reagent_containers/food/snacks/rogue/pesto,
			/obj/item/reagent_containers/food/snacks/rogue/sheetnoodles,
			/obj/item/reagent_containers/food/snacks/rogue/tomatoplate,
			/obj/item/reagent_containers/food/snacks/rogue/fishtomatoplate,
			/obj/item/reagent_containers/food/snacks/rogue/meattomatoplate,
			/obj/item/reagent_containers/food/snacks/rogue/preserved/eggplantstuffedcheese,
			/obj/item/reagent_containers/food/snacks/rogue/pie/cooked/crab,
		)),
		list(CUISINE_GRENZELHOFTIAN, list(
			/obj/item/reagent_containers/food/snacks/rogue/bun_grenz,
			/obj/item/reagent_containers/food/snacks/rogue/meat/nitzel,
			/obj/item/reagent_containers/food/snacks/rogue/meat/griddlewiener,
			/obj/item/reagent_containers/food/snacks/rogue/prezzel,
			/obj/item/reagent_containers/food/snacks/rogue/friedegg/bacon,
			/obj/item/reagent_containers/food/snacks/rogue/meat/fatty/roast,
			/obj/item/reagent_containers/food/snacks/rogue/meat/sausage/cooked,
			/obj/item/reagent_containers/food/snacks/rogue/raisinbread,
			/obj/item/reagent_containers/food/snacks/rogue/sandwich/salami,
		)),
		list(CUISINE_SOUTHEAST, list(
			/obj/item/reagent_containers/food/snacks/rogue/ricebeef,
			/obj/item/reagent_containers/food/snacks/rogue/ricebeefcar,
			/obj/item/reagent_containers/food/snacks/rogue/ricebird,
			/obj/item/reagent_containers/food/snacks/rogue/ricebirdcar,
			/obj/item/reagent_containers/food/snacks/rogue/ricecheese,
			/obj/item/reagent_containers/food/snacks/rogue/riceegg,
			/obj/item/reagent_containers/food/snacks/rogue/riceeggcheese,
			/obj/item/reagent_containers/food/snacks/rogue/ricepork,
			/obj/item/reagent_containers/food/snacks/rogue/riceporkcuc,
			/obj/item/reagent_containers/food/snacks/rogue/riceshrimp,
			/obj/item/reagent_containers/food/snacks/rogue/riceshrimpcar,
			/obj/item/reagent_containers/food/snacks/rogue/preserved/rice_cooked,
			/obj/item/reagent_containers/food/snacks/rogue/fryfish/carp,
			/obj/item/reagent_containers/food/snacks/rogue/fryfish/cod,
			/obj/item/reagent_containers/food/snacks/rogue/fryfish/salmon,
		)),
		list(CUISINE_DWARVEN, list(
			/obj/item/reagent_containers/food/snacks/rogue/friedegg/hammerhold,
			/obj/item/reagent_containers/food/snacks/rogue/meat/bear/fried,
			/obj/item/reagent_containers/food/snacks/rogue/meat/sausage/cooked,
			/obj/item/reagent_containers/food/snacks/rogue/pie/cooked/pot,
			/obj/item/reagent_containers/food/snacks/rogue/preserved/potato_baked,
			/obj/item/reagent_containers/food/snacks/rogue/sandwich/ham,
			/obj/item/reagent_containers/food/snacks/rogue/wienerpotatonions,
		)),
		list(CUISINE_ELVEN, list(
			/obj/item/reagent_containers/food/snacks/rogue/raisinbread,
			/obj/item/reagent_containers/food/snacks/rogue/honey,
		)),
		list(CUISINE_NORTHERN, list(
			/obj/item/reagent_containers/food/snacks/rogue/meat/bacon/fried,
			/obj/item/reagent_containers/food/snacks/rogue/meat/bear/fried,
			/obj/item/reagent_containers/food/snacks/rogue/meat/fatty/roast,
			/obj/item/reagent_containers/food/snacks/rogue/meat/rabbit/fried,
			/obj/item/reagent_containers/food/snacks/rogue/meat/rat/fried,
			/obj/item/reagent_containers/food/snacks/rogue/meat/sausage/cooked,
			/obj/item/reagent_containers/food/snacks/rogue/meat/steak/fried,
			/obj/item/reagent_containers/food/snacks/rogue/meat/wolf/fried,
			/obj/item/reagent_containers/food/snacks/rogue/meat/fish/fried,
			/obj/item/reagent_containers/food/snacks/rogue/fryfish/cod,
			/obj/item/reagent_containers/food/snacks/rogue/fryfish/salmon,
			/obj/item/reagent_containers/food/snacks/rogue/alecod,
			/obj/item/reagent_containers/food/snacks/rogue/pepperlobsta,
		)),
	)

// Dish type registry. dish_type is intrinsic (a steak is meat regardless of realm), so it is resolved here by
// typepath the same way as cuisine. Each entry is list(dish_flag, list(bases...)) with an optional third
// list(excludes...): the meat base excludes the poultry and seafood subtrees so birds/fish stay distinct.
// An item can carry multiple dish flags (e.g. riceeggcheese is Egg + Dairy) - the |= handles that.

GLOBAL_LIST_INIT(dish_foods, build_dish_map(dish_food_sources()))

/proc/build_dish_map(list/entries)
	var/list/out = list()
	for(var/list/entry in entries)
		var/dish_flag = entry[1]
		var/list/excluded
		if(length(entry) >= 3)
			excluded = list()
			for(var/ex in entry[3])
				for(var/extype in typesof(ex))
					excluded[extype] = TRUE
		for(var/base in entry[2])
			for(var/expanded in typesof(base))
				if(excluded && excluded[expanded])
					continue
				out[expanded] |= dish_flag
	return out

/proc/food_dish(food_type)
	return GLOB.dish_foods[food_type]

/proc/dish_food_sources()
	return list(
		list(DISH_MEAT, list(
			/obj/item/reagent_containers/food/snacks/rogue/meat,
			/obj/item/reagent_containers/food/snacks/rogue/peppersteak,
			/obj/item/reagent_containers/food/snacks/rogue/onionsteak,
			/obj/item/reagent_containers/food/snacks/rogue/carrotsteak,
			/obj/item/reagent_containers/food/snacks/rogue/steakcarrotonion,
			/obj/item/reagent_containers/food/snacks/rogue/wienercabbage,
			/obj/item/reagent_containers/food/snacks/rogue/wienerpotato,
			/obj/item/reagent_containers/food/snacks/rogue/wieneronions,
			/obj/item/reagent_containers/food/snacks/rogue/wienerpotatonions,
			/obj/item/reagent_containers/food/snacks/rogue/lemoncoppiette,
			/obj/item/reagent_containers/food/snacks/rogue/ricepork,
			/obj/item/reagent_containers/food/snacks/rogue/riceporkcuc,
			/obj/item/reagent_containers/food/snacks/rogue/ricebeef,
			/obj/item/reagent_containers/food/snacks/rogue/ricebeefcar,
			/obj/item/reagent_containers/food/snacks/rogue/pie/cooked/meat,
			/obj/item/reagent_containers/food/snacks/rogue/pie/cooked/pot,
		), list(
			/obj/item/reagent_containers/food/snacks/rogue/meat/poultry,
			/obj/item/reagent_containers/food/snacks/rogue/meat/fish,
			/obj/item/reagent_containers/food/snacks/rogue/meat/shellfish,
			/obj/item/reagent_containers/food/snacks/rogue/meat/crab,
			/obj/item/reagent_containers/food/snacks/rogue/meat/mince/fish,
			/obj/item/reagent_containers/food/snacks/rogue/meat/driedfishfilet,
			/obj/item/reagent_containers/food/snacks/rogue/pie/cooked/meat/fish,
		)),
		list(DISH_POULTRY, list(
			/obj/item/reagent_containers/food/snacks/rogue/meat/poultry,
			/obj/item/reagent_containers/food/snacks/rogue/frybirdtato,
			/obj/item/reagent_containers/food/snacks/rogue/frybirdbucket,
			/obj/item/reagent_containers/food/snacks/rogue/ricebird,
			/obj/item/reagent_containers/food/snacks/rogue/ricebirdcar,
		)),
		list(DISH_SEAFOOD, list(
			/obj/item/reagent_containers/food/snacks/fish,
			/obj/item/reagent_containers/food/snacks/rogue/fryfish,
			/obj/item/reagent_containers/food/snacks/rogue/meat/fish,
			/obj/item/reagent_containers/food/snacks/rogue/meat/shellfish,
			/obj/item/reagent_containers/food/snacks/rogue/meat/crab,
			/obj/item/reagent_containers/food/snacks/rogue/meat/mince/fish,
			/obj/item/reagent_containers/food/snacks/rogue/meat/driedfishfilet,
			/obj/item/reagent_containers/food/snacks/rogue/pepperfish,
			/obj/item/reagent_containers/food/snacks/rogue/dendorsalmon,
			/obj/item/reagent_containers/food/snacks/rogue/berrysalmon,
			/obj/item/reagent_containers/food/snacks/rogue/milkclam,
			/obj/item/reagent_containers/food/snacks/rogue/onionplaice,
			/obj/item/reagent_containers/food/snacks/rogue/jelliedeel,
			/obj/item/reagent_containers/food/snacks/rogue/crabcake,
			/obj/item/reagent_containers/food/snacks/rogue/pepperlobsta,
			/obj/item/reagent_containers/food/snacks/rogue/garlickbass,
			/obj/item/reagent_containers/food/snacks/rogue/alecod,
			/obj/item/reagent_containers/food/snacks/rogue/buttersole,
			/obj/item/reagent_containers/food/snacks/rogue/foodbase/crabcakeraw,
			/obj/item/reagent_containers/food/snacks/rogue/riceshrimp,
			/obj/item/reagent_containers/food/snacks/rogue/riceshrimpcar,
			/obj/item/reagent_containers/food/snacks/rogue/pie/cooked/meat/fish,
			/obj/item/reagent_containers/food/snacks/rogue/pie/cooked/crab,
		)),
		list(DISH_VEGETABLE, list(
			/obj/item/reagent_containers/food/snacks/grown/vegetable,
			/obj/item/reagent_containers/food/snacks/grown/onion,
			/obj/item/reagent_containers/food/snacks/grown/cabbage,
			/obj/item/reagent_containers/food/snacks/grown/potato,
			/obj/item/reagent_containers/food/snacks/grown/garlick,
			/obj/item/reagent_containers/food/snacks/grown/carrot,
			/obj/item/reagent_containers/food/snacks/grown/cucumber,
			/obj/item/reagent_containers/food/snacks/grown/eggplant,
			/obj/item/reagent_containers/food/snacks/rogue/veg,
			/obj/item/reagent_containers/food/snacks/veg,
			/obj/item/reagent_containers/food/snacks/rogue/preserved/cabbage_fried,
			/obj/item/reagent_containers/food/snacks/rogue/preserved/potato_baked,
			/obj/item/reagent_containers/food/snacks/rogue/preserved/potato_fried,
			/obj/item/reagent_containers/food/snacks/rogue/preserved/carrot_baked,
			/obj/item/reagent_containers/food/snacks/rogue/preserved/onion_fried,
			/obj/item/reagent_containers/food/snacks/rogue/eggplantcarved,
			/obj/item/reagent_containers/food/snacks/rogue/eggplantmeat,
			/obj/item/reagent_containers/food/snacks/rogue/preserved/eggplantstuffed,
			/obj/item/reagent_containers/food/snacks/rogue/preserved/eggplantstuffedcheese,
			/obj/item/reagent_containers/food/snacks/roastseeds,
			/obj/item/reagent_containers/food/snacks/rogue/pesto,
			/obj/item/reagent_containers/food/snacks/rogue/pie/cooked/pumpkin,
		)),
		list(DISH_FRUIT, list(
			/obj/item/reagent_containers/food/snacks/grown/fruit,
			/obj/item/reagent_containers/food/snacks/grown/apple,
			/obj/item/reagent_containers/food/snacks/grown/berries,
			/obj/item/reagent_containers/food/snacks/rogue/fruit,
			/obj/item/reagent_containers/food/snacks/rogue/raisins,
			/obj/item/reagent_containers/food/snacks/rogue/trailmix,
			/obj/item/reagent_containers/food/snacks/rogue/preserved/pumpkin_mashed,
			/obj/item/reagent_containers/food/snacks/rogue/pie/cooked/berry,
			/obj/item/reagent_containers/food/snacks/rogue/pie/cooked/apple,
		)),
		list(DISH_BREAD, list(
			/obj/item/reagent_containers/food/snacks/rogue/bread,
			/obj/item/reagent_containers/food/snacks/rogue/breadslice,
			/obj/item/reagent_containers/food/snacks/rogue/applebread,
			/obj/item/reagent_containers/food/snacks/rogue/challah,
			/obj/item/reagent_containers/food/snacks/rogue/crackerscooked,
			/obj/item/reagent_containers/food/snacks/rogue/toastcrumbs,
			/obj/item/reagent_containers/food/snacks/rogue/bun,
			/obj/item/reagent_containers/food/snacks/rogue/bun_jamtallow,
			/obj/item/reagent_containers/food/snacks/rogue/bun_marmalade,
			/obj/item/reagent_containers/food/snacks/rogue/bun_grenz,
			/obj/item/reagent_containers/food/snacks/rogue/bun_raston,
			/obj/item/reagent_containers/food/snacks/rogue/crossbun,
			/obj/item/reagent_containers/food/snacks/rogue/psycrossbun,
			/obj/item/reagent_containers/food/snacks/rogue/cheesebun,
			/obj/item/reagent_containers/food/snacks/rogue/frybread,
			/obj/item/reagent_containers/food/snacks/rogue/cornbread,
			/obj/item/reagent_containers/food/snacks/rogue/cornfrybread,
			/obj/item/reagent_containers/food/snacks/rogue/corn_ball_cooked,
			/obj/item/reagent_containers/food/snacks/rogue/raisinbread,
		)),
		list(DISH_DAIRY, list(
			/obj/item/reagent_containers/food/snacks/butter,
			/obj/item/reagent_containers/food/snacks/butterslice,
			/obj/item/reagent_containers/food/snacks/rogue/cheese,
			/obj/item/reagent_containers/food/snacks/rogue/cheddar,
			/obj/item/reagent_containers/food/snacks/rogue/cheddarwedge,
			/obj/item/reagent_containers/food/snacks/rogue/cheddarslice,
			/obj/item/reagent_containers/food/snacks/rogue/foodbase/cheesewheel,
			/obj/item/reagent_containers/food/snacks/rogue/frosting,
			/obj/item/reagent_containers/food/snacks/rogue/ricecheese,
			/obj/item/reagent_containers/food/snacks/rogue/riceeggcheese,
		)),
		list(DISH_PASTRY, list(
			/obj/item/reagent_containers/food/snacks/rogue/pastry,
			/obj/item/reagent_containers/food/snacks/rogue/biscuit,
			/obj/item/reagent_containers/food/snacks/rogue/chocolatebiscuit,
			/obj/item/reagent_containers/food/snacks/rogue/plumbiscuit,
			/obj/item/reagent_containers/food/snacks/rogue/tangerinebiscuit,
			/obj/item/reagent_containers/food/snacks/rogue/cookie,
			/obj/item/reagent_containers/food/snacks/rogue/cookiec,
			/obj/item/reagent_containers/food/snacks/rogue/cookied,
			/obj/item/reagent_containers/food/snacks/rogue/cookier,
			/obj/item/reagent_containers/food/snacks/rogue/prezzel,
			/obj/item/reagent_containers/food/snacks/rogue/pumpkinball,
			/obj/item/reagent_containers/food/snacks/rogue/pumpkinloaf,
			/obj/item/reagent_containers/food/snacks/rogue/handpie,
			/obj/item/reagent_containers/food/snacks/rogue/muffin,
			/obj/item/reagent_containers/food/snacks/rogue/strudel,
			/obj/item/reagent_containers/food/snacks/rogue/dot_tart,
			/obj/item/reagent_containers/food/snacks/rogue/bookbread,
			/obj/item/reagent_containers/food/snacks/rogue/chocolatebookbread,
			/obj/item/reagent_containers/food/snacks/rogue/jackberrybookbread,
			/obj/item/reagent_containers/food/snacks/rogue/lemonbookbread,
			/obj/item/reagent_containers/food/snacks/rogue/pearbookbread,
			/obj/item/reagent_containers/food/snacks/rogue/plumbookbread,
			/obj/item/reagent_containers/food/snacks/rogue/raspberrybookbread,
			/obj/item/reagent_containers/food/snacks/rogue/tangerinebookbread,
			/obj/item/reagent_containers/food/snacks/rogue/blackberrybookbread,
			/obj/item/reagent_containers/food/snacks/rogue/cake,
			/obj/item/reagent_containers/food/snacks/rogue/frostedcake,
			/obj/item/reagent_containers/food/snacks/rogue/applecake,
			/obj/item/reagent_containers/food/snacks/rogue/applenutcake,
			/obj/item/reagent_containers/food/snacks/rogue/berrycake,
			/obj/item/reagent_containers/food/snacks/rogue/blackberrycake,
			/obj/item/reagent_containers/food/snacks/rogue/carrotcake,
			/obj/item/reagent_containers/food/snacks/rogue/ccake,
			/obj/item/reagent_containers/food/snacks/rogue/corncake,
			/obj/item/reagent_containers/food/snacks/rogue/corncake_lemon,
			/obj/item/reagent_containers/food/snacks/rogue/corncake_lime,
			/obj/item/reagent_containers/food/snacks/rogue/hcake,
			/obj/item/reagent_containers/food/snacks/rogue/lemoncake,
			/obj/item/reagent_containers/food/snacks/rogue/limecake,
			/obj/item/reagent_containers/food/snacks/rogue/menthacake,
			/obj/item/reagent_containers/food/snacks/rogue/peacecake,
			/obj/item/reagent_containers/food/snacks/rogue/raspberrycake,
			/obj/item/reagent_containers/food/snacks/rogue/rocknutcake,
			/obj/item/reagent_containers/food/snacks/rogue/strawberrycake,
			/obj/item/reagent_containers/food/snacks/rogue/tangerinecake,
		)),
		list(DISH_PIE, list(
			/obj/item/reagent_containers/food/snacks/rogue/pie,
		)),
		list(DISH_SWEET, list(
			/obj/item/reagent_containers/food/snacks/caramel,
			/obj/item/reagent_containers/food/snacks/chocolate,
			/obj/item/reagent_containers/food/snacks/dragee,
			/obj/item/reagent_containers/food/snacks/jamtallow,
			/obj/item/reagent_containers/food/snacks/marmalade,
			/obj/item/reagent_containers/food/snacks/sugarstatue,
			/obj/item/reagent_containers/food/snacks/grown/sugarshape,
			/obj/item/reagent_containers/food/snacks/squiresdelight,
			/obj/item/reagent_containers/food/snacks/rogue/honey,
			/obj/item/reagent_containers/food/snacks/rogue/raisins/sweetglass,
			/obj/item/reagent_containers/food/snacks/grown/fruit/tangerine_sugared,
			/obj/item/reagent_containers/food/snacks/grown/fruit/blackberry_sugared,
			/obj/item/reagent_containers/food/snacks/grown/nut_sugared,
		)),
		list(DISH_EGG, list(
			/obj/item/reagent_containers/food/snacks/rogue/friedegg,
			/obj/item/reagent_containers/food/snacks/rogue/stuffedegg,
			/obj/item/reagent_containers/food/snacks/rogue/omelette,
			/obj/item/reagent_containers/food/snacks/rogue/omelette_meat,
			/obj/item/reagent_containers/food/snacks/rogue/omelette_veggie,
			/obj/item/reagent_containers/food/snacks/rogue/omelette_raw,
			/obj/item/reagent_containers/food/snacks/rogue/omelette_raw_meat,
			/obj/item/reagent_containers/food/snacks/rogue/omelette_raw_onion,
			/obj/item/reagent_containers/food/snacks/rogue/omelette_raw_veggie,
			/obj/item/reagent_containers/food/snacks/rogue/riceegg,
			/obj/item/reagent_containers/food/snacks/rogue/riceeggcheese,
		)),
	)
