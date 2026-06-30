GLOBAL_LIST_INIT(bum_quotes, world.file2list("strings/rt/bumlines.txt"))
GLOBAL_LIST_INIT(bum_aggro, world.file2list("strings/rt/bumaggrolines.txt"))

/mob/living/carbon/human/species/human/northern/bum
	ai_controller = /datum/ai_controller/human_npc
	d_intent = INTENT_PARRY
	faction = list(FACTION_BUMS, FACTION_STATION)
	ambushable = FALSE
	dodgetime = 30

/mob/living/carbon/human/species/human/northern/bum/ambush



/mob/living/carbon/human/species/human/northern/bum/Initialize()
	. = ..()
	//Begin RANDOMISE here
	set_species(pick(NPC_RACES_TYPES))
	gender = pick(MALE, FEMALE)
	dna.species.random_character(src) //Now we just randomise here, MUST be called after both race + gender
	addtimer(CALLBACK(src, PROC_REF(after_creation)), 1 SECONDS)

/mob/living/carbon/human/species/human/northern/bum/after_creation()
	..()
	AddComponent(/datum/component/ai_aggro_system)
	SEND_SIGNAL(src, COMSIG_MOB_MODIFY_AGGRO_LINES, GLOB.bum_aggro, TRUE)
	job = "Beggar"
	ADD_TRAIT(src, TRAIT_NOMOOD, TRAIT_GENERIC)
	ADD_TRAIT(src, TRAIT_NOHUNGER, TRAIT_GENERIC)
	ADD_TRAIT(src, TRAIT_LEECHIMMUNE, INNATE_TRAIT)
	ADD_TRAIT(src, TRAIT_BREADY, TRAIT_GENERIC)
	ADD_TRAIT(src, TRAIT_NPC_EXAMINE, TRAIT_GENERIC)
	random_voice_NPC()
	random_hair_NPC()
	random_eye_color_NPC()
	correct_features_NPC()
	equipOutfit(new /datum/outfit/job/roguetown/bum_npc)
	STALUC = rand(5, 15)
	STACON = rand(4, 10)
	STAWIL = rand(4, 10)
	STASTR = rand(7, 10)
	STAINT = rand(5, 15) //Hilarious

/datum/outfit/job/roguetown/bum_npc/pre_equip(mob/living/carbon/human/H)
	..()
	if(prob(20))
		head = /obj/item/clothing/head/roguetown/knitcap

	if(prob(5))
		beltr = /obj/item/reagent_containers/powder/moondust

	if(prob(10))
		beltl = /obj/item/clothing/mask/cigarette/rollie/cannabis

	if(prob(10))
		cloak = /obj/item/clothing/cloak/raincloak/brown

	if(should_wear_femme_clothes(H))
		armor = /obj/item/clothing/suit/roguetown/shirt/rags
	else if(should_wear_masc_clothes(H))
		armor = null
		pants = /obj/item/clothing/under/roguetown/tights/vagrant

		if(prob(50))
			pants = /obj/item/clothing/under/roguetown/tights/vagrant/l

		shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/vagrant

		if(prob(50))
			shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/vagrant/l

	if(prob(5))
		r_hand = /obj/item/rogueweapon/mace/woodclub
	else
		r_hand = null

	if(prob(5))
		l_hand = /obj/item/rogueweapon/mace/woodclub
	else
		l_hand = null
