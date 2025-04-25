-- Define the maximum allowable lag cost per player
local PLAYER_LAG_COST_LIMIT = 8000  -- Adjust this value as needed
local PLAYER_LAG_COST_LIMIT_WS = PLAYER_LAG_COST_LIMIT  -- Lag cost limit for workshop vehicles not authored by the player

-- Component lag costs for each type
local COMPONENT_LAG_COSTS = {
    ["signs"] = 3,
    ["seats"] = 2,
    ["buttons"] = 2,
    ["dials"] = 2,
    ["tanks"] = 5,
    ["batteries"] = 10,
    ["hoppers"] = 7,
    ["guns"] = 20,
    ["rope_hooks"] = 4,
    -- Add more component types and their respective lag costs here
}

-- Define the lag cost per voxel
local VOXEL_LAG_COST = 0.2  -- Adjust this value as needed

-- TPS Monitoring
local TPS_THRESHOLD = 35  -- Adjusted TPS threshold for your calculation method
local tps_countdown = nil  -- Countdown timer in seconds
local tps_warning_issued = false

-- TPS Calculation Variables
local TIME = server.getTimeMillisec()
local TICKS = 0
local TPS = 0

-- Emergency Cleanup Variables
local emergency_cleanup_tps = 5  -- Default TPS threshold for emergency cleanup
local emergency_cleanup_countdown = nil
local emergency_cleanup_start_time = nil

-- Debug Mode Variable
local debug_mode = false

-- Tables to store tracking data
local vehicle_lag_costs = {}         -- [vehicle_id] = {lag_cost = number, peer_id = number, group_id = number, is_ws = boolean}
local player_vehicle_groups = {}     -- [peer_id] = {group_id = {vehicle_ids}}
local group_peer_mapping = {}        -- [group_id] = peer_id
local player_lag_costs = {}          -- [peer_id] = total_lag_cost
local vehicle_loading = {}           -- [vehicle_id] = {peer_id, group_id}
local group_tps_impact = {}          -- [group_id] = {pre_tps = number, check_time = number}

-- Function to calculate and update TPS (optimized)
function updateTPS(game_ticks)
    local tempo = server.getTimeMillisec()
    
    if tempo - TIME < 1000 then -- Check every second instead of 1996ms
        TICKS = TICKS + game_ticks -- Removed multiplier for more accurate counting
    else
        TPS = TICKS
        TIME = tempo
        TICKS = 0
        
        -- Check if TPS is below threshold
        if TPS < TPS_THRESHOLD then
            if not tps_countdown then
                tps_countdown = 8
                tps_warning_issued = false
                tps_countdown_start_time = tempo
            end
        else
            tps_countdown = nil
            tps_warning_issued = false
        end

        -- Emergency cleanup check
        if TPS < emergency_cleanup_tps then
            if not emergency_cleanup_countdown then
                emergency_cleanup_countdown = 2500
                emergency_cleanup_start_time = tempo
            end
        else
            emergency_cleanup_countdown = nil
        end
    end
end

-- Function to check vehicle loading and calculate lag cost when ready
-- Add this at the top of your script with other variable declarations
local notified_groups = {}  -- [group_id] = true if the group has been notified

-- Function to check vehicle loading and calculate lag cost when ready
function updateVehicleLoading()
    for vehicle_id, info in pairs(vehicle_loading) do
        local vehicle_data, is_success = server.getVehicleData(vehicle_id)
        if is_success then
            if vehicle_data["simulating"] then
                if debug_mode then
                    server.announce("[DEBUG]", "Vehicle is now simulating: ID=" .. vehicle_id)
                end

                -- Vehicle is loaded; calculate lag cost
                calculateVehicleLagCost(vehicle_id, info.peer_id, info.group_id)

                -- Remove from loading list
                vehicle_loading[vehicle_id] = nil

                -- Check if all vehicles in the group are simulating
                if areAllGroupVehiclesSimulating(info.group_id) then
                    -- Check if the group has already been notified
                    if not notified_groups[info.group_id] then
                        -- Announce the group spawn
                        announceGroupSpawn(info.group_id, info.peer_id)
                        -- Mark the group as notified
                        notified_groups[info.group_id] = true

                        -- Measure TPS impact
                        measureGroupTPSImpact(info.group_id)
                    end
                end
            end
        else
            -- Vehicle no longer exists; remove from loading list
            vehicle_loading[vehicle_id] = nil
            if debug_mode then
                server.announce("[DEBUG]", "Vehicle " .. vehicle_id .. " not found. Removed from loading list.", -1)
            end
        end
    end
end


-- Function to check if all vehicles in a group are simulating
function areAllGroupVehiclesSimulating(group_id)
    local peer_id = group_peer_mapping[group_id]
    if not peer_id then
        if debug_mode then
            server.announce("[DEBUG]", "Group ID " .. group_id .. " not found in group_peer_mapping.", -1)
        end
        return false
    end

    if not player_vehicle_groups[peer_id] then
        if debug_mode then
            server.announce("[DEBUG]", "No vehicle groups found for peer ID " .. peer_id, -1)
        end
        return false
    end

    local vehicles = player_vehicle_groups[peer_id][group_id]
    if not vehicles then
        if debug_mode then
            server.announce("[DEBUG]", "Group ID " .. group_id .. " not found under peer ID " .. peer_id .. " in player_vehicle_groups.", -1)
        end
        return false
    end

    for _, vehicle_id in ipairs(vehicles) do
        local vehicle_data, is_success = server.getVehicleData(vehicle_id)
        if not (is_success and vehicle_data["simulating"]) then
            return false
        end
    end

    if debug_mode then
        server.announce("[DEBUG]", "All vehicles in group " .. group_id .. " are now simulating.", -1)
    end
    return true
end

-- Function to announce the group spawn
function announceGroupSpawn(group_id, peer_id)
    -- If peer_id is 0, it's the server or an addon; do not announce
    if peer_id < 0 then
        if debug_mode then
            server.announce("[DEBUG]", "Group " .. group_id .. " spawned by server/addon (peer_id 0). Not announcing.", -1)
        end
        return
    end
    local vehicles = player_vehicle_groups[peer_id][group_id]
    if not vehicles then
        if debug_mode then
            server.announce("[DEBUG]", "No vehicles found for group " .. group_id .. " for announcement.", -1)
        end
        return
    end

    local player_name = server.getPlayerName(peer_id)
    local total_lag_cost = 0
    local vehicle_names_set = {}
    local vehicle_authors_set = {}
    local is_ws_vehicle = false

    for _, vehicle_id in ipairs(vehicles) do
        local vehicle_info = vehicle_lag_costs[vehicle_id]
        if vehicle_info then
            total_lag_cost = total_lag_cost + vehicle_info.lag_cost
            if vehicle_info.is_ws then
                is_ws_vehicle = true
            end

            -- Collect vehicle names
            local vehicle_name = vehicle_info.vehicle_name or "no name"
            vehicle_names_set[vehicle_name] = true

            -- Collect authors
            for _, author_info in ipairs(vehicle_info.vehicle_authors) do
                local author_name = author_info.name or "Unknown"
                vehicle_authors_set[author_name] = true
            end
        else
            if debug_mode then
                server.announce("[DEBUG]", "Vehicle info not found for vehicle " .. vehicle_id .. " in group " .. group_id, -1)
            end
        end
    end

    -- Convert vehicle names set to a comma-separated string
    local vehicle_names_str = ""
    for name, _ in pairs(vehicle_names_set) do
        if vehicle_names_str == "" then
            vehicle_names_str = name
        else
            vehicle_names_str = vehicle_names_str .. ", " .. name
        end
    end

    -- Convert authors set to a comma-separated string
    local authors_str = ""
    if next(vehicle_authors_set) == nil then
        authors_str = "self"
    else
        local authors = {}
        for author_name, _ in pairs(vehicle_authors_set) do
            table.insert(authors, author_name)
        end
        authors_str = table.concat(authors, ", ")
    end

    -- Announce vehicle group spawn information
    local message = "Vehicle Group Spawned:\n"
    message = message .. "Player: " .. player_name .. "\n"
    message = message .. "Vehicle Names: " .. vehicle_names_str .. "\n"
    message = message .. "Authors: " .. authors_str .. "\n"
    message = message .. "Group ID: " .. group_id .. "\n"
    message = message .. "Total Lag Cost: " .. total_lag_cost

    server.notify(-1,"[MAL]", message, 4)

    -- Determine lag cost limit based on whether it's a workshop vehicle
    local lag_cost_limit = PLAYER_LAG_COST_LIMIT
    if is_ws_vehicle then
        lag_cost_limit = PLAYER_LAG_COST_LIMIT_WS
    end

    -- Check if the player's lag cost exceeds the limit
    if player_lag_costs[peer_id] > lag_cost_limit then
        -- Despawn the player's vehicles
        despawnPlayerVehicles(peer_id)
        server.notify(peer_id, "[MAL]", "Your vehicles have been despawned due to exceeding the lag cost limit.", 2)
    end
end

-- Function to measure the TPS impact of a vehicle group
function measureGroupTPSImpact(group_id)
    -- Record pre-spawn TPS
    local pre_tps = TPS  -- Use the adjusted TPS variable
    -- Schedule TPS impact check after 8 seconds
    local check_time = server.getTimeMillisec() + 8000  -- Current time + 8000 milliseconds
    group_tps_impact[group_id] = {pre_tps = pre_tps, check_time = check_time}

    if debug_mode then
        server.announce("[DEBUG]", "Measuring TPS impact for group " .. group_id .. ". Pre-TPS: " .. pre_tps)
    end
end

-- Function to update and check TPS impact after countdown
function updateGroupTPSImpact()
    local current_time = server.getTimeMillisec()
    for group_id, impact_info in pairs(group_tps_impact) do
        if current_time >= impact_info.check_time then
            -- Time to check TPS impact
            local post_tps = TPS
            local tps_drop = impact_info.pre_tps - post_tps

            if debug_mode then
                server.announce("[DEBUG]", "TPS impact check for group " .. group_id .. ". Post-TPS: " .. post_tps .. ", TPS Drop: " .. tps_drop)
            end

            if tps_drop >= 5 then  -- TPS dropped by 5 or more
                -- Despawn the vehicle group
                despawnVehicleGroup(group_id)
                -- Notify the owner
                local peer_id = group_peer_mapping[group_id]
                server.announce("[MAL]", "Your vehicle has been despawned due to high TPS impact.", peer_id)
            end

            -- Clean up
            group_tps_impact[group_id] = nil
        end
    end
end

-- Function to calculate the lag cost for a single vehicle
function calculateVehicleLagCost(vehicle_id, peer_id, group_id)
    -- If peer_id is 0, it's the server or an addon; ignore this vehicle
    if peer_id < 0 then
        if debug_mode then
            server.announce("[DEBUG]", "Vehicle " .. vehicle_id .. " spawned by server/addon (peer_id 0). Skipping lag cost calculation.", -1)
        end
        return
    end
    -- Before calculating lag cost, check if the vehicle still exists
    local vehicle_data, is_success = server.getVehicleData(vehicle_id)
    if not is_success then
        if debug_mode then
            server.announce("[DEBUG]", "Vehicle " .. vehicle_id .. " does not exist. Skipping lag cost calculation.", -1)
        end
        return
    end

    -- Retrieve vehicle components
    local vehicle_components, is_success = server.getVehicleComponents(vehicle_id)
    if not is_success then
        if debug_mode then
            server.announce("[DEBUG]", "Failed to get components for vehicle " .. vehicle_id .. ". Skipping lag cost calculation.", -1)
        end
        return
    end

    local total_lag_cost = 0  -- Initialize total lag cost

    -- Include voxel count in lag cost
    local voxel_count = vehicle_components["voxels"] or 0
    local voxel_lag_cost = voxel_count * VOXEL_LAG_COST
    total_lag_cost = total_lag_cost + voxel_lag_cost

    -- Loop through each component type and calculate lag cost
    for component_type, components in pairs(vehicle_components["components"]) do
        if COMPONENT_LAG_COSTS[component_type] then
            local component_count = #components
            total_lag_cost = total_lag_cost + (COMPONENT_LAG_COSTS[component_type] * component_count)
        end
    end

    -- Retrieve vehicle data for author and name
    local vehicle_name = vehicle_data["name"] or "no name"
    local vehicle_authors = vehicle_data["authors"] or {}

    local is_ws_vehicle = false
    local player_name = server.getPlayerName(peer_id)

    local player_is_author = false

    if #vehicle_authors > 0 then
        -- Vehicle has authors (from workshop)
        is_ws_vehicle = true
        -- Check if the player's name is among the authors
        for _, author_info in ipairs(vehicle_authors) do
            local author_name = author_info.name or "Unknown"
            if author_name == player_name then
                -- Player is among the authors
                player_is_author = true
                break
            end
        end
        if player_is_author then
            is_ws_vehicle = false
        end
    else
        -- No authors, vehicle is self-made
        is_ws_vehicle = false
        vehicle_authors = { { name = "self" } }
    end

    -- Store the vehicle's lag cost along with peer_id, group_id, and other info
    vehicle_lag_costs[vehicle_id] = {
        lag_cost = total_lag_cost,
        peer_id = peer_id,
        group_id = group_id,
        is_ws = is_ws_vehicle,
        vehicle_name = vehicle_name,
        vehicle_authors = vehicle_authors
    }

    -- Update the player's total lag cost
    if not player_lag_costs[peer_id] then
        player_lag_costs[peer_id] = 0
    end
    player_lag_costs[peer_id] = player_lag_costs[peer_id] + total_lag_cost

    if debug_mode then
        server.announce("[DEBUG]", "Calculated lag cost for vehicle " .. vehicle_id .. ": " .. total_lag_cost, -1)
        server.announce("[DEBUG]", "Total lag cost for player " .. peer_id .. ": " .. player_lag_costs[peer_id], -1)
    end

    -- Removed per-vehicle announcement
end


-- Function to despawn all vehicles belonging to a player
function despawnPlayerVehicles(peer_id)
    -- If peer_id is 0, do not despawn server/addon vehicles
    if peer_id < 0 then
        if debug_mode then
            server.announce("[DEBUG]", "Attempted to despawn vehicles for peer_id 0 (server/addon). Ignoring.", -1)
        end
        return
    end
    local groups = player_vehicle_groups[peer_id]
    if groups then
        for group_id, vehicle_ids in pairs(groups) do
            -- Despawn the vehicle group
            despawnVehicleGroup(group_id)
            -- group_id will be handled in onVehicleDespawn
        end

        -- Notify the player
        server.announce("[MAL]", "Your vehicles have been despawned due to exceeding the lag cost limit.", peer_id)
    end

    if debug_mode then
        server.announce("[DEBUG]", "Despawned all vehicles for player " .. peer_id)
    end
end

-- Function to despawn a vehicle group
function despawnVehicleGroup(group_id)
    local peer_id = group_peer_mapping[group_id]
    if not peer_id then
        if debug_mode then
            server.announce("[DEBUG]", "Group " .. group_id .. " has no owner. Skipping despawn.", -1)
        end
        return
    end

    local group = player_vehicle_groups[peer_id] and player_vehicle_groups[peer_id][group_id]
    if group then
        for _, vehicle_id in ipairs(group) do
            local vehicle_info = vehicle_lag_costs[vehicle_id]
            if vehicle_info then
                -- Subtract vehicle's lag cost from the player's total
                player_lag_costs[peer_id] = player_lag_costs[peer_id] - vehicle_info.lag_cost
                if player_lag_costs[peer_id] <= 0 then
                    player_lag_costs[peer_id] = nil
                end

                -- Remove from vehicle tracking
                vehicle_lag_costs[vehicle_id] = nil
            end
        end
        -- Remove group from player_vehicle_groups
        player_vehicle_groups[peer_id][group_id] = nil

        -- If player has no more groups, clean up their entry
        if next(player_vehicle_groups[peer_id]) == nil then
            player_vehicle_groups[peer_id] = nil
        end
    end

    -- Remove group from group_peer_mapping
    group_peer_mapping[group_id] = nil

    -- Despawn the group
    server.despawnVehicleGroup(group_id, true)
    server.notify(peer_id, "[MAL]", "Your vehicle group " .. group_id .. " has been despawned.", 2)

    if debug_mode then
        server.announce("[DEBUG]", "Vehicle group " .. group_id .. " despawned. Updated lag cost for player " .. peer_id, -1)
    end
end


-- Function to despawn all vehicles belonging to a player
function despawnPlayerVehicles(peer_id)
    if not player_vehicle_groups[peer_id] then
        if debug_mode then
            server.announce("[DEBUG]", "No vehicles found for player " .. peer_id .. " to despawn.", -1)
        end
        return
    end

    for group_id, vehicles in pairs(player_vehicle_groups[peer_id]) do
        despawnVehicleGroup(group_id)
    end

    -- Clean up player data
    player_vehicle_groups[peer_id] = nil
    player_lag_costs[peer_id] = nil

    if debug_mode then
        server.announce("[DEBUG]", "All vehicles despawned for player " .. peer_id, -1)
    end
end

-- Function to handle vehicle despawning
function onVehicleDespawn(vehicle_id, peer_id)
    local vehicle_info = vehicle_lag_costs[vehicle_id]
    if vehicle_info then
        local owner_peer_id = vehicle_info.peer_id
        local group_id = vehicle_info.group_id

        -- Deduct lag cost from the player
        if player_lag_costs[owner_peer_id] then
            player_lag_costs[owner_peer_id] = player_lag_costs[owner_peer_id] - vehicle_info.lag_cost
            if player_lag_costs[owner_peer_id] <= 0 then
                player_lag_costs[owner_peer_id] = nil
            end
        end

        -- Remove vehicle from tracking
        vehicle_lag_costs[vehicle_id] = nil

        -- Remove from the group
        if player_vehicle_groups[owner_peer_id] and player_vehicle_groups[owner_peer_id][group_id] then
            for i, v_id in ipairs(player_vehicle_groups[owner_peer_id][group_id]) do
                if v_id == vehicle_id then
                    table.remove(player_vehicle_groups[owner_peer_id][group_id], i)
                    break
                end
            end

            -- If group is empty, remove it
            if #player_vehicle_groups[owner_peer_id][group_id] == 0 then
                player_vehicle_groups[owner_peer_id][group_id] = nil
                group_peer_mapping[group_id] = nil
            end
        end
    end

    if debug_mode then
        server.announce("[DEBUG]", "Vehicle " .. vehicle_id .. " despawned. Lag cost updated.", -1)
    end
end


-- Function to handle TPS countdown and vehicle despawning
function handleTPSCountdown()
    if tps_countdown then
        local tempo = server.getTimeMillisec()
        local elapsed_time = (tempo - tps_countdown_start_time) / 1000  -- Convert to seconds
        local remaining_time = math.ceil(tps_countdown - elapsed_time)

        if remaining_time > 0 then
            -- Update the popup screen with the remaining time
            local message = "Server TPS is low!\nRemoving high-lag vehicles in " .. remaining_time .. " seconds."
            server.setPopupScreen(-1, 1, "[MAL] Low TPS Warning", true, message, 0.5, 0.4)  -- Position slightly above center
        else
            -- Countdown has finished
            -- Remove the popup screen
            server.removePopup(-1, 1)
            -- Despawn the vehicle with the highest lag cost
            despawnHighestLagVehicle()
            tps_countdown = nil
            tps_warning_issued = false

            if debug_mode then
                server.announce("[DEBUG]", "Countdown finished. Despawning highest lag vehicle.", -1)
            end
        end
    end
end



-- Function to handle emergency cleanup countdown
function handleEmergencyCleanup()
    if emergency_cleanup_countdown then
        local current_time = server.getTimeMillisec()
        local elapsed_time = current_time - emergency_cleanup_start_time
        local remaining_time = math.ceil((emergency_cleanup_countdown - elapsed_time) / 1000)

        if remaining_time > 0 then
            -- Update the popup screen with the remaining time
            local message = "Emergency cleanup in " .. remaining_time .. " seconds due to very low TPS."
            server.setPopupScreen(-1, 2, "[MAL] Emergency Cleanup", true, message, 0.5, 0.4)  -- Position slightly above center

            if debug_mode then
                server.announce("[DEBUG]", "Emergency cleanup countdown: " .. remaining_time .. " seconds remaining.", -1)
            end
        else
            -- Countdown has finished
            -- Remove the popup screen
            server.removePopup(-1, 2)
            -- Time to perform emergency cleanup
            server.cleanVehicles()
            server.notify(-1, "[MAL]", "Emergency cleanup executed due to very low TPS.", 1)
            if debug_mode then
                server.announce("[DEBUG]", "Emergency cleanup executed.", -1)
            end
            emergency_cleanup_countdown = nil
        end
    end
end



-- Initialize last_despawn_time at the top of your script
local last_despawn_time = 0  -- Time in milliseconds

-- Function to despawn the vehicle with the highest lag cost
function despawnHighestLagVehicle()
    local current_time = server.getTimeMillisec()
    -- Check if at least 2000 milliseconds have passed since the last despawn
    if current_time - last_despawn_time < 2000 then
        -- Not enough time has passed; skip despawning
        if debug_mode then
            server.announce("[DEBUG]", "Despawn cooldown active. Skipping despawn.", -1)
        end
        return
    end

    -- Update the last despawn time
    last_despawn_time = current_time

    local highest_lag_cost = 0
    local vehicle_to_despawn = nil
    local vehicle_info_to_despawn = nil  -- Store the info along with the vehicle_id

    for vehicle_id, info in pairs(vehicle_lag_costs) do
        if info and info.lag_cost > highest_lag_cost and info.peer_id ~= 0 then
            highest_lag_cost = info.lag_cost
            vehicle_to_despawn = vehicle_id
            vehicle_info_to_despawn = info  -- Store the info here
        end
    end

    if vehicle_to_despawn and vehicle_info_to_despawn then
        local group_id = vehicle_info_to_despawn.group_id
        despawnVehicleGroup(group_id)
        -- Notify the owner
        local peer_id = vehicle_info_to_despawn.peer_id
        server.notify(peer_id, "[MAL]", "Your vehicle has been despawned due to high server load.", 2)  -- Notification type 2: failed_mission

        if debug_mode then
            server.announce("[DEBUG]", "Despawning vehicle with highest lag cost: Vehicle ID=" .. vehicle_to_despawn, -1)
        end
    else
        if debug_mode then
            server.announce("[DEBUG]", "No vehicles to despawn.", -1)
        end
    end
end



-- Function to show player's lag cost
function showPlayerLagCost(target_peer_id, requesting_peer_id)
    local lag_cost = player_lag_costs[target_peer_id] or 0
    local lag_cost_limit = PLAYER_LAG_COST_LIMIT
    local lag_cost_left = lag_cost_limit - lag_cost

    local message = "Lag Cost for Player " .. target_peer_id .. ":\nTotal Lag Cost: " .. lag_cost .. "\nLag Cost Left: " .. lag_cost_left

    -- List groups and their lag costs
    local groups = player_vehicle_groups[target_peer_id]
    if groups then
        message = message .. "\nVehicle Groups:"
        for group_id, vehicles in pairs(groups) do
            local group_lag_cost = 0
            for _, vehicle_id in ipairs(vehicles) do
                local vehicle_info = vehicle_lag_costs[vehicle_id]
                if vehicle_info then
                    group_lag_cost = group_lag_cost + vehicle_info.lag_cost
                end
            end
            message = message .. "\nGroup ID: " .. group_id .. " - Lag Cost: " .. group_lag_cost
        end
    else
        message = message .. "\nNo vehicle groups."
    end

    server.announce("[MAL]", message, requesting_peer_id)
end

-- Function to clear laggy vehicles
function clearLag(lag_threshold)
    local group_lag_costs = {}  -- [group_id] = total_lag_cost
    for vehicle_id, info in pairs(vehicle_lag_costs) do
        local group_id = info.group_id
        group_lag_costs[group_id] = (group_lag_costs[group_id] or 0) + info.lag_cost
    end

    for group_id, total_lag_cost in pairs(group_lag_costs) do
        if total_lag_cost > lag_threshold then
            despawnVehicleGroup(group_id)
            local peer_id = group_peer_mapping[group_id]
            server.notify(peer_id, "[MAL]", "Your vehicle has been despawned due to exceeding lag cost threshold.", 2)
            if debug_mode then
                server.announce("[DEBUG]", "Despawning vehicle group " .. group_id .. " due to total lag cost " .. total_lag_cost .. " exceeding threshold " .. lag_threshold)
            end
        end
    end
end

-- Function to repair a specific group
function repairGroup(peer_id, group_id, is_admin)
    local owner_peer_id = group_peer_mapping[group_id]
    if owner_peer_id == peer_id or is_admin then
        local vehicle_ids, is_success = server.getVehicleGroup(group_id)
        if is_success then
            for _, vehicle_id in ipairs(vehicle_ids) do
                server.resetVehicleState(vehicle_id)
            end
            server.notify(peer_id, "[MAL]", "Repaired vehicles in group " .. group_id .. ".", 4)  -- Notification type 4: complete_mission
            if debug_mode then
                server.announce("[DEBUG]", "Player " .. peer_id .. " repaired group " .. group_id)
            end
        else
            server.notify(peer_id, "[MAL]", "Failed to repair vehicles. Group not found.", 2)
        end
    else
        server.notify(peer_id, "[MAL]", "You do not have permission to repair this vehicle group.", 2)
    end
end

-- Function to repair all vehicles of a player
function repairPlayerVehicles(peer_id)
    local groups = player_vehicle_groups[peer_id]
    if groups then
        for group_id, vehicles in pairs(groups) do
            local vehicle_ids, is_success = server.getVehicleGroup(group_id)
            if is_success then
                for _, vehicle_id in ipairs(vehicle_ids) do
                    server.resetVehicleState(vehicle_id)
                end
            end
        end
        server.notify(peer_id, "[MAL]", "Repaired all your vehicles.", 4)
        if debug_mode then
            server.announce("[DEBUG]", "Player " .. peer_id .. " repaired all their vehicles.")
        end
    else
        server.notify(peer_id, "[MAL]", "You have no vehicles to repair.", 2)
    end
end


-- Function to handle custom chat commands
function onCustomCommand(full_message, peer_id, is_admin, is_auth, command, ...)
    command = command:lower()
    local args = {...}

    if command == "?maldebug" then
        if is_admin then
            debug_mode = not debug_mode
            local state = debug_mode and "enabled" or "disabled"
            server.announce("[MAL]", "Debug mode " .. state .. ".", peer_id)
        end
    elseif command == "?mallag" or command == "?mallist" then
        if args[1] then
            if is_admin then
                local target_peer_id = tonumber(args[1])
                if target_peer_id then
                    showPlayerLagCost(target_peer_id, peer_id)
                else
                    server.announce("[MAL]", "Invalid peer_id.", peer_id)
                end
            else
                server.announce("[MAL]", "You do not have permission to view other players' lag cost.", peer_id)
            end
        else
            showPlayerLagCost(peer_id, peer_id)
        end

    elseif command == "?malcleanup" then
        if is_admin then
            server.cleanVehicles()
            server.announce("[MAL]", "Cleanup has been issued by admin, sorry for any inconvenience caused.", -1)
            if debug_mode then
                server.announce("[DEBUG]", "Admin " .. peer_id .. " issued cleanup.", -1)
            end
        else
            server.announce("[MAL]", "You do not have permission to use this command.", peer_id)
        end

    elseif command == "?malclearlag" then
        if is_admin then
            local lag_threshold = tonumber(args[1])
            if not lag_threshold then
                lag_threshold = PLAYER_LAG_COST_LIMIT / 2
            end
            clearLag(lag_threshold)
            server.announce("[MAL]", "Cleared vehicles above lag cost " .. lag_threshold .. ".", -1)
            if debug_mode then
                server.announce("[DEBUG]", "Admin " .. peer_id .. " issued clearlag with threshold " .. lag_threshold .. ".", -1)
            end
        else
            server.announce("[MAL]", "You do not have permission to use this command.", peer_id)
        end

    elseif command == "?malmaxlagcost" then
        if is_admin then
            local new_limit = tonumber(args[1])
            if new_limit and new_limit >= 1000 and new_limit <= 50000 then
                PLAYER_LAG_COST_LIMIT = new_limit
                PLAYER_LAG_COST_LIMIT_WS = new_limit / 2  -- Reset WS limit to half of new limit
                server.announce("[MAL]", "Set maximum lag cost to " .. new_limit .. ".", -1)
                if debug_mode then
                    server.announce("[DEBUG]", "Admin " .. peer_id .. " set PLAYER_LAG_COST_LIMIT to " .. new_limit .. ".", -1)
                end
            else
                server.announce("[MAL]", "Invalid value. Please enter a number between 1000 and 50000.", peer_id)
            end
        else
            server.announce("[MAL]", "You do not have permission to use this command.", peer_id)
        end

    elseif command == "?malmaxlagcostws" then
        if is_admin then
            local new_limit = tonumber(args[1])
            if new_limit and new_limit >= 500 and new_limit <= 25000 then
                PLAYER_LAG_COST_LIMIT_WS = new_limit
                server.announce("[MAL]", "Set workshop vehicle lag cost limit to " .. new_limit .. ".", -1)
                if debug_mode then
                    server.announce("[DEBUG]", "Admin " .. peer_id .. " set PLAYER_LAG_COST_LIMIT_WS to " .. new_limit .. ".", -1)
                end
            else
                server.announce("[MAL]", "Invalid value. Please enter a number between 500 and 25000.", peer_id)
            end
        else
            server.announce("[MAL]", "You do not have permission to use this command.", peer_id)
        end

    elseif command == "?malmintps" then
        if is_admin then
            local tps_threshold = tonumber(args[1])
            if not tps_threshold then
                tps_threshold = 35
            end
            TPS_THRESHOLD = tps_threshold
            server.announce("[MAL]", "Set TPS threshold to " .. tps_threshold .. ".", -1)
            if debug_mode then
                server.announce("[DEBUG]", "Admin " .. peer_id .. " set TPS threshold to " .. tps_threshold .. ".", -1)
            end
        else
            server.announce("[MAL]", "You do not have permission to use this command.", peer_id)
        end

    elseif command == "?malhelp" then
        local help_message = "Anti-Lag Commands:\n"
        help_message = help_message .. "?mallag/mallist - Show your current lag cost and remaining lag cost.\n"
        help_message = help_message .. "?whatislagcost - Explains how lag cost is calculated.\n"
        
        if is_admin then
            help_message = help_message .. "\nAdmin Commands:\n"
            help_message = help_message .. "?maldebug - Toggle debug mode.\n"
            help_message = help_message .. "?malcleanup - Despawn all player vehicles.\n"
            help_message = help_message .. "?malclearlag [lag_cost] - Despawn vehicle groups exceeding lag_cost.\n"
            help_message = help_message .. "?malmaxlagcost <value> - Set maximum lag cost limit.\n"
            help_message = help_message .. "?malmaxlagcostws [value] - Set workshop vehicle lag cost limit.\n"
            help_message = help_message .. "?malmintps [tps_value] - Set TPS threshold.\n"
        end
        server.announce("[MAL]", help_message, peer_id)
    end
end

-- onTick function
function onTick(game_ticks)
    -- Update TPS
    updateTPS(game_ticks)

    -- Handle TPS countdown
    handleTPSCountdown()

    -- Handle emergency cleanup
    handleEmergencyCleanup()

    -- Update vehicle loading status
    updateVehicleLoading()

    -- Update TPS impact checks
    updateGroupTPSImpact()
end

-- Add this function after other helper functions
function isPlayerGroupOwner(peer_id, group_id)
    -- If peer_id is admin, they can control any group
    if player_vehicle_groups[peer_id] and player_vehicle_groups[peer_id][group_id] then
        return true
    end
    return false
end

-- Add to onTick after other update functions
function updateDisconnectedPlayers()
    local current_time = server.getTimeMillisec()
    
    for steam_id, data in pairs(disconnected_players) do
        if current_time >= data.despawn_time then
            -- Time's up - despawn their vehicles
            if player_vehicle_groups[data.peer_id] then
                despawnPlayerVehicles(data.peer_id)
                if debug_mode then
                    server.announce("[DEBUG]", "Despawned vehicles for disconnected player (Steam ID: " .. steam_id .. ")", -1)
                end
            end
            -- Remove from tracking
            disconnected_players[steam_id] = nil
        end
    end
end
