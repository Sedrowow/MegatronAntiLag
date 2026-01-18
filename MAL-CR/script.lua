-- MAL-CR (Creative/Return to Bench) Version
-- Features: TPS display, Antisteal, ?bench command (no ?c command)

-- TPS Monitoring
local TPS_THRESHOLD = 35  -- Adjusted TPS threshold for your calculation method

-- TPS Calculation Variables
local TIME = server.getTimeMillisec()
local TICKS = 0
local TPS = 0

-- Debug Mode Variable
local debug_mode = false  -- Debug mode is off by default

-- Reload Countdown Variables
reload_countdown_active = false
reload_countdown_time = 0
reload_countdown_start_time = 0

-- Track script-initiated despawns (for money refunds)
local script_initiated_despawns = {}  -- [group_id] = true

-- Track pending removals (despawn countdown)
local pending_removals = {}  -- [group_id] = {removal_time = number, override = bool, player_requested_cancel = false, owner_peer_id = number}

-- Initialize g_savedata structure
if not g_savedata then
    g_savedata = {}
end

if not g_savedata.vehicle_lag_costs then
    g_savedata.vehicle_lag_costs = {}  -- [vehicle_id] = {peer_id = number, group_id = number}
end

if not g_savedata.player_vehicle_groups then
    g_savedata.player_vehicle_groups = {}  -- [peer_id] = {group_id = {vehicle_ids}}
end

if not g_savedata.group_peer_mapping then
    g_savedata.group_peer_mapping = {}  -- [group_id] = peer_id
end

if not g_savedata.group_costs then
    g_savedata.group_costs = {}  -- [group_id] = cost (money)
end

if not g_savedata.player_keep_vehicles then
    g_savedata.player_keep_vehicles = {}  -- [peer_id] = true if ?keepv enabled
end

if not g_savedata.disconnected_players then
    g_savedata.disconnected_players = {}  -- [steam_id] = {despawn_time = number, peer_id = number}
end

if not g_savedata.group_locked_state then
    g_savedata.group_locked_state = {}  -- [group_id] = true if locked, false if unlocked
end

if not g_savedata.group_pvp_state then
    g_savedata.group_pvp_state = {}  -- [group_id] = true if pvp disabled (invulnerable), false if pvp enabled
end

if not g_savedata.speed_units then
    g_savedata.speed_units = {}  -- [peer_id] = "MPH" | "KMH" | "M/S" | "Knots" | "Mach"
end

-- Local references for easier access (these point to g_savedata)
local vehicle_lag_costs = g_savedata.vehicle_lag_costs
local player_vehicle_groups = g_savedata.player_vehicle_groups
local group_peer_mapping = g_savedata.group_peer_mapping
local group_costs = g_savedata.group_costs
local player_keep_vehicles = g_savedata.player_keep_vehicles
local disconnected_players = g_savedata.disconnected_players
local group_locked_state = g_savedata.group_locked_state
local group_pvp_state = g_savedata.group_pvp_state
local speed_units = g_savedata.speed_units

-- Uptime tracking
local world_start_time = server.getTimeMillisec()

-- Player invulnerability tracking
local player_invulnerable = {}  -- [peer_id] = true if invulnerable
local last_player_damage_time = {}  -- [peer_id] = last time damage was taken

local DISCONNECT_DESPAWN_DELAY = 30  -- 30 seconds in seconds
local PVP_PROTECTION_RADIUS = 50  -- 50 meters for PVP protection

function onCreate(is_world_create)
    if not is_world_create then
        -- This is a script reload, not a world creation
        -- Display reload message
        local message = "Server scripts have been reloaded. Data has been restored from save."
        server.announce("[MAL-CR]", message, -1)

        -- Ensure all tables exist (for compatibility with old saves)
        g_savedata.vehicle_lag_costs = g_savedata.vehicle_lag_costs or {}
        g_savedata.player_vehicle_groups = g_savedata.player_vehicle_groups or {}
        g_savedata.group_peer_mapping = g_savedata.group_peer_mapping or {}
        g_savedata.group_costs = g_savedata.group_costs or {}
        g_savedata.player_keep_vehicles = g_savedata.player_keep_vehicles or {}
        g_savedata.disconnected_players = g_savedata.disconnected_players or {}
        g_savedata.group_locked_state = g_savedata.group_locked_state or {}
        g_savedata.group_pvp_state = g_savedata.group_pvp_state or {}
        g_savedata.speed_units = g_savedata.speed_units or {}
        g_savedata.player_positions = g_savedata.player_positions or {}

        -- Refresh local references to g_savedata
        vehicle_lag_costs = g_savedata.vehicle_lag_costs
        player_vehicle_groups = g_savedata.player_vehicle_groups
        group_peer_mapping = g_savedata.group_peer_mapping
        group_costs = g_savedata.group_costs
        player_keep_vehicles = g_savedata.player_keep_vehicles
        disconnected_players = g_savedata.disconnected_players
        group_locked_state = g_savedata.group_locked_state
        group_pvp_state = g_savedata.group_pvp_state
        speed_units = g_savedata.speed_units
        player_positions = g_savedata.player_positions

        -- Clear all old popups for all players on reload (including host at p_id 0)
        for p_id = 0, 32 do
            server.removePopup(p_id, p_id * 100 + 1)
            server.removePopup(p_id, p_id * 100 + 2)
            server.removePopup(p_id, p_id * 100 + 3)
            server.removePopup(p_id, p_id * 100 + 4)
        end
        server.removePopup(-1, 3)  -- Remove global TPS popup

        if debug_mode then
            server.announce("[DEBUG]", "Scripts reloaded. Restored vehicle data from g_savedata.", -1)
        end
    else
        -- World creation - ensure tables are initialized
        g_savedata.vehicle_lag_costs = g_savedata.vehicle_lag_costs or {}
        g_savedata.player_vehicle_groups = g_savedata.player_vehicle_groups or {}
        g_savedata.group_peer_mapping = g_savedata.group_peer_mapping or {}
        g_savedata.group_costs = g_savedata.group_costs or {}
        g_savedata.player_keep_vehicles = g_savedata.player_keep_vehicles or {}
        g_savedata.disconnected_players = g_savedata.disconnected_players or {}
        g_savedata.group_locked_state = g_savedata.group_locked_state or {}
        g_savedata.group_pvp_state = g_savedata.group_pvp_state or {}
        g_savedata.speed_units = g_savedata.speed_units or {}
        g_savedata.player_positions = g_savedata.player_positions or {}

        -- Refresh local references to g_savedata
        vehicle_lag_costs = g_savedata.vehicle_lag_costs
        player_vehicle_groups = g_savedata.player_vehicle_groups
        group_peer_mapping = g_savedata.group_peer_mapping
        group_costs = g_savedata.group_costs
        player_keep_vehicles = g_savedata.player_keep_vehicles
        disconnected_players = g_savedata.disconnected_players
        group_locked_state = g_savedata.group_locked_state
        group_pvp_state = g_savedata.group_pvp_state
        speed_units = g_savedata.speed_units
        player_positions = g_savedata.player_positions
    end
end



function onVehicleSpawn(vehicle_id, peer_id, x, y, z, cost, group_id)
    if debug_mode then
        server.announce("[DEBUG]", "Vehicle spawned: ID=" .. vehicle_id .. ", Peer ID=" .. peer_id .. ", Group ID=" .. group_id .. ", Cost=" .. cost)
    end

    -- If peer_id is negative, it's the server or an addon; ignore this vehicle
    if peer_id < 0 then
        if debug_mode then
            server.announce("[DEBUG]", "Vehicle " .. vehicle_id .. " spawned by server/addon. Ignoring.", -1)
        end
        return
    end

    -- Store the group with the associated peer_id if not already stored
    if not group_peer_mapping[group_id] then
        group_peer_mapping[group_id] = peer_id
        group_costs[group_id] = cost  -- Store the group cost for refund later

        -- Initialize player's vehicle group list if not existing
        if not player_vehicle_groups[peer_id] then
            player_vehicle_groups[peer_id] = {}
        end

        -- Initialize the group in the player's vehicle groups
        player_vehicle_groups[peer_id][group_id] = {}
    end

    -- Add the vehicle to the player's group
    table.insert(player_vehicle_groups[peer_id][group_id], vehicle_id)

    -- Store vehicle info for tracking
    vehicle_lag_costs[vehicle_id] = {
        peer_id = peer_id,
        group_id = group_id
    }

    -- Lock all vehicles by default (including host peer_id 0, but not script-spawned peer_id -1)
    if peer_id >= 0 then  -- Locks both host (0) and players (>0)
        server.setVehicleEditable(vehicle_id, false)
        -- Mark group as locked if not already set
        if group_locked_state[group_id] == nil then
            group_locked_state[group_id] = true
        end
        -- Mark group PVP as enabled (vulnerable) by default
        if group_pvp_state[group_id] == nil then
            group_pvp_state[group_id] = false
        end
        if debug_mode then
            server.announce("[DEBUG]", "Locked vehicle " .. vehicle_id .. " on spawn (group " .. group_id .. ")", -1)
        end
    end
end

-- Function to handle vehicle despawning
function onVehicleDespawn(vehicle_id, peer_id)
    local vehicle_info = vehicle_lag_costs[vehicle_id]
    if vehicle_info then
        local owner_peer_id = vehicle_info.peer_id
        local group_id = vehicle_info.group_id

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

            -- If group is empty, remove it and return money only if script-initiated
            if #player_vehicle_groups[owner_peer_id][group_id] == 0 then
                player_vehicle_groups[owner_peer_id][group_id] = nil
                
                -- Return money only if this was a script-initiated despawn
                if script_initiated_despawns[group_id] then
                    local cost = group_costs[group_id] or 0
                    if cost > 0 then
                        local current_money = server.getCurrency()
                        server.setCurrency(current_money + cost, nil)
                        if debug_mode then
                            server.announce("[DEBUG]", "Returned $" .. cost .. " (script-initiated despawn)", -1)
                        end
                    end
                    script_initiated_despawns[group_id] = nil
                elseif debug_mode then
                    server.announce("[DEBUG]", "No refund (player-initiated despawn for group " .. group_id .. ")", -1)
                end
                
                group_peer_mapping[group_id] = nil
                group_costs[group_id] = nil
                group_locked_state[group_id] = nil
            end
        end
    end

    if debug_mode then
        server.announce("[DEBUG]", "Vehicle " .. vehicle_id .. " despawned.", -1)
    end
end

-- Function to handle vehicle damage (protect PVP-disabled vehicles)
function onVehicleDamage(vehicle_id, damage_amount, vx, vy, vz, damage_type, source_peer_id, is_critical)
    local vehicle_info = vehicle_lag_costs[vehicle_id]
    if vehicle_info then
        local group_id = vehicle_info.group_id
        local is_pvp_disabled = group_pvp_state[group_id]
        
        -- If PVP is disabled, prevent damage
        if is_pvp_disabled then
            if debug_mode then
                server.announce("[DEBUG]", "Protected vehicle " .. vehicle_id .. " from damage (PVP disabled)", -1)
            end
            return 0  -- Prevent damage
        end
    end
    return damage_amount
end

-- Function to handle player damage (protect players near PVP-disabled vehicles)
function onPlayerDamage(peer_id, damage_amount, source_peer_id, is_headshot)
    -- Check if player is within 50m of any PVP-disabled vehicle
    local player_pos, success = server.getPlayerPos(peer_id)
    if not success then
        return damage_amount
    end
    
    -- Check all vehicles for PVP disabled status
    for group_id, is_pvp_disabled in pairs(group_pvp_state) do
        if is_pvp_disabled then
            -- Get a vehicle from this group to check proximity
            for owner_id in pairs(player_vehicle_groups) do
                if player_vehicle_groups[owner_id] and player_vehicle_groups[owner_id][group_id] then
                    local vehicles = player_vehicle_groups[owner_id][group_id]
                    if #vehicles > 0 then
                        local vehicle_id = vehicles[1]
                        local vehicle_pos, v_success = server.getVehiclePos(vehicle_id)
                        if v_success then
                            local distance = matrix.distance(player_pos, vehicle_pos)
                            if distance <= PVP_PROTECTION_RADIUS then
                                -- Player is protected, revive if dead and heal
                                local char_id, char_success = server.getPlayerCharacterID(peer_id)
                                if char_success then
                                    local obj_data = server.getObjectData(char_id)
                                    if obj_data and obj_data.dead then
                                        server.reviveCharacter(char_id)
                                        if debug_mode then
                                            server.announce("[DEBUG]", "Revived dead player " .. peer_id .. " (near PVP-disabled vehicle)", -1)
                                        end
                                    end
                                end
                                server.setPlayerHealth(peer_id, 100)
                                if debug_mode then
                                    server.announce("[DEBUG]", "Protected player " .. peer_id .. " from damage (near PVP-disabled vehicle)", -1)
                                end
                                return 0
                            end
                        end
                    end
                end
            end
        end
    end
    
    return damage_amount
end

-- Function to calculate and update TPS
function updateTPS(game_ticks)
    local now = server.getTimeMillisec()

    -- Count raw ticks passed
    TICKS = TICKS + (game_ticks or 0)

    if not TIME then
        TIME = now
    end

    local elapsed = now - TIME
    if elapsed >= 1000 then
        -- Calculate TPS as ticks per second (scaled from elapsed ms)
        TPS = math.floor((TICKS * 1000) / elapsed + 0.5)
        -- reset counters
        TIME = now
        TICKS = 0
    end

    -- Update TPS display at most once per second
    if not last_tps_popup_time or now - last_tps_popup_time >= 1000 then
        last_tps_popup_time = now
        server.setPopupScreen(-1, 3, "TPS", true, "TPS: " .. tostring(TPS), 0.9, 0.7)
    end
end

-- Function to convert speed to different units
function convertSpeed(speed_ms, unit)
    -- speed_ms is speed in meters per second
    if unit == "MPH" then
        return speed_ms * 2.237  -- m/s to mph
    elseif unit == "KMH" then
        return speed_ms * 3.6  -- m/s to kmh
    elseif unit == "M/S" then
        return speed_ms
    elseif unit == "Knots" then
        return speed_ms * 1.944  -- m/s to knots
    elseif unit == "Mach" then
        return speed_ms / 343  -- m/s to mach (at sea level, ~343 m/s)
    end
    return speed_ms
end

-- Function to get uptime string
function getUptimeString()
    local elapsed = server.getTimeMillisec() - world_start_time
    local seconds = math.floor(elapsed / 1000) % 60
    local minutes = math.floor(elapsed / 60000) % 60
    local hours = math.floor(elapsed / 3600000)
    return string.format("%02d:%02d:%02d", hours, minutes, seconds)
end

-- Function to toggle PVP state of a vehicle group
function toggleVehicleGroupPVP(peer_id, group_id, is_admin)
    -- Check if group exists
    local owner_peer_id = group_peer_mapping[group_id]
    if not owner_peer_id then
        server.announce("[MAL-CR]", "Vehicle group " .. group_id .. " not found.", peer_id)
        return false
    end
    
    -- Check permission (owner or admin)
    if not is_admin and owner_peer_id ~= peer_id then
        server.announce("[MAL-CR]", "You don't own this vehicle group.", peer_id)
        return false
    end
    
    -- Get vehicle IDs in the group
    local vehicle_ids = player_vehicle_groups[owner_peer_id][group_id]
    if not vehicle_ids or #vehicle_ids == 0 then
        server.announce("[MAL-CR]", "Vehicle group is empty.", peer_id)
        return false
    end
    
    -- Get current PVP state (default to enabled if not set)
    local is_pvp_disabled = group_pvp_state[group_id]
    if is_pvp_disabled == nil then
        is_pvp_disabled = false
    end
    
    -- Toggle the PVP state
    local new_state = not is_pvp_disabled
    group_pvp_state[group_id] = new_state
    
    -- Apply to all vehicles in the group
    local vehicles_updated = 0
    for _, vehicle_id in ipairs(vehicle_ids) do
        server.setVehicleInvulnerable(vehicle_id, new_state)  -- Set invulnerable based on PVP state
        vehicles_updated = vehicles_updated + 1
    end
    
    local owner_name = server.getPlayerName(owner_peer_id) or "Player " .. owner_peer_id
    local state_text = new_state and "PVP Disabled (Invulnerable)" or "PVP Enabled (Vulnerable)"
    server.announce("[MAL-CR]", state_text .. " for " .. vehicles_updated .. " vehicle(s) in group " .. group_id .. " (owned by " .. owner_name .. ").", peer_id)
    
    if debug_mode then
        server.announce("[DEBUG]", "Player " .. peer_id .. " toggled PVP for group " .. group_id .. " to " .. state_text .. " (owned by " .. owner_peer_id .. ")", -1)
    end
    
    return true
end
-- Function to toggle lock state of a vehicle group
function toggleVehicleGroupLock(peer_id, group_id, is_admin)
    -- Check if group exists
    local owner_peer_id = group_peer_mapping[group_id]
    if not owner_peer_id then
        server.announce("[MAL-CR]", "Vehicle group " .. group_id .. " not found.", peer_id)
        return false
    end
    
    -- Check permission (owner or admin)
    if not is_admin and owner_peer_id ~= peer_id then
        server.announce("[MAL-CR]", "You don't own this vehicle group.", peer_id)
        return false
    end
    
    -- Get vehicle IDs in the group
    local vehicle_ids = player_vehicle_groups[owner_peer_id][group_id]
    if not vehicle_ids or #vehicle_ids == 0 then
        server.announce("[MAL-CR]", "Vehicle group is empty.", peer_id)
        return false
    end
    
    -- Get current lock state (default to locked if not set)
    local is_locked = group_locked_state[group_id]
    if is_locked == nil then
        is_locked = true
    end
    
    -- Toggle the lock state
    local new_state = not is_locked
    group_locked_state[group_id] = new_state
    
    -- Apply to all vehicles in the group
    local vehicles_updated = 0
    for _, vehicle_id in ipairs(vehicle_ids) do
        server.setVehicleEditable(vehicle_id, new_state)  -- new_state = false means locked, true means unlocked
        vehicles_updated = vehicles_updated + 1
    end
    
    local owner_name = server.getPlayerName(owner_peer_id) or "Player " .. owner_peer_id
    local state_text = new_state and "unlocked" or "locked"
    server.announce("[MAL-CR]", state_text:gsub("^%l", string.upper) .. " " .. vehicles_updated .. " vehicle(s) in group " .. group_id .. " (owned by " .. owner_name .. ").", peer_id)
    
    if debug_mode then
        server.announce("[DEBUG]", "Player " .. peer_id .. " toggled group " .. group_id .. " to " .. state_text .. " (owned by " .. owner_peer_id .. ")", -1)
    end
    
    return true
end

-- Add to onPlayerJoin
function onPlayerJoin(steam_id, name, peer_id, is_admin, is_auth)
    -- All vehicles are locked by default on spawn, no additional setup needed
    
    -- Convert steam_id to string immediately to prevent data loss
    local steam_id_str = tostring(steam_id)
    
    -- Cancel despawn timer if player rejoins
    if disconnected_players[steam_id_str] then
        disconnected_players[steam_id_str] = nil
        server.announce("[MAL-CR]", "Welcome back, " .. name .. "! Your vehicles are still here.", peer_id)
        if debug_mode then
            server.announce("[DEBUG]", "Cancelled disconnect timer for player " .. name .. " (Steam ID: " .. steam_id_str .. ")", -1)
        end
    end
    
    if debug_mode then
        server.announce("[DEBUG]", "Player " .. name .. " (" .. peer_id .. ") joined.", -1)
    end
end

-- Add to onPlayerLeave to clean up
function onPlayerLeave(steam_id, name, peer_id, is_admin, is_auth)
    -- Convert steam_id to string immediately to prevent data loss
    local steam_id_str = tostring(steam_id)
    
    -- Don't despawn host's vehicles (peer_id 0)
    if peer_id == 0 then
        if debug_mode then
            server.announce("[DEBUG]", "Host left, keeping all vehicles.", -1)
        end
        return
    end
    
    -- Check if player has ?keepv enabled
    if player_keep_vehicles[peer_id] then
        server.announce("[MAL-CR]", name .. " has left. Vehicles will remain spawned (?keepv is active).", -1)
        if debug_mode then
            server.announce("[DEBUG]", "Player " .. name .. " left with ?keepv enabled. Vehicles kept.", -1)
        end
        return
    end
    
    -- Start despawn timer for player's vehicles (30 seconds)
    if peer_id > 0 then
        disconnected_players[steam_id_str] = {
            despawn_time = server.getTimeMillisec() + (DISCONNECT_DESPAWN_DELAY * 1000),
            peer_id = peer_id,
            name = name
        }
        server.announce("[MAL-CR]", name .. " has left. Vehicles will be despawned in " .. DISCONNECT_DESPAWN_DELAY .. " seconds.", -1)
        if debug_mode then
            server.announce("[DEBUG]", "Started disconnect timer for player " .. name .. " (Steam ID: " .. steam_id_str .. ")", -1)
        end
    end
end

-- Function to process pending removals
function processPendingRemovals()
    local current_time = server.getTimeMillisec()
    
    for group_id, removal_data in pairs(pending_removals) do
        local time_remaining = removal_data.removal_time - current_time
        
        if time_remaining <= 0 then
            -- Time's up - check conditions before removing
            if removal_data.player_requested_cancel and not removal_data.override then
                server.announce("[MAL-CR]", "Vehicle group " .. group_id .. " removal cancelled.", -1)
                pending_removals[group_id] = nil
                goto continue_removal
            end
            
            -- Despawn the vehicle group
            local cost = group_costs[group_id] or 0
            script_initiated_despawns[group_id] = true
            server.despawnVehicleGroup(group_id, true)
            
            local owner_name = server.getPlayerName(removal_data.owner_peer_id) or "Player " .. removal_data.owner_peer_id
            server.announce("[MAL-CR]", owner_name .. "'s vehicle group " .. group_id .. " has been removed. Refunded $" .. cost .. ".", -1)
            
            if debug_mode then
                server.announce("[DEBUG]", "Removed vehicle group " .. group_id .. " (script-initiated), refunded $" .. cost, -1)
            end
            
            pending_removals[group_id] = nil
        end
        
        ::continue_removal::
    end
end

-- Function to get list of online players (returns table of SWPlayer objects indexed by peer_id)
function getOnlinePlayers()
    return server.getPlayers()
end
-- Function to update disconnected players and despawn vehicles if time's up
function updateDisconnectedPlayers()
    local current_time = server.getTimeMillisec()
    
    for steam_id, data in pairs(disconnected_players) do
        if current_time >= data.despawn_time then
            -- Time's up - despawn their vehicles and return money
            if player_vehicle_groups[data.peer_id] then
                local total_refund = 0
                for group_id, vehicles in pairs(player_vehicle_groups[data.peer_id]) do
                    -- Get refund amount before despawning
                    local cost = group_costs[group_id] or 0
                    total_refund = total_refund + cost
                    
                    -- Mark as script-initiated despawn (so money gets refunded)
                    script_initiated_despawns[group_id] = true
                    
                    -- Despawn the vehicle group
                    server.despawnVehicleGroup(group_id, true)
                end
                
                -- Return money to the player's bank
                if total_refund > 0 then
                    local current_money = server.getCurrency()
                    server.setCurrency(current_money + total_refund, nil)
                    server.announce("[MAL-CR]", data.name .. "'s vehicles despawned. Returned $" .. total_refund .. " to the bank.", -1)
                end
                
                if debug_mode then
                    server.announce("[DEBUG]", "Despawned vehicles for disconnected player (Steam ID: " .. steam_id .. "), refunded $" .. total_refund, -1)
                end
            end
            -- Remove from tracking
            disconnected_players[steam_id] = nil
        end
    end
end
-- Function to update UI displays for all players
function updatePlayerUI()
    local ui_updates = 0
    local online_players = server.getPlayers()
    for peer_id, player_data in pairs(online_players) do
        local p_id = peer_id
        local player_pos, success = server.getPlayerPos(p_id)
        if success then
            ui_updates = ui_updates + 1
            -- Get player altitude (Y coordinate is at matrix index 14)
            local altitude = player_pos[14] or 0
            
            -- Calculate velocity from position change
            local speed_ms = 0
            local unit = speed_units[p_id] or "KMH"
            if player_positions[p_id] then
                -- Calculate displacement vector
                local dx = player_pos[1] - player_positions[p_id][1]
                local dy = player_pos[2] - player_positions[p_id][2]
                local dz = player_pos[3] - player_positions[p_id][3]
                -- Distance in one tick (approximately 1/60 second)
                local distance = math.sqrt(dx*dx + dy*dy + dz*dz)
                -- Approximate velocity in m/s (assuming ~60 ticks per second)
                speed_ms = distance * 60
            end
            -- Store current position for next tick
            player_positions[p_id] = {player_pos[1], player_pos[2], player_pos[3]}
            
            local converted_speed = convertSpeed(speed_ms, unit)
            
            -- Build vehicle list for player
            local vehicle_list = ""
            if player_vehicle_groups[p_id] then
                for group_id, vehicles in pairs(player_vehicle_groups[p_id]) do
                    if #vehicles > 0 then
                        local is_locked = group_locked_state[group_id]
                        local is_pvp_disabled = group_pvp_state[group_id]
                        local lock_text = is_locked and "[L]" or "[U]"
                        local pvp_text = is_pvp_disabled and "[PVP-]" or "[PVP+]"
                        vehicle_list = vehicle_list .. "G" .. group_id .. ":" .. lock_text .. pvp_text
                        for _, v_id in ipairs(vehicles) do
                            vehicle_list = vehicle_list .. " ID" .. v_id
                        end
                        vehicle_list = vehicle_list .. "\n"
                    end
                end
            end
            
            -- Top left: Uptime and vehicle info
            local uptime = getUptimeString()
            local top_left_text = "UPTIME: " .. uptime .. "\nVehicles:\n" .. (vehicle_list ~= "" and vehicle_list or "None")
            server.setPopupScreen(p_id, p_id * 100 + 1, "InfoTL", true, top_left_text, -0.75, 0.85)
            
            -- Middle left: Speed and height
            local speed_text = string.format("%.1f %s\nHeight: %.1f m", converted_speed, unit, altitude)
            server.setPopupScreen(p_id, p_id * 100 + 2, "InfoML", true, speed_text, -0.75, 0.5)
            
            -- Right center: Removal countdown (use popup ID 4 to avoid conflict with TPS which uses 3)
            local removal_text = ""
            if player_vehicle_groups[p_id] then
                local current_time = server.getTimeMillisec()
                for group_id in pairs(player_vehicle_groups[p_id]) do
                    if pending_removals[group_id] then
                        local time_remaining = math.ceil((pending_removals[group_id].removal_time - current_time) / 1000)
                        if time_remaining > 0 then
                            removal_text = removal_text .. "Group " .. group_id .. ": " .. time_remaining .. "s\n"
                        end
                    end
                end
            end
            
            if removal_text ~= "" then
                server.setPopupScreen(p_id, p_id * 100 + 4, "Removal", true, "REMOVAL COUNTDOWN\n" .. removal_text, 0.75, 0.5)
            else
                -- Clear removal countdown if no removals pending
                server.setPopupScreen(p_id, p_id * 100 + 4, "Removal", false, "", 0.75, 0.5)
            end
        end
    end
    
    if debug_mode and ui_updates > 0 then
        debug.log("[MAL-CR] UI updated for " .. ui_updates .. " player(s)")
    end
end

-- onTick function
function onTick(game_ticks)
    -- Update TPS
    updateTPS(game_ticks)
    
    -- Update disconnected players
    updateDisconnectedPlayers()
    
    -- Process pending removals
    processPendingRemovals()
    
    -- Update player UI
    updatePlayerUI()
end

-- Function to check if player owns a group
function isPlayerGroupOwner(peer_id, group_id)
    if player_vehicle_groups[peer_id] and player_vehicle_groups[peer_id][group_id] then
        return true
    end
    return false
end

-- Function to get closest owned vehicle group to player
function getClosestOwnedVehicle(peer_id)
    local player_pos, is_success = server.getPlayerPos(peer_id)
    if not is_success then
        return nil, nil
    end
    
    local closest_group_id = nil
    local closest_distance = 100  -- Max distance to consider "close enough" (100 meters)
    
    if player_vehicle_groups[peer_id] then
        for group_id, vehicles in pairs(player_vehicle_groups[peer_id]) do
            if #vehicles > 0 then
                -- Get position of first vehicle in group
                local vehicle_id = vehicles[1]
                local vehicle_pos, success = server.getVehiclePos(vehicle_id)
                if success then
                    local distance = matrix.distance(player_pos, vehicle_pos)
                    if distance < closest_distance then
                        closest_distance = distance
                        closest_group_id = group_id
                    end
                end
            end
        end
    end
    
    return closest_group_id, closest_distance
end

-- Function to return vehicle to workbench and teleport player
function returnVehicleToBench(peer_id, group_id)
    -- Check if group exists and player owns it
    local owner_peer_id = group_peer_mapping[group_id]
    if not owner_peer_id or owner_peer_id ~= peer_id then
        server.announce("[MAL-CR]", "You don't own this vehicle group.", peer_id)
        return false
    end
    
    -- Get vehicle IDs in the group
    local vehicle_ids = player_vehicle_groups[peer_id][group_id]
    if not vehicle_ids or #vehicle_ids == 0 then
        server.announce("[MAL-CR]", "Vehicle group not found.", peer_id)
        return false
    end
    
    -- Get player position before teleporting vehicles
    local player_pos, is_success = server.getPlayerPos(peer_id)
    if not is_success then
        server.announce("[MAL-CR]", "Failed to get your position.", peer_id)
        return false
    end
    
    -- Teleport each vehicle in the group (returns to workbench)
    for _, vehicle_id in ipairs(vehicle_ids) do
        server.resetVehicleState(vehicle_id)
        -- Setting vehicle pos to identity matrix teleports it to workbench
        server.setVehiclePos(vehicle_id, matrix.identity())
    end
    
    -- Teleport player to workbench (0, 10, 0 is a safe spawn point at workbench)
    local workbench_pos = matrix.translation(0, 10, 0)
    server.setPlayerPos(peer_id, workbench_pos)
    
    server.announce("[MAL-CR]", "Vehicle group " .. group_id .. " returned to workbench. You have been teleported.", peer_id)
    
    if debug_mode then
        server.announce("[DEBUG]", "Player " .. peer_id .. " returned group " .. group_id .. " to workbench.", -1)
    end
    
    return true
end

-- Function to handle custom chat commands
function onCustomCommand(full_message, peer_id, is_admin, is_auth, command, ...)
    command = command:lower()
    local args = {...}

    if command == "?debug" then
        if is_admin then
            debug_mode = not debug_mode  -- Toggle debug mode
            local state = debug_mode and "enabled" or "disabled"
            server.announce("[MAL-CR]", "Debug mode " .. state .. ".", peer_id)
            if debug_mode then
                server.announce("[DEBUG]", "Debug mode enabled. UI updates should be visible now.", peer_id)
            end
        else
            server.announce("[MAL-CR]", "You do not have permission to use this command.", peer_id)
        end

    elseif command == "?help" then
        local help_message = "Available Commands:\n"
        help_message = help_message .. "?bench [group_id] - Return vehicle to workbench. Omit group_id to return closest vehicle.\n"
        help_message = help_message .. "?as or ?antisteal [group_id] - Toggle vehicle lock/unlock. Omit group_id to toggle closest vehicle.\n"
        help_message = help_message .. "?pvp [group_id] - Toggle vehicle PVP (invulnerability). Omit group_id to toggle closest vehicle.\n"
        help_message = help_message .. "?keepv - Toggle keep vehicles on disconnect (prevents auto-despawn after 30s).\n"
        help_message = help_message .. "?unit [unitname] - Change speed unit (MPH, KMH, M/S, Knots, Mach). Omit unitname to see options.\n"
        help_message = help_message .. "?remove [group_id] - Remove a vehicle (must be unlocked). Without group_id, removes closest instantly. With group_id, 8s countdown.\n"
        help_message = help_message .. "?pleasedont [group_id] - Cancel scheduled removal. Omit group_id to cancel all.\n"
        help_message = help_message .. "?help - Show this help message.\n"
        
        if is_admin then
            help_message = help_message .. "\nAdmin Commands:\n"
            help_message = help_message .. "?removeall [override] - Remove all vehicles with 8s countdown. Override removes locked ones too.\n"
            help_message = help_message .. "?debug - Toggle debug mode.\n"
        end
        server.announce("[MAL-CR]", help_message, peer_id)

    elseif command == "?keepv" then
        -- Toggle keep vehicles on disconnect
        local current_state = player_keep_vehicles[peer_id]
        if current_state == nil then
            current_state = false
        end
        
        local new_state = not current_state
        player_keep_vehicles[peer_id] = new_state
        
        local state_text = new_state and "enabled" or "disabled"
        server.announce("[MAL-CR]", "Keep vehicles on disconnect " .. state_text .. ". Your vehicles will " .. (new_state and "remain spawned" or "be despawned after 30 seconds") .. " when you leave.", peer_id)
        
        if debug_mode then
            server.announce("[DEBUG]", "Player " .. peer_id .. " toggled ?keepv to " .. state_text, -1)
        end

    elseif command == "?as" or command == "?antisteal" then
        local group_id = tonumber(args[1])
        
        if group_id then
            -- Specific group toggle
            toggleVehicleGroupLock(peer_id, group_id, is_admin)
        else
            -- Toggle closest owned vehicle
            local closest_group_id, distance = getClosestOwnedVehicle(peer_id)
            if closest_group_id then
                server.announce("[MAL-CR]", "Toggling lock for closest vehicle (Group " .. closest_group_id .. ", " .. math.floor(distance) .. "m away)...", peer_id)
                toggleVehicleGroupLock(peer_id, closest_group_id, is_admin)
            else
                server.announce("[MAL-CR]", "No vehicles found within 100m, or you don't own any vehicles.", peer_id)
            end
        end
        return
        
    elseif command == "?bench" then
        local group_id = tonumber(args[1])
        
        if group_id then
            -- Specific group return to bench
            returnVehicleToBench(peer_id, group_id)
        else
            -- Return closest owned vehicle
            local closest_group_id, distance = getClosestOwnedVehicle(peer_id)
            if closest_group_id then
                server.announce("[MAL-CR]", "Returning closest vehicle (Group " .. closest_group_id .. ", " .. math.floor(distance) .. "m away)...", peer_id)
                returnVehicleToBench(peer_id, closest_group_id)
            else
                server.announce("[MAL-CR]", "No vehicles found within 100m, or you don't own any vehicles.", peer_id)
            end
        end
    
    elseif command == "?remove" then
        local group_id = tonumber(args[1])
        
        if not group_id then
            -- No group specified, try to remove closest vehicle instantly if unlocked
            local closest_group_id, distance = getClosestOwnedVehicle(peer_id)
            if not closest_group_id then
                server.announce("[MAL-CR]", "No vehicles found within 100m, or you don't own any vehicles.", peer_id)
                return
            end
            
            -- Check if closest vehicle is unlocked
            if group_locked_state[closest_group_id] == true then
                server.announce("[MAL-CR]", "Closest vehicle (Group " .. closest_group_id .. ") is locked. Unlock it first to remove it.", peer_id)
                return
            end
            
            -- Instant removal for closest unlocked vehicle
            local cost = group_costs[closest_group_id] or 0
            script_initiated_despawns[closest_group_id] = true
            server.despawnVehicleGroup(closest_group_id, true)
            server.announce("[MAL-CR]", "Vehicle group " .. closest_group_id .. " removed instantly. Refunded $" .. cost .. ".", peer_id)
            
            if debug_mode then
                server.announce("[DEBUG]", "Player " .. peer_id .. " instantly removed group " .. closest_group_id, -1)
            end
            return
        end
        
        -- Check if group exists
        local owner_peer_id = group_peer_mapping[group_id]
        if not owner_peer_id then
            server.announce("[MAL-CR]", "Vehicle group " .. group_id .. " not found.", peer_id)
            return
        end
        
        -- Check permission (owner or admin)
        if not is_admin and owner_peer_id ~= peer_id then
            server.announce("[MAL-CR]", "You don't own this vehicle group.", peer_id)
            return
        end
        
        -- Check if vehicle is locked
        if group_locked_state[group_id] == true then
            server.announce("[MAL-CR]", "Vehicle group " .. group_id .. " is locked. Unlock it first to remove it.", peer_id)
            return
        end
        
        -- Check if already pending removal
        if pending_removals[group_id] then
            server.announce("[MAL-CR]", "Vehicle group " .. group_id .. " is already scheduled for removal.", peer_id)
            return
        end
        
        -- Schedule removal with 8 second countdown
        pending_removals[group_id] = {
            removal_time = server.getTimeMillisec() + 8000,
            override = false,
            player_requested_cancel = false,
            owner_peer_id = owner_peer_id
        }
        
        server.announce("[MAL-CR]", "Vehicle group " .. group_id .. " scheduled for removal in 8 seconds. Type ?pleasedont " .. group_id .. " to cancel.", peer_id)
        
        if debug_mode then
            server.announce("[DEBUG]", "Player " .. peer_id .. " scheduled group " .. group_id .. " for removal", -1)
        end
    
    elseif command == "?removeall" then
        if not is_admin then
            server.announce("[MAL-CR]", "You do not have permission to use this command.", peer_id)
            return
        end
        
        local override = args[1] and args[1]:lower() == "override"
        
        -- Get list of online players
        local online_players = getOnlinePlayers()
        
        local removal_count = 0
        for group_id in pairs(group_peer_mapping) do
            local owner_peer_id = group_peer_mapping[group_id]
            local is_locked = group_locked_state[group_id]
            
            -- Skip if already scheduled for removal
            if pending_removals[group_id] then
                goto continue_removeall
            end
            
            -- Determine if should remove
            local should_remove = false
            if override then
                should_remove = true
            else
                -- Only remove if owner is offline OR vehicle is unlocked
                local owner_online = online_players[owner_peer_id] ~= nil
                if not owner_online or is_locked == false then
                    should_remove = true
                end
            end
            
            if should_remove then
                pending_removals[group_id] = {
                    removal_time = server.getTimeMillisec() + 8000,
                    override = override,
                    player_requested_cancel = false,
                    owner_peer_id = owner_peer_id
                }
                removal_count = removal_count + 1
            end
            
            ::continue_removeall::
        end
        
        local message = "Scheduled " .. removal_count .. " vehicle(s) for removal in 8 seconds"
        if override then
            message = message .. " (override mode - all vehicles including locked ones)"
        else
            message = message .. " (offline players and unlocked vehicles)"
        end
        message = message .. ". Type ?pleasedont [group_id] to save your vehicle."
        server.announce("[MAL-CR]", message, -1)
        
        if debug_mode then
            server.announce("[DEBUG]", "Admin " .. peer_id .. " scheduled " .. removal_count .. " vehicle(s) for removal (override: " .. tostring(override) .. ")", -1)
        end
    
    elseif command == "?pleasedont" then
        local group_id = tonumber(args[1])
        
        if not group_id then
            -- Cancel all removals for this player
            local cancelled_count = 0
            if player_vehicle_groups[peer_id] then
                for gid in pairs(player_vehicle_groups[peer_id]) do
                    if pending_removals[gid] then
                        pending_removals[gid].player_requested_cancel = true
                        cancelled_count = cancelled_count + 1
                    end
                end
            end
            
            if cancelled_count > 0 then
                server.announce("[MAL-CR]", "Cancelled removal of " .. cancelled_count .. " vehicle(s).", peer_id)
            else
                server.announce("[MAL-CR]", "No vehicles scheduled for removal.", peer_id)
            end
        else
            -- Cancel specific group
            if pending_removals[group_id] then
                local owner_peer_id = group_peer_mapping[group_id]
                if owner_peer_id == peer_id or is_admin then
                    if pending_removals[group_id].override then
                        server.announce("[MAL-CR]", "WARNING: Vehicle group " .. group_id .. " removal cancelled, but it was scheduled with override. An admin may reschedule it.", peer_id)
                    else
                        server.announce("[MAL-CR]", "Vehicle group " .. group_id .. " will NOT be removed.", peer_id)
                    end
                    pending_removals[group_id].player_requested_cancel = true
                else
                    server.announce("[MAL-CR]", "You don't own this vehicle group.", peer_id)
                end
            else
                server.announce("[MAL-CR]", "Vehicle group " .. group_id .. " is not scheduled for removal.", peer_id)
            end
        end
    
    elseif command == "?unit" then
        local unit_name = args[1]
        
        if not unit_name then
            -- Show all available units
            server.announce("[MAL-CR]", "Available speed units:\n- MPH\n- KMH (default)\n- M/S\n- Knots\n- Mach\n\nUsage: ?unit [unitname]", peer_id)
            return
        end
        
        unit_name = unit_name:upper()
        
        if unit_name == "MPH" or unit_name == "KMH" or unit_name == "M/S" or unit_name == "KNOTS" or unit_name == "MACH" then
            speed_units[peer_id] = unit_name
            server.announce("[MAL-CR]", "Speed unit changed to " .. unit_name .. ".", peer_id)
            
            if debug_mode then
                server.announce("[DEBUG]", "Player " .. peer_id .. " changed speed unit to " .. unit_name, -1)
            end
        else
            server.announce("[MAL-CR]", "Invalid unit. Available units: MPH, KMH, M/S, Knots, Mach", peer_id)
        end
    
    elseif command == "?pvp" then
        local group_id = tonumber(args[1])
        
        if group_id then
            -- Specific group toggle
            toggleVehicleGroupPVP(peer_id, group_id, is_admin)
        else
            -- Toggle closest owned vehicle
            local closest_group_id, distance = getClosestOwnedVehicle(peer_id)
            if closest_group_id then
                server.announce("[MAL-CR]", "Toggling PVP for closest vehicle (Group " .. closest_group_id .. ", " .. math.floor(distance) .. "m away)...", peer_id)
                toggleVehicleGroupPVP(peer_id, closest_group_id, is_admin)
            else
                server.announce("[MAL-CR]", "No vehicles found within 100m, or you don't own any vehicles.", peer_id)
            end
        end
        return
    end
end
