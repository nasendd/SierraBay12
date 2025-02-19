/obj/item/device/scanner/xenobio
	name = "xenolife scanner"
	desc = "Multipurpose organic life scanner. With spectral breath analyzer you can find out what snacks Ian had! Or what gasses alien life breathes."
	icon = 'icons/obj/tools/xenolife_scanner.dmi'
	icon_state = "xenobio"
	item_state = "analyzer"
	scan_sound = 'sound/effects/scanbeep.ogg'
	printout_color = "#f3e6ff"
	origin_tech = list(TECH_MAGNET = 1, TECH_BIO = 1)
	var/new_species = FALSE
	var/species

	var/list/valid_targets = list(
		/mob/living/carbon/human,
		/mob/living/simple_animal,
		/mob/living/carbon/slime,
	)

/obj/item/device/scanner/xenobio/is_valid_scan_target(atom/O)
	if(is_type_in_list(O, valid_targets))
		return TRUE
	if(istype(O, /obj/machinery/stasis_cage))
		var/obj/machinery/stasis_cage/cagie = O
		return !!cagie.contained
	return FALSE

/obj/item/device/scanner/xenobio/scan(mob/O, mob/user)
	scan_title = O.name
	scan_data = xenobio_scan_results(O)
	user.show_message(SPAN_NOTICE(scan_data))
//[SIERRA-EDIT] - MODPACK_RND
/obj/item/device/scanner/xenobio/proc/list_gases(gases)
	RETURN_TYPE(/list)
	. = list()
	for(var/g in gases)
		. += "[gas_data.name[g]] ([gases[g]]%)"
	return english_list(.)

/obj/item/device/scanner/xenobio/proc/xenobio_scan_results(mob/target)
//[/SIERRA-EDIT] - MODPACK_RND
	. = list()
	if(istype(target, /obj/machinery/stasis_cage))
		var/obj/machinery/stasis_cage/cagie = target
		target = cagie.contained
	if(istype(target, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = target
		. += "Data for [H]:"
		. += "Species:\t[H.species]"
		if(H.species.breath_type)
			. += "Breathes:\t[gas_data.name[H.species.breath_type]]"
		if(H.species.exhale_type)
			. += "Exhales:\t[gas_data.name[H.species.exhale_type]]"
		. += "Known toxins:\t[english_list(H.species.poison_types)]"
		. += "Temperature comfort zone:\t[H.species.cold_discomfort_level] K to [H.species.heat_discomfort_level] K"
		. += "Pressure comfort zone:\t[H.species.warning_low_pressure] kPa to [H.species.warning_high_pressure] kPa"
	else if(istype(target, /mob/living/simple_animal))
		var/mob/living/simple_animal/A = target
		. += "Data for [A]:"
		. += "Species:\t[initial(A.name)]"
		if(A.min_gas)
			. += "Breathes:\t[list_gases(A.min_gas)]"
		if(A.max_gas)
			. += "Known toxins:\t[list_gases(A.max_gas)]"
		if(A.minbodytemp && A.maxbodytemp)
			. += "Temperature comfort zone:\t[A.minbodytemp] K to [A.maxbodytemp] K"
		species = A.type
		var/area/map = locate(/area/overmap)
		for(var/obj/overmap/visitable/sector/exoplanet/P in map)
			if((A in P.animals) || is_type_in_list(A, P.repopulate_types))
				GLOB.stat_fauna_scanned |= "[P.name]-[A.type]"
				. += "New xenofauna species discovered!"
			//[SIERRA-ADD] - MODPACK_RND
				new_species = TRUE
			//[/SIERRA-ADD] - MODPACK_RND
				break
	else if(istype(target, /mob/living/carbon/slime))
		var/mob/living/carbon/slime/T = target
		. += "Slime scan result for \the [T]:"
		. += "[T.colour] [T.is_adult ? "adult" : "baby"] slime"
		. += "Nutrition:\t[T.nutrition]/[T.get_max_nutrition()]"
		if(T.nutrition < T.get_starve_nutrition())
			. += SPAN_CLASS("alert", "Warning:\tthe slime is starving!")
		else if (T.nutrition < T.get_hunger_nutrition())
			. += SPAN_WARNING("Warning:\tthe slime is hungry.")
		. += "Electric charge strength:\t[T.powerlevel]"
		. += "Health:\t[round((T.health * 100) / T.maxHealth)]%"

		var/list/mutations = T.GetMutations()

		if(!length(mutations))
			. += "This slime will never mutate."
		else
			var/list/mutationChances = list()
			for(var/i in mutations)
				if(i == T.colour)
					continue
				if(mutationChances[i])
					mutationChances[i] += T.mutation_chance / length(mutations)
				else
					mutationChances[i] = T.mutation_chance / length(mutations)

			var/list/mutationTexts = list("[T.colour] ([100 - T.mutation_chance]%)")
			for(var/i in mutationChances)
				mutationTexts += "[i] ([mutationChances[i]]%)"

			. += "Possible colours on splitting:\t[english_list(mutationTexts)]"

		if (T.cores > 1)
			. += "Anomalous slime core amount detected."
		. += "Growth progress:\t[T.amount_grown]/10."
	else
		. += "Incompatible life form, analysis failed."

	. = jointext(., "<br>")

//[SIERRA-ADD] - MODPACK_RND
/obj/item/device/scanner/xenobio/print_report(mob/living/user)
	if(!scan_data)
		to_chat(user, "There is no scan data to print.")
		return
	var/obj/item/paper/xenofauna_report/P = new(get_turf(src), scan_data, "paper - [scan_title]")
	if(new_species)
		P.new_species = TRUE
	if(species)
		P.species = species
	if(printout_color)
		P.color = printout_color
	user.put_in_hands(P)
	user.visible_message("\The [src] spits out a piece of paper.")
//[/SIERRA-ADD] - MODPACK_RND
