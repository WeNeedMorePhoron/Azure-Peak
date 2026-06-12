//defines for tea mix items, a workaround pots using only one input
/obj/item/reagent_containers/food/snacks/mix_taraxamint
	name = "Taraxacum-Mentha tea mix"
	desc = "A tea mix consisting of smothered herbs of Taraxacum and Mentha"
	icon = 'modular/Neu_teas_and_brews/icons/obj/tea_mixes.dmi'
	icon_state = "mix_taraxamint"
	list_reagents = list(/datum/reagent/consumable/nutriment = NUTRITION_QUARTER_MEAL)
	w_class = WEIGHT_CLASS_TINY
	tastes = list("overwhelming bitterness and mint" = 1)
	faretype = FARE_IMPOVERISHED
	eat_effect = null
	rotprocess = null
	foodtype = GROSS

/obj/item/reagent_containers/food/snacks/mix_utricasalvia
	name = "Urtica-Salvia tea mix"
	desc = "A tea mix consisting of smothered herbs of Urtica and Salvia"
	icon = 'modular/Neu_teas_and_brews/icons/obj/tea_mixes.dmi'
	icon_state = "mix_utricasalvia"
	list_reagents = list(/datum/reagent/consumable/nutriment = NUTRITION_QUARTER_MEAL)
	w_class = WEIGHT_CLASS_TINY
	tastes = list("overwhelming bitterness, wood and stinging" = 1)
	faretype = FARE_IMPOVERISHED
	eat_effect = null
	rotprocess = null
	foodtype = GROSS

/obj/item/reagent_containers/food/snacks/mix_sbiten
	name = "Sbiten honey mix"
	desc = "a brick of crystallized honey, infused with spices for extra comfort"
	icon = 'modular/Neu_teas_and_brews/icons/obj/tea_mixes.dmi'
	icon_state = "sbiten_brick"
	list_reagents = list(/datum/reagent/consumable/nutriment = NUTRITION_HALF_MEAL)
	w_class = WEIGHT_CLASS_TINY
	tastes = list("overwhelming bitterness, wood and stinging" = 1)
	faretype = FARE_FINE //because its a yammy honey
	eat_effect = null
	rotprocess = null
	foodtype = SUGAR
