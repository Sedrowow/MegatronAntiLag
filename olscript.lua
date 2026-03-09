g_savedata = {}
data = g_savedata
pvp = {}
name_id_lookup = {}
rev_look = {}
warns = {}
antisteal = {}
spawnlimit = {}
o_v_map = {}
v_o_map = {}
banlist = { Leo = true, freedale2009 = true, SupeRewod = true, qweqw = true, Phoenix = true, Ozworks = true, WeeLite = true }
autodespawn = false
despawn_id = 0
l_despawned = 0
homes = {}
team1 = {}
team2 = {}
capturezones = {}
server_start_time = server.getTimeMillisec()
update_timer = 60
l_time = server_start_time
ticks = server_start_time
lpos = {}
compass_complete =
"WNW-----NN-----NNE-----NE-----ENE-----EE-----ESE-----SE-----SSE-----SS-----SSW-----SW-----WSW-----WW-----WNW-----NW"
teleport_names = { "Harrison Airport", "Multiplayer Airport", "Tajin Airport", "Dremoir Airport", "O'Neil Airport",
    "Ocean Airstrip", "Military Base", "Coastguard Outpost", "Terminal Spycakes", "Terminal Camodo", "Large Dock",
    "North Harbor", "Terminal Endo", "Multiplayer Dock", "Coastguard Outpost Beginner", "Arctic Dock", "Ender airfield",
    "Nuclear plant", "Warner docks" }
ui = {}
current_time = 0
uri_reserved = {
    ["|"] = "|22",
    [" "] = "|20",
    ["!"] = "|21",
    ["#"] = "|23",
    ["$"] = "|24",
    ["%"] = "|25",
    ["&"] = "|26",
    ["'"] = "|27",
    ["("] = "|28",
    [")"] = "|29",
    ["*"] = "|2a",
    ["+"] = "|2b",
    [","] = "|2c",
    ["/"] = "|2f",
    [":"] = "|3a",
    [";"] = "|3b",
    ["="] = "|3d",
    ["?"] = "|3f",
    ["@"] = "|41",
    ["["] = "|5b",
    ["]"] = "|5d",
    ['"'] = '|5e',
    ["\\"] = "|5f",
    ["’"] = "|5g"
}
ping_timer = 1
steam_ids = { [0] = 0 }
await_collection = true
liveTimer = 120
spread = 20

event_pvp = false
event_heal = false
event_tp = false
event_tool = false
event_home = false
event_goto = false
event_repair = false

playerc = -1
vehiclec = 0

lockdown_id = 0

data_broadcast_step = 0

--set this to true only when running on a dedi server
ignore_0 = true

--have this on if you want a working server
network = true

ui_offset = 20
t1_ui_id = 1000
t2_ui_id = 2000

tool_prop = {
    diving = { nil, nil },
    firefighter = { nil, nil },
    scuba = { nil, nil },
    parachute = { 1, nil },
    arctic = { nil, nil },
    hazmat = { nil, nil },
    binoculars = { nil, nil },
    cable = { nil, nil },
    compass = { nil, nil },
    defibrillator = { 4, nil },
    fire_extinguisher = { nil, 10.0 },
    first_aid = { 4, nil },
    flare = { 4, nil },
    flaregun = { 1, nil },
    flaregun_ammo = { 4, nil },
    flashlight = { nil, 100.0 },
    hose = { 0, nil },
    night_vision_binoculars = { nil, 100.0 },
    oxygen_mask = { nil, 0.1 },
    radio = { 1, 0.1 },
    radio_signal_locator = { nil, 100.0 },
    remote_control = { 1, 100.0 },
    rope = { nil, nil },
    strobe_light = { 0, 100.0 },
    strobe_light_infrared = { 0, 100.0 },
    transponder = { 0, 100.0 },
    underwater_welding_torch = { nil, 500.0 },
    welding_torch = { nil, 500.0 },
    coal = { nil, nil },
    radiation_detector = { nil, 100.0 },
    c4 = { 1, nil },
    c4_detonator = { nil, nil },
    speargun = { 1, nil },
    speargun_ammo = { 20, nil },
    pistol = { 17, nil },
    pistol_ammo = { 17, nil },
    smg = { 40, nil },
    smg_ammo = { 40, nil },
    rifle = { 30, nil },
    rifle_ammo = { 30, nil },
    grenade = { 1, nil },
    glowstick = { nil, nil },
    dog_whistle = { nil, nil },
    bomb_disposal = { nil, nil },
    chest_rig = { nil, nil },
    black_hawk_vest = { nil, nil },
    plate_vest = { nil, nil },
    armor_vest = { nil, nil }
}
tool_slots = {
    diving = 1,
    firefighter = 1,
    scuba = 1,
    parachute = 1,
    arctic = 1,
    hazmat = 1,
    binoculars = 2,
    cable = 2,
    compass = 2,
    defibrillator = 3,
    fire_extinguisher = 3,
    first_aid = 2,
    flare = 2,
    flaregun = 2,
    flaregun_ammo = 2,
    flashlight = 2,
    hose = 3,
    night_vision_binoculars = 2,
    oxygen_mask = 2,
    radio = 2,
    radio_signal_locator = 2,
    remote_control = 2,
    rope = 3,
    strobe_light = 2,
    strobe_light_infrared = 2,
    transponder = 2,
    underwater_welding_torch = 3,
    welding_torch = 3,
    coal = 2,
    radiation_detector = 2,
    c4 = 2,
    c4_detonator = 2,
    speargun = 3,
    speargun_ammo = 2,
    pistol = 2,
    pistol_ammo = 2,
    smg = 3,
    smg_ammo = 2,
    rifle = 3,
    rifle_ammo = 2,
    grenade = 2,
    glowstick = 2,
    dog_whistle = 2,
    bomb_disposal = 1,
    chest_rig = 1,
    black_hawk_vest = 1,
    plate_vest = 1,
    armor_vest = 1
}

tool_name_map = {
    diving = 1,
    firefighter = 2,
    scuba = 3,
    parachute = 4,
    arctic = 5,
    hazmat = 29,
    binoculars = 6,
    cable = 7,
    compass = 8,
    defibrillator = 9,
    fire_extinguisher = 10,
    first_aid = 11,
    flare = 12,
    flaregun = 13,
    flaregun_ammo = 14,
    flashlight = 15,
    hose = 16,
    night_vision_binoculars = 17,
    oxygen_mask = 18,
    radio = 19,
    radio_signal_locator = 20,
    remote_control = 21,
    rope = 22,
    strobe_light = 23,
    strobe_light_infrared = 24,
    transponder = 25,
    underwater_welding_torch = 26,
    welding_torch = 27,
    coal = 28,
    radiation_detector = 30,
    c4 = 31,
    c4_detonator = 32,
    speargun = 33,
    speargun_ammo = 34,
    pistol = 35,
    pistol_ammo = 36,
    smg = 37,
    smg_ammo = 38,
    rifle = 39,
    rifle_ammo = 40,
    grenade = 41,
    glowstick = 72,
    dog_whistle = 73,
    bomb_disposal = 74,
    chest_rig = 75,
    black_hawk_vest = 76,
    plate_vest = 77,
    armor_vest = 78
}

--please set seed to 76543

server.setGameSetting("despawn_on_leave", true)

restart_buffer = 900
restart_buffer_active = false
restart_allow_buffer = 600
restart_allow_buffer_active = false
restart_player = 0

--server.notify(-1, "RELOAD", "Server managment script has been reloaded. Please type ?register to enable server features.", 8)

function ln(list)
    c = 0
    for k, v in pairs(list) do
        c = c + 1
    end
    return c
end

function blank()
    return { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }
end

function blankPos(x, y, z)
    return { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, x, y, z, 0 }
end

function nuke(pos, str)
    rx, ry, rz = matrix.position(pos)
    for x = -str, str do
        for y = -str, str do
            for z = -str, str do
                current = blankPos((x * spread) + rx, (y * spread) + ry, (z * spread) + rz)
                server.spawnExplosion(current, 1)
            end
        end
    end
end

function liveUpdate()
    data = { updateType = data_broadcast_step }
    --if 0, send player data. lists to send are: pvp, ui, warns, steam_ids, rev_look
    --if 1, send vehicle data. lists to send are: o_v_map, names(local generation)
    skip = false
    if data_broadcast_step == 0 then
        if ln(pvp) == 0 then
            skip = true
        end
        dmain = { ["pvp"] = pvp, ["ui"] = ui, ["warns"] = warns, ["steam_ids"] = steam_ids, ["names"] = rev_look }
    elseif data_broadcast_step == 1 then
        dmain = { vehicles = o_v_map }
        v_info = {}
        for o, v in pairs(o_v_map) do
            v_data = server.getVehicleData(tonumber(v))
            v_names = { ["name"] = v_data['filename'] }
            v_info[o] = v_names
        end
        dmain["info"] = v_info
        if ln(o_v_map) == 0 then
            skip = true
        end
    end
    if not (skip) then
        data["data"] = dmain
        send(data, "liveData")
    else
    end
    data_broadcast_step = data_broadcast_step + 1
    if data_broadcast_step == 2 then
        data_broadcast_step = 0
    end
end

function jcoder()
    local json = {}

    local function kind_of(obj)
        if type(obj) ~= 'table' then return type(obj) end
        local i = 1
        for _ in pairs(obj) do
            if obj[i] ~= nil then i = i + 1 else return 'table' end
        end
        if i == 1 then return 'table' else return 'array' end
    end

    local function escape_str(s)
        local in_char  = { '\\', '"', '/', '\b', '\f', '\n', '\r', '\t' }
        local out_char = { '\\', '"', '/', 'b', 'f', 'n', 'r', 't' }
        for i, c in ipairs(in_char) do
            s = s:gsub(c, '\\' .. out_char[i])
        end
        return s
    end

    local function skip_delim(str, pos, delim, err_if_missing)
        pos = pos + #str:match('^%s*', pos)
        if str:sub(pos, pos) ~= delim then
            if err_if_missing then
                error('Expected ' .. delim .. ' near position ' .. pos)
            end
            return pos, false
        end
        return pos + 1, true
    end

    local function parse_str_val(str, pos, val)
        val = val or ''
        local early_end_error = 'End of input found while parsing string.'
        if pos > #str then error(early_end_error) end
        local c = str:sub(pos, pos)
        if c == '"' then return val, pos + 1 end
        if c ~= '\\' then return parse_str_val(str, pos + 1, val .. c) end
        local esc_map = { b = '\b', f = '\f', n = '\n', r = '\r', t = '\t' }
        local nextc = str:sub(pos + 1, pos + 1)
        if not nextc then error(early_end_error) end
        return parse_str_val(str, pos + 2, val .. (esc_map[nextc] or nextc))
    end

    local function parse_num_val(str, pos)
        local num_str = str:match('^-?%d+%.?%d*[eE]?[+-]?%d*', pos)
        local val = tonumber(num_str)
        if not val then error('Error parsing number at position ' .. pos .. '.') end
        return val, pos + #num_str
    end

    function json.stringify(obj, as_key)
        local s = {}
        local kind = kind_of(obj)
        if kind == 'array' then
            if as_key then error('Can\'t encode array as key.') end
            s[#s + 1] = '['
            for i, val in ipairs(obj) do
                if i > 1 then s[#s + 1] = ', ' end
                s[#s + 1] = json.stringify(val)
            end
            s[#s + 1] = ']'
        elseif kind == 'table' then
            if as_key then error('Can\'t encode table as key.') end
            s[#s + 1] = '{'
            for k, v in pairs(obj) do
                if #s > 1 then s[#s + 1] = ', ' end
                s[#s + 1] = json.stringify(k, true)
                s[#s + 1] = ':'
                s[#s + 1] = json.stringify(v)
            end
            s[#s + 1] = '}'
        elseif kind == 'string' then
            return '"' .. escape_str(obj) .. '"'
        elseif kind == 'number' then
            if as_key then return '"' .. tostring(obj) .. '"' end
            return tostring(obj)
        elseif kind == 'boolean' then
            return tostring(obj)
        elseif kind == 'nil' then
            return 'null'
        else
            error('Unjsonifiable type: ' .. kind .. '.')
        end
        return table.concat(s)
    end

    json.null = {}

    --pos is start position
    --end delim is json end

    function json.parse(str, pos, end_delim)
        pos = pos or 1
        if pos > #str then error('Reached unexpected end of input.') end
        local pos = pos + #str:match('^%s*', pos)
        local first = str:sub(pos, pos)
        if first == '{' then
            local obj, key, delim_found = {}, true, true
            pos = pos + 1
            while true do
                key, pos = json.parse(str, pos, '}')
                if key == nil then return obj, pos end
                if not delim_found then error('Comma missing between object items.') end
                pos = skip_delim(str, pos, ':', true)
                obj[key], pos = json.parse(str, pos)
                pos, delim_found = skip_delim(str, pos, ',')
            end
        elseif first == '[' then
            local arr, val, delim_found = {}, true, true
            pos = pos + 1
            while true do
                val, pos = json.parse(str, pos, ']')
                if val == nil then return arr, pos end
                if not delim_found then error('Comma missing between array items.') end
                arr[#arr + 1] = val
                pos, delim_found = skip_delim(str, pos, ',')
            end
        elseif first == '"' then
            return parse_str_val(str, pos + 1)
        elseif first == '-' or first:match('%d') then
            return parse_num_val(str, pos)
        elseif first == end_delim then
            return nil, pos + 1
        else
            local literals = { ['true'] = true, ['false'] = false, ['null'] = json.null }
            for lit_str, lit_val in pairs(literals) do
                local lit_end = pos + #lit_str - 1
                if str:sub(pos, lit_end) == lit_str then return lit_val, lit_end + 1 end
            end
            local pos_info_str = 'position ' .. pos .. ': ' .. str:sub(pos, pos + 10)
            error('Invalid json syntax starting at ' .. pos_info_str)
        end
    end

    return json
end

function escape(s)
    result = (s:gsub('[%,%^%$%(%)%%% %.%[%]%*%+%-%?%|]', '%%%1'))
    return result
end

function dbg_record(call)
    --server.announce("[debug]",call..":"..current_time,2)
    --server.announce("[debug]",call..":"..current_time,4)
end

function register(user_peer_id)
    one = server.getPlayerName(user_peer_id)
    pvp[user_peer_id] = event_pvp
    name_id_lookup[one] = user_peer_id
    rev_look[user_peer_id] = one
    warns[user_peer_id] = 0
    antisteal[user_peer_id] = true
    pos, _ = server.getPlayerPos(user_peer_id)
    x, y, z = matrix.position(pos)
    lpos[user_peer_id] = { x, y, z }
    ui[user_peer_id] = true
end

function update(ui)
    current_time = server.getTimeMillisec() - server_start_time
    x = current_time // 1000
    seconds = x % 60
    x = x // 60
    minutes = x % 60
    x = x // 60
    hours = x % 24
    x = x // 24
    days = x
    timeString = ""
    time_diff = current_time - l_time
    l_time = current_time
    fps = string.format("%.2f", 60 / (time_diff / 1000))
    if days > 0 then
        timeString = timeString .. days .. "d"
    end
    if hours > 0 or days > 0 then
        timeString = timeString .. hours .. "h"
    end
    if minutes > 0 or hours > 0 or days > 0 then
        timeString = timeString .. minutes .. "m"
    end
    if seconds > 0 or minutes > 0 or hours > 0 or days > 0 then
        timeString = timeString .. seconds .. "s"
    end

    for k, v in pairs(ui) do
        if v == true then
            if not (o_v_map[k] == nil) then
                vehicle_string = "Owning #" .. o_v_map[k]
            else
                vehicle_string = "No vehicle owned"
            end
            if pvp[k] == true then
                pvp_string = "[PVP-Enabled]"
            else
                pvp_string = "[PVP-Disabled]"
            end
            --      pcid=server.getPlayerCharacterID(k)
            --        pos,_=server.getObjectPos(pcid)
            pos, _ = server.getPlayerPos(k)
            x, alt, z = matrix.position(pos)
            opos = lpos[k]
            ox = opos[1]
            oalt = opos[2]
            oz = opos[3]
            x_diff = (x - ox) ^ 2
            y_diff = (alt - oalt) ^ 2
            z_diff = (z - oz) ^ 2
            sum = x_diff + y_diff + z_diff
            dist = math.sqrt(sum)
            lpos[k] = { x, alt, z }
            orientx, _, orientz = server.getPlayerLookDirection(k)
            server.setPopupScreen(k, k + ui_offset, "welcome" .. k, true,
                "Destroy & Abandon\n24/7\nUp: " ..
                timeString ..
                "\nFPS: " ..
                fps ..
                "\n" ..
                vehicle_string ..
                "\n" .. pvp_string .. "\nAlt: " .. string.format("%.2f", alt) .. "m\nSpeed: " .. math.floor(dist) ..
                "m/s", -0.9, 0.7)
        else
            server.removePopup(k, k + ui_offset)
        end
    end
end

function flip(l)
    new = {}
    for k, v in pairs(l) do
        new[v] = k
    end
    return new
end

function is_int(str)
    return not (str == "" or str:find("%D")) -- str:match("%D") also works
end

tool_num_map = flip(tool_name_map)

function getFirst(l)
    local minKey = math.huge
    for k in pairs(l) do
        minKey = math.min(k, minKey)
    end
    return minKey
end

function get_keys(t)
    local keys = {}
    for key, _ in pairs(t) do
        table.insert(keys, key)
    end
    return keys
end

function dump(o)
    if type(o) == 'table' then
        if ln(o) == 0 then
            return '{}'
        else
            local s = '{'
            for k, v in pairs(o) do
                if type(k) ~= 'number' then k = '"' .. k .. '"' end
                if type(k) == 'number' then k = '"' .. k .. '"' end
                s = s .. '' .. k .. ':' .. dump(v) .. ','
            end
            return s:sub(1, -2) .. '}'
        end
    else
        if type(o) == "string" or type(o) == "boolean" then
            return '"' .. tostring(o) .. '"'
        end
        return tostring(o)
    end
end

function table.find(t, val)
    for k, v in pairs(t) do
        if val == v then
            return k
        end
    end
    return nil
end

function send(data, datatype)
    if network then
        if datatype == "c_message" or datatype == "chat" then
            data["mess"] = string.gsub(data["mess"], '"', '|51')
            data["mess"] = string.gsub(data["mess"], '\\', '|5f')
        end
        raw_list = { maindata = data, datatype = datatype, timestamp = current_time }
        raw = dump(raw_list)
        for k, v in pairs(uri_reserved) do
            if string.find(raw, k, 0, true) then
                raw = string.gsub(raw, escape(k), v)
            end
        end
        server.httpGet(12345, "/liveStorm?data=" .. raw)
    end
end

function onChatMessage(peer_id, sender_name, message)
    target = "lchat"
    data = { p_name = sender_name, mess = message }
    datatype = "chat"
    send(data, datatype)
    send({ p_id = peer_id, p_name = sender_name, mess = message }, "c_message")
end

-- Tick function that will be executed every logic tick
function onTick(game_ticks)
    for k, v in pairs(pvp) do
        if not (v) then
            target = server.getPlayerCharacterID(k)
            server.reviveCharacter(target)
            server.setCharacterData(target, 100, true, false)
        end
    end
    if restart_allow_buffer <= 0 then
        server.notify(restart_player, "?restart", "Countdown expired. Restart cancelled.", 8)
        restart_allow_buffer = 600
        restart_allow_buffer_active = false
    end
    if restart_buffer <= 0 then
        send({ message = "Manual restart started" }, "other")
        send({ ["action"] = "restart" }, "actions")
    end
    if restart_allow_buffer_active then
        restart_allow_buffer = restart_allow_buffer - 1
    end
    if restart_buffer_active then
        restart_buffer = restart_buffer - 1
    end
    --server.cleanRadiation()
    if update_timer == 0 then
        update(ui)
        send({ status = true, tps = fps, uph = hours, upm = minutes, ups = seconds }, "iping")
        send({ names = name_id_lookup }, 'names')
        --send({names=o_v_map},'vehicles')
        update_timer = 60
        --for o,v in pairs(o_v_map) do
        --i, _ = server.isInZone(server.getVehiclePos(v,0,0,0), "invuln")
        --if i then
        --    server.setVehicleInvulnerable(v, true)
        --else
        --    server.setVehicleInvulnerable(v, not(pvp[o]))
        --end
        --i, _ = server.isInZone(matrix.position(server.getPlayerPos(o)), "invuln")
        --if i then
        --    target=server.getPlayerCharacterID(o)
        --    server.reviveCharacter(target)
        --    server.setCharacterData(target, 100, true, false)
        --end
        --end
    else
        update_timer = update_timer - 1
    end
    if liveTimer == 0 then
        --liveUpdate()
        liveTimer = 120
    else
        liveTimer = liveTimer - 1
    end
    if not (lockdown_id == nil) and lockdown_id > 0 then
        server.setPlayerPos(lockdown_id, matrix.translation(0, 0, 0))
    end
    run_captures()
end

function run_captures()
    t1_capturing = {}
    t2_capturing = {}
    t1_present = {}
    t2_present = {}
    stalemates = {}
    cz = 0
    for name, zone in pairs(capturezones) do
        t1 = getPlayersInZone(team1, name)
        t2 = getPlayersInZone(team2, name)
        stalemate = #t1 > 0 and #t2 > 0
        capture_1 = #t1 > 1 and #t2 <= 1
        capture_2 = #t1 <= 1 and #t2 > 1
        for player, _ in pairs(team1) do
            server.setPopupScreen(player, t1_ui_id + cz, "team 1 status", false, "", 0, 0.9)
            server.setPopupScreen(player, t2_ui_id + cz, "team 1 status", false, "", 0, 0.9)
        end
        for player, _ in pairs(team2) do
            server.setPopupScreen(player, t1_ui_id + cz, "team 1 status", false, "", 0, 0.9)
            server.setPopupScreen(player, t2_ui_id + cz, "team 1 status", false, "", 0, 0.9)
        end
        -- -2: capped by t2, -1: t2 cap soon 0: neutral 1: t1 cap soon 2: capped by t1, 3: moving to neutral
        if stalemate then
            for player, _ in pairs(t1) do
                server.setPopupScreen(player, t1_ui_id + cz, "team 1 status", true, "Zone is in stalemate", 0, 0.9)
            end
            for player, _ in pairs(t2) do
                server.setPopupScreen(player, t2_ui_id + cz, "team 1 status", true, "Zone is in stalemate", 0, 0.9)
            end
        end
        if capture_1 then
            if capturezones[name][4] == 2 then
                for player, _ in pairs(t1) do
                    server.setPopupScreen(player, t1_ui_id + cz, "team 1 status", true, "Zone has been captured", 0, 0.9)
                end
                for player, _ in pairs(t2) do
                    server.setPopupScreen(player, t2_ui_id + cz, "team 1 status", true, "Zone is captured by the enemy",
                        0, 0.9)
                end
            elseif capturezones[name][4] == 1 then
                for player, _ in pairs(t1) do
                    server.setPopupScreen(player, t1_ui_id + cz, "team 1 status", true,
                        "Zone will be captured in " .. math.floor(15 - capturezones[name][5] + 0.5), 0, 0.9)
                end
                for player, _ in pairs(t2) do
                    server.setPopupScreen(player, t2_ui_id + cz, "team 1 status", true,
                        "Zone will be captured by the enemy in" .. math.floor(15 - capturezones[name][5] + 0.5), 0, 0.9)
                end
                capturezones[name][5] = capturezones[name][5] + (1 / 60)
                if capturezones[name][5] >= 15 then
                    capturezones[name][4] = 2
                    server.notify(-1, "Zone captured", "Team 1 has captured " .. name, 9)
                end
            elseif capturezones[name][4] == 0 then
                capturezones[name][4] = 1
            elseif capturezones[name][4] == -1 then
                capturezones[name][4] = 3
            elseif capturezones[name][4] == -2 then
                capturezones[name][4] = 3
            elseif capturezones[name][4] == 3 then
                for player, _ in pairs(t1) do
                    server.setPopupScreen(player, t1_ui_id + cz, "team 1 status", true,
                        "Zone will be captured in " .. math.floor(30 - (15 - capturezones[name][5]) + 0.5), 0, 0.9)
                end
                for player, _ in pairs(t2) do
                    server.setPopupScreen(player, t2_ui_id + cz, "team 1 status", true,
                        "Zone will be captured by the enemy in" .. math.floor(30 - (15 - capturezones[name][5]) + 0.5), 0,
                        0.9)
                end
                capturezones[name][5] = capturezones[name][5] - (1 / 60)
                if capturezones[name][5] <= 0 then
                    capturezones[name][4] = 1
                end
            end
        end
        if capture_2 then
            if capturezones[name][4] == -2 then
                for player, _ in pairs(t2) do
                    server.setPopupScreen(player, t2_ui_id + cz, "team 1 status", true, "Zone has been captured", 0, 0.9)
                end
                for player, _ in pairs(t1) do
                    server.setPopupScreen(player, t1_ui_id + cz, "team 1 status", true, "Zone is captured by the enemy",
                        0, 0.9)
                end
            elseif capturezones[name][4] == -1 then
                for player, _ in pairs(t2) do
                    server.setPopupScreen(player, t2_ui_id + cz, "team 1 status", true,
                        "Zone will be captured in " .. math.floor(15 - capturezones[name][5] + 0.5), 0, 0.9)
                end
                for player, _ in pairs(t1) do
                    server.setPopupScreen(player, t1_ui_id + cz, "team 1 status", true,
                        "Zone will be captured by the enemy in" .. math.floor(15 - capturezones[name][5] + 0.5), 0, 0.9)
                end
                capturezones[name][5] = capturezones[name][5] + (1 / 60)
                if capturezones[name][5] >= 15 then
                    capturezones[name][4] = -2
                    server.notify(-1, "Zone captured", "Team 2 has captured " .. name, 9)
                end
            elseif capturezones[name][4] == 0 then
                capturezones[name][4] = -1
            elseif capturezones[name][4] == 1 then
                capturezones[name][4] = 3
            elseif capturezones[name][4] == 2 then
                capturezones[name][4] = 3
            elseif capturezones[name][4] == 3 then
                for player, _ in pairs(t2) do
                    server.setPopupScreen(player, t2_ui_id + cz, "team 1 status", true,
                        "Zone will be captured in " .. math.floor(30 - (15 - capturezones[name][5]) + 0.5), 0, 0.9)
                end
                for player, _ in pairs(t1) do
                    server.setPopupScreen(player, t1_ui_id + cz, "team 1 status", true,
                        "Zone will be captured by the enemy in" .. math.floor(30 - (15 - capturezones[name][5]) + 0.5), 0,
                        0.9)
                end
                capturezones[name][5] = capturezones[name][5] - (1 / 60)
                if capturezones[name][5] <= 0 then
                    capturezones[name][4] = -1
                end
            end
        end
        cz = cz + 2
        -- -2: capped by t2, -1: t2 cap soon 0: neutral 1: t1 cap soon 2: capped by t1, 3: moving to neutral
        str = tostring(capturezones[name][4])
        r = 0
        g = 0
        b = 0
        if capturezones[name][4] == -2 then
            str = "Zone captured by team 2"
            r = 255
            g = 0
            b = 0
        elseif capturezones[name][4] == -1 then
            str = "Zone being captured by team 2"
            r = 100
            g = 0
            b = 0
        elseif capturezones[name][4] == 0 then
            str = "Zone is neutral"
            r = 255
            g = 255
            b = 255
        elseif capturezones[name][4] == 1 then
            str = "Zone being captured by team 1"
            r = 0
            g = 0
            b = 100
        elseif capturezones[name][4] == 2 then
            str = "Zone captured by team 1"
            r = 0
            g = 0
            b = 255
        elseif capturezones[name][4] == 3 then
            str = "Zone becoming neutral"
            r = 100
            g = 100
            b = 100
        end
        server.removeMapObject(-1, cz + 1)
        server.addMapObject(-1, cz + 1, 0, 18, zone[1], zone[3], 0, 0, 0, 0, name, 100, str, r, g, b, 255)
    end
end

function getPlayersInZone(players, zone)
    plays = {}
    for player, _ in pairs(players) do
        if server.isInZone(server.getPlayerPos(player), zone) then
            table.insert(plays, player)
        end
    end
    return plays
end

function onPlayerDie(steam_id, name, peer_id, is_admin, is_auth)
    send({ p_id = peer_id, p_name = name }, "p_death")
    dbg_record("onPlayerDie")
end

function httpReply(port, request, reply)
    if string.sub(reply, 1, 1) == "{" then
        parsed = jcoder().parse(reply, 1, nil)
        if parsed["type"] == "iping" then
            liveque = parsed["que"]
            messages = liveque["msgs"]
            cmds = liveque["cmds"]
            for _, v in pairs(messages) do
                for author, message in pairs(v) do
                    server.announce(author, message)
                    send({ p_id = "discord", p_name = author, mess = message }, "c_message")
                end
            end
            for _, v in pairs(cmds) do
                remote_console(v)
            end
        elseif parsed["type"] == "flyback" then
            if parsed["flytype"] == "verify" then
                server.announce("Verification", "Use code '" .. parsed["code"] .. "' in #verification to get verified.",
                    name_id_lookup[parsed["user"]])
            elseif parsed["flytype"] == "names" then
                server.announce("Name history", "Known past names for " .. rev_look[parsed["target"]] .. ':',
                    name_id_lookup[parsed["user"]])
                for k, v in pairs(parsed["names"]) do
                    server.announce("Name history", k .. ": " .. v, name_id_lookup[parsed["user"]])
                end
            elseif parsed["flytype"] == "isverified" then
                verified = parsed["verified"]
            elseif parsed['flytype'] == 'joinactions' then
                peer_id = name_id_lookup[parsed['user']]
                steam_id = tonumber(parsed['steamid'])
                actions = parsed['actions']
                if actions['kick'] == 1 then
                    server.kickPlayer(peer_id)
                    send({ message = "Autokicked " .. peer_id }, "other")
                else
                    server.removeAuth(peer_id)
                    server.removeAdmin(peer_id)
                    if actions['admin'] == 1 then
                        send({ message = "Admin " .. peer_id }, "other")
                        server.addAdmin(peer_id)
                    end
                    if actions['auth'] == 1 then
                        send({ message = "Auth " .. peer_id }, "other")
                        server.addAuth(peer_id)
                    end
                    if actions['popup'] == 1 then
                        send({ message = "Showed workshop popup to " .. peer_id }, "other")
                        server.setPopupScreen(peer_id, 2, "No Workshop", true,
                            "Welcome to Destroy & Abandon. This is a no workshop server. Type ?noworkshop to recieve auth."
                            , 0, 0)
                    end
                    if actions['reminder'] == 1 then
                        send({ message = "Showed workshop reminder to " .. peer_id }, "other")
                        server.announce("Reminder",
                            "Remember: this is a no workshop server! Please only use things you have made.", peer_id)
                    end
                    if actions['discord'] == 1 then
                        server.setPopupScreen(name_id_lookup[parsed["user"]], 5, "discord invite", false,
                            "Join our discord at\ndiscord.gg/SU2c48wX7n", 0.9, -0.9)
                    end
                    pos, _ = server.getPlayerPos(peer_id)
                    x, y, z = matrix.position(pos)
                    lpos[peer_id] = { x, y, z }
                    ui[peer_id] = true
                    steam_ids[peer_id] = steam_id
                    send({ username = name, flytype = "isverified" }, "flyback")
                end
            end
        end
    end
end

function error(r)
    send({ message = "ERROR" }, "other")
end

function onPlayerRespawn(peer_id)
    send({ p_id = peer_id, p_name = rev_look[peer_id] }, "p_respawn")
end

function remote_console(full_message)
    q = string.gmatch(full_message, "%S+")
    f = {}
    for t in q do
        table.insert(f, t)
    end
    command = f[1]
    one = f[2]
    two = f[3]
    three = f[4]
    command = string.lower(command)
    if (command == "pvp") then
        if not (pvp[tonumber(one)] == nil) then
            if pvp[tonumber(one)] then
                send({ message = rev_look[tonumber(one)] .. " has opted in to PVP." }
                , "other")
            else
                send({ message = rev_look[tonumber(one)] .. " has opted out of PVP." }
                , "other")
            end
        else
            send({ message = "Player not found." }, "other")
        end
    elseif command == "warn" then
        server.removeAuth(one)
        warn = warns[tonumber(one)] + 1
        p = command .. " " .. one .. " "
        reason = (full_message:sub(0, #p) == p) and full_message:sub(#p + 1) or full_message
        server.notify(one, "Warning", "This is your #" .. warn .. " warning. Reason: " .. reason, 9)
        server.announce("[Server]", rev_look[tonumber(one)] .. " has been given a warning for " .. reason)
        send({
            p_id = 0,
            p_name = '[Server]',
            mess = rev_look[tonumber(one)] .. " has been given a warning for " ..
                reason
        }, "chat")
        warns[tonumber(one)] = warn
        server.setPopupScreen(tonumber(one), 2, "Welcome to Destroy & Abandon", true,
            "You are recieving this message because you have recieved a warning by the moderators. Type ?auth to recieve auth."
            , 0, 0)
        --if warn==3 then
        --server.kickPlayer(tonumber(one))
        --server.announce("[Server]",rev_look[tonumber(one)].." has been kicked for exceeding 3 warnings.")
        --end
        send({ p_name = rev_look[tonumber(one)], p_id = one, setting = "warn", val = warns[tonumber(one)] }, "p_setting")
        if not (o_v_map[tonumber(one)] == nil) then
            send({ message = "Despawned vehicle #" .. o_v_map[tonumber(one)] }, "other")
            server.despawnVehicle(o_v_map[tonumber(one)], true)
            v_o_map[o_v_map[tonumber(one)]] = nil
            l_despawned = o_v_map[tonumber(one)]
            o_v_map[tonumber(one)] = nil
            autodespawn = true
            despawn_id = tonumber(one)
        else
            send({ message = "No vehicle spawned." }, "other")
        end
    elseif command == "reset_warnings" then
        if not (tonumber(one) == nil) then
            warns[tonumber(one)] = 0
            server.notify(one, "Warnings cleared", "Your warning have been reset to 0.", 8)
            send({ message = "Warnings have been reset to 0." }, "other")
            send({ p_name = rev_look[tonumber(one)], p_id = one, setting = "warn", val = warns[tonumber(one)] },
                "p_setting")
        else
            send({ message = "User not found" }, "other")
        end
    elseif command == "kick" then
        if not (tonumber(one) == nil) then
            server.kickPlayer(tonumber(one))
        else
            send({ message = "User not found" }, "other")
        end
    elseif command == "ban" then
        if not (tonumber(one) == nil) then
            server.banPlayer(tonumber(one))
        else
            send({ message = "User not found" }, "other")
        end
    elseif command == "warnings" then
        send({ message = rev_look[tonumber(one)] .. " have " .. warns[tonumber(one)] .. " warnings." }, "other")
    elseif command == "help" then
        send({ message = "[Help]       Avalible commands:" }, "other")
        send({ message = "pvp (id):       Displays specified player's PVP status." }, "other")
        send(
        { message = "warn (id) (reason):       Warn player with specified ID for specified reason, removing their auth." }
        , "other")
        send({ message = "reset_warnings (id):       Cleares the specified players warnings." }, "other")
        send({ message = "warnings (id):       Displays how many warnings the specified user has recieved." }, "other")
        send({ message = "recollect_tp:       Collects teleports. mandatory after a server restart." }, "other")
        send({ message = "dsp (id):       Despawn a players vehicle" }, "other")
        send(
        { message =
        "remove (id):       Removes a vehicle, Use ?dsp in most cases, as this one does not handle ownership removal." }
        , "other")
        send({ message = "announce (message):       Sends an announcement to the entire server." }, "other")
        send({ message = "getplayers:       Gets general player info." }, "other")
    elseif command == "recollect_tp" then
        zones = server.getZones()
        teleports = {}
        for k, v in pairs(zones) do
            --send({ message = "m " .. v.tags_full .. ' ' .. v.name }, "other")
            if string.match(v.tags_full, "teleport") then
                tp_id = v.name
                x, y, z = matrix.position(v.transform)
                teleports[tp_id] = { x, y, z }
                send({ message = "collected teleport " .. v.name }, "other")
            end
        end
    elseif command == "recollect_cz" then
        zones = server.getZones()
        capturezones = {}
        for k, v in pairs(zones) do
            --send({ message = "m " .. v.tags_full .. ' ' .. v.name }, "other")
            if string.match(v.tags_full, "capture") then
                tp_id = v.name
                x, y, z = matrix.position(v.transform)
                capturezones[tp_id] = { x, y, z, 0, 0 } -- -2: capped by t2, -1: t2 cap soon 0: neutral 1: t1 cap soon 2: capped by t1, 3: moving to neutral
                send({ message = "collected capture zone " .. v.name }, "other")
            end
        end
    elseif command == "getplayers" then
        playcount = 1
        capturezones = {}
        for name, id in pairs(name_id_lookup) do
            if not (o_v_map[id] == nil) then
                vehic = "Currently owns #" .. o_v_map[id] .. '.'
            else
                vehic = "No vehicle spawned."
            end
            strong = playcount ..
                ": " .. name .. " (" .. id .. ") " .. warns[id] .. " warnings, pvp is " .. tostring(pvp[id]) ..
                ". " .. vehic
            send({ message = strong }, "other")
            playcount = playcount + 1
        end
    elseif command == "bind" then
        o_v_map[tonumber(one)] = tonumber(two)
        v_o_map[tonumber(two)] = tonumber(two)
    elseif command == "dsp" then
        if not (o_v_map[tonumber(one)] == nil) then
            send({ message = "Despawned vehicle #" .. o_v_map[tonumber(one)] }, "other")
            server.despawnVehicle(o_v_map[tonumber(one)], true)
            v_o_map[o_v_map[tonumber(one)]] = nil
            l_despawned = o_v_map[tonumber(one)]
            o_v_map[tonumber(one)] = nil
            autodespawn = true
            despawn_id = tonumber(one)
        else
            send({ message = "No vehicle spawned." }, "other")
        end
    elseif command == "remove" then
        server.despawnVehicle(tonumber(one), true)
    elseif command == "dumpcz" then
        send({ message = "captures " .. dump(capturezones) }, "other")
    elseif command == "announce" then
        p = "announce "
        server.notify(-1, "Announcement", (full_message:sub(0, #p) == p) and full_message:sub(#p + 1) or full_message, 8)
        send({
            p_id = 0,
            p_name = '[Server]',
            mess = "Server announcement: " .. ((full_message:sub(0, #p) == p) and full_message:sub(#p + 1) or
                full_message)
        }, "chat")
    elseif command == "settings" then
        if one == "get" then
            settings = server.getGameSettings()
            send({ message = "[Settings]       Current settings:" }, "other")
            for s, v in pairs(settings) do
                send({ message = "[Settings]       " .. s .. ": " .. tostring(v) }, "other")
            end
        elseif one == "set" then
            if two == "day_night_length" or two == "sunrise" or two == "sunset" then
                send({ message = "[Settings]       " .. two .. " is read only." }, "other")
            else
                new = nil
                if three == "false" then
                    new = false
                elseif three == "true" then
                    new = true
                else
                    new = tonumber(three)
                end
                if not (new == nil) then
                    server.setGameSetting(two, new)
                    valid = server.getGameSettings()["two"] == new
                    if valid then
                        send({ message = "[Settings]       " .. two .. " has been updated to " .. tostring(new) .. "." }
                        , "other")
                    else
                        send({ message = "[Settings]       Invalid setting." }, "other")
                    end
                else
                    send({ message = "[Settings]      Invalid value." }, "other")
                end
            end
        else
            send({ message = "[Settings]       Invalid operation. Use 'set' or 'get'." }, "other")
        end
        send({ message = "Command execution complete." }, "other")
    else
        send({ message = "Invalid command" }, "other")
    end
end

function onVehicleSpawn(vehicle_id, peer_id, x, y, z, cost)
    if not ((ignore_0 and peer_id < 1) or peer_id == 65535) then
        vehiclec = vehiclec + 1
        send({ p_id = peer_id, v_id = vehicle_id, p_name = rev_look[peer_id] }, "v_spawn")
        dbg_record("onVehicleSpawn")
        if rev_look[peer_id] == nil then
            one = server.getPlayerName(peer_id)
            pvp[peer_id] = event_pvp
            name_id_lookup[one] = peer_id
            rev_look[peer_id] = one
            warns[peer_id] = 0
            antisteal[peer_id] = true
            pos, _ = server.getPlayerPos(peer_id)
            x, y, z = matrix.position(pos)
            lpos[peer_id] = { x, y, z }
            ui[peer_id] = true
        end
        if peer_id >= 0 then
            --server.notify(peer_id, "Spawned", name_id_lookup[peer_id] .. " spawned vehicle #"..vehicle_id, 8)
            server.notify(peer_id, "Spawned", "Spawned vehicle #" .. vehicle_id .. ".", 8)
            if o_v_map[peer_id] == nil then
                o_v_map[peer_id] = vehicle_id
                v_o_map[vehicle_id] = peer_id
            else
                server.notify(peer_id, "Despawned", "Despawned your old vehicle to make space for your new one.", 8)
                server.notify(peer_id, "Despawned", "Despawned vehicle #" .. o_v_map[peer_id], 8)
                server.despawnVehicle(o_v_map[peer_id], true)
                o_v_map[peer_id] = vehicle_id
                v_o_map[vehicle_id] = peer_id
                autodespawn = true
                despawn_id = peer_id
                l_despawned = vehicle_id
            end
            server.setVehicleEditable(vehicle_id, not antisteal[peer_id])
            server.setVehicleInvulnerable(vehicle_id, not pvp[peer_id])
            if pvp[peer_id] then
                pvpstring = "enabled"
            else
                pvpstring = "disabled"
            end
            server.setVehicleTooltip(vehicle_id,
                "Vehicle #" .. vehicle_id .. "\nOwner: " .. rev_look[peer_id] .. "\nPVP " .. pvpstring)
        end
    end
end

function onVehicleDespawn(vehicle_id, peer_id)
    if (not autodespawn) then
        send({ p_id = peer_id, v_id = vehicle_id, p_name = rev_look[peer_id] }, "v_despawn")
    else
        send({ p_id = despawn_id, v_id = vehicle_id, p_name = rev_look[despawn_id] }, "v_despawn")
    end
    if (peer_id ~= -1 and peer_id ~= 0) then
        dbg_record("onVehicleDespawn")
        if rev_look[peer_id] == nil then
            one = server.getPlayerName(peer_id)
            pvp[peer_id] = event_pvp
            name_id_lookup[one] = peer_id
            rev_look[peer_id] = one
            warns[peer_id] = 0
            antisteal[peer_id] = true
            pos, _ = server.getPlayerPos(peer_id)
            x, y, z = matrix.position(pos)
            lpos[peer_id] = { x, y, z }
            ui[peer_id] = true
        end
        if not (vehicle_id == l_despawned) then
            if not autodespawn then
                if peer_id >= 0 then
                    server.notify(v_o_map[vehicle_id], "Despawned", "Despawned vehicle #" .. vehicle_id, 8)
                    o_v_map[peer_id] = nil
                    v_o_map[vehicle_id] = nil
                    l_despawned = vehicle_id
                end
            else
                autodespawn = false
            end
        end
    end
    vehiclec = vehiclec - 1
end

function onPlayerJoin(steam_id, name, peer_id, admin, auth)
    send({ s_id = steam_id, p_name = name, p_id = peer_id }, "p_join")
    dbg_record("onPlayerJoin")
    server.setPopupScreen(peer_id, 5, "discord invite", true, "Join our discord at\ndiscord.gg/zaMJ95AR", 0.9, -0.9)
    if not (peer_id == 0 and ignore_0) then
        pvp[peer_id] = event_pvp
        name_id_lookup[name] = peer_id
        rev_look[peer_id] = name
        warns[peer_id] = 0
        spawnlimit[peer_id] = 1
        antisteal[peer_id] = true
        send({ steamid = steam_id, username = name, flytype = 'joinactions' }, 'flyback')
        server.announce("[Server]", name .. " joined the game")
        send({ p_id = 0, p_name = '[Server]', mess = name .. ' joined the game' }, "chat")
    end
    playerc = playerc + 1
end

function onPlayerLeave(steam_id, name, peer_id, admin, auth)
    send({ p_name = name, p_id = peer_id }, "p_quit")
    dbg_record("onPlayerLeave")
    server.announce("[Server]", name .. " left the game")
    send({ p_id = 0, p_name = '[Server]', mess = name .. ' left the game' }, "chat")
    name_id_lookup[name] = nil
    rev_look[peer_id] = nil
    if not (o_v_map[peer_id] == nil) then
        steam_ids[peer_id] = nil
        server.notify(peer_id, "Despawned", "Despawned vehicle #" .. o_v_map[peer_id], 8)
        v_o_map[o_v_map[peer_id]] = nil
        server.despawnVehicle(o_v_map[peer_id], true)
        o_v_map[peer_id] = nil
        pvp[peer_id] = nil
    end
    server.removePopup(peer_id, peer_id + ui_offset)
    playerc = playerc - 1
    team1[peer_id] = nil
    team2[peer_id] = nil
end

function probableLeave(peer_id)
    dbg_record("onPlayerLeave")
    name = rev_look[peer_id]
    server.announce("[Server]", name .. " possibly suffered a crash.")
    name_id_lookup[name] = nil
    rev_look[peer_id] = nil
    if not (o_v_map[peer_id] == nil) then
        v_o_map[o_v_map[peer_id]] = nil
        server.despawnVehicle(o_v_map[peer_id], true)
        o_v_map[peer_id] = nil
    end
    server.removePopup(peer_id, peer_id + ui_offset)
end

function onCustomCommand(full_message, user_peer_id, is_admin, is_auth, command, one, two, three, four, five)
    dbg_record("onCustomCommand")
    send(
    { p_id = user_peer_id, command = full_message, p_name = rev_look[user_peer_id], auth = is_auth, admin = is_admin }
    , "c_command")
    rawcomm = command
    command = string.lower(command)
    if command == "?freeze" and is_admin then
        if not (one == nil) then
            lockdown_id = tonumber(one)
        end
    end
    if command == "?forcepvp" and is_admin then
        if not (tonumber(one) == nil) then
            if not (rev_look[user_peer_id] == nil) then
                p_pvp = pvp[tonumber(one)]
                server.notify(user_peer_id, command,
                    "Forced pvp toggle on " .. rev_look[tonumber(one)] .. ". Now set to " .. tostring(not (p_pvp)) .. "."
                    , 8)
                pvp[tonumber(one)] = not (p_pvp)
                if not (o_v_map[user_peer_id] == nil) then
                    server.setVehicleInvulnerable(o_v_map[user_peer_id], not pvp[user_peer_id])
                    if pvp[user_peer_id] == true then
                        pvpstring = "enabled"
                    else
                        pvpstring = "disabled"
                    end
                    server.setVehicleTooltip(o_v_map[user_peer_id],
                        "Vehicle #" .. o_v_map[user_peer_id] .. "\nOwner: " ..
                        rev_look[user_peer_id] .. "\nPVP " .. pvpstring)
                end
            else
                server.notify(user_peer_id, "Player not found.", one, 8)
            end
        else
            server.notify(user_peer_id, "Player not found.", "", 8)
        end
    elseif command == "?restart" and is_admin then
        if restart_buffer_active then
            server.notify(user_peer_id, command, "Restart countdown already started.", 8)
        elseif restart_allow_buffer_active then
            restart_allow_buffer_active = false
            restart_buffer_active = true
            server.notify(-1, "Restarting", "Server will restart in 15 seconds.", 8)
            send({ p_id = 0, p_name = '[Server]', mess = "Server restarting in 15 seconds." }, "chat")
        else
            server.notify(user_peer_id, command, "Run ?restart again to begin restart.", 8)
            restart_allow_buffer = 600
            restart_allow_buffer_active = true
            restart_player = user_peer_id
        end
    elseif command == "?event" and is_admin then
        if one == '1' then
            if not (event_pvp) then
                event_pvp = true
                server.notify(-1, "PVP disabled", "The PVP command has been disabled due to an event.", 8)
                server.announce("[Server]", "The PVP command has been disabled due to an event.")
                send({ p_name = "[Server]", mess = "The PVP command has been disabled due to an event." }, "chat")
                for p, m in pairs(pvp) do
                    pvp[p] = true
                    if o_v_map[p] ~= nil then
                        server.setVehicleInvulnerable(o_v_map[p], false)
                    end
                end
            else
                event_pvp = false
                server.notify(-1, "PVP enabled", "The PVP command has been reenabled.", 8)
                server.announce("[Server]", "The PVP command has been reenabled.")
                send({ p_name = "[Server]", mess = "The PVP command has been reenabled." }, "chat")
            end
        elseif one == '2' then
            if not (event_heal) then
                event_heal = true
                server.notify(-1, "Heal disabled", "The heal command has been disabled due to an event.", 8)
                server.announce("[Server]", "The heal command has been disabled due to an event.")
                send({ p_name = "[Server]", mess = "The heal command has been disabled due to an event." }, "chat")
                for p, m in pairs(pvp) do
                    pvp[p] = true
                    if o_v_map[p] ~= nil then
                        server.setVehicleInvulnerable(o_v_map[p], false)
                    end
                end
            else
                event_heal = false
                server.notify(-1, "Heal enabled", "The heal command has been reenabled.", 8)
                server.announce("[Server]", "The heal command has been reenabled.")
                send({ p_name = "[Server]", mess = "The heal command has been reenabled." }, "chat")
            end
        elseif one == '3' then
            if not (event_repair) then
                event_repair = true
                server.notify(-1, "Repair disabled", "The repair command has been disabled due to an event.", 8)
                server.announce("[Server]", "The repair command has been disabled due to an event.")
                send({ p_name = "[Server]", mess = "The repair command has been disabled due to an event." }, "chat")
                for p, m in pairs(pvp) do
                    pvp[p] = true
                    if o_v_map[p] ~= nil then
                        server.setVehicleInvulnerable(o_v_map[p], false)
                    end
                end
            else
                event_repair = false
                server.notify(-1, "Repair enabled", "The repair command has been reenabled.", 8)
                server.announce("[Server]", "The repair command has been reenabled.")
                send({ p_name = "[Server]", mess = "The repair command has been reenabled." }, "chat")
            end
        elseif one == '4' then
            if not (event_tool) then
                event_tool = true
                server.notify(-1, "Tool disabled", "The tool command has been disabled due to an event.", 8)
                server.announce("[Server]", "The tool command has been disabled due to an event.")
                send({ p_name = "[Server]", mess = "The tool command has been disabled due to an event." }, "chat")
                for p, m in pairs(pvp) do
                    pvp[p] = true
                    if o_v_map[p] ~= nil then
                        server.setVehicleInvulnerable(o_v_map[p], false)
                    end
                end
            else
                event_tool = false
                server.notify(-1, "Tool enabled", "The tool command has been reenabled.", 8)
                server.announce("[Server]", "The tool command has been reenabled.")
                send({ p_name = "[Server]", mess = "The tool command has been reenabled." }, "chat")
            end
        elseif one == '5' then
            if not (event_tp) then
                event_tp = true
                server.notify(-1, "TP disabled", "The TP command has been disabled due to an event.", 8)
                server.announce("[Server]", "The TP command has been disabled due to an event.")
                send({ p_name = "[Server]", mess = "The TP command has been disabled due to an event." }, "chat")
                for p, m in pairs(pvp) do
                    pvp[p] = true
                    if o_v_map[p] ~= nil then
                        server.setVehicleInvulnerable(o_v_map[p], false)
                    end
                end
            else
                event_tp = false
                server.notify(-1, "TP enabled", "The TP command has been reenabled.", 8)
                server.announce("[Server]", "The TP command has been reenabled.")
                send({ p_name = "[Server]", mess = "The TP command has been reenabled." }, "chat")
            end
        elseif one == '6' then
            if not (event_home) then
                event_home = true
                server.notify(-1, "Home disabled", "The home command has been disabled due to an event.", 8)
                server.announce("[Server]", "The home command has been disabled due to an event.")
                send({ p_name = "[Server]", mess = "The home command has been disabled due to an event." }, "chat")
                for p, m in pairs(pvp) do
                    pvp[p] = true
                    if o_v_map[p] ~= nil then
                        server.setVehicleInvulnerable(o_v_map[p], false)
                    end
                end
            else
                event_home = false
                server.notify(-1, "Home enabled", "The home command has been reenabled.", 8)
                server.announce("[Server]", "The home command has been reenabled.")
                send({ p_name = "[Server]", mess = "The home command has been reenabled." }, "chat")
            end
        elseif one == '7' then
            if not (event_goto) then
                event_goto = true
                server.notify(-1, "Goto disabled", "The goto command has been disabled due to an event.", 8)
                server.announce("[Server]", "The goto command has been disabled due to an event.")
                send({ p_name = "[Server]", mess = "The goto command has been disabled due to an event." }, "chat")
                for p, m in pairs(pvp) do
                    pvp[p] = true
                    if o_v_map[p] ~= nil then
                        server.setVehicleInvulnerable(o_v_map[p], false)
                    end
                end
            else
                event_goto = false
                server.notify(-1, "Goto enabled", "The goto command has been reenabled.", 8)
                server.announce("[Server]", "The goto command has been reenabled.")
                send({ p_name = "[Server]", mess = "The goto command has been reenabled." }, "chat")
            end
        else
            server.announce("[Server]", "?event", user_peer_id)
            server.announce("[Server]", "1. toggle pvp, currently " .. (event_pvp and 'true' or 'false'), user_peer_id)
            server.announce("[Server]", "2. toggle heal, currently " .. (event_home and 'true' or 'false'), user_peer_id)
            server.announce("[Server]", "3. toggle repair, currently " .. (event_repair and 'true' or 'false'),
                user_peer_id)
            server.announce("[Server]", "4. toggle tool, currently " .. (event_tool and 'true' or 'false'), user_peer_id)
            server.announce("[Server]", "5. toggle tp, currently " .. (event_tp and 'true' or 'false'), user_peer_id)
            server.announce("[Server]", "6. toggle home, currently " .. (event_home and 'true' or 'false'), user_peer_id)
            server.announce("[Server]", "7. toggle goto, currently " .. (event_goto and 'true' or 'false'), user_peer_id)
        end
    elseif (command == "?pvp") and (not event_pvp) then
        if event_pvp then
            server.notify(user_peer_id, "Event PVP is enabled. PVP controls are not currently allowed.")
        else
            if (tonumber(one) == nil) then
                pvp[user_peer_id] = not pvp[user_peer_id]
                if pvp[user_peer_id] then
                    server.notify(user_peer_id, "PVP", "You have enabled PVP. Others can now shoot you.", 7)
                else
                    server.notify(user_peer_id, "PVP", "You have disabled PVP. Refrain from shooting others.", 7)
                end
                send({ p_name = rev_look[user_peer_id], p_id = user_peer_id, setting = "pvp", val = pvp[user_peer_id] },
                    "p_setting")
                if not (o_v_map[user_peer_id] == nil) then
                    server.setVehicleInvulnerable(o_v_map[user_peer_id], not pvp[user_peer_id])
                    if pvp[user_peer_id] == true then
                        pvpstring = "enabled"
                    else
                        pvpstring = "disabled"
                    end
                    server.setVehicleTooltip(o_v_map[user_peer_id],
                        "Vehicle #" .. o_v_map[user_peer_id] .. "\nOwner: " .. rev_look[user_peer_id] .. "\nPVP " ..
                        pvpstring)
                end
            else
                if not (pvp[tonumber(one)] == nil) then
                    if pvp[tonumber(one)] then
                        server.notify(user_peer_id, rev_look[tonumber(one)] .. "'s PVP",
                            rev_look[tonumber(one)] .. " has opted in to PVP.", 7)
                    else
                        server.notify(user_peer_id, rev_look[tonumber(one)] .. "'s PVP",
                            rev_look[tonumber(one)] .. " has opted out of PVP.", 7)
                    end
                else
                    server.notify(user_peer_id, "Player not found.", 7, 8)
                end
            end
        end
    elseif command == "?register" then
        one = server.getPlayerName(user_peer_id)
        pvp[user_peer_id] = event_pvp
        name_id_lookup[one] = user_peer_id
        rev_look[user_peer_id] = one
        warns[user_peer_id] = 0
        antisteal[user_peer_id] = true
        pos, _ = server.getPlayerPos(user_peer_id)
        x, y, z = matrix.position(pos)
        lpos[user_peer_id] = { x, y, z }
        ui[user_peer_id] = true
    elseif command == "?dump" then
        server.notify(user_peer_id, "team1", dump(team1), 8)
        server.notify(user_peer_id, "team2", dump(team2), 8)
        server.notify(user_peer_id, "captures", dump(capturezones), 8)
    elseif command == "?dump_cz" then
        server.notify(user_peer_id, "team1", dump(t1_capturing), 8)
        server.notify(user_peer_id, "team2", dump(t2_capturing), 8)
        server.notify(user_peer_id, "stalemates ", dump(stalemates), (8 and stalemated or 7))
    elseif command == "?noworkshop" or command == "?auth" then
        server.addAuth(user_peer_id)
        server.removePopup(user_peer_id, 0)
        server.removePopup(user_peer_id, 2)
        if rawcomm == "?NOWORKSHOP" then
            server.notify(user_peer_id, command, "Auth granted. Also, your capslock is on.", 8)
        end
    elseif command == "?warn" and is_admin then
        if not (warns[tonumber(one)] == nil) then
            server.removeAuth(one)
            warn = warns[tonumber(one)] + 1
            p = command .. " " .. one .. " "
            reason = (full_message:sub(0, #p) == p) and full_message:sub(#p + 1) or full_message
            server.notify(one, "Warning", "This is your #" .. warn .. " warning. Reason: " .. reason, 9)
            server.announce("[Server]", rev_look[tonumber(one)] .. " has been given a warning for " .. reason)
            send({
                p_id = 0,
                p_name = '[Server]',
                mess = rev_look[tonumber(one)] ..
                    " has been given a warning for " .. reason
            }, "chat")
            warns[tonumber(one)] = warn
            server.setPopupScreen(tonumber(one), 2, "Welcome to Destroy & Abandon", true,
                "You are recieving this message because you have recieved a warning by the moderators. Type ?auth to recieve auth."
                , 0, 0)
            --if warn==3 then
            --server.kickPlayer(tonumber(one))
            --server.announce("[Server]",rev_look[tonumber(one)].." has been kicked for exceeding 3 warnings.")
            --end
            send({ p_name = rev_look[tonumber(one)], p_id = one, setting = "warn", val = warns[tonumber(one)] },
                "p_setting")
            if not (o_v_map[tonumber(one)] == nil) then
                server.notify(user_peer_id, command, "Despawned vehicle #" .. o_v_map[tonumber(one)], 8)
                server.despawnVehicle(o_v_map[tonumber(one)], true)
                v_o_map[o_v_map[tonumber(one)]] = nil
                l_despawned = o_v_map[tonumber(one)]
                o_v_map[tonumber(one)] = nil
                autodespawn = true
                despawn_id = tonumber(one)
            else
                server.notify(user_peer_id, command, "No vehicle spawned.", 8)
            end
        else
            server.notify(user_peer_id, command, "Player not found", 8)
        end
    elseif command == "?reset_warnings" and is_admin then
        if tonumber(one) == nil then
            server.notify(user_peer_id, command, "User not found", 8)
        else
            warns[tonumber(one)] = 0
            server.notify(one, "Warnings cleared", "Your warning have been reset to 0.", 8)
            server.notify(user_peer_id, "Warnings cleared", "Warnings have been reset to 0.", 8)
            send({ p_name = rev_look[tonumber(one)], p_id = one, setting = "warn", val = warns[tonumber(one)] },
                "p_setting")
        end
    elseif command == "?warnings" and is_admin then
        if not (rev_look[tonumber(one)] == nil) then
            server.notify(user_peer_id, "Warnings", rev_look[tonumber(one)] ..
                " have " .. warns[tonumber(one)] .. " warnings.", 8)
        else
            server.notify(user_peer_id, command, "Player not found", 8)
        end
    elseif command == "?help" then
        server.announce("[Help]", "Avalible commands:", user_peer_id)
        server.announce("?pvp", "Without any arguments, toggles pvp.", user_peer_id)
        server.announce("?pvp (id)", "With ID, displays specified player's PVP status.", user_peer_id)
        server.announce("?antisteal", "Toggles the antisteal status of your vehicle.", user_peer_id)
        server.announce("?c or ?cleanup", "Removes your spawned vehicle.", user_peer_id)
        server.announce("?repair", "Repairs any damage on your vehicle, and resets any consumables.", user_peer_id)
        server.announce("?gps", "Tells you your current location.", user_peer_id)
        server.announce("?sethome", "Sets your home to your current position.", user_peer_id)
        server.announce("?home", "Teleports you to your set home.", user_peer_id)
        server.announce("?die", "Kills you.", user_peer_id)
        server.announce("?goto", "Without any arguments, teleports you to the first unnamed seat on your vehicle.",
            user_peer_id)
        server.announce("?goto (name)", "With a name, teleports you to the first seat with that name on your vehicle.",
            user_peer_id)
        server.announce("?tool", "Without any arguments, tells you a list of tools and tool ids.", user_peer_id)
        server.announce("?tool (id/name)", "With name or id, gives you an item with that name or id.", user_peer_id)
        server.announce("?heal", "Sets you to full health.", user_peer_id)
        server.announce("?tp", "Without any arguments, tells you a list of teleports and teleport ids.", user_peer_id)
        server.announce("?tp (id)", "With id, teleports you to a position with the provided id.", user_peer_id)
        server.announce("?ui", "Toggles ui.", user_peer_id)
        if is_admin then
            server.announce(" ", " ", user_peer_id)
            server.announce("[Help]", "Following are admin-only commands.", user_peer_id)
            server.announce("?warn (id) (reason)",
                "Warn player with specified ID for specified reason, removing their auth.", user_peer_id)
            server.announce("?reset_warnings (id)", "Cleares the specified players warnings.", user_peer_id)
            server.announce("?warnings (id)", "Displays how many warnings the specified user has recieved.", user_peer_id)
            server.announce("?names (id)", "Displays the users steam name history. Useful for detecting workshop.",
                user_peer_id)
        end
    elseif command == "?rules" then
        server.announce("[Rules]", "SW Destroy & Abandon 24/7 Server Rules:", user_peer_id)
        server.announce("[Rules]", "#1: Do not shoot/damage people who has PVP off or if you don't have it enabled.",
            user_peer_id)
        server.announce("[Rules]", "#2: No combat in the spawn areas.", user_peer_id)
        server.announce("[Rules]", "#3: No EMP/Radiation bombs.", user_peer_id)
        server.announce("[Rules]", "#4: Lag machines are not allowed, laggy creations might get despawned by staff.",
            user_peer_id)
        server.announce("[Rules]", "#5: No shouting into voice chat, also do not play loud music from your microphone.",
            user_peer_id)
        server.announce("[Rules]", "#6: Do not troll/annoy others.", user_peer_id)
        server.announce("[Rules]", "#7: Staff have the final say.", user_peer_id)
        server.announce("[Rules]", "#8: Do not argue about politics, culture or religion..", user_peer_id)
    elseif command == "?antisteal" then
        antisteal[user_peer_id] = not (antisteal[user_peer_id])
        if antisteal[user_peer_id] then
            server.notify(user_peer_id, command, "You have enabled antisteal.", 8)
        else
            server.notify(user_peer_id, command, "You have disabled antisteal.", 8)
        end
        send({
            p_name = rev_look[user_peer_id],
            p_id = user_peer_id,
            setting = "antisteal",
            val = antisteal[user_peer_id
            ]
        }, "p_setting")
        if not (o_v_map[user_peer_id] == nil) then
            server.setVehicleEditable(o_v_map[user_peer_id], not antisteal[user_peer_id])
        end
    elseif command == "?c4" and is_admin then
        target, _ = server.getPlayerCharacterID(user_peer_id)
        server.setCharacterItem(target, 2, 31, false, 1000)
    elseif command == "?minigun" and is_admin then
        target, _ = server.getPlayerCharacterID(user_peer_id)
        server.setCharacterItem(target, 1, 33, false, 1000)
    elseif command == "?c" or command == "?cleanup" then
        if not (o_v_map[user_peer_id] == nil) then
            server.notify(user_peer_id, command, "Despawned vehicle #" .. o_v_map[user_peer_id], 8)
            autodespawn = true
            despawn_id = user_peer_id
            l_despawned = o_v_map[user_peer_id]
            server.despawnVehicle(o_v_map[user_peer_id], true)
            v_o_map[o_v_map[user_peer_id]] = nil
            l_despawned = o_v_map[user_peer_id]
            o_v_map[user_peer_id] = nil
        else
            server.notify(user_peer_id, command, "No vehicle spawned.", 8)
        end
    elseif command == "?repair" and (not event_repair) then
        if not (o_v_map[user_peer_id] == nil) then
            sim, _ = server.getVehicleSimulating(o_v_map[user_peer_id])
            if sim then
                server.resetVehicleState(o_v_map[user_peer_id])
                server.notify(user_peer_id, command, "Vehicle repaired", 8)
            else
                server.notify(user_peer_id, command, "Vehicle not simulating.", 8)
            end
        else
            server.notify(user_peer_id, command, "No vehicle spawned.", 8)
        end
    elseif command == "?gps" then
        pos, _ = server.getPlayerPos(user_peer_id)
        x = pos[13]
        alt = pos[14]
        z = pos[15]
        server.notify(user_peer_id, command,
            "Pos:\nx: " ..
            tonumber(string.format("%.3f", x)) ..
            " y: " .. tonumber(string.format("%.3f", z)) .. "\nAlt: " .. tonumber(string.format("%.3f", alt)), 8)
    elseif command == "?sethome" then
        pos, _ = server.getPlayerPos(user_peer_id)
        x = pos[13]
        alt = pos[14]
        z = pos[15]
        homes[user_peer_id] = { x, alt, z }
        server.notify(user_peer_id, command, "Home set", 8)
    elseif command == "?home" and (not event_home) then
        if not (homes[user_peer_id] == nil) then
            home = homes[user_peer_id]
            x = home[1]
            alt = home[2]
            z = home[3]
            server.setPlayerPos(user_peer_id, matrix.translation(x, alt, z))
        else
            server.notify(user_peer_id, command, "No home set. Use ?sethome to set one.", 8)
        end
    elseif command == "?die" then
        target = server.getPlayerCharacterID(user_peer_id)
        server.killCharacter(target)
    elseif command == "?goto" and (not event_goto) then
        if not (o_v_map[user_peer_id] == nil) then
            target = server.getPlayerCharacterID(user_peer_id)
            if one then
                server.setCharacterSeated(target, o_v_map[user_peer_id], one)
            else
                server.setCharacterSeated(target, o_v_map[user_peer_id], "")
            end
        else
            server.notify(user_peer_id, command, "No vehicle spawned.", 8)
        end
    elseif (command == "?tool" or command == "?give") and (not event_tool) then
        if one then
            target, _ = server.getPlayerCharacterID(user_peer_id)
            success = false
            tool_num = 0
            tool_name = ""
            if is_int(one) then
                if tonumber(one) < 41 then
                    tool_num = tonumber(one)
                    tool_name = tool_num_map[tool_num]
                    success = true
                end
            else
                tool_name = one
                tool_num = tool_name_map[tool_name]
                if not (tool_num == nil) then
                    success = true
                end
            end
            if success then
                server.notify(user_peer_id, command, "Gave tool " .. tool_name .. " (ID: " .. tool_num .. ")", 8)
                slot_type = tool_slots[tool_name]
                props = tool_prop[tool_name]
                i = props[1]
                f = props[2]
                if slot_type == 3 then
                    server.setCharacterItem(target, 1, tool_num, false, i, f)
                elseif slot_type == 1 then
                    server.setCharacterItem(target, 10, tool_num, false, i, f)
                else
                    if server.getCharacterItem(target, 2) == 0 then
                        server.setCharacterItem(target, 2, tool_num, false, i, f)
                    elseif server.getCharacterItem(target, 3) == 0 then
                        server.setCharacterItem(target, 3, tool_num, false, i, f)
                    elseif server.getCharacterItem(target, 4) == 0 then
                        server.setCharacterItem(target, 4, tool_num, false, i, f)
                    elseif server.getCharacterItem(target, 5) == 0 then
                        server.setCharacterItem(target, 5, tool_num, false, i, f)
                    elseif server.getCharacterItem(target, 6) == 0 then
                        server.setCharacterItem(target, 6, tool_num, false, i, f)
                    elseif server.getCharacterItem(target, 7) == 0 then
                        server.setCharacterItem(target, 7, tool_num, false, i, f)
                    elseif server.getCharacterItem(target, 8) == 0 then
                        server.setCharacterItem(target, 8, tool_num, false, i, f)
                    else
                        server.setCharacterItem(target, 9, tool_num, false, i, f)
                    end
                end
            else
                server.notify(user_peer_id, command, "Tool not found.", 8)
            end
        else
            for k, v in pairs(tool_num_map) do
                server.announce(k, v, user_peer_id)
            end
        end
    elseif command == "?heal" and (not event_heal) then
        target = server.getPlayerCharacterID(user_peer_id)
        server.setCharacterData(target, 100, true, false)
    elseif command == "?ui" then
        ui[user_peer_id] = not (ui[user_peer_id])
        if not (ui[user_peer_id]) then
            server.removePopup(user_peer_id, user_peer_id + ui_offset)
            server.setPopupScreen(user_peer_id, 5, "discord invite", false, "Join our discord at\ndiscord.gg/FbkH3my3PX"
            , 0.9, -0.9)
        else
            server.setPopupScreen(user_peer_id, 5, "discord invite", true, "Join our discord at\ndiscord.gg/FbkH3my3PX",
                0.9, -0.9)
        end
        send({ p_name = rev_look[user_peer_id], p_id = user_peer_id, setting = "ui", val = ui[user_peer_id] },
            "p_setting")
    elseif command == "?" then
        p = "? "
        server.announce(rev_look[user_peer_id], (full_message:sub(0, #p) == p) and full_message:sub(#p + 1) or
            full_message)
        send({
            p_id = user_peer_id,
            rev_look[user_peer_id],
            mess = (full_message:sub(0, #p) == p) and full_message:sub(#p + 1) or full_message
        }, "chat")
    elseif command == "?tp" and (not event_tp) then
        if not (one == nil) then
            if not (tonumber(one) == nil) then
                if await_collection then
                    await_collection = false
                    raw_teleports = server.getZones("teleport")
                    teleports = {}
                    for k, v in pairs(raw_teleports) do
                        tp_id = v.name
                        x, y, z = matrix.position(v.transform)
                        teleports[tp_id] = { x, y, z }
                        send({ message = "collected teleport " .. v.name }, "other")
                    end
                end
                if tonumber(one) > 0 and tonumber(one) < 20 then
                    position = teleports[one]
                else
                    position = teleports["2"]
                    one = "2"
                end
                x = position[1]
                y = position[2]
                z = position[3]
                server.setPlayerPos(user_peer_id, matrix.translation(x, y, z))
                server.notify(user_peer_id, command, "Teleported you to " .. teleport_names[tonumber(one)], 8)
            end
        else
            for n, name in pairs(teleport_names) do
                server.announce("[TP Locations]", n .. ' - ' .. name, user_peer_id)
            end
        end
    elseif command == "?recollect_tp" and is_admin then
        raw_teleports = server.getZones("teleport")
        teleports = {}
        for k, v in pairs(raw_teleports) do
            tp_id = v.name
            x, y, z = matrix.position(v.transform)
            teleports[tp_id] = { x, y, z }
            send({ message = "collected teleport " .. v.name }, "other")
        end
    elseif command == "?bind" and is_admin then
        o_v_map[tonumber(one)] = tonumber(two)
        v_o_map[tonumber(two)] = tonumber(two)
    elseif command == "?dsp" and is_admin then
        if not (o_v_map[tonumber(one)] == nil) then
            server.notify(user_peer_id, command, "Despawned vehicle #" .. o_v_map[tonumber(one)], 8)
            server.despawnVehicle(o_v_map[tonumber(one)], true)
            v_o_map[o_v_map[tonumber(one)]] = nil
            l_despawned = o_v_map[tonumber(one)]
            o_v_map[tonumber(one)] = nil
            autodespawn = true
            despawn_id = tonumber(one)
        else
            server.notify(user_peer_id, command, "No vehicle spawned.", 8)
        end
    elseif command == "?remove" and is_admin then
        server.despawnVehicle(tonumber(one), true)
    elseif command == "?dump_settings" then
        server.announce("settings", dump(server.getGameSettings()))
    elseif command == "?ping" then
        server.notify(user_peer_id, command, "Ping recieved", 8)
    elseif command == "?announce" and is_admin then
        p = "?announce "
        server.notify(-1, "Announcement", (full_message:sub(0, #p) == p) and full_message:sub(#p + 1) or full_message, 8)
        send({
            p_id = 0,
            p_name = '[Server]',
            mess = "Server announcement: " .. ((full_message:sub(0, #p) == p) and full_message:sub(#p + 1) or
                full_message)
        }, "chat")
    elseif command == '?verify' then
        send({ username = rev_look[user_peer_id], flytype = "verify" }, "flyback")
    elseif command == '?names' and is_admin then
        if not (steam_ids[tonumber(one)] == nil) then
            send({
                steamid = steam_ids[tonumber(one)],
                flytype = "names",
                target = tonumber(one),
                username = rev_look[user_peer_id]
            }, "flyback")
        else
            server.notify(user_peer_id, command, "Unable to find player.", 8)
        end
    elseif command == '?timestamp' then
        server.notify(user_peer_id, command, current_time, 8)
    elseif command == "?flip" then
        if not (o_v_map[user_peer_id] == nil) then
            server.notify(user_peer_id, command, "Flipped vehicle #" .. o_v_map[user_peer_id], 8)
            pos, _ = server.getVehiclePos(o_v_map[user_peer_id], 0, 0, 0)
            x, y, z = matrix.position(pos)
            newpos = matrix.translation(x, y + 5, z)
            server.setVehiclePos(o_v_map[user_peer_id], newpos)
        else
            server.notify(user_peer_id, command, "No vehicle spawned.", 8)
        end
    elseif command == "?nuke" and is_admin then
        if one == "p" then
            if not (pvp[tonumber(two)] == nil) then
                server.spawnExplosion(server.getPlayerPos(tonumber(two)), 1)
            else
                server.notify(user_peer_id, command, "Unable to find player.", 8)
            end
        elseif one == "v" then
            if not (v_o_map[tonumber(two)] == nil) then
                server.spawnExplosion(server.getVehiclePos(tonumber(two)), 1)
            else
                server.notify(user_peer_id, command, "Unable to find vehicle.", 8)
            end
        elseif one == nil or one == '' then
            server.spawnExplosion(server.getPlayerPos(tonumber(user_peer_id)), 1)
        else
            server.notify(user_peer_id, command, "Invalid option.", 8)
        end
    elseif command == "?hypernuke" and is_admin then
        if one == "p" then
            if not (pvp[tonumber(two)] == nil) then
                nuke(server.getPlayerPos(tonumber(two)), 3)
            else
                server.notify(user_peer_id, command, "Unable to find player.", 8)
            end
        elseif one == "v" then
            if not (v_o_map[tonumber(two)] == nil) then
                nuke(server.getVehiclePos(tonumber(two)), 3)
            else
                server.notify(user_peer_id, command, "Unable to find vehicle.", 8)
            end
        elseif one == nil or one == '' then
            nuke(server.getPlayerPos(tonumber(user_peer_id)), 3)
        else
            server.notify(user_peer_id, command, "Invalid option.", 8)
        end
    elseif command == '?spread' and is_admin then
        spread = tonumber(one)
    elseif command == "?team" then
        if one == "1" then
            team1[user_peer_id] = 1
            team2[user_peer_id] = nil
            server.notify(-1, command, rev_look[user_peer_id] .. " has joined team 1.", 8)
            server.setPopupScreen(user_peer_id, t1_ui_id, "team 1 status", true, "Not in a capture zone", 0, 0.9)
            server.setPopupScreen(user_peer_id, t2_ui_id, "team 2 status", false, "Not in a capture zone", 0, 0.9)
        elseif one == '2' then
            team1[user_peer_id] = nil
            team2[user_peer_id] = 1
            server.notify(-1, command, rev_look[user_peer_id] .. " has joined team 2.", 8)
            server.setPopupScreen(user_peer_id, t1_ui_id, "team 1 status", false, "Not in a capture zone", 0, 0.9)
            server.setPopupScreen(user_peer_id, t2_ui_id, "team 2 status", true, "Not in a capture zone", 0, 0.9)
        elseif one == '0' then
            team1[user_peer_id] = nil
            team2[user_peer_id] = nil
            server.notify(-1, command, rev_look[user_peer_id] .. " has left their team.", 8)
            server.setPopupScreen(user_peer_id, t1_ui_id, "team 1 status", false, "Not in a capture zone", 0, 0.9)
            server.setPopupScreen(user_peer_id, t2_ui_id, "team 2 status", false, "Not in a capture zone", 0, 0.9)
        else
            server.notify(user_peer_id, command, "Invalid team. Enter 1 or 2 to join a team, or 0 to leave one.", 8)
        end
    else
        server.notify(user_peer_id, command, "Invalid command", 8)
    end
end

zones = server.getZones()
teleports = {}
for k, v in pairs(zones) do
    --send({ message = "m " .. v.tags_full .. ' ' .. v.name }, "other")
    if string.match(v.tags_full, "teleport") then
        tp_id = v.name
        x, y, z = matrix.position(v.transform)
        teleports[tp_id] = { x, y, z }
        send({ message = "collected teleport " .. v.name }, "other")
    end
end

--do this instead of ?register
--much more user friendly, however still does not solve the issue of vehicles
--potentially lift livedata info about vehicles to recreate ownership

plas = server.getPlayers()
for _, v in pairs(plas) do
    register(v["id"])
end


send({ message = 'Server started' }, "other")
send({ p_id = 0, p_name = '[Server]', mess = 'Server started.' }, "chat")
