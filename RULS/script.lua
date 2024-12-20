local discord = "4EqNtG9ZGX"
local systemName = "[Auth System]"
local rules = {
    "===RULES===",
    "1) Please use common sense and stop doing a certain action when told to.",
    "2) Be Friendly! There is no need to explain that!",
    "3) Vehicle that cause more than two warning messages as well as laggy vehicles are prohibited!",
    "4) Workshop is allowed, as long as they fit into the rules!.",
    "5) PvP in Hangars or spawn areas are not allowed, Please move",
    "6) Please Refrain from using Flare Bombs, EMPs or anything to annoy people.",
    "7) Do NOT at all try break the server in any way (this will lead to a perminent ban!)",
    "9) Ensure you are given permission by the other player to PvP",
    "10) Admins have final say",
    "",
    "And dont forget to have fun!"
}

local randomAnnouncements = {
    string.format("For support and updates\nconsider joining our Discord!\ndiscord.gg/" .. discord),
    "Nuclear bombs (if with bad intentions or at spawn), Flare Bombs, Nuclear reactors designed to explode or anything designed to annoy or break the server are not permitted",
    "Got desynced from a Server?\nPress the F2 key to enable\nthe Vehicle Debugger which helps\nwith catching up to servers!",
    "You have the ability to vote!, to see what is avaiable just type: '?votehelp' !"
}

local function showPopup(peer_id, ui_id, text)
    server.setPopupScreen(peer_id, ui_id, "[AuthSys]", true, text, 0, 0)
end

local function removePopup(peer_id, ui_id)
    server.removePopup(peer_id, ui_id)
end

local player_ui_ids = {}

function onPlayerJoin(steam_id, name, user_id, admin, auth)
    player_ui_ids[user_id] = 1
    ui_id = user_id * 100 + player_ui_ids[user_id]
    if (auth) and not (admin) then
        server.removeAuth(user_id)
        showPopup(user_id, ui_id, "To get authed\ntype ?rules")
        announce("To get authed again, type ?rules", user_id)
    elseif not (auth) and not (admin) then
        showPopup(user_id, ui_id, "To get authed\ntype ?rules")
        announce("To get authed, type ?rules", user_id)
    end
    if (admin) then
        if not (auth) then
            server.addAuth(user_id)
        end
    end
end

function onCustomCommand(full_message, peer_id, is_admin, is_auth, command, one, two, three, four, five)
    command = string.lower(command)
    player_ui_ids[peer_id] = (player_ui_ids[peer_id] or 0) + 1
    ui_id = peer_id * 100 + player_ui_ids[peer_id]

    if (command == "?rules") then
        local rules = createList(
        rules, 
        function(rules) return true end, 
        function(rules) return rules end
    )
        announce(rules, peer_id)
        removePopup(peer_id, ui_id)
        player_ui_ids[peer_id] = player_ui_ids[peer_id] + 1
        ui_id2 = peer_id * 100 + player_ui_ids[peer_id]
        showPopup(peer_id, ui_id2, "To get auth, type in one line:\n?auth\n"..peer_id.."\naccept")
    end
    if (command == "?auth") then
        if (one == nil or two == nil) then
            announce("Usage: ?auth player_id accept", peer_id)
            return
        end

        local peerID = tonumber(one)

        if (peerID == nil) then
            announce("Invalid player ID", peer_id)
            return
        end

        if one ~= nil and two == "accept" then
            if (peer_id == peerID) then
                server.addAuth(peer_id)
                announce("You have been granted auth", peer_id)
                removePopup(peer_id, ui_id2)
            else
                announce("That is not your player_id! Your player id is: '"..peer_id.."'!", peer_id)
            end
        end
    end
end

local messagesBeforeRandomAnnounce = 0

function onChatMessage(peer_id, sender_name, message)
    messagesBeforeRandomAnnounce = messagesBeforeRandomAnnounce + 1
    if (messagesBeforeRandomAnnounce > 10) then
        messagesBeforeRandomAnnounce = 0
        local randInt = math.random(1, #randomAnnouncements)
        announce(randomAnnouncements[randInt])
    end
end

function createList(items, condition, transform)
    local result = ""
    local hasItems = false

    for i, item in ipairs(items) do
        if condition(item) then
            if transform then
                result = result .. transform(item)
            else
                result = result .. tostring(item)
            end

            local nextItemIndex = i + 1
            while nextItemIndex <= #items and not condition(items[nextItemIndex]) do
                nextItemIndex = nextItemIndex + 1
            end

            if nextItemIndex <= #items then
                result = result .. "\n"
            end

            hasItems = true
        end
    end

    if not hasItems then
        result = "NONE"
    end

    return result
end

function announce(message, peerID)
    -- Insert "|" before each newline in the message
    message = message:gsub("\n", "\n| ")
    if peerID then
        server.announce(systemName, "| " .. message, peerID)
    else
        server.announce(systemName, "| " .. message)
    end
end
