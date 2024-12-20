-- Existing script variables
local discord = "4EqNtG9ZGX"
local systemName = "[Auth System]"
local rules = {
    "===RULES===",
    "1) Please use common sense and stop doing a certain action when told to.",
    "2) Be Friendly! There is no need to explain that!",
    "3) Vehicles that cause more than two warning messages as well as laggy vehicles are prohibited!",
    "4) Workshop is allowed, as long as they fit into the rules!",
    "5) PvP in Hangars or spawn areas are not allowed, Please move",
    "6) Please refrain from using Flare Bombs, EMPs, or anything to annoy people.",
    "7) Do NOT at all try to break the server in any way (this will lead to a permanent ban!)",
    "9) Ensure you are given permission by the other player to PvP",
    "10) Admins have final say",
    "",
    "And don't forget to have fun!"
}

local randomAnnouncements = {
    string.format("For support and updates\nconsider joining our Discord!\ndiscord.gg/" .. discord),
    "Nuclear bombs (if with bad intentions or at spawn), Flare Bombs, Nuclear reactors designed to explode, or anything designed to annoy or break the server are not permitted",
    "Got desynced from a server?\nPress the F2 key to enable\nthe Vehicle Debugger which helps\nwith catching up to servers!",
    "You have the ability to vote! To see what is available, just type '?votehelp'!",
    "Please make sure to read the rules with ?rules to avoid getting kicked or even banned!",
    "Did you know: ?vlag tells you how much lag cost you have used, and how much is left for you to use?",
    "Did you know: ?repair is an existing command!",
}

-- Initialize g_savedata if not already initialized
if not g_savedata then
    g_savedata = {}
end

-- Initialize reports, warnings, and tempbans tables in g_savedata
function initializeSavedData()
    g_savedata.reports = g_savedata.reports or {}
    g_savedata.warnings = g_savedata.warnings or {}
    g_savedata.tempbans = g_savedata.tempbans or {}
end

initializeSavedData()

local function showPopup(peer_id, ui_id, text)
    server.setPopupScreen(peer_id, ui_id, "AuthSys", true, text, 0, 0)
end

local function removePopup(peer_id, ui_id)
    server.removePopup(peer_id, ui_id)
end

local player_ui_ids = {}

-- Function to get player data by peer_id
local function getPlayerData(peer_id)
    local players = server.getPlayers()
    for _, player in ipairs(players) do
        if player.id == peer_id then
            return player
        end
    end
    return nil
end

-- Function to get Steam ID by peer_id
local function getSteamID(peer_id)
    local player = getPlayerData(peer_id)
    if player then
        return player.steam_id
    end
    return nil
end

-- Function to get player name by peer_id
local function getPlayerName(peer_id)
    local player = getPlayerData(peer_id)
    if player then
        return player.name
    end
    return "Unknown"
end

-- Function to check if a player is an admin
local function isPlayerAdmin(peer_id)
    local player = getPlayerData(peer_id)
    if player then
        return player.admin
    end
    return false
end

-- Scheduled tasks table
local scheduled_tasks = {}

-- Warning countdowns table
local warning_countdowns = {}

function onPlayerJoin(steam_id, name, peer_id, is_admin, is_auth)
    player_ui_ids[peer_id] = peer_id
    ui_id = peer_id * 100 + player_ui_ids[peer_id]

    -- Check for temp ban
    local is_temp_banned = checkTempBanOnJoin(peer_id, steam_id, is_admin)
    if is_temp_banned then
        -- Player is temp-banned, do not proceed with auth logic
        return
    end

    -- Auth system
    if is_auth and not is_admin then
        server.removeAuth(peer_id)
        showPopup(peer_id, ui_id, "To get authed\ntype ?rules")
        announce("To get authed again, type ?rules", peer_id)
    elseif not is_auth and not is_admin then
        showPopup(peer_id, ui_id, "To get authed\ntype ?rules")
        announce("To get authed, type ?rules", peer_id)
    end
    if is_admin then
        if not is_auth then
            server.addAuth(peer_id)
        end
        -- Notify admin of recent reports
        notifyAdminOfReports(peer_id)
    end
end

-- Function to check and handle temp bans when a player joins
function checkTempBanOnJoin(peer_id, steam_id, is_admin)
    if is_admin then
        return false
    end
    local tempbans = g_savedata.tempbans
    local current_time = server.getTimeMillisec()
    for index, ban in ipairs(tempbans) do
        if ban.steam_id == steam_id then
            local remaining_time_ms = ban.end_time - current_time
            if remaining_time_ms > 0 then
                -- Player is temp-banned
                local remaining_time_sec = math.ceil(remaining_time_ms / 1000)
                local remaining_time_formatted = formatTime(remaining_time_sec)
                local message = string.format("You are temp-banned!\nRemaining ban time: %s", remaining_time_formatted)
                local ui_id = 9999
                showPopup(peer_id, ui_id, message)
                -- After 10 seconds, update the popup to include autokick message
                local autokick_in_seconds = 5 -- Countdown before autokick
                local execute_at = current_time + 10000 -- 10 seconds from now
                table.insert(scheduled_tasks, {execute_at = execute_at, func = function()
                    local message = string.format("You are temp-banned!\nRemaining ban time: %s\nAutokick in %d seconds", remaining_time_formatted, autokick_in_seconds)
                    showPopup(peer_id, ui_id, message)
                    -- Schedule kick after autokick_in_seconds
                    local kick_at = server.getTimeMillisec() + autokick_in_seconds * 1000
                    table.insert(scheduled_tasks, {execute_at = kick_at, func = function()
                        server.kickPlayer(peer_id)
                    end})
                end})
                return true
            else
                -- Ban expired, remove from tempbans
                table.remove(tempbans, index)
                break
            end
        end
    end
    return false
end

-- Function to format time in hours:minutes:seconds
function formatTime(seconds)
    local hours = math.floor(seconds / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    seconds = seconds % 60
    if hours > 0 then
        return string.format("%dh:%02dm:%02ds", hours, minutes, seconds)
    else
        return string.format("%dm:%02ds", minutes, seconds)
    end
end

function onCreate(is_world_create)
    initializeSavedData()
    if not is_world_create then
        -- This is a script reload, not a world creation
        local onlineplayers = server.getPlayers()

        for _, player in ipairs(onlineplayers) do
            -- Access the 'auth' field from the player table
            local is_authed = player.auth or false  -- Default to false if not present

            -- Display a popup screen for non-authed players
            if not is_authed then
                local message = "Server scripts have been reloaded...\n For the ability to get AUTH, PLEASE REJOIN!"
                server.setPopupScreen(player.id, 14011, "[Auth System] Reloaded", true, message, 0, 0)
            end
        end
    end
end

-- Function to announce messages
function announce(message, peer_id)
    -- Insert "|" before each newline in the message
    message = message:gsub("\n", "\n| ")
    if peer_id then
        server.announce(systemName, "| " .. message, peer_id)
    else
        server.announce(systemName, "| " .. message)
    end
end

function onCustomCommand(full_message, peer_id, is_admin, is_auth, command, ...)
    command = string.lower(command)
    local args = {...}
    player_ui_ids[peer_id] = player_ui_ids[peer_id] or peer_id
    ui_id = peer_id * 100 + player_ui_ids[peer_id]

    if command == "?rules" then
        local rulesText = table.concat(rules, "\n")
        announce(rulesText, peer_id)

        if not is_auth then
            removePopup(peer_id, ui_id)
            player_ui_ids[peer_id] = player_ui_ids[peer_id] + 1
            ui_id2 = peer_id * 101 + player_ui_ids[peer_id]
            showPopup(peer_id, ui_id2, "To get auth, type \n?auth " .. peer_id .. " accept")
        end
    elseif command == "?help" then
        showHelp(peer_id, is_admin)
    elseif command == "?auth" then
        if isPlayerTempBanned(peer_id) then
            announce("You are temp-banned and cannot authenticate.", peer_id)
            return
        end
        local one = args[1]
        local two = args[2]
        if not one or not two then
            announce("Usage: ?auth <your_peer_id> accept", peer_id)
            return
        end

        local peerID = tonumber(one)

        if not peerID then
            announce("Invalid player ID", peer_id)
            return
        end

        if peer_id == peerID and two == "accept" then
            server.addAuth(peer_id)
            announce("You have been granted auth", peer_id)
            removePopup(peer_id, ui_id2)
        else
            announce("That is not your player_id! Your player id is: '" .. peer_id .. "'!", peer_id)
        end

    -- Start of new commands

    elseif command == "?report" then
        local target_peer_id = tonumber(args[1])
        if not target_peer_id or not args[2] then
            announce("Usage: ?report <peer_id> <reason>", peer_id)
            return
        end
        local reason = table.concat(args, " ", 2)
        addReport(peer_id, target_peer_id, reason)
    elseif command == "?checkrep" then
        if not is_admin then
            announce("You do not have permission to use this command.", peer_id)
            return
        end
        local target_peer_id = tonumber(args[1])
        if target_peer_id then
            checkReportsForPlayer(peer_id, target_peer_id)
        else
            listAllReports(peer_id)
        end
    elseif command == "?clearrep" then
        if not is_admin then
            announce("You do not have permission to use this command.", peer_id)
            return
        end
        local target_peer_id = tonumber(args[1])
        local report_number = tonumber(args[2])
        if not target_peer_id then
            announce("Usage: ?clearrep <peer_id> [report_number]", peer_id)
            return
        end
        clearReports(peer_id, target_peer_id, report_number)
    elseif command == "?warn" then
        if not is_admin then
            announce("You do not have permission to use this command.", peer_id)
            return
        end
        local target_peer_id = tonumber(args[1])
        if not target_peer_id or not args[2] then
            announce("Usage: ?warn <peer_id> <reason>", peer_id)
            return
        end
        local reason = table.concat(args, " ", 2)
        addWarning(peer_id, target_peer_id, reason)
    elseif command == "?delwarn" then
        if not is_admin then
            announce("You do not have permission to use this command.", peer_id)
            return
        end
        local target_peer_id = tonumber(args[1])
        local warning_number = tonumber(args[2])
        if not target_peer_id then
            announce("Usage: ?delwarn <peer_id> [warning_number]", peer_id)
            return
        end
        removeWarning(peer_id, target_peer_id, warning_number)
    elseif command == "?tempban" then
        if not is_admin then
            announce("You do not have permission to use this command.", peer_id)
            return
        end
        local target_peer_id = tonumber(args[1])
        local minutes = tonumber(args[2])
        if not target_peer_id or not minutes then
            announce("Usage: ?tempban <peer_id> <minutes>", peer_id)
            return
        end
        tempBanPlayer(peer_id, target_peer_id, minutes)
    elseif command == "?deltempban" then
        if not is_admin then
            announce("You do not have permission to use this command.", peer_id)
            return
        end
        local ban_number = tonumber(args[1])
        if ban_number then
            removeTempBan(peer_id, ban_number)
        else
            listTempBans(peer_id)
        end
    elseif command == "?myreports" then
        if not is_auth then
            announce("You need to be authed to use this command.", peer_id)
            return
        end
        listMyReports(peer_id)
    end
end

-- Function to display help messages
function showHelp(peer_id, is_admin)
    local commands = {
        "?rules - Display the server rules",
        "?help - Display this help message",
        "?report <peer_id> <reason> - Report a player",
        "?myreports - View reports made against you",
        -- Any other player commands
    }

    local message = "Available Commands:\n" .. table.concat(commands, "\n")

    if is_admin then
        local admin_commands = {
            "?checkrep [peer_id] - Check player reports",
            "?clearrep <peer_id> [report_number] - Clear player reports",
            "?warn <peer_id> <reason> - Warn a player",
            "?delwarn <peer_id> [warning_number] - Remove warnings from a player",
            "?tempban <peer_id> <minutes> - Temp-ban a player",
            "?deltempban [ban_number] - Remove a temp ban",
            -- Any other admin commands
        }
        message = message .. "\n\nAdmin Commands:\n" .. table.concat(admin_commands, "\n")
    end

    announce(message, peer_id)
end

local messagesBeforeRandomAnnounce = 0

function onChatMessage(peer_id, sender_name, message)
    messagesBeforeRandomAnnounce = messagesBeforeRandomAnnounce + 1
    if messagesBeforeRandomAnnounce > 10 then
        messagesBeforeRandomAnnounce = 0
        local randInt = math.random(1, #randomAnnouncements)
        announce(randomAnnouncements[randInt])
    end
end

-- Function to notify admins of recent reports upon joining
function notifyAdminOfReports(peer_id)
    local reports = g_savedata.reports
    if #reports > 0 then
        announce("Recent Reports:", peer_id)
        for i = math.max(1, #reports - 5), #reports do
            local report = reports[i]
            local message = string.format("%s reported %s: %s",
                report.reporter_name, report.reported_name, report.reason)
            announce(message, peer_id)
        end
    else
        announce("No recent reports.", peer_id)
    end
end

-- Function to add a report
function addReport(reporter_peer_id, reported_peer_id, reason)
    local reporter_name = getPlayerName(reporter_peer_id)
    local reported_name = getPlayerName(reported_peer_id)
    local report = {
        reporter_id = reporter_peer_id,
        reporter_name = reporter_name,
        reported_id = reported_peer_id,
        reported_name = reported_name,
        reason = reason,
        time = server.getTimeMillisec()
    }
    table.insert(g_savedata.reports, report)
    -- Notify admins
    local admins = server.getAdmins()
    for _, admin in ipairs(admins) do
        announce(string.format("New report from %s against %s: %s",
            reporter_name, reported_name, reason), admin.id)
    end
    announce("Your report has been submitted.", reporter_peer_id)
end

-- Function to list all reports (for admins)
function listAllReports(admin_peer_id)
    local reports = g_savedata.reports
    if #reports == 0 then
        announce("No reports available.", admin_peer_id)
        return
    end
    -- Sort reports by newest first
    table.sort(reports, function(a, b)
        return a.time > b.time
    end)
    announce("All Reports:", admin_peer_id)
    for _, report in ipairs(reports) do
        local message = string.format("%s reported %s (%d): %s",
            report.reporter_name, report.reported_name, report.reported_id, report.reason)
        announce(message, admin_peer_id)
    end
end

-- Function to check reports for a specific player
function checkReportsForPlayer(admin_peer_id, target_peer_id)
    local target_name = getPlayerName(target_peer_id)
    local reports = g_savedata.reports
    local found = false
    for _, report in ipairs(reports) do
        if report.reported_id == target_peer_id then
            if not found then
                announce("Reports for " .. target_name .. ":", admin_peer_id)
                found = true
            end
            local message = string.format("Reported by %s: %s",
                report.reporter_name, report.reason)
            announce(message, admin_peer_id)
        end
    end
    if not found then
        announce("No reports found for " .. target_name, admin_peer_id)
    end
end

-- Function to clear reports for a player
function clearReports(admin_peer_id, target_peer_id, report_number)
    local target_name = getPlayerName(target_peer_id)
    local reports = g_savedata.reports
    local removed = false
    if report_number then
        -- Clear specific report
        local count = 0
        for i = 1, #reports do
            if reports[i].reported_id == target_peer_id then
                count = count + 1
                if count == report_number then
                    table.remove(reports, i)
                    announce("Removed report #" .. report_number .. " for " .. target_name, admin_peer_id)
                    removed = true
                    break
                end
            end
        end
        if not removed then
            announce("Report #" .. report_number .. " not found for " .. target_name, admin_peer_id)
        end
    else
        -- Clear all reports for the player
        for i = #reports, 1, -1 do
            if reports[i].reported_id == target_peer_id then
                table.remove(reports, i)
                removed = true
            end
        end
        if removed then
            announce("Cleared all reports for " .. target_name, admin_peer_id)
        else
            announce("No reports found for " .. target_name, admin_peer_id)
        end
    end
end

-- Function to add a warning
function addWarning(admin_peer_id, target_peer_id, reason)
    if isPlayerAdmin(target_peer_id) then
        announce("Admins cannot be warned, but their actions won't be forgotten.", admin_peer_id)
        return
    end
    local target_name = getPlayerName(target_peer_id)
    local steam_id = getSteamID(target_peer_id)
    if not steam_id then
        announce("Player not found.", admin_peer_id)
        return
    end
    local warnings = g_savedata.warnings
    warnings[steam_id] = warnings[steam_id] or {count = 0, records = {}}
    local player_warnings = warnings[steam_id]
    player_warnings.count = player_warnings.count + 1
    table.insert(player_warnings.records, {
        reason = reason,
        time = server.getTimeMillisec(),
        admin_id = admin_peer_id,
        admin_name = getPlayerName(admin_peer_id)
    })
    announce("Warning issued to " .. target_name .. ". Reason: " .. reason, admin_peer_id)
    announce("You have been warned. Reason: " .. reason, target_peer_id)

    -- Handle kick after warnings
    handleWarnings(target_peer_id, steam_id, player_warnings.count, reason)
end

-- Function to remove warnings
function removeWarning(admin_peer_id, target_peer_id, warning_number)
    local target_name = getPlayerName(target_peer_id)
    local steam_id = getSteamID(target_peer_id)
    if not steam_id then
        announce("Player not found.", admin_peer_id)
        return
    end
    local warnings = g_savedata.warnings
    local player_warnings = warnings[steam_id]
    if not player_warnings or #player_warnings.records == 0 then
        announce("No warnings found for " .. target_name, admin_peer_id)
        return
    end

    if warning_number then
        -- Remove specific warning
        if warning_number < 1 or warning_number > #player_warnings.records then
            announce("Invalid warning number.", admin_peer_id)
            return
        end
        table.remove(player_warnings.records, warning_number)
        player_warnings.count = player_warnings.count - 1
        announce("Removed warning #" .. warning_number .. " for " .. target_name, admin_peer_id)
    else
        -- Remove all warnings
        warnings[steam_id] = nil
        announce("Cleared all warnings for " .. target_name, admin_peer_id)
    end
end

-- Function to handle warnings and kick if necessary
function handleWarnings(peer_id, steam_id, warning_count, reason)
    local countdown_time = 0 -- in seconds
    local initial_message = ""

    if warning_count == 5 then
        countdown_time = 16 -- seconds
        initial_message = "You have received 5 warnings."
    elseif warning_count >= 10 then
        countdown_time = 8 -- seconds
        initial_message = "You have received " .. warning_count .. " warnings. You risk being permabanned."
    else
        return
    end

    if isPlayerAdmin(peer_id) then
        -- Admins cannot be kicked
        announce("Admins cannot be kicked, but their actions won't be forgotten.", peer_id)
        return
    end

    -- Store the countdown info for this player
    warning_countdowns[peer_id] = {
        end_time = server.getTimeMillisec() + countdown_time * 1000,
        last_update = -1, -- to ensure the first update happens
        initial_message = initial_message,
        ui_id = 8888, -- the popup id
    }

    -- Show initial popup
    showPopup(peer_id, 8888, initial_message .. "\nYou will be kicked in " .. countdown_time .. " seconds.")
end

-- Function to temp-ban a player
function tempBanPlayer(admin_peer_id, target_peer_id, minutes)
    if isPlayerAdmin(target_peer_id) then
        announce("Admins cannot be temp-banned, who else would do?", admin_peer_id)
        return
    end
    local target_name = getPlayerName(target_peer_id)
    local steam_id = getSteamID(target_peer_id)
    if not steam_id then
        announce("Player not found.", admin_peer_id)
        return
    end
    local end_time = server.getTimeMillisec() + (minutes * 60000) -- Convert minutes to milliseconds
    table.insert(g_savedata.tempbans, {
        steam_id = steam_id,
        player_name = target_name,
        end_time = end_time
    })
    announce(target_name .. " has been temp-banned for " .. minutes .. " minutes.", admin_peer_id)
    announce("You have been temp-banned for " .. minutes .. " minutes.", target_peer_id)
    server.kickPlayer(target_peer_id)
end

-- Function to remove a temp ban
function removeTempBan(admin_peer_id, ban_number)
    local tempbans = g_savedata.tempbans
    if tempbans[ban_number] then
        local player_name = tempbans[ban_number].player_name
        table.remove(tempbans, ban_number)
        announce("Temp ban lifted for " .. player_name, admin_peer_id)
    else
        announce("Invalid temp ban number.", admin_peer_id)
    end
end

-- Function to list active temp bans
function listTempBans(admin_peer_id)
    local tempbans = g_savedata.tempbans
    if #tempbans == 0 then
        announce("No active temp bans.", admin_peer_id)
        return
    end
    announce("Active Temp Bans:", admin_peer_id)
    local current_time = server.getTimeMillisec()
    for index, ban in ipairs(tempbans) do
        local remaining_time = ban.end_time - current_time
        if remaining_time > 0 then
            local message = string.format("%d) %s - Remaining time: %s", index, ban.player_name, formatTime(math.ceil(remaining_time / 1000)))
            announce(message, admin_peer_id)
        else
            -- Ban expired, remove it
            table.remove(tempbans, index)
        end
    end
end

-- Function to list reports for the player themselves
function listMyReports(peer_id)
    local player_name = getPlayerName(peer_id)
    local reports = g_savedata.reports
    local found = false
    for _, report in ipairs(reports) do
        if report.reported_id == peer_id then
            if not found then
                announce("Reports against you:", peer_id)
                found = true
            end
            local message = string.format("Reported by %s: %s", report.reporter_name, report.reason)
            announce(message, peer_id)
        end
    end
    if not found then
        announce("You have no reports, good work", peer_id)
    end
end

-- Function to check if a player is temp-banned
function isPlayerTempBanned(peer_id)
    local steam_id = getSteamID(peer_id)
    if not steam_id then
        return false
    end
    local tempbans = g_savedata.tempbans
    local current_time = server.getTimeMillisec()
    for index, ban in ipairs(tempbans) do
        if ban.steam_id == steam_id then
            if ban.end_time > current_time then
                return true
            else
                -- Ban expired, remove it
                table.remove(tempbans, index)
                return false
            end
        end
    end
    return false
end

-- onTick function to handle scheduled tasks and warning countdowns
function onTick(game_ticks)
    local current_time = server.getTimeMillisec()

    -- Handle warning countdowns
    for peer_id, countdown_info in pairs(warning_countdowns) do
        local time_left_ms = countdown_info.end_time - current_time
        local time_left = math.ceil(time_left_ms / 1000) -- in seconds

        if time_left <= 0 then
            -- Countdown has finished
            if isPlayerAdmin(peer_id) then
                -- Admins cannot be kicked
                announce("Admins cannot be kicked, but their actions won't be forgotten.", peer_id)
                -- Remove from warning_countdowns
                warning_countdowns[peer_id] = nil
                -- Remove the popup
                removePopup(peer_id, countdown_info.ui_id)
            else
                -- Kick the player
                server.kickPlayer(peer_id)
                -- Remove from warning_countdowns
                warning_countdowns[peer_id] = nil
                -- Remove the popup
                removePopup(peer_id, countdown_info.ui_id)
            end
        else
            -- Update the popup every second
            if time_left ~= countdown_info.last_update then
                -- Update the message
                local message = countdown_info.initial_message .. "\nYou will be kicked in " .. time_left .. " seconds."
                showPopup(peer_id, countdown_info.ui_id, message)
                countdown_info.last_update = time_left
            end
        end
    end

    -- Handle scheduled tasks
    for i = #scheduled_tasks, 1, -1 do
        local task = scheduled_tasks[i]
        if current_time >= task.execute_at then
            if task.func_name == "kickPlayer" then
                local target_peer_id = task.peer_id
                if isPlayerAdmin(target_peer_id) then
                    -- Admins cannot be kicked
                    announce("Admins cannot be kicked, but their actions won't be forgotten.", target_peer_id)
                else
                    task.func()
                end
            else
                task.func()
            end
            table.remove(scheduled_tasks, i)
        end
    end

    -- Other code if needed
end
