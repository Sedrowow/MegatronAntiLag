-- Define the maximum allowable lag cost per player
local PLAYER_LAG_COST_LIMIT = 1000  -- Adjust this value as needed

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
local VOXEL_LAG_COST = 1  -- Adjust this value as needed

-- Tables to store tracking data
local vehicle_lag_costs = {}         -- [vehicle_id] = {lag_cost = number, peer_id = number, group_id = number}
local player_vehicle_groups = {}     -- [peer_id] = {group_id = {vehicle_ids}}
local group_peer_mapping = {}        -- [group_id] = peer_id
local player_lag_costs = {}          -- [peer_id] = total_lag_cost

-- Function to handle vehicle spawning
function onVehicleSpawn(vehicle_id, peer_id, x, y, z, cost, group_id)
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
    trackVehicleLoading(vehicle_id, peer_id, group_id)
end

-- Function to track vehicle loading and calculate lag cost when ready
function trackVehicleLoading(vehicle_id, peer_id, group_id)
    -- Continuously check if the vehicle is simulating
    local vehicle_loading_coroutine = coroutine.create(function()
        while true do
            local vehicle_data, is_success = server.getVehicleData(vehicle_id)
            if is_success and vehicle_data["simulating"] then
                -- Vehicle is loaded; calculate lag cost
                calculateVehicleLagCost(vehicle_id, peer_id, group_id)
                break
            end
            coroutine.yield()
        end
    end)

    -- Store the coroutine for updating in onTick
    if not vehicle_loading_coroutines then
        vehicle_loading_coroutines = {}
    end
    table.insert(vehicle_loading_coroutines, vehicle_loading_coroutine)
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
        player_lag_costs[peer_id] = player_lag_costs[peer_id] + total_lag_cost

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
            server.despawnVehicleGroup(group_id, true)
            -- group_id will be handled in onVehicleDespawn
        end

        -- Notify the player
        server.announce("Server", "Your vehicles have been despawned due to exceeding the lag cost limit.", peer_id)
    end
end

-- Function to handle vehicle despawning
function onVehicleDespawn(vehicle_id, peer_id)
    -- Retrieve vehicle info
    local vehicle_info = vehicle_lag_costs[vehicle_id]
    if vehicle_info then
        local owner_peer_id = vehicle_info.peer_id
        local group_id = vehicle_info.group_id
        local lag_cost = vehicle_info.lag_cost

        -- Update player's lag cost
        player_lag_costs[owner_peer_id] = player_lag_costs[owner_peer_id] - lag_cost

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
            end
        end

        -- If player has no more vehicles, remove them from tracking
        if next(player_vehicle_groups[owner_peer_id]) == nil then
            player_vehicle_groups[owner_peer_id] = nil
            player_lag_costs[owner_peer_id] = nil
        end
    end
end

-- Function to update vehicle loading coroutines
function updateVehicleLoadingCoroutines()
    if vehicle_loading_coroutines then
        local i = 1
        while i <= #vehicle_loading_coroutines do
            local co = vehicle_loading_coroutines[i]
            local status = coroutine.status(co)
            if status == "dead" then
                table.remove(vehicle_loading_coroutines, i)
            else
                coroutine.resume(co)
                i = i + 1
            end
        end
    end
end

-- onTick function
function onTick(game_ticks)
    -- Update vehicle loading coroutines
    updateVehicleLoadingCoroutines()

    -- Other game logic...
end
