/obj/item/roguemachine/navigator/smuggler
	name = "battered navigator"
	desc = "A crudely repaired navigator bolted to the hull of a leaky boat. It stinks of brine and contraband."
	motto = "NAVIGA??R - ...a smuggler never tells."
	fixed_tax = 0.7

/obj/item/roguemachine/navigator/smuggler/examine()
	. = ..()
	. += span_notice("The rates here are disastrous. Having a facilitator from the bathhouse nearby might improve them.")
	if(fixed_tax <= 0.5)
		. += span_notice("A facilitator is present. Current handler's fee: [fixed_tax * 100]%.")
	else
		. += span_warning("No facilitator present. Current handler's fee: [fixed_tax * 100]%.")

/obj/item/roguemachine/navigator/smuggler/process()
	var/bath_nearby = FALSE
	for(var/mob/living/carbon/human/H in range(7, src))
		if(H.stat != DEAD && (H.job in GLOB.bathhouse_positions))
			bath_nearby = TRUE
			break
	fixed_tax = bath_nearby ? 0.5 : 0.7
	return ..()
