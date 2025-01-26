/obj/weather_manager/snow
	weather_turfs_types = list(
		/obj/weather/snow
	)
	stages = list(
		"calm",
		"midle",
		"storm"
	)
	can_blowout = TRUE
	blowout_prepare_messages = list(
		"...всё резко стихло...затишье перед бурей?...не к добру...",
		"Всё стихло, а в небе что-то словно зажигается...это не есть хорошо.",
		"Все чувства, даже шестое, проснулось в тебе...что-то грядёт."
	)
	blowout_messages = list(
		"Вы видете в небе северное сияние и разряды молний в небе! Нужно укрыться!",
		"Вы слышите треск и шорох словно от статического электричества, а по полу расползаются малые электродуги! Нужно укрыться!"
	)

/obj/weather_manager/snow/no_blowout
	can_blowout = FALSE

/obj/weather_manager/snow/change_stage(force_state, monitor = FALSE, sound = FALSE)
	.=..()
	if(!.) //Родитель сказал Баста, смена не нужна
		return FALSE
	var/possible_stages = stages.Copy()
	LAZYREMOVE(possible_stages, current_stage)
	if(!force_state)
		current_stage = pick(possible_stages)
	else
		current_stage = force_state
	if(current_stage == "calm")
		for(var/obj/weather/weather in connected_weather_turfs)
			weather.icon_state = "void"
			weather.play_monitor_effect = FALSE
			weather.play_sound = FALSE
			weather.update()
	else if(current_stage == "midle")
		for(var/obj/weather/weather in connected_weather_turfs)
			weather.icon_state = "light_snow"
			weather.play_monitor_effect = FALSE
			weather.play_sound = FALSE
			weather.update()
	else if(current_stage == "storm")
		for(var/obj/weather/weather in connected_weather_turfs)
			weather.icon_state = "snow_storm"
			weather.play_monitor_effect = TRUE
			weather.play_sound = TRUE
			weather.update()

/obj/weather/snow/flick_weather_icon(state)
	flick("[icon_state]_to_[state]", src)


/obj/weather_manager/snow/prepare_to_blowout()
	.=..()
	if(!.) //Родитель сказал Баста, выброс не нужен
		return
	for(var/obj/weather/weather in connected_weather_turfs)
		weather.icon_state = "void_storm"
		weather.play_monitor_effect = FALSE
		weather.play_sound = FALSE
		weather.update()

/obj/weather_manager/snow/start_blowout()
	.=..()
	if(!.) //Родитель сказал Баста, выброс не нужен
		return
	//Выброс в виде белой мглы медленно перекатывается слева направо
	var/start_x
	var/list/blowout_weather_turfs = connected_weather_turfs.Copy()
	start_x = calculate_smallest_x(blowout_weather_turfs)
	while(LAZYLEN(blowout_weather_turfs))
		for(var/obj/weather/weather in blowout_weather_turfs)
			if(weather.x == start_x)
				weather.icon_state = weather.blowout_icon_state
				weather.play_monitor_effect = FALSE
				weather.play_sound = FALSE
				weather.blowout_status = TRUE
				weather.update()
				weather.blowout_check_turf()
				LAZYREMOVE(blowout_weather_turfs, weather)
		sleep(15)
		start_x++
	sleep(rand(10 SECONDS,20 SECONDS))
	report_progress("DEBUG ANOM: Выброс в процессе. Начинается стадия авроры.")
	for(var/obj/weather/weather in connected_weather_turfs)
		weather.blowout_status = FALSE
		weather.icon_state = "void_storm"
	for(var/obj/structure/aurora/aurora_structure in SSweather.aurora_sctructures)
		if(z == aurora_structure.z)
			aurora_structure.wake_up(rand(5 MINUTES, 9 MINUTES))
	sleep(rand(10 MINUTES, 15 MINUTES))
	report_progress("DEBUG ANOM:: Выброс в процессе. Аврора окончена. Начинается перереспавн аномалий и артефактов.")
	regenerate_anomalies_on_planet()
	stop_blowout()

/obj/weather_manager/snow/stop_blowout()
	for(var/obj/weather/weather in connected_weather_turfs)
		weather.blowout_status = FALSE
		weather.icon_state = initial(weather.icon_state)
	..()


/proc/calculate_smallest_x(list/objects_list)
	var/smallest_x = 10000
	for(var/obj/atom in objects_list)
		if(atom.x < smallest_x)
			smallest_x = atom.x
	return smallest_x

//Эффект снежной вьюги
/obj/weather/snow
	icon_state = "snow_storm"
	icon = 'mods/weather/icons/weather_effects.dmi'
	must_react_at_enter = TRUE
	sound_type = list(
		'mods/weather/sounds/snowstorm.ogg'
	)
	blowout_icon_state = "snow_blowout"




//Эффект снега на экране
/obj/screen/fullscreen/snow_effect
	icon = 'mods/weather/icons/snow_screen.dmi'
	icon_state = "snow"
	layer = BLIND_LAYER
	scale_to_view = TRUE



/obj/weather/snow/add_monitor_effect(mob/living/input_mob)
	input_mob.overlay_fullscreen("snow_monitor", /obj/screen/fullscreen/snow_effect)
	//Логируем пользователя в глобальный список

/obj/weather/snow/remove_monitor_effect(mob/living/input_mob)
	input_mob.clear_fullscreen("snow_monitor")

/obj/weather/snow/react_at_enter_in_blowout(atom/movable/atom)
	if(isliving(atom))
		var/mob/input_mob = atom
		input_mob.emp_act(1)
	return

/obj/weather/snow/react_at_leave_from_blowout(atom/movable/atom)
	return

/obj/weather/snow/blowout_check_turf()
	for(var/mob/living/somebody in get_turf(src))
		somebody.emp_act(1)
