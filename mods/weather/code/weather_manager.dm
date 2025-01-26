///Менеджер/контроллер управляет всей погодой что привязана к нему
/obj/weather_manager
	mouse_opacity = MOUSE_OPACITY_UNCLICKABLE
	var/list/weather_turfs_types = list()
	var/list/connected_weather_turfs = list()
	//Время смены
	var/change_time_result
	var/blowout_time_result
	var/last_change_time
	var/last_blowout_time
	var/list/stages = list(

	)
	var/current_stage
	//Выброс
	var/can_blowout = FALSE
	//Игрокам в зоне выброса сообщают о нём.
	var/must_message_about_blowout = TRUE
	var/blowout_change_stage
	var/delay_between_message_and_blowout
	var/list/blowout_prepare_messages = list()
	var/list/blowout_messages = list()

/obj/weather_manager/Initialize()
	.=..()
	var/area/my_area = get_area(src)
	var/managers_here = 0
	for(var/turf/picked_turf in my_area)
		if(locate(/obj/weather_manager) in picked_turf)
			managers_here++
	if(managers_here > 1)
		qdel(src)
		return //В нашей зоне уже есть контроллер, второму тут не место.
	if(!LAZYLEN(weather_turfs_types)) //Если нам нечего спавнить - всем спасибо, все свободны
		qdel(src)
		return
	//Сам спавн
	calculate_change_time()
	calculate_blowout_time()
	var/list/all_turfs = get_area_turfs(get_area(src))
	for(var/turf/picked_turf in all_turfs)
		var/spawn_type = pick(weather_turfs_types)
		var/obj/weather/spawned_weather = new spawn_type(picked_turf)
		LAZYADD(connected_weather_turfs, spawned_weather)
	last_change_time = world.time
	last_blowout_time = world.time
	LAZYADD(SSweather.weather_managers_in_world, src)
	START_PROCESSING(SSweather,src)

/obj/weather_manager/Process()
	..()
	if(world.time - last_change_time >= change_time_result)
		change_stage()
	if(can_blowout && world.time - last_blowout_time >= blowout_time_result)
		start_blowout()

/obj/weather_manager/proc/change_stage()
	set waitfor = FALSE
	set background = TRUE
	var/need_change = FALSE
	last_change_time = world.time
	for(var/mob/living/carbon/human/picked_human in GLOB.living_players)
		if(get_z(picked_human) == get_z(src))
			need_change = TRUE
			break
	if(!need_change)
		return FALSE
	for(var/obj/weather/connected_weather in connected_weather_turfs)
		connected_weather.update()
	calculate_change_time()
	return TRUE

/obj/weather_manager/proc/start_blowout()
	set waitfor = FALSE
	set background = TRUE
	var/need_blowout = FALSE
	calculate_blowout_message_delay_time()
	report_progress("DEBUG ANOM: Начинается выброс. Стадия - подготовка.")
	STOP_PROCESSING(SSweather, src)
	prepare_to_blowout()
	for(var/mob/living/carbon/human/picked_human in GLOB.living_players)
		if(get_z(picked_human) == get_z(src))
			need_blowout = TRUE
			if(must_message_about_blowout)
				message_about_blowout_prepare(picked_human)
	if(!need_blowout)
		report_progress("DEBUG ANOM: Должен был случиться выброс, но нет игроков на Z уровне погоды. Отмена.")
		calculate_blowout_time()
		last_blowout_time = world.time
		return FALSE
	for(var/obj/weather/connected_weather in connected_weather_turfs)
		if(connected_weather.blowout_status)
			change_stage(connected_weather.blowout_status, FALSE, FALSE)
	sleep(delay_between_message_and_blowout)
	report_progress("DEBUG ANOM: Начинается выброс. Стадия - начало.")
	for(var/mob/living/carbon/human/picked_human in GLOB.living_players)
		if(get_z(picked_human) == get_z(src))
			if(must_message_about_blowout)
				message_about_blowout(picked_human)
	return TRUE

/obj/weather_manager/proc/message_about_blowout_prepare(mob/living/input_mob)
	if(LAZYLEN(blowout_prepare_messages))
		to_chat(input_mob, pick(blowout_prepare_messages))

/obj/weather_manager/proc/message_about_blowout(mob/living/input_mob)
	if(LAZYLEN(blowout_messages))
		to_chat(input_mob, SPAN_DANGER(pick(blowout_messages)))

/obj/weather_manager/proc/prepare_to_blowout()
	return

/obj/weather_manager/proc/stop_blowout()
	if(!is_processing)
		report_progress("DEBUG: Выброс окончен.")
		START_PROCESSING(SSweather, src)

/obj/weather_manager/proc/regenerate_anomalies_on_planet() //Выполняет перереспавн всех аномалий которые были заспавнены стандартным генератором на планете
	set waitfor = FALSE
	var/obj/overmap/visitable/sector/exoplanet/my_planet = map_sectors["[get_z(src)]"]
	my_planet.full_clear_from_anomalies()
	my_planet.generate_big_anomaly_artefacts()

/obj/weather_manager/proc/calculate_change_time()
	change_time_result = rand(8, 20 MINUTES)

/obj/weather_manager/proc/calculate_blowout_time()
	blowout_time_result = rand(60 MINUTES, 85 MINUTES)

/obj/weather_manager/proc/calculate_blowout_message_delay_time()
	delay_between_message_and_blowout = rand(2 MINUTES, 4 MINUTES)

/obj/weather_manager/shuttle_land_on()
	move_to_safe_turf(src)

/proc/move_to_safe_turf(obj/input_obj)
	var/list/possible_turfs = get_area_turfs(get_area(input_obj))
	var/turf/my_turf = get_turf(input_obj)
	//Сдвинем турф минимум на 15 турфов подальше. Как ещё защитить его от посадки на него шаттла - не знаю.
	for(var/turf/picked_turf in possible_turfs)
		if(get_dist(picked_turf,my_turf) <= 15)
			LAZYREMOVE(possible_turfs,picked_turf)
	input_obj.forceMove(pick(possible_turfs))
