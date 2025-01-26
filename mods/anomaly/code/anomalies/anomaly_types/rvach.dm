//Рвач просто порвёт конечности
#define RVACH_DAMAGE_EFFECT 2
//Рвач гибнет, админская штука
#define RVACH_DESTROY_EFFECT 3

/obj/anomaly/rvach
	name = "Refractions of light"
	anomaly_tag = "Rvach"
	with_sound = TRUE
	sound_type = 'mods/anomaly/sounds/rvach_activation.ogg'
	static_sound_type = 'mods/anomaly/sounds/gravi_idle.ogg'
	idle_effect_type = "rvach_idle"
	activation_effect_type = "gravy_anomaly_down"
	detection_icon_state = "hot_anomaly"
	can_born_artefacts = TRUE
	weight_sensity = ITEM_SIZE_LARGE
	///Сколько длится первая фаза рвача(всасывание)
	effect_time = 3.5 SECONDS
	effect_type = LONG_ANOMALY_EFFECT
	effect_power = RVACH_DAMAGE_EFFECT
	cooldown_time = 25 SECONDS
	iniciators = list(
		/mob/living,
		/obj/item
	)
	artefacts = list(
		/obj/item/artefact/gravi = 1,
		/obj/item/artefact/flyer = 2
	)
	artefact_spawn_chance = 20
	detection_skill_req = SKILL_EXPERIENCED

//Аномалия выполняет своё финальное воздействие на все обьекты что оказались в её центре
/obj/anomaly/rvach/proc/get_end_effect_by_anomaly(target)
///Рвач отрывает конечности, гибает обычные вещи с пола
	//Если рвач мощный
	if(effect_power == RVACH_DESTROY_EFFECT)
		if(istype(target, /mob/living))
			var/mob/living/victim = target
			SSanom.add_last_gibbed(target, "Рвач")
			var/list/result_effects = calculate_artefact_reaction(target, "Гиб Рвача")
			if(result_effects)
				if(result_effects.Find("Защищает от гиба рвачом"))
					return
			victim.gib()
			playsound(src, 'mods/anomaly/sounds/rvach_gibbed.ogg', 100, FALSE  )

	//Если рвач обычный
	else if(effect_power == RVACH_DAMAGE_EFFECT)
		SSanom.add_last_attack(target, "Рвач")
		var/list/result_effects = calculate_artefact_reaction(target, "Гиб Рвача")
		if(result_effects)
			if(result_effects.Find("Защищает от гиба рвачом"))
				return
		if(istype(target, /mob/living/carbon/human))
			var/mob/living/carbon/human/victim = target
			if(!victim.incapacitated(INCAPACITATION_UNRESISTING) == TRUE) //Убедимся что наш чувак в сознании
				//Персонаж может вырваться из аномали, деж если он аутист
				if(victim.skill_check(SKILL_HAULING, SKILL_MASTER))
					if(prob(7 * victim.get_skill_value(SKILL_HAULING)))
						victim.Weaken(10)
						return

			//Создаём список органов, которые мы МОЖЕМ оторвать
			var/list/list_of_organs_types = list(
				/obj/item/organ/external/arm,
				/obj/item/organ/external/arm/right,
				/obj/item/organ/external/leg,
				/obj/item/organ/external/leg/right
			)
			var/obj/item/organ/external/to_destroy = pick(list_of_organs_types)
			for(var/obj/item/organ/external/E in victim.organs)
				if(E.type == to_destroy)
					E.take_external_damage(500)
					playsound(src, 'mods/anomaly/sounds/rvach_gibbed.ogg', 100, FALSE  )
		else if(istype(target, /mob/living))
			var/mob/living/victim = target
			SSanom.add_last_gibbed(target, "Рвач")
			victim.gib()
			playsound(src, 'mods/anomaly/sounds/rvach_gibbed.ogg', 100, FALSE  )
		else if(istype(target, /obj/item))
			qdel(target)
		else if(istype(target, /obj/structure/mech_wreckage))
			qdel(target)

//Рвач всасывает всех в свой центр
/obj/anomaly/rvach/process_long_effect()
	rvach_pull_around(src, effect_range, STAGE_THREE)
	start_processing_long_effect()


/obj/anomaly/rvach/stop_processing_long_effect()
	addtimer(new Callback(src, PROC_REF(rvach_gib)), 2 SECONDS)


/obj/anomaly/rvach/proc/rvach_gib()
	for(var/atom/movable/target in src.loc)
		get_end_effect_by_anomaly(target)
	//Рвач раскидает всех из себя
	throw_everyone_from_rvach(throw_range)
	//Выполняем стандартные действия функции stop_processing_long_effect()
	stop_long_visual_effect()
	currently_active = FALSE
	start_recharge()

//Рвач раскидывает всё что попадает в зону рвача из себя
/obj/anomaly/rvach/proc/throw_everyone_from_rvach()
	var/list/victims = list()
	var/list/objs = list()
	var/turf/T = get_turf(src)
	//Собираем все обьекты радиусом на 1 больше, чем расположены вспомогательные части рвачика
	get_mobs_and_objs_in_view_fast(T, multititle_parts_range, victims, objs)
	LAZYMERGELIST(victims, objs)
	for(var/atom/movable/detected_atom in victims)
		if((!ismob(detected_atom) && !isitem(detected_atom)) || detected_atom.anchored)
			continue
		var/local_range_of_throw = 1
		if(ismob(detected_atom))
			var/mob/detected_mob = detected_atom
			var/list/result_effects = calculate_artefact_reaction(detected_mob, "Гиб Рвача")
			if(result_effects)
				//Цель не сможет вышвырнуть из рвача, артефакт не даёт
				if(result_effects.Find("Защищает от гиба рвачом"))
					return
				if(result_effects.Find("Усиливает дальность полёта"))
					local_range_of_throw = 5

		var/dis = get_dist(src, detected_atom)
		if(dis < 1)
			detected_atom.throw_at_random(get_turf(src), local_range_of_throw, 5)
		else
			var/throw_dir = get_dir(src, detected_atom)
			var/target_turf = get_ranged_target_turf(detected_atom, throw_dir, local_range_of_throw)
			detected_atom.throw_at(target_turf, local_range_of_throw, 5)


/proc/rvach_pull_around(atom/target, pull_range = 255, pull_power = STAGE_FIVE)
	for(var/atom/A in range(pull_range, target))
		if(ismech(A))
			continue
		A.rvach_anomaly_pull(get_turf(target), pull_power)


/atom/proc/rvach_anomaly_pull(turf/target, current_size)
	return

/obj/item/rvach_anomaly_pull(turf/target, current_size)
	step_towards(src, target)

/mob/living/rvach_anomaly_pull(turf/target, current_size)
	step_towards(src, target)
	Weaken(5)

/mob/living/carbon/human/rvach_anomaly_pull(turf/target, current_size)
	//На не лежачих не воздействуем.
	if(get_turf(target) == get_turf(src))
		Weaken(5)
		return
	if(!lying)
		return
	if(get_turf(target) != get_turf(src))
		step_towards(src, target)
	Weaken(5)

/obj/anomaly/rvach/Crossed(atom/movable/O)
	if(currently_active)
		return
	if(currently_charging_after_activation)
		return
	if(can_be_activated(O) == "too small weight")
		O.forceMove(get_turf(src))
	else if(can_be_activated(O))
		activate_anomaly()
		step_towards(O, src)
		if(isliving(O))
			var/mob/living/detected_living = O
			detected_living.Weaken(5)

//Человек пытается выбраться из рвача FALSE - не даём вылезти, TRUE - даём
/obj/anomaly/rvach/Uncross(O)
	if(currently_charging_after_activation || !currently_active)
		return TRUE
	if(!ishuman(O))
		return TRUE
	if(do_after(O, 2 SECONDS, src, DO_PUBLIC_UNIQUE | DO_BAR_OVER_USER, INCAPACITATION_NONE))
		var/mob/living/jumper = O
		jumper.forceMove(get_ranged_target_turf(jumper, jumper.dir, 1))
		//После того как игрок выпрыгнул из рвача, тот может опять его всосать если он вылез слишком рано.
		//Но Игрок смотрящий на вылезшего игрока может выхватить его, если будет достаточно близко когда наша
		//Жертва выпрыгнет
		var/turf/helper_turf = get_ranged_target_turf(jumper, jumper.dir, 1)
		for(var/mob/living/carbon/human/helper in helper_turf)
			if(helper.a_intent == I_HELP && turn(jumper.dir, 180) == helper.dir && helper.incapacitated(INCAPACITATION_UNRESISTING) != TRUE) //Лезущий и помощник должны смотреть друг другу в лицо
				to_chat(jumper, SPAN_GOOD("[helper] выхватывает вас за протянутую руку!"))
				to_chat(helper, SPAN_GOOD("Вы дёргаете [jumper] на себя за протянутую руку!"))
				jumper.forceMove(get_ranged_target_turf(jumper, jumper.dir, 1))
				jumper.Weaken(5)
				helper.Weaken(5)
		return TRUE

/obj/anomaly/rvach/handle_human_teamplay(mob/living/carbon/human/target, mob/living/carbon/human/helper)
	visible_message(SPAN_GOOD("[helper] с силой дёргает [target] на себя!"))
	var/turf/target_turf = get_ranged_target_turf(target, get_dir(target, helper), 2)
	if(TurfBlocked(target_turf))
		to_chat(helper, "Чёрт, мне не куда отходить!")
		target.forceMove(get_turf(helper))
		target.Weaken(5)
		helper.Weaken(5)
	else
		target.forceMove(target_turf)
		helper.forceMove(target_turf)
		target.Weaken(5)
		helper.Weaken(5)

/obj/anomaly/rvach/get_detection_icon()
	return "rvach_detection"
