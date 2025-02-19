//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31

/obj/machinery/recharger
	name = "recharger"
	desc = "An all-purpose recharger for a variety of devices."
	icon = 'icons/obj/machines/rechargers.dmi'
	icon_state = "recharger0"
	anchored = TRUE
	idle_power_usage = 4
	active_power_usage = 30 KILOWATTS
	obj_flags = OBJ_FLAG_CAN_TABLE
	var/obj/item/charging = null
	var/list/allowed_devices = list(/obj/item/gun/energy, /obj/item/gun/magnetic/railgun, /obj/item/melee/baton, /obj/item/cell, /obj/item/modular_computer, /obj/item/device/suit_sensor_jammer, /obj/item/stock_parts/computer/battery_module, /obj/item/shield_diffuser, /obj/item/clothing/mask/smokable/ecig, /obj/item/device/radio)
	var/icon_state_charged = "recharger2"
	var/icon_state_charging = "recharger1"
	var/icon_state_idle = "recharger0" //also when unpowered
	var/portable = 1
	construct_state = /singleton/machine_construction/default/panel_closed
	uncreated_component_parts = null

/obj/machinery/recharger/Initialize()
	. = ..()
	RefreshParts()

/obj/machinery/recharger/RefreshParts()
	for(var/obj/item/stock_parts/SP in component_parts)
		if(istype(SP, /obj/item/stock_parts/capacitor))
			active_power_usage *= SP.rating

/obj/machinery/recharger/use_tool(obj/item/G, mob/living/user, list/click_params)
	var/allowed = 0
	for (var/allowed_type in allowed_devices)
		if (istype(G, allowed_type)) allowed = 1

	if(allowed)
		if(charging)
			to_chat(user, SPAN_WARNING("\A [charging] is already charging here."))
			return TRUE
		// Checks to make sure he's not in space doing it, and that the area got proper power.
		if(!powered())
			to_chat(user, SPAN_WARNING("\The [name] blinks red as you try to insert the item!"))
			return TRUE
		if (istype(G, /obj/item/gun/energy))
			var/obj/item/gun/energy/E = G
			if(E.self_recharge || E.disposable)
				to_chat(user, SPAN_NOTICE("You can't find a charging port on \the [E]."))
				return TRUE
		if(!G.get_cell())
			to_chat(user, "This device does not have a battery installed.")
			return TRUE

		if(user.unEquip(G))
			G.forceMove(src)
			charging = G
			update_icon()
			return TRUE

	if (portable && isWrench(G))
		if(charging)
			to_chat(user, SPAN_WARNING("Remove [charging] first!"))
			return TRUE
		anchored = !anchored
		to_chat(user, "You [anchored ? "attached" : "detached"] the recharger.")
		playsound(loc, 'sound/items/Ratchet.ogg', 75, 1)
		return TRUE

	return ..()

/obj/machinery/recharger/physical_attack_hand(mob/user)
	if(charging)
		charging.update_icon()
		user.put_in_hands(charging)
		charging = null
		update_icon()
		return TRUE

/obj/machinery/recharger/Process()
	if(inoperable() || !anchored)
		update_use_power(POWER_USE_OFF)
		icon_state = icon_state_idle
		return

	if(!charging)
		update_use_power(POWER_USE_IDLE)
		icon_state = icon_state_idle
	else
		var/obj/item/cell/C = charging.get_cell()
		if(istype(C))
			if(!C.fully_charged())
				icon_state = icon_state_charging
				C.give(active_power_usage*CELLRATE)
				update_use_power(POWER_USE_ACTIVE)
			else
				icon_state = icon_state_charged
				update_use_power(POWER_USE_IDLE)

/obj/machinery/recharger/emp_act(severity)
	if(inoperable() || !anchored)
		..(severity)
		return
	if(charging)
		var/obj/item/cell/C = charging.get_cell()
		if(istype(C))
			C.emp_act(severity)
	..(severity)

/obj/machinery/recharger/on_update_icon()	//we have an update_icon() in addition to the stuff in process to make it feel a tiny bit snappier.
	if(charging)
		icon_state = icon_state_charging
	else
		icon_state = icon_state_idle

/obj/machinery/recharger/examine(mob/user)
	. = ..()
	if(isnull(charging))
		return

	var/obj/item/cell/C = charging.get_cell()
	if(!isnull(C))
		to_chat(user, "Item's charge at [round(C.percent())]%.")

/obj/machinery/recharger/wallcharger
	name = "wall recharger"
	desc = "A heavy duty wall recharger specialized for energy weaponry."
	icon = 'icons/obj/machines/rechargers.dmi'
	icon_state = "wrecharger0"
	active_power_usage = 50 KILOWATTS	//It's more specialized than the standalone recharger (guns and batons only) so make it more powerful
	allowed_devices = list(/obj/item/gun/magnetic/railgun, /obj/item/gun/energy, /obj/item/melee/baton, /obj/item/device/radio)
	icon_state_charged = "wrecharger2"
	icon_state_charging = "wrecharger1"
	icon_state_idle = "wrecharger0"
	portable = 0
