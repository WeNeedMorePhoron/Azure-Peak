/datum/book_entry/cuisine
	abstract_type = /datum/book_entry/cuisine
	category = "Cuisines"
	var/cuisine_flag = NONE
	var/blurb

/datum/book_entry/cuisine/proc/fare_label(fare)
	switch(fare)
		if(FARE_FINE)
			return "Fine"
		if(FARE_LAVISH)
			return "Lavish"
	return null

/datum/book_entry/cuisine/proc/quality_label(quality)
	switch(quality)
		if(DRINK_NICE)
			return "Nice"
		if(DRINK_GOOD)
			return "Good"
		if(DRINK_VERYGOOD)
			return "Very Good"
		if(DRINK_FANTASTIC)
			return "Fantastic"
	return null

/datum/book_entry/cuisine/inner_book_html(mob/user)
	var/html = "<div>"
	if(blurb)
		html += "<p><i>[blurb]</i></p>"

	var/list/dishes = list()
	for(var/obj/item/reagent_containers/food/snacks/S as anything in subtypesof(/obj/item/reagent_containers/food/snacks))
		if(!(initial(S.cuisine) & cuisine_flag))
			continue
		if(initial(S.faretype) < FAVORITE_FOOD_MINFARE)
			continue
		var/dname = initial(S.name)
		if(!dname || dishes[dname])
			continue
		dishes[dname] = S
	sortTim(dishes, GLOBAL_PROC_REF(cmp_text_asc))

	html += "<h3>Dishes</h3>"
	if(length(dishes))
		html += "<ul>"
		for(var/dname in dishes)
			var/obj/item/reagent_containers/food/snacks/S = dishes[dname]
			var/key = SScooking?.get_producer_key(S)
			var/label = key ? "<a href='byond://?src=[REF(get_recipe_wiki())];view_recipe=[key]'>[dname]</a>" : dname
			var/fare = fare_label(initial(S.faretype))
			html += "<li>[label][fare ? " ([fare])" : ""]</li>"
		html += "</ul>"
	else
		html += "<p>No dish of note.</p>"

	var/list/drinks = list()
	for(var/datum/reagent/consumable/R as anything in subtypesof(/datum/reagent/consumable))
		if(!(initial(R.cuisine) & cuisine_flag))
			continue
		if(initial(R.quality) < FAVORITE_DRINK_MINQUALITY)
			continue
		var/rname = initial(R.name)
		if(!rname || drinks[rname])
			continue
		drinks[rname] = R
	sortTim(drinks, GLOBAL_PROC_REF(cmp_text_asc))

	html += "<h3>Drinks</h3>"
	if(length(drinks))
		html += "<ul>"
		for(var/rname in drinks)
			var/datum/reagent/consumable/R = drinks[rname]
			var/quality = quality_label(initial(R.quality))
			html += "<li>[rname][quality ? " ([quality])" : ""]</li>"
		html += "</ul>"
	else
		html += "<p>No drink of note.</p>"

	html += "<p><i>Only fine fare or better, and nice drinks or better, can delight a lover of this cuisine. Humbler foods may still belong to it in spirit.</i></p>"
	html += "</div>"
	return html

/datum/book_entry/cuisine/north_imperial
	name = "North Imperial"
	book_priority = 7
	cuisine_flag = CUISINE_NORTH_IMPERIAL
	blurb = "A broad category for the cuisine that originated from the old Celestial Empire's heartland, modern dae Grenzelhoft. It is hearty and delicious, full of breads, pies, sausage. Though seafood are eaten, it is not as prominent and does not feature in its dishes list. Ale and Beer are the main source of drinks, with occasional spirits added in. Famous dishes includes the Grenzelbun, Squire's Delight, Nitzel and Schnitzel."

/datum/book_entry/cuisine/south_imperial
	name = "South Imperial"
	book_priority = 6
	cuisine_flag = CUISINE_SOUTH_IMPERIAL
	blurb = "A grandiose name for the cuisine that developed in Azuria during its heyday, when snow elves still ruled from the mountain valley of Tarichea. It incorporated elements of North Imperial food - namely the hearty staple of breads, tomatoplate and bookbreads - and deliberately excludes pies (excluding crab and fish pies), which are viewed as food suitable for campaigning but not for a noble tongue. Compared to its northern counterpart, it includes practically all seafood dishes, specifically fish pies (and no other pies) and anything with fish as originally Azurean. It includes elements of wood elven cuisine, incorporated as a native and uniquely Azurian aspect, and Tarichean and Azurian lords made sure to dine on them conspicuously to show that they are both capable of imitation and innovation - honey, mead, slow roasted fishes, game, rosa tea - all elements of the Rosawoodian diet that the nobles and burghers of this land eat with pride."

/datum/book_entry/cuisine/otavais
	name = "Otavais"
	book_priority = 5
	cuisine_flag = CUISINE_OTAVAIS
	blurb = "Otava and its predecessor were never under the yoke of the Celestial Empire, and were boosted with a bountiful coastline and diverse climate. So their cuisine has a little bit of everything, and is known for its richness. A bit of signature pies, a bit of signature bread, cheesecake (though not honeycake, viewed as too decadent and Ranesheni), fruit cakes, and some but not all good seafood."

/datum/book_entry/cuisine/northern
	name = "Northern"
	book_priority = 4
	cuisine_flag = CUISINE_NORTHERN
	blurb = "Hammerhold and Gronn share a somewhat similar cuisine and part of their culture. The hardy Gronnmen subsides on the bounty of the land, whether it is fish or games, farm what little they can and trade for the rest, while Hammerhold is known for its pretzels and handpies and of course, world-famous alcohol. Grains find few purchase up north - except for potatoes that can grow even in the harsh northern land."

/datum/book_entry/cuisine/etruscan
	name = "Etruscan"
	book_priority = 3
	cuisine_flag = CUISINE_ETRUSCAN
	blurb = "With access to the abundance of the sea, spice trade and diverse cultural contact, the Etruscans developed their own unique cuisine and staples - based on noodles, rice and tomatoplates, with some unique, fancier breads - though nearly all upper class dishes are based on the aforementioned three staples. Rice plates are overwhelmingly seafood based instead of land food based."

/datum/book_entry/cuisine/southeastern
	name = "Southeastern"
	book_priority = 2
	cuisine_flag = CUISINE_SOUTHEASTERN
	blurb = "The climate of southeastern Psydonia leads to abundant rainfall, and so the Lingyuese and Kazengunese share a somewhat similar cuisine based on rice cultivation. The bountiful seas provide for plenty of seafood, and so both cuisines find themselves serving up delicious seafood and rice based meals aplenty. Wheat products are absent, and so is dairy."

/datum/book_entry/cuisine/ranesheni
	name = "Ranesheni"
	book_priority = 1
	cuisine_flag = CUISINE_RANESHENI
	blurb = "Raneshen is a realm of four realms itself, with diverse cuisine. Well known Ranesheni cuisine are dominated by its component realm of Mücevkabher and Chorodiaki. Their cuisine is well known for the heavy usage of spices, braided bread, thick and dark coffee, and famous honeycake. The Naledian, though far away and split by an entire massive ocean, is known for some similarity in their cuisine due to the shared climate."
