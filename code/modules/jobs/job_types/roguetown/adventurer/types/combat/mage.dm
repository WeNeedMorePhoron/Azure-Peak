/datum/advclass/mage
	name = "Sorcerer"
	tutorial = "You are a learned mage and a scholar, having spent your life studying the arcane and its ways."
	allowed_sexes = list(MALE, FEMALE)
	allowed_races = RACES_ALL_KINDS
	outfit = /datum/outfit/job/roguetown/adventurer/mage
	class_select_category = CLASS_CAT_MAGE
	category_tags = list(CTAG_ADVENTURER, CTAG_COURTAGENT)
	traits_applied = list(TRAIT_MAGEARMOR, TRAIT_ARCYNE_T3, TRAIT_ALCHEMY_EXPERT)
	subclass_stats = list(
		STATKEY_INT = 3,
		STATKEY_PER = 2,
		STATKEY_SPD = 1,
	)
	age_mod = /datum/class_age_mod/adv_mage
	subclass_spellpoints = 14
	subclass_skills = list(
		/datum/skill/combat/staves = SKILL_LEVEL_APPRENTICE,
		/datum/skill/combat/polearms = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/climbing = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/athletics = SKILL_LEVEL_NOVICE,
		/datum/skill/combat/wrestling = SKILL_LEVEL_NOVICE,
		/datum/skill/combat/unarmed = SKILL_LEVEL_NOVICE,
		/datum/skill/misc/reading = SKILL_LEVEL_EXPERT,
		/datum/skill/craft/alchemy = SKILL_LEVEL_APPRENTICE,
		/datum/skill/magic/arcane = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/swimming = SKILL_LEVEL_NOVICE,
	)

/datum/outfit/job/roguetown/adventurer/mage/pre_equip(mob/living/carbon/human/H)
	..()
	to_chat(H, span_warning("You are a learned mage and a scholar, having spent your life studying the arcane and its ways."))
	head = /obj/item/clothing/head/roguetown/roguehood/mage
	shoes = /obj/item/clothing/shoes/roguetown/boots
	pants = /obj/item/clothing/under/roguetown/trou/leather
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson
	armor = /obj/item/clothing/suit/roguetown/shirt/robe/mage
	belt = /obj/item/storage/belt/rogue/leather
	beltr = /obj/item/reagent_containers/glass/bottle/rogue/manapot
	neck = /obj/item/storage/belt/rogue/pouch/coins/poor
	beltl = /obj/item/rogueweapon/huntingknife
	backl = /obj/item/storage/backpack/rogue/satchel
	backr = /obj/item/rogueweapon/woodstaff
	H.dna.species.soundpack_m = new /datum/voicepack/male/wizard()
	if(H.mind)
		var/spec = list("Sorcerer", "Alchemist") // Much smaller selection with only three swords. You will probably want to upgrade.
		var/spec_choice = input(H, "Choose your specialization.", "WHO AM I?") as anything in spec
		switch(spec_choice)
			if("Sorcerer") //standart adventure mage
				H.mind?.adjust_spellpoints(4) //18, standart
				backpack_contents = list(
					/obj/item/spellbook_unfinished/pre_arcyne = 1,
					/obj/item/roguegem/amethyst = 1,
					/obj/item/chalk = 1
					)
			if("Alchemist") //less points, no book and chalk, but good alchemistry skill with roundstart and folding cauldron it backpack.
				H.adjust_skillrank_up_to(/datum/skill/craft/alchemy, SKILL_LEVEL_JOURNEYMAN, TRUE)
				backl = /obj/item/storage/backpack/rogue/backpack
				backpack_contents = list(
					/obj/item/folding_alchcauldron_stored = 1,
					/obj/item/reagent_containers/glass/bottle = 3,
					/obj/item/reagent_containers/glass/bottle/alchemical = 3,
					/obj/item/recipe_book/alchemy = 1,
					)
	backpack_contents |= list(
		/obj/item/flashlight/flare/torch = 1,
		/obj/item/recipe_book/survival = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
		/obj/item/recipe_book/magic = 1,
		)
	H.cmode_music = 'sound/music/cmode/adventurer/combat_outlander4.ogg'
	switch(H.patron?.type)
		if(/datum/patron/inhumen/zizo)
			H.cmode_music = 'sound/music/combat_heretic.ogg'

/datum/advclass/mage/spellblade
	name = "Spellblade"
	tutorial = "You are skilled in both the arcyne art and the art of the blade. But you are not a master of either nor could you channel your magick in armor."
	outfit = /datum/outfit/job/roguetown/adventurer/spellblade
	traits_applied = list(TRAIT_MAGEARMOR, TRAIT_ARCYNE_T2)
	subclass_stats = list(
		STATKEY_STR = 2,
		STATKEY_INT = 1,
		STATKEY_CON = 1,
		STATKEY_WIL = 1,
	)
	subclass_spellpoints = 12
	subclass_skills = list(
		/datum/skill/misc/climbing = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/swords = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/shields = SKILL_LEVEL_NOVICE,
		/datum/skill/combat/wrestling = SKILL_LEVEL_APPRENTICE,
		/datum/skill/combat/unarmed = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/athletics = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/reading = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/magic/arcane = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/swimming = SKILL_LEVEL_NOVICE,
	)

/datum/outfit/job/roguetown/adventurer/spellblade/pre_equip(mob/living/carbon/human/H)
	..()
	to_chat(H, span_warning("You are skilled in both the arcyne art and the art of the blade. But you are not a master of either nor could you channel your magick in armor."))
	head = /obj/item/clothing/head/roguetown/bucklehat
	shoes = /obj/item/clothing/shoes/roguetown/boots
	pants = /obj/item/clothing/under/roguetown/trou/leather
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson
	gloves = /obj/item/clothing/gloves/roguetown/angle
	belt = /obj/item/storage/belt/rogue/leather
	neck = /obj/item/clothing/neck/roguetown/chaincoif
	backl = /obj/item/storage/backpack/rogue/satchel
	beltl = /obj/item/storage/belt/rogue/pouch/coins/poor
	wrists = /obj/item/clothing/wrists/roguetown/bracers/leather
	backpack_contents = list(/obj/item/flashlight/flare/torch = 1, /obj/item/recipe_book/survival = 1)
	if(H.mind)
		H.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/projectile/airblade)
		H.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/enchant_weapon)
		H.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/conjure_weapon)
	H.cmode_music = 'sound/music/cmode/adventurer/combat_outlander3.ogg'
	if(H.mind)
		var/weapons = list("Longsword", "Falchion & Wooden Shield", "Messer & Wooden Shield", "Hwando") // Much smaller selection with only three swords. You will probably want to upgrade.
		var/weapon_choice = input(H, "Choose your weapon.", "TAKE UP ARMS") as anything in weapons
		switch(weapon_choice)
			if("Longsword")
				beltr = /obj/item/rogueweapon/scabbard/sword
				r_hand = /obj/item/rogueweapon/sword/long
				armor = /obj/item/clothing/suit/roguetown/armor/leather/heavy/coat
			if("Falchion & Wooden Shield")
				beltr = /obj/item/rogueweapon/scabbard/sword
				backr = /obj/item/rogueweapon/shield/wood
				r_hand = /obj/item/rogueweapon/sword/short/falchion
				armor = /obj/item/clothing/suit/roguetown/armor/leather/heavy/coat
				H.adjust_skillrank_up_to(/datum/skill/combat/shields, SKILL_LEVEL_APPRENTICE, TRUE)
			if("Messer & Wooden Shield")
				beltr = /obj/item/rogueweapon/scabbard/sword
				backr = /obj/item/rogueweapon/shield/wood
				r_hand = /obj/item/rogueweapon/sword/short/messer/iron
				armor = /obj/item/clothing/suit/roguetown/armor/leather/heavy/coat
				H.adjust_skillrank_up_to(/datum/skill/combat/shields, SKILL_LEVEL_APPRENTICE, TRUE)
			if("Hwando")
				r_hand = /obj/item/rogueweapon/sword/sabre/mulyeog // Meant to not have the special foreign scabbards.
				beltr = /obj/item/rogueweapon/scabbard/sword
				armor = /obj/item/clothing/suit/roguetown/armor/basiceast
	switch(H.patron?.type)
		if(/datum/patron/inhumen/zizo)
			H.cmode_music = 'sound/music/combat_heretic.ogg'

/datum/advclass/mage/spellblade2
	name = "Spellblade 2"
	tutorial = "A melee warrior who channels arcyne momentum through combat. Build power with your blade, then unleash it."
	outfit = /datum/outfit/job/roguetown/adventurer/spellblade2
	traits_applied = list(TRAIT_MAGEARMOR, TRAIT_ARCYNE_T2)
	subclass_stats = list(
		STATKEY_STR = 2,
		STATKEY_INT = 1,
		STATKEY_CON = 1,
		STATKEY_WIL = 1,
	)
	subclass_spellpoints = 12
	subclass_skills = list(
		/datum/skill/misc/climbing = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/swords = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/shields = SKILL_LEVEL_NOVICE,
		/datum/skill/combat/wrestling = SKILL_LEVEL_APPRENTICE,
		/datum/skill/combat/unarmed = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/athletics = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/reading = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/magic/arcane = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/swimming = SKILL_LEVEL_NOVICE,
	)

/datum/outfit/job/roguetown/adventurer/spellblade2
	var/subclass_selected

/datum/outfit/job/roguetown/adventurer/spellblade2/Topic(href, href_list)
	. = ..()
	if(href_list["subclass"])
		subclass_selected = href_list["subclass"]

/datum/outfit/job/roguetown/adventurer/spellblade2/pre_equip(mob/living/carbon/human/H)
	..()
	to_chat(H, span_warning("A melee warrior who channels arcyne momentum through combat. Build power with your weapon, then unleash it."))
	head = /obj/item/clothing/head/roguetown/bucklehat
	shoes = /obj/item/clothing/shoes/roguetown/boots
	pants = /obj/item/clothing/under/roguetown/trou/leather
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson
	gloves = /obj/item/clothing/gloves/roguetown/angle
	belt = /obj/item/storage/belt/rogue/leather
	neck = /obj/item/clothing/neck/roguetown/chaincoif
	backl = /obj/item/storage/backpack/rogue/satchel
	beltl = /obj/item/storage/belt/rogue/pouch/coins/poor
	wrists = /obj/item/clothing/wrists/roguetown/bracers/leather
	backpack_contents = list(/obj/item/flashlight/flare/torch = 1, /obj/item/recipe_book/survival = 1)

	// --- Subclass selection via HTML UI ---
	subclass_selected = null
	var/selection_html = get_subclass_selection_html(H)
	H << browse(selection_html, "window=spellblade_oath;size=700x800")

	// Wait for player to click a subclass button
	var/timeout = 0
	while(!subclass_selected && timeout < 600)
		sleep(1)
		timeout++
	H << browse(null, "window=spellblade_oath")

	if(!subclass_selected)
		subclass_selected = "blade"

	// Seed momentum status effect
	H.apply_status_effect(/datum/status_effect/buff/arcyne_momentum)

	// --- Apply spells (combat abilities first for HUD ordering) ---
	if(H.mind)
		// Subclass combat abilities — these appear first in the spell HUD
		switch(subclass_selected)
			if("blade")
				H.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/shukuchi)
				H.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/crescent_slash)
				H.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/impale)
				H.mind.AddSpell(new /obj/effect/proc_holder/spell/self/arcyne_riposte)
				H.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/wind_wall)
				H.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/projectile/excalibur)
			if("phalangite")
				H.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/azurean_phalanx)
				H.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/projectile/azurean_javelin)
				H.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/triumphant_arrival)
				H.mind.AddSpell(new /obj/effect/proc_holder/spell/self/advance)
				H.mind.AddSpell(new /obj/effect/proc_holder/spell/self/recall_weapon)
				H.adjust_skillrank_up_to(/datum/skill/combat/polearms, SKILL_LEVEL_JOURNEYMAN, TRUE)

		// Shared utility spells — appear after combat abilities
		H.mind.AddSpell(new /obj/effect/proc_holder/spell/self/arcyne_bind)
		H.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/mending)
		H.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/enchant_weapon)
		H.mind.adjust_spellpoints(2)

	// --- Equipment (no weapon choice) ---
	armor = /obj/item/clothing/suit/roguetown/armor/leather/heavy/coat
	backr = /obj/item/rogueweapon/shield/wood
	H.adjust_skillrank_up_to(/datum/skill/combat/shields, SKILL_LEVEL_APPRENTICE, TRUE)

	switch(subclass_selected)
		if("blade")
			beltr = /obj/item/rogueweapon/scabbard/sword
			r_hand = /obj/item/rogueweapon/sword/sabre/mulyeog
		if("phalangite")
			r_hand = /obj/item/rogueweapon/spear

	H.cmode_music = 'sound/music/cmode/adventurer/combat_outlander3.ogg'
	switch(H.patron?.type)
		if(/datum/patron/inhumen/zizo)
			H.cmode_music = 'sound/music/combat_heretic.ogg'

/// Builds the HTML subclass selection page with oath, ability preview, and clickable buttons
/datum/outfit/job/roguetown/adventurer/spellblade2/proc/get_subclass_selection_html(mob/living/carbon/human/H)
	var/grace_line
	var/blade_oath
	var/phalanx_oath

	if(HAS_TRAIT(H, TRAIT_BLACKOAK))
		blade_oath = {"<p><em>I am a blade unto myself.</em></p>
<p><em>The sword is my law, and blood my ink.</em></p>
<p><em>With a hundred cuts I shall carve my own path.</em></p>
<p><em>No grace required — only steel.</em></p>"}
		phalanx_oath = {"<p><em>I am a wall unto myself.</em></p>
<p><em>The spear is my law, and the line my decree.</em></p>
<p><em>With a hundred thrusts I shall break what stands before me.</em></p>
<p><em>No grace required — only will.</em></p>"}
	else
		if(istype(H.patron, /datum/patron/inhumen/zizo))
			grace_line = "By <b>Her</b> grace"
		else
			grace_line = "By her grace"

		blade_oath = {"<p><em>I am a blade of Azuria.</em></p>
<p><em>The sword is my voice, and war my verse.</em></p>
<p><em>With a hundred cuts I shall cleanse our land of its foes.</em></p>
<p><em>[grace_line], I am unsheathed.</em></p>"}
		phalanx_oath = {"<p><em>I am a shield of Azuria.</em></p>
<p><em>The spear is my reach, and duty my anchor.</em></p>
<p><em>With a hundred thrusts I shall hold our foe at bay.</em></p>
<p><em>[grace_line], I stand unbroken.</em></p>"}

	var/html = {"<!DOCTYPE html>
<html>
<head>
<style>
body {
	background-color: #1a1410;
	color: #d4c4a0;
	font-family: Georgia, 'Times New Roman', serif;
	margin: 0;
	padding: 20px;
}
.oath-container {
	max-width: 660px;
	margin: 0 auto;
	text-align: center;
}
h2 {
	color: #c9a96e;
	font-size: 20px;
	letter-spacing: 3px;
	text-transform: uppercase;
	border-bottom: 1px solid #8b7355;
	padding-bottom: 10px;
	margin-bottom: 25px;
}
.columns {
	display: flex;
	gap: 20px;
	margin-bottom: 20px;
}
.column {
	flex: 1;
	background: linear-gradient(135deg, #2a2015 0%, #1a1410 50%, #2a2015 100%);
	border: 2px solid #8b7355;
	border-radius: 4px;
	padding: 20px;
	box-shadow: 0 0 15px rgba(139, 115, 85, 0.2);
}
.column h3 {
	color: #a08050;
	font-size: 15px;
	letter-spacing: 2px;
	margin: 0 0 15px 0;
}
.oath-text p {
	font-size: 12px;
	line-height: 1.7;
	margin: 3px 0;
}
.oath-text em {
	color: #e0d0b0;
}
.abilities {
	text-align: left;
	border-top: 1px solid #5a4a30;
	padding-top: 12px;
	margin-top: 15px;
}
.abilities h4 {
	color: #a08050;
	font-size: 11px;
	letter-spacing: 1px;
	margin: 0 0 8px 0;
	text-transform: uppercase;
	text-align: center;
}
.abilities ul {
	list-style: none;
	padding: 0;
	margin: 0;
}
.abilities li {
	font-size: 11px;
	line-height: 1.5;
	margin: 5px 0;
	color: #b0a080;
}
.abilities li b {
	color: #d4c4a0;
}
.weapon-info {
	text-align: center;
	font-size: 12px;
	color: #c9a96e;
	margin-top: 12px;
	padding-top: 8px;
	border-top: 1px solid #5a4a30;
	font-style: italic;
}
a.choose-btn {
	display: block;
	margin-top: 15px;
	padding: 10px 15px;
	background: #3a2a15;
	border: 1px solid #8b7355;
	border-radius: 3px;
	color: #c9a96e;
	text-decoration: none;
	font-family: Georgia, serif;
	font-size: 13px;
	letter-spacing: 1px;
	text-align: center;
}
a.choose-btn:hover {
	background: #4a3a20;
	border-color: #c9a96e;
	color: #e0d0b0;
}
.shared-info {
	background: #2a2015;
	border: 1px solid #5a4a30;
	border-radius: 3px;
	padding: 10px 15px;
	text-align: center;
}
.shared-info h4 {
	color: #a08050;
	font-size: 11px;
	letter-spacing: 1px;
	text-transform: uppercase;
	margin: 0 0 5px 0;
}
.shared-info p {
	font-size: 11px;
	color: #b0a080;
	margin: 0;
}
</style>
</head>
<body>
<div class="oath-container">
<h2>The Oath</h2>
<div class="columns">
<div class="column">
<h3>— Blade —</h3>
<div class="oath-text">
[blade_oath]
</div>
<div class="abilities">
<h4>Abilities</h4>
<ul>
<li><b>Issen</b> — Dash through enemies, consuming all momentum for bonus damage.</li>
<li><b>Crescent Slash</b> — Arcyne arc attack. At 3+ momentum, pulls targets toward you.</li>
<li><b>Impale</b> — Strike at the feet. Slows targets with weak foot armor.</li>
<li><b>Arcyne Riposte</b> — Instantly reset your guard cooldown.</li>
<li><b>Wind Wall</b> — Conjure a barrier of arcyne wind.</li>
<li><b>Excalibur</b> — Devastating beam that pierces structures and up to 3 targets. Scales with momentum.</li>
</ul>
</div>
<p class="weapon-info">Sabre & Shield</p>
<a class="choose-btn" href='?src=\ref[src];subclass=blade'>Swear the Blade Oath</a>
</div>
<div class="column">
<h3>— Phalangite —</h3>
<div class="oath-text">
[phalanx_oath]
</div>
<div class="abilities">
<h4>Abilities</h4>
<ul>
<li><b>Azurean Phalanx</b> — 3-tile line thrust that pushes enemies back.</li>
<li><b>Azurean Javelin</b> — Hurl an armor-piercing phantom spear that slows.</li>
<li><b>Triumphant Arrival</b> — Leap to a target from above, knock back others.</li>
<li><b>Recall Weapon</b> — Teleport your bound weapon back to your hand.</li>
<li><b>Advance</b> — Charge forward 3 paces and thrust. Mirror of Phalanx — close distance instead of creating it.</li>
</ul>
</div>
<p class="weapon-info">Spear & Shield</p>
<a class="choose-btn" href='?src=\ref[src];subclass=phalangite'>Swear the Phalangite Oath</a>
</div>
</div>
<div class="shared-info">
<h4>Shared Abilities</h4>
<p>Arcyne Bind · Mending · Enchant Weapon · 2 Whimsy Spell Points</p>
</div>
</div>
</body>
</html>
"}
	return html

/datum/advclass/mage/spellsinger
	name = "Spellsinger"
	tutorial = "You belong to a school of bards renowned for their study of both the arcane and the arts."
	outfit = /datum/outfit/job/roguetown/adventurer/spellsinger
	traits_applied = list(TRAIT_MAGEARMOR, TRAIT_ARCYNE_T2, TRAIT_EMPATH, TRAIT_GOODLOVER)
	subclass_stats = list(
		STATKEY_INT = 2,
		STATKEY_SPD = 2,
		STATKEY_WIL = 1,
	)
	subclass_spellpoints = 14
	subclass_skills = list(
		/datum/skill/misc/climbing = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/music = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/swords = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/wrestling = SKILL_LEVEL_APPRENTICE,
		/datum/skill/combat/unarmed = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/athletics = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/reading = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/magic/arcane = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/swimming = SKILL_LEVEL_NOVICE,
	)
/datum/outfit/job/roguetown/adventurer/spellsinger/pre_equip(mob/living/carbon/human/H)
	..()
	to_chat(H, span_warning("You belong to a school of bards renowned for their study of both the arcane and the arts."))
	head = /obj/item/clothing/head/roguetown/spellcasterhat
	shoes = /obj/item/clothing/shoes/roguetown/boots
	pants = /obj/item/clothing/under/roguetown/trou/leather
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/dark
	gloves = /obj/item/clothing/gloves/roguetown/angle
	belt = /obj/item/storage/belt/rogue/leather
	neck = /obj/item/clothing/neck/roguetown/gorget/steel
	armor = /obj/item/clothing/suit/roguetown/shirt/robe/spellcasterrobe
	backl = /obj/item/storage/backpack/rogue/satchel
	beltl = /obj/item/storage/belt/rogue/pouch/coins/poor
	wrists = /obj/item/clothing/wrists/roguetown/bracers/leather
	beltr = /obj/item/rogueweapon/scabbard/sword
	r_hand = /obj/item/rogueweapon/sword/sabre
	backpack_contents = list(/obj/item/flashlight/flare/torch = 1, /obj/item/recipe_book/survival = 1)
	var/datum/inspiration/I = new /datum/inspiration(H)
	I.grant_inspiration(H, bard_tier = BARD_T2)
	if(H.mind)
		H.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/mockery)
		H.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/enchant_weapon)
		H.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/conjure_weapon)
	H.cmode_music = 'sound/music/cmode/adventurer/combat_outlander3.ogg'
	switch(H.patron?.type)
		if(/datum/patron/inhumen/zizo)
			H.cmode_music = 'sound/music/combat_heretic.ogg'
	if(H.mind)
		var/weapons = list("Harp","Lute","Accordion","Guitar","Hurdy-Gurdy","Viola","Vocal Talisman", "Psyaltery", "Flute")
		var/weapon_choice = tgui_input_list(H, "Choose your instrument.", "TAKE UP ARMS", weapons)
		H.set_blindness(0)
		switch(weapon_choice)
			if("Harp")
				backr = /obj/item/rogue/instrument/harp
			if("Lute")
				backr = /obj/item/rogue/instrument/lute
			if("Accordion")
				backr = /obj/item/rogue/instrument/accord
			if("Guitar")
				backr = /obj/item/rogue/instrument/guitar
			if("Hurdy-Gurdy")
				backr = /obj/item/rogue/instrument/hurdygurdy
			if("Viola")
				backr = /obj/item/rogue/instrument/viola
			if("Vocal Talisman")
				backr = /obj/item/rogue/instrument/vocals
			if("Psyaltery")
				backr = /obj/item/rogue/instrument/psyaltery
			if("Flute")
				backr = /obj/item/rogue/instrument/flute
