-- Define the maximum allowable lag cost per player
local PLAYER_LAG_COST_LIMIT = 8000  -- Adjust this value as needed
local PLAYER_LAG_COST_LIMIT_WS = PLAYER_LAG_COST_LIMIT / 2  -- Lag cost limit for workshop vehicles not authored by the player

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
local debug_mode = false  -- Debug mode is off by default

-- Reload Countdown Variables
reload_countdown_active = false
reload_countdown_time = 0
reload_countdown_start_time = 0

-- NPC Management Variables
local player_npcs = {}  -- [peer_id] = { npc_id = { name = string, type = number } }

-- Tables to store tracking data
local vehicle_lag_costs = {}         -- [vehicle_id] = {lag_cost = number, peer_id = number, group_id = number, is_ws = boolean}
local player_vehicle_groups = {}     -- [peer_id] = {group_id = {vehicle_ids}}
local group_peer_mapping = {}        -- [group_id] = peer_id
local player_lag_costs = {}          -- [peer_id] = total_lag_cost
local vehicle_loading = {}           -- [vehicle_id] = {peer_id, group_id}
local group_tps_impact = {}          -- [group_id] = {pre_tps = number, check_time = number}

function onCreate(is_world_create)
    if not is_world_create then
        -- This is a script reload, not a world creation
        -- Start the reload countdown
        reload_countdown_active = true
        reload_countdown_time = 5  -- Countdown time in seconds
        reload_countdown_start_time = server.getTimeMillisec()

        -- Display a popup screen in the center for all players
        local message = "Server scripts have been reloaded. Resuming operations in " .. reload_countdown_time .. " seconds."
        server.setPopupScreen(-1, 0, "[MAL] Script Reloaded", true, message, 0.5, 0.5)  -- Position (0.5, 0.5) centers the popup

        if debug_mode then
            server.announce("[DEBUG]", "Scripts have been reloaded via onCreate. Starting countdown.", -1)
        end
    end
end

-- Function to handle the reload countdown
function handleReloadCountdown()
    if reload_countdown_active then
        local current_time = server.getTimeMillisec()
        local elapsed_time = (current_time - reload_countdown_start_time) / 1000  -- Convert to seconds
        local remaining_time = math.ceil(reload_countdown_time - elapsed_time)

        if remaining_time > 0 then
            -- Update the popup screen with the remaining time
            local message = "Server scripts have been reloaded. Resuming operations after cleanup in " .. remaining_time .. " seconds."
            server.setPopupScreen(-1, 0, "[MAL] Script Reloaded", true, message, 0.5, 0.5)
        else
            -- Countdown has finished
            reload_countdown_active = false
            -- Remove the popup screen
            server.removePopup(-1, 0)
            -- Initialize or reset variables and tables
            TIME = server.getTimeMillisec()    
            tps_countdown = nil
            tps_warning_issued = false
            emergency_cleanup_countdown = nil
            emergency_cleanup_start_time = nil
            server.cleanVehicles()
            -- Reset tracking tables
            vehicle_lag_costs = {}
            vehicle_loading = {}
            group_tps_impact = {}
            group_peer_mapping = {}
            player_vehicle_groups = {}
            player_lag_costs = {}
            player_npcs = {}
            if debug_mode then
                server.announce("[DEBUG]", "Reload countdown completed and cleanup commenced. Resuming normal operations.", -1)
            end
        end
    end
end

-- Function to handle vehicle spawning
function onVehicleSpawn(vehicle_id, peer_id, x, y, z, cost, group_id)
    if debug_mode then
        server.announce("[DEBUG]", "Vehicle spawned: ID=" .. vehicle_id .. ", Peer ID=" .. peer_id .. ", Group ID=" .. group_id)
    end

    -- If peer_id is 0, it's the server or an addon; ignore this vehicle
    if peer_id == 0 then
        if debug_mode then
            server.announce("[DEBUG]", "Vehicle " .. vehicle_id .. " spawned by server/addon (peer_id 0). Ignoring.", -1)
        end
        return
    end

    -- Store the group with the associated peer_id if not already stored
    if not group_peer_mapping[group_id] then
        group_peer_mapping[group_id] = peer_id

        -- Initialize player's vehicle group list if not existing
        if not player_vehicle_groups[peer_id] then
            player_vehicle_groups[peer_id] = {}
            player_lag_costs[peer_id] = 0
        end

        -- Initialize the group in the player's vehicle groups
        player_vehicle_groups[peer_id][group_id] = {}
    end

    -- Add the vehicle to the player's group
    table.insert(player_vehicle_groups[peer_id][group_id], vehicle_id)

    -- Start tracking vehicle loading status
    vehicle_loading[vehicle_id] = {peer_id = peer_id, group_id = group_id}
end



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
                    -- Announce the group spawn
                    announceGroupSpawn(info.group_id, info.peer_id)

                    -- Measure TPS impact
                    measureGroupTPSImpact(info.group_id)
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
    if peer_id == 0 then
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

    server.announce("[MAL]", message)

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
    if peer_id == 0 then
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
    if peer_id == 0 then
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
    server.despawnVehicleGroup(group_id, true)
    -- Notify the owner
    local peer_id = group_peer_mapping[group_id]
    server.notify(peer_id, "[MAL]", "Your vehicle has been despawned due to high server load.", 2)  -- Notification type 2: failed_mission
    if debug_mode then
        server.announce("[DEBUG]", "Despawning vehicle group " .. group_id)
    end
    -- Vehicles will be handled in onVehicleDespawn
end

-- Function to handle vehicle despawning
function onVehicleDespawn(vehicle_id, peer_id)
    if debug_mode then
        server.announce("[DEBUG]", "Vehicle despawned: ID=" .. vehicle_id .. ", Peer ID=" .. peer_id, -1)
    end

    -- If peer_id is 0, it's the server or an addon; ignore this vehicle
    if peer_id == 0 then
        if debug_mode then
            server.announce("[DEBUG]", "Vehicle " .. vehicle_id .. " despawned by server/addon (peer_id 0). Ignoring.", -1)
        end
        return
    end

    -- Remove vehicle from loading list if it's there
    if vehicle_loading[vehicle_id] then
        vehicle_loading[vehicle_id] = nil
        if debug_mode then
            server.announce("[DEBUG]", "Vehicle " .. vehicle_id .. " removed from loading list.", -1)
        end
    end

    -- Retrieve vehicle info
    local vehicle_info = vehicle_lag_costs[vehicle_id]
    if vehicle_info then
        local owner_peer_id = vehicle_info.peer_id
        local group_id = vehicle_info.group_id
        local lag_cost = vehicle_info.lag_cost

        -- Update player's lag cost
        if player_lag_costs[owner_peer_id] then
            player_lag_costs[owner_peer_id] = player_lag_costs[owner_peer_id] - lag_cost

            if debug_mode then
                server.announce("[DEBUG]", "Updated lag cost for player " .. owner_peer_id .. ": " .. (player_lag_costs[owner_peer_id] or 0), -1)
            end

            if player_lag_costs[owner_peer_id] <= 0 then
                player_lag_costs[owner_peer_id] = nil
                if debug_mode then
                    server.announce("[DEBUG]", "Player " .. owner_peer_id .. " has no more lag cost.", -1)
                end
            end
        end

        -- Remove vehicle from tracking
        vehicle_lag_costs[vehicle_id] = nil

        -- Remove vehicle from player's group
        if player_vehicle_groups[owner_peer_id] and player_vehicle_groups[owner_peer_id][group_id] then
            local group = player_vehicle_groups[owner_peer_id][group_id]
            for i, v_id in ipairs(group) do
                if v_id == vehicle_id then
                    table.remove(group, i)
                    break
                end
            end

            -- If group is empty, remove it
            if #group == 0 then
                player_vehicle_groups[owner_peer_id][group_id] = nil
                group_peer_mapping[group_id] = nil
                if debug_mode then
                    server.announce("[DEBUG]", "Removed empty group " .. group_id .. " for player " .. owner_peer_id, -1)
                end

                -- Check if player has any more groups
                if next(player_vehicle_groups[owner_peer_id]) == nil then
                    player_vehicle_groups[owner_peer_id] = nil
                    if debug_mode then
                        server.announce("[DEBUG]", "Player " .. owner_peer_id .. " has no more vehicle groups.", -1)
                    end
                end
            end
        else
            if debug_mode then
                server.announce("[DEBUG]", "Group " .. group_id .. " not found for player " .. owner_peer_id, -1)
            end
        end
    else
        -- Vehicle lag cost was not calculated (e.g., despawned before simulating)
        -- Attempt to retrieve owner_peer_id and group_id from tracking data
        local owner_peer_id = nil
        local group_id = nil

        -- Check if vehicle exists in any player's vehicle groups
        for peer_id, groups in pairs(player_vehicle_groups) do
            for g_id, vehicles in pairs(groups) do
                for i, v_id in ipairs(vehicles) do
                    if v_id == vehicle_id then
                        owner_peer_id = peer_id
                        group_id = g_id
                        -- Remove vehicle from the group
                        table.remove(vehicles, i)
                        break
                    end
                end
                if owner_peer_id then
                    -- If group is empty, remove it
                    if #vehicles == 0 then
                        player_vehicle_groups[owner_peer_id][group_id] = nil
                        group_peer_mapping[group_id] = nil
                        if debug_mode then
                            server.announce("[DEBUG]", "Removed empty group " .. group_id .. " for player " .. owner_peer_id, -1)
                        end

                        -- Check if player has any more groups
                        if next(player_vehicle_groups[owner_peer_id]) == nil then
                            player_vehicle_groups[owner_peer_id] = nil
                            if debug_mode then
                                server.announce("[DEBUG]", "Player " .. owner_peer_id .. " has no more vehicle groups.", -1)
                            end
                        end
                    end
                    break
                end
            end
            if owner_peer_id then
                break
            end
        end

        if owner_peer_id then
            -- Since we never calculated lag cost, we might not have added it to player_lag_costs
            -- Ensure player_lag_costs entry exists
            if player_lag_costs[owner_peer_id] then
                -- If necessary, adjust player's lag cost (if we had an estimated lag cost)
                -- For this case, since lag cost was not added, we do not need to subtract it
                if debug_mode then
                    server.announce("[DEBUG]", "Vehicle " .. vehicle_id .. " despawned before lag cost calculation. No lag cost to remove for player " .. owner_peer_id, -1)
                end
            end
        else
            if debug_mode then
                server.announce("[DEBUG]", "Vehicle info not found for ID " .. vehicle_id .. " in any tracking data.", -1)
            end
        end
    end
end


-- Function to calculate and update TPS
function updateTPS(game_ticks)
    local tempo = server.getTimeMillisec()

    if tempo - TIME < 1996 then
        TICKS = TICKS + (game_ticks * 0.49875)
    else
        -- TICKS remains the same
    end

    if tempo - TIME >= 1996 then
        TPS = TICKS
        TIME = tempo
        TICKS = 0
    end

    -- Optionally, display TPS
    server.setPopupScreen(-1, 3, "TPS", true, "TPS: " .. tostring(TPS), 0.9, 0.8)

    -- Check if TPS is below threshold
    if TPS < TPS_THRESHOLD then
        if not tps_countdown then
            tps_countdown = 8  -- Start 8 seconds countdown
            tps_warning_issued = false
            tps_countdown_start_time = tempo

            if debug_mode then
                server.announce("[DEBUG]", "TPS dropped below threshold. Starting countdown.", -1)
            end
        end
    else
        if tps_countdown then
            -- Remove the TPS countdown popup if TPS recovers
            server.removePopup(-1, 1)
            if debug_mode then
                server.announce("[DEBUG]", "TPS recovered above threshold. Countdown stopped.", -1)
            end
        end
        tps_countdown = nil
        tps_warning_issued = false
    end

    -- Emergency cleanup check
    if TPS < emergency_cleanup_tps then
        if not emergency_cleanup_countdown then
            emergency_cleanup_countdown = 2500  -- milliseconds
            emergency_cleanup_start_time = tempo
            -- Display the emergency cleanup popup
            local message = "Emergency cleanup in 2 seconds due to very low TPS."
            server.setPopupScreen(-1, 2, "[MAL] Emergency Cleanup", true, message, 0.5, 0.4)  -- Position slightly above center

            if debug_mode then
                server.announce("[DEBUG]", "Emergency cleanup initiated.", -1)
            end
        end
    else
        if emergency_cleanup_countdown then
            -- Remove the emergency cleanup popup if TPS recovers
            server.removePopup(-1, 2)
        end
        emergency_cleanup_countdown = nil
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

    if command == "?debug" then
        if is_admin then
            debug_mode = not debug_mode  -- Toggle debug mode
            local state = debug_mode and "enabled" or "disabled"
            server.announce("[MAL]", "Debug mode " .. state .. ".", peer_id)
        else
            server.announce("[MAL]", "You do not have permission to use this command.", peer_id)
        end

    elseif command == "?vlag" then
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

    elseif command == "?cleanup" then
        if is_admin then
            server.cleanVehicles()
            server.announce("[MAL]", "Cleanup has been issued by admin, sorry for any inconvenience caused.", -1)
            if debug_mode then
                server.announce("[DEBUG]", "Admin " .. peer_id .. " issued cleanup.", -1)
            end
        else
            server.announce("[MAL]", "You do not have permission to use this command.", peer_id)
        end

    elseif command == "?clearlag" then
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

    elseif command == "?maxlagcost" then
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

    elseif command == "?maxlagcostws" then
        if is_admin then
            local new_limit = tonumber(args[1])
            if new_limit and new_limit >= 500 and new_limit <= 25000 then
                PLAYER_LAG_COST_LIMIT_WS = new_limit
                server.announce("[MAL]", "Set workshop vehicle lag cost limit to " .. new_limit .. ".", -1)
                if debug_mode then
                    server.announce("[DEBUG]", "Admin " .. peer_id .. " set PLAYER_LAG_COST_LIMIT_WS to " .. new_limit .. ".", -1)
                end
            elseif not(new_limit) then
                -- Reset to half of current PLAYER_LAG_COST_LIMIT
                PLAYER_LAG_COST_LIMIT_WS = PLAYER_LAG_COST_LIMIT / 2
                server.announce("[MAL]", "Reset workshop vehicle lag cost limit to " .. PLAYER_LAG_COST_LIMIT_WS .. ".", -1)
                if debug_mode then
                    server.announce("[DEBUG]", "Admin " .. peer_id .. " reset PLAYER_LAG_COST_LIMIT_WS to " .. PLAYER_LAG_COST_LIMIT_WS .. ".", -1)
                end
            else
                server.announce("[MAL]", "Invalid value. Please enter a number between 500 and 25000.", peer_id)
            end
        else
            server.announce("[MAL]", "You do not have permission to use this command.", peer_id)
        end

    elseif command == "?announce" then
        if is_admin then
            local countdown = tonumber(args[1]) or 12  -- Default to 12 seconds
            if countdown <= 0 then
                countdown = 12  -- Ensure countdown is positive
            end
            local full_message = table.concat(args, " ")
            if tonumber(args[1]) then
                full_message = table.concat(args, " ", 2)
            end
            if full_message == "" then
                server.announce("[MAL]", "Please provide a message to announce.", peer_id)
                return
            end
            -- Remove any leading question marks or command prefixes
            full_message = full_message:gsub("^%??announce%s*", "")
            full_message = full_message:gsub("^%?", "")
            -- Start the announcement
            startAnnouncement(peer_id, full_message, countdown)
            server.announce("[ANNOUNCEMENT]", full_message)
            server.notify(-1, "[ANNOUNCEMENT]", full_message,8)
        else
            server.announce("[MAL]", "You dont have the permission to use this command.", peer_id)
        end
    -- NPC Management Commands
    elseif command == "?npc" then
        local name = args[1]
        local char_type = tonumber(args[2]) or 11  -- Default to 11 (civilian)
        if not name then
            server.announce("[MAL]", "Usage: ?npc <name> [type]", peer_id)
            return
        end
        spawnNPC(peer_id, name, char_type)
    elseif command == "?delnpc" then
        local npc_id = tonumber(args[1])
        despawnNPC(peer_id, npc_id)
    elseif command == "?npclist" then
        listNPCs(peer_id)
    elseif command == "?aiType" then
        local npc_id = tonumber(args[1])
        local ai_state = tonumber(args[2]) or 0  -- Default to 0 (none)
        if not npc_id then
            server.announce("[MAL]", "Usage: ?AIType <npc_id> [ai_state]", peer_id)
            return
        end
        setNPC_AIState(peer_id, npc_id, ai_state)
    
    elseif command == "?repair" then
        local group_id = args[1]
        if group_id then
            group_id = tonumber(group_id)
            if group_id then
                repairGroup(peer_id, group_id, is_admin)
            else
                server.announce("[MAL]", "Invalid group_id.", peer_id)
            end
        else
            repairPlayerVehicles(peer_id)
        end
    elseif command == "?mintps" then
        if is_admin then
            local TPS_THRESHOLD = tonumber(args[1])
            if not TPS_THRESHOLD then
                TPS_THRESHOLD = 35
            end
            server.announce("[MAL]", "Set TPS threshold for emergency cleanup to " .. TPS_THRESHOLD .. ".", -1)
            if debug_mode then
                server.announce("[DEBUG]", "Admin " .. peer_id .. " set emergency cleanup TPS threshold to " .. TPS_THRESHOLD .. ".", -1)
            end
        else
            server.announce("[MAL]", "You do not have permission to use this command.", peer_id)
        end
    elseif command == "?cleartps" then
        if is_admin then
            local tps_threshold = tonumber(args[1])
            if not tps_threshold then
                tps_threshold = math.ceil(TPS_THRESHOLD / 2)
            end
            emergency_cleanup_tps = tps_threshold
            server.announce("[MAL]", "Set TPS threshold for emergency cleanup to " .. tps_threshold .. ".", -1)
            if debug_mode then
                server.announce("[DEBUG]", "Admin " .. peer_id .. " set emergency cleanup TPS threshold to " .. tps_threshold .. ".", -1)
            end
        else
            server.announce("[MAL]", "You do not have permission to use this command.", peer_id)
        end
    elseif command == "?whatislagcost" then
        local lag_guide = "heres how lag cost is calculated:\n"
        lag_guide = lag_guide .."each voxel: 0.2\n"
        lag_guide = lag_guide .."[signs] = 3,\n"
        lag_guide = lag_guide .."[seats] = 2\n"
        lag_guide = lag_guide .."[buttons] = 2\n"
        lag_guide = lag_guide .."[dials] = 2\n"
        lag_guide = lag_guide .."[tanks] = 5\n"
        lag_guide = lag_guide .."[batteries] = 10\n"
        lag_guide = lag_guide .."[hoppers] = 7\n"
        lag_guide = lag_guide .."[guns] = 20\n"
        lag_guide = lag_guide .."[rope_hooks] = 4\n\n"
        lag_guide = lag_guide .."Everything togerther is the lag cost!"
        
        server.announce("[MAL]", lag_guide, peer_id)
        
    elseif command == "?mhelp" then
        local help_message = "Available Commands:\n"
        help_message = help_message .. "?vlag - Show your current lag cost and remaining lag cost.\n"
        help_message = help_message .. "?repair [group_id] - Repair your vehicles. If group_id is provided, repairs that group.\n"
        help_message = help_message .. "?help - Show this help message.\n"
        help_message = help_message .. "?announce <countdown> <message> - Make an announcement with an optional countdown.\n"
        help_message = help_message .. "?npc <name> [type] - Spawn an NPC with the specified name and type.\n"
        help_message = help_message .. "?delnpc [npc_id] - Despawn your NPCs or a specific NPC by ID.\n"
        help_message = help_message .. "?npclist - List your current spawned NPCs.\n"
        help_message = help_message .. "?AIType <npc_id> [ai_state] - Set AI state for your NPC.\n"
    
        if is_admin then
            help_message = help_message .. "\nAdmin Commands:\n"
            help_message = help_message .. "?debug - Toggle debug mode.\n"
            help_message = help_message .. "?cleanup - Despawn all player vehicles.\n"
            help_message = help_message .. "?clearlag [lag_cost] - Despawn vehicle groups exceeding lag_cost.\n"
            help_message = help_message .. "?maxlagcost <value> - Set maximum lag cost limit.\n"
            help_message = help_message .. "?maxlagcostws [value] - Set workshop vehicle lag cost limit.\n"
            help_message = help_message .. "?mintps [tps_value] - Set TPS threshold for normal lag despawn.\n"
            help_message = help_message .. "?cleartps [tps_value] - Set TPS threshold for emergency cleanup.\n"
            help_message = help_message .. "?vlag [peer_id] - View another player's lag cost.\n"
        end
        server.announce("Server", help_message, peer_id)

    end
end

-- Function to start an announcement
function startAnnouncement(peer_id, message, countdown)
    local announcer_name = server.getPlayerName(peer_id)
    local full_message = "Announcement by " .. announcer_name .. ":\n" .. message
    local end_time = server.getTimeMillisec() + (countdown * 1000)
    local popup_id = 100 + peer_id  -- Unique popup ID per player

    -- Function to update the announcement popup
    local function updateAnnouncement()
        local current_time = server.getTimeMillisec()
        local remaining_time = math.ceil((end_time - current_time) / 1000)
        if remaining_time > 0 then
            -- Update the popup screen with the remaining time
            local display_message = full_message .. "\nClosing in " .. remaining_time .. " seconds."
            server.setPopupScreen(-1, popup_id, "[ANNOUNCEMENT]", true, display_message, 0.5, 0.5)
        else
            -- Countdown has finished
            -- Remove the popup screen
            server.removePopup(-1, popup_id)
            -- Remove the update function from onTick
            announcement_popups[popup_id] = nil
        end
    end

    -- Store the update function to be called in onTick
    announcement_popups[popup_id] = updateAnnouncement
end

-- Table to store active announcement popups
announcement_popups = {}

-- Function to update announcement popups
function updateAnnouncements()
    for _, updateFunction in pairs(announcement_popups) do
        updateFunction()
    end
end

-- Function to spawn an NPC
function spawnNPC(peer_id, name, char_type)
    -- Limit NPCs per player to 3
    if not player_npcs[peer_id] then
        player_npcs[peer_id] = {}
    end
    local npc_count = 0
    for _ in pairs(player_npcs[peer_id]) do
        npc_count = npc_count + 1
    end
    if npc_count >= 3 then
        server.announce("[MAL]", "You have reached the NPC limit (3). Despawn an NPC to spawn a new one.", peer_id)
        return
    end
    -- Get player's position to spawn NPC nearby
    local player_transform, is_success = server.getPlayerPos(peer_id)
    if not is_success then
        server.announce("[MAL]", "Could not get your position. Try again later.", peer_id)
        return
    end
    -- Adjust position slightly
    player_transform[13] = player_transform[13] + 2  -- Raise NPC 2 meters above ground
    -- Spawn the NPC
    local npc_id, is_success = server.spawnCharacter(player_transform, char_type)
    if is_success then
        server.setCharacterData(npc_id, 100, true, false)  -- Set NPC to interactable, no AI by default
        server.setCharacterTooltip(npc_id, name)
        -- Store NPC info
        player_npcs[peer_id][npc_id] = { name = name, type = char_type }
        server.announce("[MAL]", "NPC '" .. name .. "' spawned with ID " .. npc_id .. ".", peer_id)
    else
        server.announce("[MAL]", "Failed to spawn NPC. Try again later.", peer_id)
    end
end

-- Function to despawn NPCs
function despawnNPC(peer_id, npc_id)
    if not player_npcs[peer_id] then
        server.announce("[MAL]", "You have no NPCs to despawn.", peer_id)
        return
    end
    if npc_id then
        if player_npcs[peer_id][npc_id] or is_admin then
            server.despawnObject(npc_id, true)
            player_npcs[peer_id][npc_id] = nil
            server.announce("[MAL]", "NPC with ID " .. npc_id .. " has been despawned.", peer_id)
        else
            server.announce("[MAL]", "You do not own NPC with ID " .. npc_id .. ".", peer_id)
        end
    else
        -- Despawn all NPCs for the player
        for id in pairs(player_npcs[peer_id]) do
            server.despawnObject(id, true)
        end
        player_npcs[peer_id] = {}
        server.announce("[MAL]", "All your NPCs have been despawned.", peer_id)
    end
end

-- Function to list player's NPCs
function listNPCs(peer_id)
    if not player_npcs[peer_id] or next(player_npcs[peer_id]) == nil then
        server.announce("[MAL]", "You have no NPCs.", peer_id)
        return
    end
    local message = "Your NPCs:\n"
    for id, info in pairs(player_npcs[peer_id]) do
        message = message .. "ID: " .. id .. ", Name: " .. info.name .. ", Type: " .. info.type .. "\n"
    end
    server.announce("[MAL]", message, peer_id)
end

-- Function to set AI state for NPC
function setNPC_AIState(peer_id, npc_id, ai_state)
    if player_npcs[peer_id] and player_npcs[peer_id][npc_id] or is_admin then
        server.setCharacterData(npc_id, 100, true, true)  -- Enable AI
        server.setAIState(npc_id, ai_state)
        server.announce("[MAL]", "Set AI state for NPC ID " .. npc_id .. " to " .. ai_state .. ".", peer_id)
    else
        server.announce("[MAL]", "You do not own NPC with ID " .. npc_id .. ".", peer_id)
    end
end

-- onTick function
function onTick(game_ticks)
    -- Handle reload countdown
    handleReloadCountdown()

    -- Update announcement popups
    updateAnnouncements()

    -- Only proceed with normal operations if the reload countdown is not active
    if not reload_countdown_active then
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

        -- Other game logic...
    else
        -- Optionally, you can pause other operations or provide feedback during the countdown
        if debug_mode then
            server.announce("[DEBUG]", "Reload countdown active. Pausing normal operations.", -1)
        end
    end
end
