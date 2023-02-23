local Translations = {
    label = {
        ["asklocation"] = "Ask for a location"

    },

    mail = {
        ["sender"] = "Mr. Shadow",
        --
        ["subject"] = "House location",
        ["message"] = "This one should be empty. Get all that juice out of there!",
        --
        ["subject2"] = "Good.",
        ["message2"] = "Hope you got some good shit from that house. Comeback later and I might have another location for ya.",
        --
        ["subject3"] = "Bad.",
        ["message3"] = "That was not good my friend. How about you take some extra time off."
    },

    text3d = {
        ["text"] = "<b>Entry</b></p>[F] Start the robbery",
        ["text2"] = "<b>Exit</b></p>[F] End the robbery and leave the house.",
        ["text3"] = "[E] Look for stuff here"
    },

    notify = {
        ["starting"] = "Starting!",
        ["robberyinprogress"] = "Your robbery is still in progress.",
        ["needtowait"] = "You need to wait ",
        ["needtowait2"] = "s before you can start robbery again!",
        ["recivedlocation"] = "You recived an robbery location.",
        ["donthaveitem"] = "You don't have item!",
        ["alreadycheacked"] = "You already cheacked here.",
        ["gotthedoor"] = "You got the door open!",
        ["messedup"] = "You messed up the lock! Get outa there!",
        ["canceled"] = "Process Canceled"
    },

    progress = {
        ["lookingforstuff"] = "Looking for stuff.."
    }
}

Lang = Lang or Locale:new({
    phrases = Translations,
    warnOnMissing = true
})