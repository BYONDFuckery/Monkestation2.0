// File: items/crystalrespawn.dm

/proc/respawn_as_death_commando(mob/living/carbon/human/player)
{
    if (!player || !player.client)
    {
        world.log << "Error: Invalid player or missing client for respawn_as_death_commando"
        return
    }

    // Set the player's role to Death Commando
    var/mob/living/carbon/human/Death_Commando = new /mob/living/carbon/human/death_commando
    Death_Commando.name = player.name
    Death_Commando.key = player.key

    // Place the new Death Commando in the game world at CentCom (coordinates 10, 10, 1)
    var/turf/start_location = locate(10, 10, 1)  // Z-level 1
    if (!start_location)
    {
        world.log << "Error: Could not find start location for respawn_as_death_commando"
        return
    }
    Death_Commando.loc = start_location

    // Transfer the player's client to the new Death Commando
    player.client.mob = Death_Commando

    // Notify the player
    to_chat(Death_Commando, "You have been respawned as a Death Commando!")
    to_chat(Death_Commando, "Being a Death Commando does not permit griefing or killing. Follow server rules.")

    // Send a notification to admins
    world << "<span class='notice'>ADMIN NOTICE: [Death_Commando.name] ([Death_Commando.key]) has won the Academy Ticket and has been respawned as a Death C
