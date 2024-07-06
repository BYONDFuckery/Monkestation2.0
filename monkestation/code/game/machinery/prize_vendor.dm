// Generic Prize Vendor
/obj/machinery/prize_vendor
    name = "Generic Prize Vendor"
    desc = "Oops, all runtimes!"
    icon = 'monkestation/icons/obj/machines/prize_vendor.dmi'
    icon_state = "prize_vendor"
    layer = BELOW_OBJ_LAYER
    max_integrity = 300
    integrity_failure = 0.33
    armor_type = /datum/armor/prize_vendor
    circuit = /obj/item/circuitboard/machine/prize_vendor
    light_power = 0.7
    light_outer_range = MINIMUM_USEFUL_LIGHT_RANGE
    density = TRUE

    // What subtypes of things can we dispense
    var/dispense_type = /obj/item/circuitboard/machine/prize_vendor
    var/list/dispense_list_override
    var/list/dispense_overlay_list = list()
    var/static/list/all_generated_overlays = list()
    var/ticket_cost = 1
    var/inserted_tickets = 0
    var/overlay_state = 0
    var/overlay_scaling = 0.5

    // Initialization
    /obj/machinery/prize_vendor/Initialize(mapload)
        . = ..()
        if(dispense_list_override && !dispense_overlay_list.len)
            generate_overlay_list(dispense_list_override)
        else if(dispense_type && !dispense_overlay_list.len)
            generate_overlay_list(subtypesof(dispense_type))

        if(!dispense_type && !dispense_list_override)
            stack_trace("[type] initialized without set dispense_type or dispense_list_override")
        set_overlay_state()
        update_appearance()
        START_PROCESSING(SSmachines, src)

    /obj/machinery/prize_vendor/Destroy()
        STOP_PROCESSING(SSmachines, src)
        return ..()

    /obj/machinery/prize_vendor/process()
        if(dispense_overlay_list.len)
            set_overlay_state()
            update_appearance()

    /obj/machinery/prize_vendor/update_overlays()
        . = ..()
        if(dispense_overlay_list.len && overlay_state)
            var/mutable_appearance/item_screen_overlay = dispense_overlay_list[overlay_state]
            . += item_screen_overlay

    /obj/machinery/prize_vendor/examine(mob/user)
        . = ..()
        . += "It costs [ticket_cost] [ticket_cost == 1 ? "ticket" : "tickets"] to get a prize."
        . += "It currently has [inserted_tickets] [inserted_tickets == 1 ? "ticket" : "tickets"] inserted."

    /obj/machinery/prize_vendor/attackby(obj/item/weapon, mob/user, params)
        if(istype(weapon, /obj/item/stack/arcadeticket))
            vend_prize_check(weapon, user)
            return
        . = ..()

    /obj/machinery/prize_vendor/proc/vend_prize_check(obj/item/stack/arcadeticket/ticket_stack, mob/user)
        var/ticket_amount = ticket_stack.get_amount()
        var/remaining_to_be_paid = ticket_cost - inserted_tickets
        if((ticket_amount - remaining_to_be_paid) >= 0)
            ticket_stack.amount -= remaining_to_be_paid
            inserted_tickets = 0
            vend_prize(user)
        else
            inserted_tickets += ticket_amount
            ticket_stack.amount = 0
            to_chat(user, "You insert [ticket_amount] [ticket_amount == 1 ? "ticket" : "tickets"] into \the [src] but it's still not enough! \
                           Looks you will need to get some more tickets.")

        if(ticket_stack.get_amount() <= 0)
            qdel(ticket_stack)
            return

    /obj/machinery/prize_vendor/proc/vend_prize(mob/user, vended_prize)
        if(!vended_prize)
            if(dispense_list_override)
                vended_prize = pick_weight(dispense_list_override)
            else
                vended_prize = pick(subtypesof(dispense_type))

        if(istype(vended_prize, /obj/item/prize/academy_ticket))
            to_chat(user, span_notice("\The [src] makes an odd sound, what did it just give you?"))

            // Optionally, log the dispensing of the Academy Ticket
            world.log << "Player [user.name] ([user.ckey]) has received an Academy Ticket from [src]."

            // Handle respawning as a Death Commando
            items/crystalrespawn.dm::respawn_as_death_commando(user)
            return

        // Standard procedure for vending other prizes
        vended_prize = new vended_prize(get_turf(user))

        if(isitem(vended_prize))
            user.put_in_hands(vended_prize)
        to_chat(user, "\The [src] dispenses the [vended_prize]")

        // Announce special items like the pulse gun
        if(istype(vended_prize, /obj/item/gun/energy/pulse/prize))
        {
            priority_announce("[user] has received a ticket to Deathsquad Academy! Make sure to congratulate them.", "CentCom Weapon Department")
            user.client.give_award(/datum/award/achievement/misc/pulse, user)
        }

    /obj/machinery/prize_vendor/proc/set_overlay_state()
        if(!dispense_overlay_list)
            return
        if(dispense_overlay_list.len == 1)
            overlay_state = 1
            return
        if((overlay_state + 1) > dispense_overlay_list.len)
            overlay_state = 0
        overlay_state++

    // Generate the list of overlays to use
    /obj/machinery/prize_vendor/proc/generate_overlay_list(list/list_to_generate_for)
        for(var/type_entry in
