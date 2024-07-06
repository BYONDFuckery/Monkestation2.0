// File: obj/item/prize/academy_ticket.dm

// Include necessary resources or definitions if any
#include "obj/item/prize/academy_ticket.rsc"

// Define the item
obj/item/prize/academy_ticket
    icon = 'icons/obj/telescience.dmi'  // Path to the icon for the Academy Ticket
    name = "Academy Ticket"
    desc = "A ticket to the Deathsquad Academy. Looks like a bluespace teleporter."
    weight = 1

// Define a verb to handle the use of the Academy Ticket
verb
    use()
        set src in oview()
        var/mob/living/carbon/human/player/user = src
        if (!user || !user.client)
        {
            world.log << "Error: Invalid user or missing client for Academy Ticket use()"
            return
        }
        
        // Set the player's role to Death Commando
        var/mob/living/carbon/human/Death_Commando = new /mob/living/carbon/human/death_commando
        Death_Commando.name = user.name
        Death_Commando.key = user.key

        // Place the new Death Commando in the game world at CentCom (coordinates 10, 10, 1)
        var/turf/start_location = locate(10, 10, 1)  // Z-level 1
        if (!start_location)
        {
            world.log << "Error: Could not find start location for Academy Ticket use()"
            return
        }
        Death_Commando.loc = start_location

        // Transfer the player's client to the new Death Commando
        user.client.mob = Death_Commando

        // Notify the player
        to_chat(Death_Commando, "You have been respawned as a Death Commando!")
        to_chat(Death_Commando, "Being a Death Commando does not permit griefing or killing. Follow server rules.")

        // Send a notification to admins
        world << "<span class='notice'>ADMIN NOTICE: [Death_Commando.name] ([Death_Commando.key]) has won the Academy Ticket and has been respawned as a Death Commando!</span>"

        // Optionally, consume the Academy Ticket
        user.loc.remove(src)  // Remove the ticket from the player's inventory
        del src  // Delete the ticket object from the game world

// Optional: Define other verbs or properties as needed
