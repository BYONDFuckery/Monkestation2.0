// Include necessary resources or definitions if any
#include "obj/item/prize/academy_ticket.rsc"

// Define the item
code/game/objects/items/academy_ticket.dm
    icon = 'icons/obj/telescience.dmi'  // Path to the icon for the Academy Ticket
    name = "Academy Ticket"
    desc = "A ticket to the Deathsquad Academy."
    weight = 1

// Define a verb to handle the use of the Academy Ticket
verb
    use()
        set src in oview()
        var/mob/living/carbon/human/player/user = src
        if(!user)
            return
        // Call respawn_as_death_commando procedure
        respawn_as_death_commando(user)

// Optional: Define other verbs or properties as needed
