/obj/item/fishing
	name = "fishing tackle"
	icon = 'icons/roguetown/items/fishing.dmi'
	icon_state = "twinereel"
	w_class = WEIGHT_CLASS_TINY
	dropshrink = 1
	var/attachtype

/obj/item/fishing/reel
	attachtype = "reel"

/obj/item/fishing/reel/twine
	name = "twine fishing line"
	desc = "A simple fishing line made out of woven fibers. Cheap, but breaks easily."

/obj/item/fishing/reel/leather
	name = "leather fishing line"
	desc = "A fishing line made out of leather. Far stronger than twine, but its visibility makes fish more wary."
	icon_state = "leatherreel"

/obj/item/fishing/reel/silk
	name = "silk fishing line"
	desc = "A fishing line made out of woven silk. Strong and thin, it's a common choice among seasoned fisherman."
	icon_state = "silkreel"

/obj/item/fishing/reel/deluxe
	name = "deluxe fishing line"
	desc = "Extremely sought after by seasoned fisherman, this fishing line was blessed by Abyssorians in their underwater temples. A perfect fishing line, if not for the cost."
	icon_state = "deluxereel"
