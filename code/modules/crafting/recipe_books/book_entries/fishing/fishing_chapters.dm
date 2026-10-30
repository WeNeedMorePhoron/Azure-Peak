/datum/book_entry/fishing
	abstract_type = /datum/book_entry/fishing
	category = null

/datum/book_entry/fishing/basics
	name = "01. Introduction and Basic Mechanics"

/datum/book_entry/fishing/basics/inner_book_html(mob/user)
	return {"
		<div>
		<h3>How to Fish</h3>
		<p>To fish, cast with a fishing rod that is equipped with a hook, a fishing line and preferably a piece of bait on a body of water. Once the bobber moves, you can left click to start the fishing minigame.</p>
		<p>Not using any bait greatly reduces the chance of fishing anything worthy.</p>

		<h3>Bait, Tackles and Tools</h3>
		<p>Bait quality multiplies the weight of higher value fishes.</p>
		<ul>
			<li><b>Passable</b>: worm, slice of cheese.</li>
			<li><b>Good</b>: grub, leech, leech tick, slice of aged cheese.</li>
			<li><b>Excellent</b>: cerulean aril, bloated leech tick.</li>
		</ul>
		<p>Certain fishes are herbivorous or carnivorous, they are more likely to bite onto types of bait they like. Carnivorous bait includes worms, grubs, leeches and leech ticks. Herbivorous bait includes fresh vegetables and fruit.</p>
		<p>Picky fishes will not bite onto passable bait at all unless it is one of their favourites. Every fish also has favourite baits that make it easier to catch, and disliked baits that make it harder.</p>
		<p>Certain fishes are also wary, and a cloaked line helps you catch them.</p>

		<h3>Sources and Stocks</h3>
		<p>Fishing sources are counted per region and water type. For example, murky water and deep water have different distributions of fishes, and the north coast and south coast deepwater share different pools. Moving around semi frequently is a good idea to maximize the value of your catches.</p>

		<h3>Other Ways to Fish</h3>
		<ul>
			<li>The fishing cage almost exclusively catches crustaceans, and takes a while to catch one.</li>
			<li>The fishing spear does not use any bait or minigame, but will only catch as effectively as an unbaited rod.</li>
		</ul>

		<h3>Trivia</h3>
		<ul>
			<li>Cautious Fishers are less likely to accidentally catch a hostile mob.</li>
		</ul>
		</div>
	"}
