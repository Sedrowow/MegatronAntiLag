-- Define the maximum allowable lag cost per player
local PLAYER_LAG_COST_LIMIT = 2000  -- Adjust this value as needed

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
local emergency_cleanup_tps = 10  -- Default TPS threshold for emergency cleanup
local emergency_cleanup_countdown = nil
local emergency_cleanup_start_time = nil

-- Debug Mode Variable
local debug_mode = false  -- Debug mode is off by default

-- Tables to store tracking data
local vehicle_lag_costs = {}         -- [vehicle_id] = {lag_cost = number, peer_id = number, group_id = number}
local player_vehicle_groups = {}     -- [peer_id] = {group_id = {vehicle_ids}}
local group_peer_mapping = {}        -- [group_id] = peer_id
local player_lag_costs = {}          -- [peer_id] = total_lag_cost
local vehicle_loading = {}           -- [vehicle_id] = {peer_id, group_id}
local group_tps_impact = {}          -- [group_id] = {pre_tps = number, check_time = number}

-- Function to handle vehicle spawning
function onVehicleSpawn(vehicle_id, peer_id, x, y, z, cost, group_id)
    if debug_mode then
        server.announce("[DEBUG]", "Vehicle spawned: ID=" .. vehicle_id .. ", Peer ID=" .. peer_id .. ", Group ID=" .. group_id)
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
        if is_success and vehicle_data["simulating"] then
            if debug_mode then
                server.announce("[DEBUG]", "Vehicle is now simulating: ID=" .. vehicle_id)
            end

            -- Vehicle is loaded; calculate lag cost
            calculateVehicleLagCost(vehicle_id, info.peer_id, info.group_id)

            -- Remove from loading list
            vehicle_loading[vehicle_id] = nil

            -- Check if all vehicles in the group are simulating
            if areAllGroupVehiclesSimulating(info.group_id) then
                -- Measure TPS impact
                measureGroupTPSImpact(info.group_id)
            end
        end
    end
end

-- Function to check if all vehicles in a group are simulating
function areAllGroupVehiclesSimulating(group_id)
    local peer_id = group_peer_mapping[group_id]
    local vehicles = player_vehicle_groups[peer_id][group_id]
    for _, vehicle_id in ipairs(vehicles) do
        local vehicle_data, is_success = server.getVehicleData(vehicle_id)
        if not (is_success and vehicle_data["simulating"]) then
            return false
        end
    end
    if debug_mode then
        server.announce("[DEBUG]", "All vehicles in group " .. group_id .. " are now simulating.")
    end
    return true
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
    local vehicle_components, is_success = server.getVehicleComponents(vehicle_id)

    if is_success then
        local total_lag_cost = 0

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

        -- Store the vehicle's lag cost along with peer_id and group_id
        vehicle_lag_costs[vehicle_id] = {
            lag_cost = total_lag_cost,
            peer_id = peer_id,
            group_id = group_id
        }

        -- Update the player's total lag cost
        if not player_lag_costs[peer_id] then
            player_lag_costs[peer_id] = 0
        end
        player_lag_costs[peer_id] = player_lag_costs[peer_id] + total_lag_cost

        if debug_mode then
            server.announce("[DEBUG]", "Calculated lag cost for vehicle " .. vehicle_id .. ": " .. total_lag_cost)
            server.announce("[DEBUG]", "Total lag cost for player " .. peer_id .. ": " .. player_lag_costs[peer_id])
        end

        -- Check if the player's lag cost exceeds the limit
        if player_lag_costs[peer_id] > PLAYER_LAG_COST_LIMIT then
            -- Despawn the player's vehicles
            despawnPlayerVehicles(peer_id)
        end
    end
end

-- Function to despawn all vehicles belonging to a player
function despawnPlayerVehicles(peer_id)
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
        server.announce("[DEBUG]", "Vehicle despawned: ID=" .. vehicle_id)
    end

    -- Retrieve vehicle info
    local vehicle_info = vehicle_lag_costs[vehicle_id]
    if vehicle_info then
        local owner_peer_id = vehicle_info.peer_id
        local group_id = vehicle_info.group_id
        local lag_cost = vehicle_info.lag_cost

        -- Update player's lag cost
        player_lag_costs[owner_peer_id] = player_lag_costs[owner_peer_id] - lag_cost

        if debug_mode then
            server.announce("[DEBUG]", "Updated lag cost for player " .. owner_peer_id .. ": " .. player_lag_costs[owner_peer_id])
        end

        -- Remove vehicle from tracking
        vehicle_lag_costs[vehicle_id] = nil

        -- Remove vehicle from player's group
        local group = player_vehicle_groups[owner_peer_id][group_id]
        if group then
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
                    server.announce("[DEBUG]", "Removed empty group " .. group_id .. " for player " .. owner_peer_id)
                end
            end
        end

        -- If player has no more vehicles, remove them from tracking
        if next(player_vehicle_groups[owner_peer_id]) == nil then
            player_vehicle_groups[owner_peer_id] = nil
            player_lag_costs[owner_peer_id] = nil
            if debug_mode then
                server.announce("[DEBUG]", "Player " .. owner_peer_id .. " has no more vehicles.")
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
    server.setPopupScreen(-1, 1, "TPS", true, "TPS: " .. tostring(TPS), 0.9, 0.8)

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
            if debug_mode then
                server.announce("[DEBUG]", "TPS recovered above threshold. Countdown stopped.")
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
            server.notify(-1, "[MAL]", "Emergency cleanup initiated due to very low TPS!", 1)  -- Notification type 1: new_mission_critical
            if debug_mode then
                server.announce("[DEBUG]", "Emergency cleanup initiated.")
            end
        end
    else
        emergency_cleanup_countdown = nil
    end
end


-- Function to handle TPS countdown and vehicle despawning
function handleTPSCountdown()
    if tps_countdown then
        local tempo = server.getTimeMillisec()
        local elapsed_time = (tempo - tps_countdown_start_time) / 1000  -- Convert to seconds
        local remaining_time = tps_countdown - elapsed_time

        if not tps_warning_issued then
            -- Notify all players once
            server.announce("[MAL]", "[MAL] TPS is low! Removing high-lag vehicles in " .. math.ceil(remaining_time) .. " seconds.", -1)
            tps_warning_issued = true

            if debug_mode then
                server.announce("[DEBUG]", "Issued low TPS warning to all players.")
            end
        end

        if remaining_time <= 0 then
            -- Despawn the vehicle with the highest lag cost
            despawnHighestLagVehicle()
            tps_countdown = nil
            tps_warning_issued = false
            tps_warning_issued = true
            server.notify(-1, "[MAL]", "Countdown finished. Despawning highest lag vehicle.",1)
            if debug_mode then
                server.announce("[DEBUG]", "Countdown finished. Despawning highest lag vehicle.")
            end
        end
    end
end


-- Function to handle emergency cleanup countdown
function handleEmergencyCleanup()
    if emergency_cleanup_countdown then
        local current_time = server.getTimeMillisec()
        local elapsed_time = current_time - emergency_cleanup_start_time
        if elapsed_time >= emergency_cleanup_countdown then
            -- Time to perform emergency cleanup
            server.cleanVehicles()
            server.notify(-1, "[MAL]", "Emergency cleanup executed due to very low TPS.", 1)
            if debug_mode then
                server.announce("[DEBUG]", "Emergency cleanup executed.")
            end
            emergency_cleanup_countdown = nil
        else
            local remaining_time = math.ceil((emergency_cleanup_countdown - elapsed_time) / 1000)
            server.announce("[MAL]", "Emergency cleanup in " .. remaining_time .. " seconds due to very low TPS.")
            if debug_mode then
                server.announce("[DEBUG]", "Emergency cleanup countdown: " .. remaining_time .. " seconds remaining.")
            end
        end
    end
end

-- Function to despawn the vehicle with the highest lag cost
function despawnHighestLagVehicle()
    local highest_lag_cost = 0
    local vehicle_to_despawn = nil

    for vehicle_id, info in pairs(vehicle_lag_costs) do
        if info.lag_cost > highest_lag_cost then
            highest_lag_cost = info.lag_cost
            vehicle_to_despawn = vehicle_id
        end
    end

    if vehicle_to_despawn then
        local group_id = vehicle_lag_costs[vehicle_to_despawn].group_id
        despawnVehicleGroup(group_id)
        -- Notify the owner
        local peer_id = vehicle_lag_costs[vehicle_to_despawn].peer_id
        server.notify(peer_id, "[MAL]", "Your vehicle has been despawned due to high server load.", 2)  -- Notification type 2: failed_mission

        if debug_mode then
            server.announce("[DEBUG]", "Despawning vehicle with highest lag cost: Vehicle ID=" .. vehicle_to_despawn)
        end
    else
        if debug_mode then
            server.announce("[DEBUG]", "No vehicles to despawn.")
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



-- onTick function
function onTick(game_ticks)
    -- Update TPS
    updateTPS(game_ticks)

    -- Handle TPS countdown
    handleTPSCountdown()

    -- Update vehicle loading status
    updateVehicleLoading()

    -- Update TPS impact checks
    updateGroupTPSImpact()

    -- Other game logic...
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

    elseif command == "?setmaxcostlag" then
        if is_admin then
            local new_limit = tonumber(args[1])
            if new_limit and new_limit >= 1000 and new_limit <= 50000 then
                PLAYER_LAG_COST_LIMIT = new_limit
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
    elseif command == "?help" then
        local help_message = "Available Commands:\n"
        help_message = help_message .. "?vlag - Show your current lag cost and remaining lag cost.\n"
        help_message = help_message .. "?repair [group_id] - Repair your vehicles. If group_id is provided, repairs that group.\n"
        help_message = help_message .. "?help - Show this help message.\n"
    
        if is_admin then
            help_message = help_message .. "\nAdmin Commands:\n"
            help_message = help_message .. "?debug - Toggle debug mode.\n"
            help_message = help_message .. "?cleanup - Despawn all player vehicles.\n"
            help_message = help_message .. "?clearlag [lag_cost] - Despawn vehicle groups exceeding lag_cost.\n"
            help_message = help_message .. "?setmaxcostlag <value> - Set maximum lag cost limit.\n"
            help_message = help_message .. "?cleartps [tps_value] - Set TPS threshold for emergency cleanup.\n"
            help_message = help_message .. "?vlag [peer_id] - View another player's lag cost.\n"
        end
        server.announce("Server", help_message, peer_id)

    else
        server.announce("[MAL]", "Unknown command.", peer_id)
    end
end
