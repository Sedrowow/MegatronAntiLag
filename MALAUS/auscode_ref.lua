---@diagnostic disable: lowercase-global
-- g_savedata table that persists between game sessions
g_savedata = {
	playerdata={},
	usercreations={}
}

-- perm numbers
PermNone = 0
PermAuth = 1
PermMod = 2
PermAdmin = 3
PermOwner = 4

-- admin list. formating: adminlist = {{"76561199240115313",PermOwner},{"76561199143631975",PermAdmin}}
adminlist = {{"76561199240115313",PermOwner},{"76561199143631975",PermAdmin},{"76561199032157360",PermAdmin},{"76561198170233995",PermAdmin},{"76561199514304709",PermAdmin},{"76561198453848694",PermAdmin},{"76561199477098490",PermMod}}

-- tables
nosave = {playerdata={}} -- list that doesnt save
chatMessages = {}
hiddencommands = {"?msg","?warn","?pi","?pc","?forcepvp","?forceas","?forcerepair","?ep","?e"} -- list of commands to dont want to show to everyone in chat
disabledcommands = {} -- list of commands that are disabled
playerlist = {}
-- settings
discordlink = "discord.aussieworks.xyz"
rules = "1.Common sense rules apply\n2.No flares / radiation / emp\n3.Move vehicles out of the hanger if there are other people trying to spawn things\n4.Staff have final say\n5.Despawn your vehicles after use"
maxMessages = 250
playermaxvehicles = 1
unlockislands = true
playerdatasave = true
despawnonreload = false
customchat = true
showcommandsinchat = true
disablecommandsnotification = false
customweatherevents = false
customweatherfrequency = 60 -- in seconds
forcepvp = false -- if true then pvp will be on by default and the ?pvp command will be dissabled
pvpeffects = true -- if player dies with pvp off they will get revived and healed ect
subbodylimiting = true
maxsubbodys = 15
voxellimiting = true
voxellimit = 25000
despawndropeditems = true
despawndropeditemsdelay = 10
limitingbypass = false
limitingbypassperm = PermOwner
warnactionthreashold = 3
warnaction = "kick" -- can be "kick" or "ban"
allownicknames = true
permtonick = PermAdmin
enableplaytime = true
enablebackend = true -- requires backend to be running. and also requires the backend to be from AusCode, otherwise it may not work
backendport = 8000
heartbeatfrequency = 5
servernumber = 1 -- this corresponds to what number your server is. for example 1 would be server1. this only matters if you are using the backend and the server control scripts.
playtimetodbfrequency = 60 -- in seconds
playtimeupdatefrequency = 10 -- in seconds
testingwarning = false -- used to tell players that the scripts are in development and their might be frequent script reloads
tipFrequency = 180  -- in seconds
tips = true -- if true then tips will be shown in chat
tipmessages = {"use ?help to get a list of all the available commands","use ?auth if you dont have permision to use a workbench","we have a discord server. dont forget to join. "..discordlink.." or run the command ?disc","use ?as or ?antisteal to toggle your personal antisteal","use ?pvp to toggle your personal pvp","use ?ui to toggle your personal ui"} -- list of tips that will be shown in chat
debug_enabled = false -- currently not fully implemented
-- dont touch
tiptimer = 0
uitimer = 0
tipstep = 1
TIME = server.getTimeMillisec()
TICKS = 0
TPS = 0
tickDuration = 1000
scriptversion = "v1.7.0-Testing"



-- Player Managment
-- initalising the player
function playerint(steam_id, peer_id)
	local pn = server.getPlayerName(peer_id)
	pn = friendlystring(pn)
	if playerdatasave then
		if g_savedata["playerdata"][tostring(steam_id)] == nil then
			g_savedata["playerdata"][tostring(steam_id)] = {steam_id=tostring(steam_id), peer_id=tostring(peer_id), name=tostring(pn), as=true, pvp=false, ui=false, warns=0, nicked=false, lastseat={}, pt=0, ptlu=server.getTimeMillisec(), ptachivment=0, groups=getPlayerVehicleGroups(peer_id)}
			for _, sid in pairs(adminlist) do
				if tostring(sid[1]) == tostring(steam_id) then
					g_savedata["playerdata"][tostring(steam_id)]["perms"] = sid[2]
				end
			end
			if g_savedata["playerdata"][tostring(steam_id)]["perms"] == nil then
				g_savedata["playerdata"][tostring(steam_id)]["perms"] = PermNone
			end
			if forcepvp then
				g_savedata["playerdata"][tostring(steam_id)]["pvp"] = true
			end
		elseif g_savedata["playerdata"][tostring(steam_id)] ~= nil then
			g_savedata["playerdata"][tostring(steam_id)]["peer_id"] = tostring(peer_id)
			if allownicknames then
				if g_savedata["playerdata"][tostring(steam_id)]["nicked"] == true then
					g_savedata["playerdata"][tostring(steam_id)]["name"] = g_savedata["playerdata"][tostring(steam_id)]["name"]
				else
					g_savedata["playerdata"][tostring(steam_id)]["name"] = pn
				end
			else
				g_savedata["playerdata"][tostring(steam_id)]["name"] = pn
			end
			g_savedata["playerdata"][tostring(steam_id)]["as"] = g_savedata["playerdata"][tostring(steam_id)]["as"] or true
			g_savedata["playerdata"][tostring(steam_id)]["pvp"] = g_savedata["playerdata"][tostring(steam_id)]["pvp"] or false
			g_savedata["playerdata"][tostring(steam_id)]["ui"] = g_savedata["playerdata"][tostring(steam_id)]["ui"] or false
			g_savedata["playerdata"][tostring(steam_id)]["warns"] = tostring(g_savedata["playerdata"][tostring(steam_id)]["warns"]) or "0"
			g_savedata["playerdata"][tostring(steam_id)]["nicked"] = g_savedata["playerdata"][tostring(steam_id)]["nicked"] or false
			g_savedata["playerdata"][tostring(steam_id)]["pt"] = g_savedata["playerdata"][tostring(steam_id)]["pt"] or 0
			g_savedata["playerdata"][tostring(steam_id)]["ptlu"] = server.getTimeMillisec()
			g_savedata["playerdata"][tostring(steam_id)]["ptachivment"] = g_savedata["playerdata"][tostring(steam_id)]["ptachivment"] or 0
			g_savedata["playerdata"][tostring(steam_id)]["groups"] = getPlayerVehicleGroups(peer_id)
			for _, sid in pairs(adminlist) do
				if tostring(sid[1]) == tostring(steam_id) then
					g_savedata["playerdata"][tostring(steam_id)]["perms"] = sid[2]
				end
			end
			if g_savedata["playerdata"][tostring(steam_id)]["perms"] == nil then
				g_savedata["playerdata"][tostring(steam_id)]["perms"] = PermNone
			end
			if forcepvp then
				g_savedata["playerdata"][tostring(steam_id)]["pvp"] = true
			end
		end
	end
	if playerdatasave == false then
		nosave["playerdata"][tostring(steam_id)] = {steam_id=tostring(steam_id), peer_id=peer_id, name=tostring(pn), as=true, pvp=false, ui=false, warns=0}
		for _, sid in pairs(adminlist) do
			if tostring(sid[1]) == tostring(steam_id) then
				nosave["playerdata"][tostring(steam_id)]["perms"] = sid[2]
			end
		end
		if nosave["playerdata"][tostring(steam_id)]["perms"] == nil then
			nosave["playerdata"][tostring(steam_id)]["perms"] = PermNone
		end
		if forcepvp then
			g_savedata["playerdata"][tostring(steam_id)]["pvp"] = true
		end
	end
end

-- function to get playerdata
---@param get string | nil
---@param idtoggle boolean
---@param id string | number
---@return any
function getPlayerdata(get, idtoggle, id)
	local playerdata = nil

	if playerdatasave then
		if idtoggle then
			local sid = getsteam_id(id)
			if sid == nil then
				return nil
			end
			playerdata = g_savedata["playerdata"][tostring(sid)]
		else
			playerdata = g_savedata["playerdata"][tostring(id)]
		end
	else
		if idtoggle then
			local sid = getsteam_id(id)
			if sid == nil then
				return nil
			end
			playerdata = nosave["playerdata"][tostring(sid)]
		else
			playerdata = nosave["playerdata"][tostring(id)]
		end
	end

	if playerdata == nil then
		return nil
	end

	if get ~= nil then
		return playerdata[get]
	else
		return playerdata
	end
end

-- function to set playerdata
---@param set string
---@param idtoggle boolean
---@param id string | number
---@param value boolean | string | number | table
function setPlayerdata(set, idtoggle, id, value) -- if idtoggle true it will try to use peer_id
	if playerdatasave then
		if idtoggle then
			local sid = getsteam_id(id)
			if set ~= nil then
				if g_savedata["playerdata"][tostring(sid)][set] ~= nil then
					if value ~= nil then
						g_savedata["playerdata"][tostring(sid)][set] = value
					end
				end
			end
		else
			if set ~= nil then
				if value ~= nil then
					g_savedata["playerdata"][tostring(id)][set] = value
				end
			end
		end
	elseif not playerdatasave then
		if idtoggle then
			local sid = getsteam_id(id)
			if set ~= nil then
				nosave["playerdata"][tostring(sid)][set] = value
			end
		else
			if set ~= nil then
				nosave["playerdata"][tostring(id)][set] = value
			end
		end
	end
end

-- player joined
function onPlayerJoin(steam_id, name, peer_id, admin, auth)
	sendannounce("[Server]", peer_id.." | "..name.." joined the game")
	server.setPopupScreen(peer_id, 3, "auth", true, "You are not authed. type ?auth in chat to get authed", 0, 0)
	if testingwarning then
		sendannounce("[AusCode]", "Script is being worked on and there will be many script reloads", peer_id)
	end
	server.removeAuth(peer_id)
	sendChat = true
	playerint(steam_id, peer_id)
	sendJoin(steam_id)
end

-- player leave
function onPlayerLeave(steam_id, name, peer_id, admin, auth)
	sendannounce("[Server]", peer_id.." | "..name.." left the game")
	local ownersteamid = getsteam_id(peer_id)
	for group_id, GroupData in pairs(g_savedata["usercreations"]) do
		if GroupData["ownersteamid"] == ownersteamid then
			server.despawnVehicleGroup(group_id, true)
		end
	end
	setPlayerdata("groups", true, peer_id, {})
	for i, player in pairs(playerlist) do
		if player.id == peer_id then
			if enableplaytime then
				updatePlaytime()
			end
			if enablebackend then
				sendPlaytime(steam_id)
			end
			table.remove(playerlist, i)
		end
	end
end

-- geting the steam id off a peer id
function getsteam_id(peer_id)
	peer_id = tostring(peer_id)
	if playerdatasave then
		for _, playerdata in pairs(g_savedata["playerdata"]) do
			if tostring(playerdata["peer_id"]) == tostring(peer_id) then
				return playerdata["steam_id"]
			end
		end
	else
		for _, playerdata in pairs(nosave["playerdata"]) do
			if tostring(playerdata["peer_id"]) == tostring(peer_id) then
				return playerdata["steam_id"]
			end
		end
	end
end

-- geting the peer id off a steam id
function getpeer_id(steam_id)
	if playerdatasave then
		for _, playerdata in pairs(g_savedata["playerdata"]) do
			if tostring(playerdata["steam_id"]) == tostring(steam_id) then
				return playerdata["peer_id"]
			end
		end
	else
		for _, playerdata in pairs(nosave["playerdata"]) do
			if tostring(playerdata["steam_id"]) == tostring(steam_id) then
				return playerdata["peer_id"]
			end
		end
	end
end

-- custom chat function
if customchat then
	function logChatMessage(name, full_message)
		table.insert(chatMessages, {full_message=full_message,name=name,topid=nil})
		for _, chat in pairs(chatMessages) do
			if countitems(chatMessages) > maxMessages then
				table.remove(chatMessages, 1)
			end
		end
	end
	function printChatMessages()
		for _, chat in ipairs(chatMessages) do
			if chat.topid == nil then
				server.announce(chat.name, chat.full_message)
			else
				server.announce(chat.name, chat.full_message, chat.topid)
			end
		end
	end
	function onChatMessage(peer_id, sender_name, message)
		local sender_name = getPlayerdata("name", true, peer_id)
		local perms = getPlayerdata("perms", true, peer_id)
		local name = ""
		if perms == PermOwner then
			name = "[Owner] "..sender_name
		elseif perms == PermAdmin then
			name = "[Admin] "..sender_name
		elseif perms == PermMod then
			name = "[Mod] "..sender_name
		elseif perms == PermAuth then
			name = "[Player] "..sender_name
		elseif perms == PermNone then
			name = "[Player] "..sender_name
		end
		logChatMessage(name, message)
		sendChat = true
		if debug_enabled then
			sendannounce("[Debug]", tostring(sendChat))
		end
	end
end
--endregion


-- Vehicle Managment
-- vehicle spawned
function onVehicleSpawn(vehicle_id, peer_id, x, y, z, group_cost, group_id)
	if peer_id ~= -1 then
		local pvp = ""
		if getPlayerdata("as", true, peer_id) == true then
			server.setVehicleEditable(vehicle_id, false)
		elseif getPlayerdata("as", true, peer_id) == false then
			server.setVehicleEditable(vehicle_id, true)
		end
		if getPlayerdata("pvp", true, peer_id) == true then
			server.setVehicleInvulnerable(vehicle_id, false)
			pvp = "true"
		elseif getPlayerdata("pvp", true, peer_id) == false then
			server.setVehicleInvulnerable(vehicle_id, true)
			pvp = "false"
		end
		local name = getPlayerdata("name", true, peer_id)
		server.setVehicleTooltip(vehicle_id, "Owner: "..peer_id.." | "..name.."\nPVP: "..pvp.." | Group ID: "..group_id)
		if peer_id ~= -1 and peer_id ~= nil then
			if g_savedata["usercreations"][tostring(group_id)] == nil then
				g_savedata["usercreations"][tostring(group_id)] = {OwnerID=peer_id, ownersteamid=getsteam_id(peer_id), Vehicleparts={}, cost=group_cost}
			end
			g_savedata["usercreations"][tostring(group_id)]["Vehicleparts"][tostring(vehicle_id)] = 1
			local ownersteamid = getsteam_id(peer_id)
			local vehiclespawned = 0
			for group_id, GroupData in pairs(g_savedata["usercreations"]) do
				if GroupData["ownersteamid"] == ownersteamid then
					local groupdata, gexists = server.getVehicleGroup(group_id)
					if gexists then
						vehiclespawned = vehiclespawned + 1
					else
						g_savedata["usercreations"][tostring(group_id)] = nil
					end
					if vehiclespawned > playermaxvehicles then
						server.despawnVehicleGroup(group_id, true)
						server.notify(peer_id, "[Server]", "You can only have "..playermaxvehicles.." vehicle spawned at a time", 6)

					end
				end
			end
		end
	end
end

-- on vehicle spawn 
function onGroupSpawn(group_id, peer_id, x, y, z, group_cost)
	local sid = getsteam_id(peer_id)
	if sid ~= 0 then
		loop(0.5,
		function(id)
			local groupdata, is_success = server.getVehicleGroup(group_id)
			if is_success then
				local despawned = checklimmiting(group_id, peer_id)
				if not despawned then
					if g_savedata["usercreations"][tostring(group_id)] ~= nil then
						local name = getPlayerdata("name", true, peer_id)
						if group_cost == 0 then
							sendannounce("[Server]", peer_id.." | "..name.." spawned vehicle group: "..group_id)
						else
							sendannounce("[Server]", peer_id.." | "..name.." spawned vehicle group: "..group_id.." Cost: $"..string.format("%.0f",group_cost))
						end
						setPlayerdata("groups", true, peer_id, getPlayerVehicleGroups(peer_id))
						removeLoop(id)
					end
				end
				if despawned then
					removeLoop(id)
				end
			end
		end
		)
	end
end

-- check limiting
function checklimmiting(group_id, peer_id)
	local bypassperms = 0
	if limitingbypass then
		bypassperms = getPlayerdata("perms", true, peer_id)
	end
	if bypassperms < limitingbypassperm then
		if voxellimiting then
			local name = getPlayerdata("name", true, peer_id)
			local voxel_count = calculateVoxels(group_id)
			if voxel_count > voxellimit then
				server.despawnVehicleGroup(group_id, true)
				sendannounce("[Server]", peer_id.." | "..name.."'s vehicle group: "..group_id.." has been despawned for exceededing block limit "..voxel_count.."/"..voxellimit)
				return true
			end
			if debug_enabled then
				sendannounce("[AusCode]", voxel_count)
			end
		end
		if subbodylimiting then
			local subbodys = server.getVehicleGroup(group_id)
			if #subbodys > maxsubbodys then
				if debug_enabled then
					sendannounce("[AusCode]", #subbodys)
				end
				name = server.getPlayerName(peer_id)
				sendannounce("[Server]", peer_id.." | "..name.."'s vehicle group: "..group_id.." has been despawned for exceededing subbody limit "..#subbodys.."/"..maxsubbodys)
				server.despawnVehicleGroup(group_id, true)
				return true
			end
		end
	end
end

-- calculate voxels
function calculateVoxels(group_id)
	local voxel_count = 0
	local group = tostring(group_id)
	for group_id, GroupData in pairs(g_savedata["usercreations"]) do
		if group_id == group then
			for vehicle_id, _ in pairs(GroupData["Vehicleparts"]) do
				local vehicle_components, is_success = server.getVehicleComponents(vehicle_id)
				if is_success then
					voxel_count = vehicle_components["voxels"] + voxel_count
				end
			end
		end
	end
	return voxel_count
end

-- vehicle despawned
function onVehicleDespawn(vehicle_id, peer_id)
	local groupid = -1
	for group_id, GroupData in pairs(g_savedata["usercreations"]) do
		if GroupData["Vehicleparts"][tostring(vehicle_id)] ~= nil then
			groupid = group_id
			break
		end
	end
	if groupid ~= -1 then
		g_savedata["usercreations"][tostring(groupid)]["Vehicleparts"][tostring(vehicle_id)] = nil
		if countitems(g_savedata["usercreations"][tostring(groupid)]["Vehicleparts"]) == 0 then
			onGroupDespawn(groupid, g_savedata["usercreations"][tostring(groupid)]["OwnerID"])
		end
	end
end

-- remove vehicle off list
function onGroupDespawn(group_id, peer_id)
	local m = server.getCurrency()
	local nm = m + g_savedata["usercreations"][tostring(group_id)]["cost"]
	server.setCurrency(nm, 0)
	g_savedata["usercreations"][tostring(group_id)] = nil
	setPlayerdata("groups", true, peer_id, getPlayerVehicleGroups(peer_id))
end

-- get a players vehicle groups
function getPlayerVehicleGroups(peer_id)
	local groups = {}
	local ownersteamid = getsteam_id(peer_id)
	for group_id, GroupData in pairs(g_savedata["usercreations"]) do
		if GroupData["ownersteamid"] == ownersteamid then
			local groupdata, gexists = server.getVehicleGroup(group_id)
			if gexists then
				GroupData["group_id"] = group_id
				table.insert(groups, GroupData)
			end
		end
	end
	return groups
end


-- count stuffs
function countitems(list)
	local number = 0
	for _, item in pairs(list) do
		if item ~= nil then
			number = number + 1
		end
	end
	return number
end
--endregion

-- Misc
-- send announcement
function sendannounce(name,message,target)
	if target == nil then
		target = -1
	end
	server.announce(name,message,target)
	table.insert(chatMessages, {full_message=message,name=name,topid=target})
end

-- Function to format runtime in days, hours, minutes, and seconds
function formatUptime(uptimeTicks, tickDuration)
	uptimeTicks = server.getTimeMillisec()
	local totalSeconds = math.floor(uptimeTicks / tickDuration)
	local hours = math.floor(totalSeconds / 3600)
	local minutes = math.floor((totalSeconds % 3600) / 60)
	local seconds = totalSeconds % 60
	return string.format("%02dh %02dm %02ds", hours, minutes, seconds)
end

-- format time
function formattime(uptimeTicks, tickDuration)
	uptimeTicks = tonumber(uptimeTicks) or 0
	tickDuration = 1000
	local totalSeconds = math.floor(uptimeTicks / tickDuration)
	local hours = math.floor(totalSeconds / 3600)
	local minutes = math.floor((totalSeconds % 3600) / 60)
	local seconds = totalSeconds % 60
	return string.format("%02dh %02dm %02ds", hours, minutes, seconds)
end

-- removes characters that brake things
function friendlystring(String)
	return string.gsub(String, "[<]", "")
end

-- Backend things
---@param steam_id string
function sendPlaytime(steam_id)
	if not enablebackend then
		return
	end
	server.httpGet(backendport, "/player/playtime/post?steam_id="..tostring(steam_id).."&playtime="..getPlayerdata("pt", false, steam_id))
end
function getPlaytime(steam_id)
	if not enablebackend then
		return
	end
	server.httpGet(backendport, "/player/playtime/get?steam_id="..tostring(steam_id))
end
function heartbeat()
	if not enablebackend then
		return
	end
	server.httpGet(backendport, "/heartbeat/"..tostring(servernumber).."?tps="..tostring(math.floor(TPS)).."&players="..tostring(#playerlist))
end
function sendJoin(steam_id)
	if not enablebackend then
		return
	end
	server.httpGet(backendport, "/player/join?steam_id="..tostring(steam_id))
end
function sendWarn(steam_id)
	if not enablebackend then
		return
	end
	server.httpGet(backendport, "/player/warn?steam_id="..tostring(steam_id))
end
function httpReply(port, request, reply)
	if startsWith(request, "/player/playtime/get") then
		request = tostring(request)
		local sid = request:gsub("^/player/playtime/get%?steam_id=%s*", "")
		setPlayerdata("pt", false, sid, reply)
		local playtime = tonumber(reply) or 0
		if playtime >= 36000000 then
			setPlayerdata("ptachivment", false, sid, 6)
		elseif playtime >= 28800000 then
			setPlayerdata("ptachivment", false, sid, 5)
		elseif playtime >= 14400000 then
			setPlayerdata("ptachivment", false, sid, 4)
		elseif playtime >= 7200000 then
			setPlayerdata("ptachivment", false, sid, 3)
		elseif playtime >= 3600000 then
			setPlayerdata("ptachivment", false, sid, 2)
		elseif playtime >= 1800000 then
			setPlayerdata("ptachivment", false, sid, 1)
		end
		if debug_enabled then
			sendannounce("[Debug]", "Playtime for "..sid.." is "..reply)
		end
	end
end
--endregion

-- check if starts with
function startsWith(str, value)
	return str:sub(1, #value) == value
end
--endregion

--toggle players pvp
function togglePVP(peer_id, state, silently)
	if forcepvp then
		return
	end

	local pvp = getPlayerdata("pvp", true, peer_id)
	local name = getPlayerdata("name", true, peer_id)

	if state ~= nil then
		state = state:lower()
		if tostring(state) == tostring(pvp) then
			return
		end
		if tostring(state) == "true" then
			setPlayerdata("pvp", true, peer_id, true)
			if not silently then
				server.notify(peer_id, "[Server]", "PVP enabled", 5)
				sendannounce("[Server]", peer_id.." | "..name.." has enabled their PVP")
			end
		elseif tostring(state) == "false" then
			setPlayerdata("pvp", true, peer_id, false)
			if not silently then
				server.notify(peer_id, "[Server]", "PVP disabled", 6)
				sendannounce("[Server]", peer_id.." | "..name.." has disabled their PVP")
			end
		end
	else
		if pvp == true then
			setPlayerdata("pvp", true, peer_id, false)
			if not silently then
				server.notify(peer_id, "[Server]", "PVP disabled", 6)
				sendannounce("[Server]", peer_id.." | "..name.." has disabled their PVP")
			end
		elseif pvp == false then
			setPlayerdata("pvp", true, peer_id, true)
			if not silently then
				server.notify(peer_id, "[Server]", "PVP enabled", 5)
				sendannounce("[Server]", peer_id.." | "..name.." has enabled their PVP")
			end
		end
	end

	-- Update vehicle tooltips and invulnerability
	local ownersteamid = getsteam_id(peer_id)
	for group_id, GroupData in pairs(g_savedata["usercreations"]) do
		if GroupData["ownersteamid"] == ownersteamid then
			for vehicle_id, _ in pairs(GroupData["Vehicleparts"]) do
				server.setVehicleTooltip(vehicle_id, "Owner: "..peer_id.." | "..name.."\nPVP: "..tostring(getPlayerdata("pvp", true, peer_id)).." | Group ID: "..group_id)
				server.setVehicleInvulnerable(vehicle_id, not getPlayerdata("pvp", true, peer_id))
			end
		end
	end
end

-- toggle players anti-steal
function toggleAS(peer_id, state)
	local as = getPlayerdata("as", true, peer_id)

	if state ~= nil then
		state = state:lower()
		if tostring(state) == tostring(as) then
			return
		end
		if tostring(state) == "true" then
			setPlayerdata("as", true, peer_id, true)
			server.notify(peer_id, "[Server]", "Anti-steal enabled", 5)
		elseif tostring(state) == "false" then
			setPlayerdata("as", true, peer_id, false)
			server.notify(peer_id, "[Server]", "Anti-steal disabled", 6)
		end
	else
		if as == true then
			setPlayerdata("as", true, peer_id, false)
			server.notify(peer_id, "[Server]", "Anti-steal disabled", 6)
		elseif as == false then
			setPlayerdata("as", true, peer_id, true)
			server.notify(peer_id, "[Server]", "Anti-steal enabled", 5)
		end
	end

	-- Update vehicle editability
	local ownersteamid = getsteam_id(peer_id)
	for group_id, GroupData in pairs(g_savedata["usercreations"]) do
		if GroupData["ownersteamid"] == ownersteamid then
			for vehicle_id, _ in pairs(GroupData["Vehicleparts"]) do
				server.setVehicleEditable(vehicle_id, not getPlayerdata("as", true, peer_id))
			end
		end
	end
end

-- toggle players ui
function toggleUI(peer_id, state, silently)
	if silently == nil then
		silently = false
	end
	local ui = getPlayerdata("ui", true, peer_id)

	if state ~= nil then
		state = tostring(state):lower()
		if tostring(state) == tostring(ui) then
			return
		end
		if tostring(state) == "true" then
			setPlayerdata("ui", true, peer_id, true)
			if not silently then
				server.notify(peer_id, "[Server]", "UI enabled", 5)
			end
		elseif tostring(state) == "false" then
			setPlayerdata("ui", true, peer_id, false)
			server.removePopup(peer_id, 2)
			if not silently then
				server.notify(peer_id, "[Server]", "UI disabled", 6)
			end
		end
	else
		if ui == true then
			setPlayerdata("ui", true, peer_id, false)
			server.removePopup(peer_id, 2)
			if not silently then
				server.notify(peer_id, "[Server]", "UI disabled", 6)
			end
		elseif ui == false then
			setPlayerdata("ui", true, peer_id, true)
			if not silently then
				server.notify(peer_id, "[Server]", "UI enabled", 5)
			end
		end
	end
end

-- Commands
function onCustomCommand(full_message, user_peer_id, is_admin, is_auth, command, one, two, three, four, five)
	local perms = getPlayerdata("perms", true, user_peer_id)
	local commandfound = false
	sendChat = true
	-- shows command players run
	if showcommandsinchat then
		local playername = getPlayerdata("name", true, user_peer_id)
		local name = ""
		if perms == PermOwner then
			name = "[Owner] "..playername
		elseif perms == PermAdmin then
			name = "[Admin] "..playername
		elseif perms == PermMod then
			name = "[Mod] "..playername
		elseif perms == PermAuth then
			name = "[Player] "..playername
		elseif perms == PermNone then
			name = "[Player] "..playername
		end
		if not customchat then
			name = playername
		end

		local hidecommand = false
		for c, commanddata in pairs(hiddencommands) do
			if command:lower() == commanddata then
				hidecommand = true
			end
		end
		if not hidecommand then
			sendannounce(name, "> "..full_message)
		end
		local disabledcommand = false
		for c, commanddata in pairs(disabledcommands) do
			if command:lower() == commanddata then
				disabledcommand = true
			end
		end
		if disabledcommand then
			if disablecommandsnotification then
				server.notify(user_peer_id, "[Server]", "That command has been disabled. try using ?help for a list of commands", 6)
			end
			return
		end
	end


-- Player
	-- player info
	if (command:lower() == "?pi") then
		commandfound = true
		if one ~= nil then
			if server.getPlayerName(one) == "" then
				server.notify(user_peer_id, "[Server]", "Player with the specified ID does not exist.", 6)
			else
				local sid = "Unknown"
				local name = "Unknown"
				local pvp = "Unknown"
				local was = "Unknown"
				local wui = "Unknown"
				local nms = "Unknown"
				local pt = "Unknown"
				local pta = "Unknown"
				local vsp = "None"
				if perms >= PermAdmin then
					local playerdata = getPlayerdata(nil, true, one)
					sid = playerdata["steam_id"]
					name = playerdata["name"]
					local warns = playerdata["warns"]
					if playerdata["as"] ~= nil then
						was = tostring(playerdata["as"])
					end
					if playerdata["pvp"] ~= nil then
						pvp = tostring(playerdata["pvp"])
					end
					if playerdata["ui"] ~= nil then
						wui = tostring(playerdata["ui"])
					end
					if playerdata["nicked"] ~= nil then
						nms = tostring(playerdata["nicked"])
					end
					if enableplaytime then
						if playerdata["pt"] ~= nil then
							pt = formattime(playerdata["pt"])
						end
						if playerdata["ptachivment"] ~= nil then
							pta = tostring(playerdata["ptachivment"])
						end
					end
					local vehicles = getPlayerVehicleGroups(one)
					for _, GroupData in pairs(vehicles) do
						if vsp == "None" then
							vsp = GroupData["group_id"]
						else
							vsp = vsp..", "..GroupData["group_id"]
						end
					end
					sendannounce("[Server]", "Peer id: "..tostring(one).."\nName: "..name.."\nNicked: "..nms.."\nSteam id: "..tostring(sid).."\nAntisteal: "..was.."\nPVP: "..pvp.."\nUI: "..wui.."\nWarns: "..warns.."\nPlaytime: "..pt.."\nPlaytimeachivment: "..pta.."\nVehicles: "..vsp, user_peer_id)
				end
			end
		else
			local pid = ""
			local name = ""
			if perms >= PermAdmin then
				if playerdatasave then
					for sid, playedata in pairs(g_savedata["playerdata"]) do
						pid = getpeer_id(sid)
						name = playedata["name"]
						sendannounce("[Server]", "Peer id: "..tostring(pid).."\nName: "..tostring(name).."\nSteam id: "..tostring(sid), user_peer_id)
					end
				else
					for sid, playedata in pairs(nosave["playerdata"]) do
						pid = getpeer_id(sid)
						name = playedata["name"]
						sendannounce("[Server]", "Peer id: "..pid.."\nName: "..tostring(name).."\nSteam id: "..tostring(sid), user_peer_id)
					end
				end
			end
		end
	end

	-- teleport player to player
	if (command:lower() == "?tpp") then
		commandfound = true
		if perms >= PermMod then
			if two == nil then
				if server.getPlayerName(one) ~= "" then
					local m1 = server.getPlayerPos(one)
					server.setPlayerPos(user_peer_id, m1)
				else
					server.notify(user_peer_id, "[Server]", "Player with the specified ID does not exist.", 6)
				end
			elseif two ~= nil then
				if server.getPlayerName(one) ~= "" and server.getPlayerName(two) ~= "" then
					local m1 = server.getPlayerPos(two)
					server.setPlayerPos(one, m1)
				else
					server.notify(user_peer_id, "[Server]", "Player with the specified ID does not exist.", 6)
				end
			end
		else
			if server.getPlayerName(one) ~= "" then
				local m1 = server.getPlayerPos(one)
				server.setPlayerPos(user_peer_id, m1)
			else
				server.notify(user_peer_id, "[Server]", "Player with the specified ID does not exist.", 6)
			end
		end
	end

	-- teleport player to vehicle
	if (command:lower() == "?tpv") then
		commandfound = true
		local cworked = false
		if one ~= nil then
			if type(tonumber(one)) == "number" then
				local parts, vworked= server.getVehicleGroup(one)
				if vworked then
					local vmatrix, pworked = server.getVehiclePos(parts[1], 0, 0, 0)
					if pworked then
						local x,y,z = matrix.position(vmatrix)
						cworked = server.setPlayerPos(user_peer_id, matrix.translation(x,y+10,z))
					end
				end
			end
		elseif one == nil then
			server.notify(user_peer_id, "[Server]", "You have to input the vehicles group id of the vehicle you want to go to", 6)
		end
		if cworked == true then
			server.notify(user_peer_id, "[Server]", "You have been teleported to vehicle group: "..one, 5)
		elseif cworked == false then
			server.notify(user_peer_id, "[Server]", "Vehicle group: "..one.." does not exist", 6)
		end
	end

	-- teleport vehicle to player
	if (command:lower() == "?tvp") then
		if two == nil then
			commandfound = true
			local worked = false
			if one ~= nil then
				local ownersteamid = getsteam_id(user_peer_id)
				for group_id, GroupData in pairs(g_savedata["usercreations"]) do
					if group_id == one then
						if GroupData["ownersteamid"] == ownersteamid then
								local ppos = server.getPlayerPos(user_peer_id)
								local x,y,z = matrix.position(ppos)
								local dest = matrix.translation(x,y+5,z)
								worked = server.setGroupPos(one, dest)
						elseif perms >= PermAdmin then
							local ppos = server.getPlayerPos(user_peer_id)
							local x,y,z = matrix.position(ppos)
							local dest = matrix.translation(x,y+5,z)
							worked = server.setGroupPos(one, dest)
						else
							server.notify(user_peer_id, "[Server]", "You do not own the vehicle group: "..one, 6)
						end
					end
				end
			elseif one == nil then
				server.notify(user_peer_id, "[Server]", "You have to input the vehicles group id of the vehicle you want to go to you", 6)
			end
			if worked == true then
				server.notify(user_peer_id, "[Server]", "Vehicle group: "..one.." has been teleported to you", 5)
			elseif worked == false then
				server.notify(user_peer_id, "[Server]", "Vehicle group: "..one.." does not exist", 6)
			end
		elseif two ~= nil then
			if perms >= PermAdmin then
				commandfound = true
				if server.getPlayerName(two) ~= "" then
					local ppos = server.getPlayerPos(two)
					local x,y,z = matrix.position(ppos)
					local dest = matrix.translation(x,y+2,z)
					worked = server.setGroupPos(one, dest)
					if one == nil then
						server.notify(user_peer_id, "[Server]", "You have to input the vehicles group id of the vehicle you want to go to you", 6)
					end
					if worked == true then
						server.notify(user_peer_id, "[Server]", "Vehicle group: "..one.." has been teleported to "..two, 5)
					elseif worked == false then
						server.notify(user_peer_id, "[Server]", "Vehicle group: "..one.." does not exist", 6)
					end
				else
					server.notify(user_peer_id, "[Server]", "Player with the specified ID does not exist.", 6)
				end
			end
		end
	end

	-- auth command
	if (command:lower() == "?auth") then
		commandfound = true
		if not is_auth then
			server.addAuth(user_peer_id)
			server.notify(user_peer_id, "[Server]", "You have been authed", 5)
			server.removePopup(user_peer_id, 3)
			toggleUI(user_peer_id, false, true)
			loop(3,
				function(id)
					if enablebackend then
						getPlaytime(getsteam_id(user_peer_id))
					end
					toggleUI(user_peer_id, true, true)
					removeLoop(id)
				end
			)
			table.insert(playerlist, {id=user_peer_id,steam_id=getsteam_id(user_peer_id),name=getPlayerdata("name", true, user_peer_id)})
		else
			server.notify(user_peer_id, "[Server]", "You are already authed", 6)
			server.removePopup(user_peer_id, 3)
			if user_peer_id == 0 and getPlayerdata("steam_id", true, user_peer_id) ~= 0 then
				toggleUI(user_peer_id, false, true)
				loop(3,
					function(id)
						if enablebackend then
							getPlaytime(getsteam_id(user_peer_id))
						end
						toggleUI(user_peer_id, true, true)
						removeLoop(id)
					end
				)
				table.insert(playerlist, {id=user_peer_id,steam_id=getsteam_id(user_peer_id),name=getPlayerdata("name", true, user_peer_id)})
			end
		end
	end

	if (command:lower() == "?warn") then
		commandfound = true
		if perms >= PermMod then
			if server.getPlayerName(one) ~= "" then
				server.removeAuth(one)
				local reason = full_message:gsub("^%?warn%s*", ""):gsub("^%?", ""):gsub(one, "") -- removes ?warn and varible one from full_message
				server.notify(one, "[Warn]", "You have been warned".."\nReason: "..reason, 6)
				local ownersteamid = getsteam_id(one)
				for group_id, GroupData in pairs(g_savedata["usercreations"]) do
					if GroupData["ownersteamid"] == ownersteamid then
						server.despawnVehicleGroup(group_id, true)
					end
				end
				local warns = tonumber(getPlayerdata("warns", true, one)) + 1
				if warns >= warnactionthreashold then
					setPlayerdata("warns", true, one, tostring(0))
					if warnaction == "kick" then
						local name = getPlayerdata("name", true, one)
						sendannounce("[Server]", one.." | "..name.." has been kick for reaching the warning threashold")
						server.kick(one)
					elseif warnaction == "ban" then
						local name = getPlayerdata("name", true, one)
						sendannounce("[Server]", one.." | "..name.." has been banned for reaching the warning threashold")
						server.ban(one)
					end
				elseif warns < warnactionthreashold then
					setPlayerdata("warns", true, one, tostring(warns))
				end
				sendWarn(getsteam_id(one))
			else
				server.notify(user_peer_id, "[Server]", "Player with the specified ID does not exist.", 6)
			end
		end
	end
--endregion


-- Vehicles
	-- gets info about a vehicle
	if (command:lower() == "?vi") or (command:lower() == "?vehicleinfo") then
		commandfound = true
		if one ~= nil then
			local parts = server.getVehicleGroup(one)
			local ownersteamid = getsteam_id(user_peer_id)
			local pvp = "Unknown"
			local worked = false
			for group_id, GroupData in pairs(g_savedata["usercreations"]) do
				if group_id == one then
					if GroupData["ownersteamid"] == ownersteamid then
						local name = getPlayerdata("name", true, user_peer_id)
						if GroupData["Vehicleparts"][tostring(parts[1])] ~= nil then
							if getPlayerdata("pvp", true, user_peer_id) == true then
								pvp = "true"
							elseif getPlayerdata("pvp", true, user_peer_id) == false then
								pvp = "false"
							end
							local voxel_count = calculateVoxels(one)
							local subgrids = #parts
							sendannounce("[Server]", "Vehicle group: "..one.."\nOwner: "..user_peer_id.." | "..name.."\nVoxel count: "..voxel_count.."\nSubgrids: "..subgrids.."\nPVP: "..pvp, user_peer_id)
							worked = true
						end
					elseif perms >= PermAdmin then
						if GroupData["Vehicleparts"][tostring(parts[1])] ~= nil then
							local voxel_count = calculateVoxels(one)
							local subgrids = #parts
							local ownersteamid = GroupData["ownersteamid"]
							local pid = getpeer_id(ownersteamid)
							if getPlayerdata("pvp", true, pid) == true then
								pvp = "true"
							elseif getPlayerdata("pvp", true, pid) == false then
								pvp = "false"
							end
							local name = getPlayerdata("name", true, pid)
							sendannounce("[Server]", "Vehicle group: "..one.."\nOwner: "..pid.." | "..name.."\nOwner steam_id: "..ownersteamid.."\nVoxel count: "..voxel_count.."\nSubgrids: "..subgrids.."\nPVP: "..pvp, user_peer_id)
							worked = true
						end
					else
						server.notify(user_peer_id, "[Server]", "You do not own the vehicle group: "..one, 6)
					end
				end
			end
			if worked == false then
				server.notify(user_peer_id, "[Server]", "The vehicle group: "..one.." does not exist", 6)
			end
		elseif one == nil then
			server.notify(user_peer_id, "[Server]", "You have to input the vehicles group id of the vehicle you want to get info on", 6)
		end
	end

	-- clear vehicle command
	if (command:lower() == "?c") or (command:lower() == "?clear") then
		commandfound = true
		if one == nil then
			local ownersteamid = getsteam_id(user_peer_id)
			local vehiclespawned = false
			for group_id, GroupData in pairs(g_savedata["usercreations"]) do
				if GroupData["ownersteamid"] == ownersteamid then
					vehiclespawned = true
					local vd = server.despawnVehicleGroup(group_id, true)
					if not vd then
						g_savedata["usercreations"][tostring(group_id)] = nil
					end
					server.notify(user_peer_id, "[Server]", "Your vehicle/s have been despawned", 5)
				end
			end
			if vehiclespawned == false then
				server.notify(user_peer_id, "[Server]", "You do not have any vehicle/s spawned", 6)
			end
		elseif one ~= nil then
			local ownersteamid = getsteam_id(user_peer_id)
			local vehiclespawned = false
			for group_id, GroupData in pairs(g_savedata["usercreations"]) do
				if GroupData["ownersteamid"] == ownersteamid then
					if group_id == one then
						vehiclespawned = true
						local vd = server.despawnVehicleGroup(group_id, true)
						if not vd then
							g_savedata["usercreations"][tostring(group_id)] = nil
						end
						server.notify(user_peer_id, "[Server]", "Your vehicle/s with the group id of "..one..", has been despawned", 5)
					end
				end
			end
			if vehiclespawned == false then
				server.notify(user_peer_id, "[Server]", "You do not have any vehicle groups with the id "..one, 6)
			end
		end
	end

	-- clear spesific players vehicle
	if (command:lower() == "?pc") or (command:lower() == "?playerclear") then
		commandfound = true
		if perms >= PermMod then
			if server.getPlayerName(one) ~= "" then
				local ownersteamid = getsteam_id(one)
				local vehiclespawned = false
				for group_id, GroupData in pairs(g_savedata["usercreations"]) do
					if GroupData["ownersteamid"] == ownersteamid then
						vehiclespawned = true
						local vd = server.despawnVehicleGroup(group_id, true)
						if not vd then
							g_savedata["usercreations"][tostring(group_id)] = nil
						end
						server.notify(user_peer_id, "[Server]", "Specified player's vehicle/s have been despawned", 5)
					end
				end
				if vehiclespawned == false then
					server.notify(user_peer_id, "[Server]", "Specified player dosn't have any vehicle/s to despawned", 6)
				end
			else
				server.notify(user_peer_id, "[Server]", "Player with the specified ID does not exist.", 6)
			end
		end
	end

	-- clear all vehicles
	if (command:lower() == "?ca") or (command:lower() == "?clearall") then
		commandfound = true
		if perms >= PermAdmin then
			local vehiclespawned = false
			for group_id, GroupData in pairs(g_savedata["usercreations"]) do
				vehiclespawned = true
				local vd = server.despawnVehicleGroup(group_id, true)
				if not vd then
					g_savedata["usercreations"][tostring(group_id)] = nil
				end
			end
			if vehiclespawned == true then
				server.notify(user_peer_id, "[Server]", "All vehicles have been despawned", 5)
			end
			if vehiclespawned == false then
				server.notify(user_peer_id, "[Server]", "There are no vehicles to despawn", 6)
			end
		end
	end

	-- pvp command
	if (command:lower() == "?pvp") then
		if not forcepvp then
			commandfound = true
			if one == nil or one:lower() == "true" or one:lower() == "false" then
				togglePVP(user_peer_id,one)
			else
				server.notify(user_peer_id, "[Server]", "Invalid value for state. Use true, false, or leave it empty.", 6)
			end
		end
	end

	-- force pvp
	if (command:lower() == "?forcepvp") then
		if perms >= PermAdmin then
			commandfound = true
			if one ~= nil and server.getPlayerName(one) ~= "" then
				if two == nil or two:lower() == "true" or two:lower() == "false" then
					togglePVP(one,two,true)
					server.notify(user_peer_id, "[Server]", "Players PVP has been set to: "..tostring(getPlayerdata("pvp",true,one)), 5)
				else
					server.notify(user_peer_id, "[Server]", "Invalid value for state. Use true, false, or leave it empty.", 6)
				end
			else
				server.notify(user_peer_id, "[Server]", "Player with the specified ID does not exist.", 6)
			end
		end
	end

	-- repair vehicles
	if (command:lower() == "?repair") or (command:lower() == "?r")then
		commandfound = true
		local ownersteamid = getsteam_id(user_peer_id)
		local vehicle_id = nil
		local worked = false
		for group_id, GroupData in pairs(g_savedata["usercreations"]) do
			if GroupData["ownersteamid"] == ownersteamid then
				for vehicle_id, vehicledata in pairs(GroupData["Vehicleparts"]) do
					server.resetVehicleState(vehicle_id)
					worked = true
				end
			end
		end
		if worked == true then
			local name = getPlayerdata("name", true, user_peer_id)
			server.notify(user_peer_id, "[Server]", "Your vehicle/s has been repaired and restocked", 5)
			sendannounce("[Server]", user_peer_id.." | "..name.." has repaired and restocked their vehicle/s")
		else
			server.notify(user_peer_id, "[Server]", "You have no vehicle/s to be repaired and restocked", 6)
		end
	end

	-- forces inputed peer ids vehicles to be repaired
	if (command:lower() == "?forcerepair") then
		commandfound = true
		if perms >= PermAdmin then
			if one ~= nil then
				if server.getPlayerName(one) ~= "" then
					local ownersteamid = getsteam_id(one)
					local vehicle_id = nil
					local worked = false
					for group_id, GroupData in pairs(g_savedata["usercreations"]) do
						if GroupData["ownersteamid"] == ownersteamid then
							for vehicle_id, vehicledata in pairs(GroupData["Vehicleparts"]) do
								server.resetVehicleState(vehicle_id)
								worked = true
							end
						end
					end
					if worked == true then
						local name = getPlayerdata("name", true, one)
						server.notify(one, "[Server]", "Your vehicle/s has been repaired and restocked", 5)
						sendannounce("[Server]", one.." | "..name.." has repaired and restocked their vehicle/s")
					else
						server.notify(one, "[Server]", "You have no vehicle/s to be repaired and restocked", 6)
					end
				else
					server.notify(user_peer_id, "[Server]", "Player with the specified ID does not exist.", 6)
				end
			end
		end
	end

	-- flip vehicles command
	if (command:lower() == "?flip") or (command:lower() == "?f") then
		commandfound = true
		local ownersteamid = getsteam_id(user_peer_id)
		local worked = false
		for group_id, GroupData in pairs(g_savedata["usercreations"]) do
			if GroupData["ownersteamid"] == ownersteamid then
				for vehicle_id, vehicledata in pairs(GroupData["Vehicleparts"]) do
					worked = true
					VehicleMatrix = server.getVehiclePos(vehicle_id)
					x,y,z = matrix.position(VehicleMatrix)
					server.setVehiclePos(vehicle_id, matrix.translation(x,y+1,z))
					server.notify(user_peer_id, "[Server]", "Unflipped vehicle/s", 5)
				end
			end
		end
		if not worked then
			server.notify(user_peer_id, "[Server]", "No vehicle/s to unflipped", 6)
		end
	end

	if (command:lower() == "?forceflip") then
		commandfound = true
		if perms >= PermMod then
			if one ~= nil then
				if server.getPlayerName(one) ~= "" then
					local ownersteamid = getsteam_id(one)
					local worked = false
					for group_id, GroupData in pairs(g_savedata["usercreations"]) do
						if GroupData["ownersteamid"] == ownersteamid then
							for vehicle_id, vehicledata in pairs(GroupData["Vehicleparts"]) do
								worked = true
								VehicleMatrix = server.getVehiclePos(vehicle_id)
								x,y,z = matrix.position(VehicleMatrix)
								server.setVehiclePos(vehicle_id, matrix.translation(x,y+1,z))
								server.notify(user_peer_id, "[Server]", "Unflipped vehicle/s", 5)
								server.notify(one, "[Server]", "Unflipped vehicle/s", 5)
							end
						end
					end
					if not worked then
						server.notify(user_peer_id, "[Server]", "No vehicle/s to unflipped", 6)
					end
				else
					server.notify(user_peer_id, "[Server]", "Player with the specified ID does not exist.", 6)
				end
			end
		end
	end

	-- anti steal command
	if (command:lower() == "?as") or (command:lower() == "?antisteal") then
		commandfound = true
		if one == nil or one:lower() == "true" or one:lower() == "false" then
			toggleAS(user_peer_id,one)
		else
			server.notify(user_peer_id, "[Server]", "Invalid value for state. Use true, false, or leave it empty.", 6)
		end
	end

	-- force antisteal
	if (command:lower() == "?forceas") or (command:lower() == "?forceantisteal")then
		commandfound = true
		if perms >= PermAdmin then
			if one ~= nil and server.getPlayerName(one) ~= "" then
				if two == nil or two:lower() == "true" or two:lower() == "false" then
					toggleAS(one,two)
				else
					server.notify(user_peer_id, "[Server]", "Invalid value for state. Use true, false, or leave it empty.", 6)
				end
			else
				server.notify(user_peer_id, "[Server]", "Player with the specified ID does not exist.", 6)
			end
		end
	end
--endregion

-- Misc
	-- lists players with pvp on
	if (command:lower() == "?pvplist") then
		commandfound = true
		sendannounce("[Server]", "-=Players with pvp on=-", user_peer_id)
		local pid = 0
		local name = ""
		for _, playerdata in pairs(playerlist) do
			if playerdatasave then
				if getPlayerdata("pvp", true, playerdata["id"]) then
					name = getPlayerdata("name", true, playerdata["id"])
					pid = playerdata["id"]
					sendannounce("[Server]", pid.." | "..name, user_peer_id)
				end
			end
		end
	end

	-- playtime leaderboard
	if (command:lower() == "?ptlb") then
		commandfound = true
		if enableplaytime then
			local playtimedata = {}
			for sid, playedata in pairs(g_savedata["playerdata"]) do
				if playedata["pt"] ~= nil then
					table.insert(playtimedata, {sid=sid, pt=playedata["pt"]})
				end
			end
			table.sort(playtimedata, function(a,b) return a.pt > b.pt end)
			sendannounce("[Server]", "-=Playtime Leaderboard=-", user_peer_id)
			local message = ""
			for i, data in pairs(playtimedata) do
				local name = getPlayerdata("name", true, getpeer_id(data["sid"]))
				local pt = formattime(data["pt"])
				message = message.."\n"..i..". "..getpeer_id(data["sid"]).." | "..name.." | "..pt
			end
			sendannounce("[Server]", message, user_peer_id)
		end
	end
	
	-- ui command
	if (command:lower() == "?ui") then
		commandfound = true
		if one == nil or one:lower() == "true" or one:lower() == "false" then
			toggleUI(user_peer_id,one)
		else
			server.notify(user_peer_id, "[Server]", "Invalid value for state. Use true, false, or leave it empty.", 6)
		end
	end

	-- uptime command
	if (command:lower() == "?ut") or (command:lower() == "?uptime") then
		commandfound = true
		sendannounce("[Server]", "Uptime: "..ut, user_peer_id)
	end

	-- lists all the commands
	if (command:lower() == "?help") then
		commandfound = true
		sendannounce("[Server]", "-=General Commands=-\nFormating: [required] {optional}\n|?help\n|lists all commands\n|?auth\n|gives you auth\n|?c {group id}\n|clears your spawned vehicles or specified group\n|?disc\n|states our discord link\n|?ui {true/false}\n|toggles your ui\n|?ver\n|show script version and current settings to staff\n|?ut\n|shows you the uptime of the server\n|?as {true/false}\n|toggles your personal antisteal\n|?pvp {true/false}\n|toggles your pvp\n|?pvplist\n|lists all the players with pvp enabled\n|?repair\n|repairs all of your spawned vehicles\n|?tpv [group_id]\n|teleports you to vehicle group\n|?tvp [group_id] {peer_id}\n|teleports vehicle group to you or another player\n|?tpp [peer_id] {peer_id}\n|teleports you to a player or a player to a player\n|?nick [reset/set] {nickname}\n|sets nickname and removes it\n|?vi [group_id]\n|tells you info about inputed group_id\n|?ptlb\n|lists all players playtime in order\n|?rules\n|displays the server rules\n|?msg [peer_id] [message]\n|sends a private message to another player\n|?flip\n|flips your vehicles\n|?die\n|kills your character to respawn", user_peer_id)
		if perms >= PermMod then
			sendannounce("[Server]", "-=Admin Commands=-\nFormating: [required] {optional}\n|?warn [peer_id] {reason}\n|warns selected player\n|?ca\n|clears all vehicles\n|?kick [peer id]\n|kicks player with inputed id\n|?pi {peer id}\n|lists players, if inputed tells about player\n|?pc [peer id]\n|clears vehicles of inputed players ids\n|?forceas [peer_id] {true/false}\n|forces antisteal state for inputed peer id\n|?forcepvp [peer_id] {true/false}\n|forces pvp state for inputed peer id\n|?clearchat\n|clears chat\n|?forceflip [peer_id]\n|flips vehicles of inputed peer id\n|?forcerepair [peer_id]\n|repairs vehicles of inputed peer id\n|?setmoney [amount]\n|sets the server's money\n|?w [fog] [rain] [wind]\n|sets weather conditions\n|?printchat\n|prints chat messages\n|?explodeplayer [peer_id] {power}\n|explodes the player with inputed peer id\n|?explode [group_id] {power}\n|explodes the vehicle group with inputed id", user_peer_id)
		end
	end

	--  weather command
	if (command:lower() == "?w") or (command:lower() == "?weather") then
		commandfound = true
		if perms >= PermAdmin then
			if tonumber(one) ~= nil then
				server.setWeather(one, two, three)
				sendannounce("[Server]", "Weather has been set to".."\nFog: "..one.."\nRain: "..two.."\nWind: "..three)
			elseif one == "reset" then
				server.setWeather(0, 0, 0)
				sendannounce("[Server]", "Weather has been reset")
			end
		end
	end

	--set money
	if (command:lower() == "?setmoney") then
		commandfound = true
		if perms >= PermAdmin then
			server.setCurrency(one, 0)
			sendannounce("[Server]", "Money has been set to: $"..one)
		end
	end

	-- discord command
	if (command:lower() == "?disc") or (command:lower() == "?discord")then
		commandfound = true
		sendannounce("[DiscordLink]", discordlink, user_peer_id)
	end

	-- print chatMessages
	if (command:lower() == "?printchat") then
		commandfound = true
		if perms >= PermAdmin then
			printChatMessages()
		end
	end

	-- sets and enables nicknames
	if (command:lower() == "?nick") then
		if allownicknames then
			if perms >= permtonick then
				commandfound = true
				if one:lower() == "set" then
					local nm = full_message:gsub("^%?nick%s*", ""):gsub("^%?", ""):gsub(one.." ", "")
					if nm ~= "" then
						sendannounce("[NickName]", "Nickname has been set to: "..nm, user_peer_id)
						setPlayerdata("name", true, user_peer_id, nm)
						setPlayerdata("nicked", true, user_peer_id, true)
					end
				elseif one:lower() == "reset" or "remove" then
					if getPlayerdata("nicked", true, user_peer_id) then
						setPlayerdata("name", true, user_peer_id, friendlystring(server.getPlayerName(user_peer_id)))
						setPlayerdata("nicked", true, user_peer_id, false)
						sendannounce("[NickName]", "Nickname has been removed", user_peer_id)
					else
						sendannounce("[NickName]", "You arn't nicked", user_peer_id)
					end
				end
			end
		end
	end

	-- clear chat
	if (command:lower() ==  "?clearchat") then
		commandfound = true
		if perms >= PermMod then
			for i = 1, maxMessages - 1 do
				sendannounce(" ", "")
			end
			local name = getPlayerdata("name", true, user_peer_id)
			sendannounce("[Chat]", "Chat Cleared By: "..name)
		end
	end

	-- private message another player
	if (command:lower() == "?msg") then
		commandfound = true
		if one ~= nil then
			if server.getPlayerName(one) ~= "" then
				local message = full_message:gsub("^%?msg%s*", ""):gsub("^%?", ""):gsub(one, "")
				local sendername = getPlayerdata("name", true, user_peer_id)
				local toname =	getPlayerdata("name", true, one)
				sendannounce("[Msg] From ->"..sendername, message, one)
				sendannounce("[Msg] To ->"..toname, message, user_peer_id)
			else
				server.notify(user_peer_id, "[Server]", "Player with the specified ID does not exist.", 6)
			end
		else
			sendannounce("[Msg]", "Please input a peer id to send to", user_peer_id)
		end
	end

	-- displays script version and other info
	if (command:lower() == "?ver") or (command:lower() == "?version") then
		commandfound = true
		local m = "|AusCode version: "..scriptversion
		if perms >= PermMod then
			m=m.."\n|Script settings: \n|CustomChat: "..tostring(customchat).."\n|PvpEffects: "..tostring(pvpeffects).."\n|DespawnOnReload: "..tostring(despawnonreload).."\n|PlayerMaxVehicles: "..tostring(playermaxvehicles).."\n|SubbodyLimiting: "..tostring(subbodylimiting).."\n|MaxSubbodys: "..tostring(maxsubbodys).."\n|VoxelLimiting: "..tostring(voxellimiting).."\n|VoxelLimit: "..voxellimit.."\n|WarnThreashold: "..tostring(warnactionthreashold).."\n|WarnAction: "..tostring(warnaction).."\n|ShowCommandsInChat: "..tostring(showcommandsinchat).."\n|DespawnDropedItems: "..tostring(despawndropeditems).."\n|DespawnDropedItemsDelay: "..tostring(despawndropeditemsdelay).."\n|AllowNicknames: "..tostring(allownicknames).."\n|Playtime: "..tostring(enableplaytime).."\n|PlaytimeUpdateFrequency: "..tostring(playtimeupdatefrequency).."\n|Backend: "..tostring(enablebackend).."\n|BackendPort: "..tostring(backendport).."\n|HeartbeatFrequency: "..tostring(heartbeatfrequency).."\n|ServerNumber: "..tostring(servernumber).."\n|Uptime: "..ut
		end
		sendannounce("[AusCode]", m, user_peer_id)
	end

	-- used to fix my silly mistakes with deleting parts of g_savedata...
	if (command:lower() == "?repairgsave") then
		commandfound = true
		if perms >= PermOwner then
			g_savedata = {playerdata={}, usercreations={}}
			sendannounce("[AusCode]", "Scripts require reloading after using this command")
		end
	end

	if (command:lower() == "?test") then
		commandfound = true
		if perms >= PermOwner then
			getPlaytime(getsteam_id(user_peer_id))
		end
	end

	-- tps command
	if (command:lower() == "?tps") then
		commandfound = true
		sendannounce("[Server]", "TPS: "..string.format("%.0f",TPS), user_peer_id)
	end

	-- temp rules command
	if (command:lower() == "?rules") then
		commandfound = true
		sendannounce("[Server]", rules, user_peer_id)
	end

	-- explode player
	if (command:lower() == "?ep") or (command:lower() == "?explodeplayer") then
		if perms >= PermMod then
			commandfound = true
			if one ~= nil then
				local Ppos, worked = server.getPlayerPos(one)
				if not worked then
					server.notify(user_peer_id, "[Server]", "Invalid peer id", 6)
					return
				elseif worked then
					if two == nil then
						server.spawnExplosion(Ppos, 0.1)
					elseif two ~= nil then
						server.spawnExplosion(Ppos, two)
					end
				end
			end
		end
	end

	-- explode vehicle
	if (command:lower() == "?explode") or (command:lower() == "?e") then
		if perms >= PermMod then
			commandfound = true
			if one ~= nil then
				local parts = server.getVehicleGroup(one)
				local Vpos, worked = server.getVehiclePos(parts[1], 0, 0, 0)
				if not worked then
					server.notify(user_peer_id, "[Server]", "Invalid Group id", 6)
					return
				elseif worked then
					if two == nil then
						server.spawnExplosion(Vpos, 0.1)
					elseif two ~= nil then
						server.spawnExplosion(Vpos, two)
					end
				end
			end
		end
	end

	--die/respawn command
	if (command:lower() == "?die") or (command:lower() == "?respawn") then
		commandfound = true
		if getPlayerdata("pvp", true, user_peer_id) then
			local charId = server.getPlayerCharacterID(user_peer_id)
			server.killCharacter(charId)
		else
			server.notify(user_peer_id, "[Server]", "You cannot use this command while pvp is disabled", 6)
		end
	end
--endregion

	-- checks if user has inputed a correct command
	if not commandfound then
		server.notify(user_peer_id, "[Server]", "Command not found. try using ?help for a list of commands", 6)
	end
end
--endregion

--Misc functions
-- tip messages
function updateTips()
	if not tips then
		return
	end
	local playercount = #playerlist
	if playercount >= 1 then
		tiptimer = tiptimer + 1
		if tiptimer >= tipFrequency*60 then
			sendannounce("[Tip]", tipmessages[tipstep])
			if tipstep >= #tipmessages then
				tipstep = 1
			else
				tipstep = tipstep + 1
			end
			tiptimer = 0
		end
	end
end
--endregion


-- Main onTick
function onTick(game_ticks)
	-- uptime
	uptimeTicks = server.getTimeMillisec()
	ut = formatUptime(uptimeTicks, tickDuration)
	
	-- calls functions
	updateTips()
	updateTPS(game_ticks)
	updateUI()
	loopManager()
	
	-- pvp effects
	if pvpeffects then
		updatePVPEffects()
	end
	-- custom chat
	if customchat then
		if sendChat then
			printChatMessages()
			sendChat = false
		end
	end

	-- removes oil and radiation
	server.clearOilSpill()
	server.clearRadiation()
end

-- tps function
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
end

-- playtime manager
function updatePlaytime()
	if enableplaytime then
		local currentTime = server.getTimeMillisec() or 0
		for _, player in pairs(playerlist) do
			local peer_id = player.id
			if peer_id ~= nil then
				local playtime = tonumber(getPlayerdata("pt", true, peer_id)) or 0
				local lastUpdate = getPlayerdata("ptlu", true, peer_id) or currentTime
				playtime = (playtime + (currentTime - lastUpdate)) or 0
				setPlayerdata("pt", true, peer_id, playtime)
				setPlayerdata("ptlu", true, peer_id, currentTime)
				if playtime >= 1800000 and tonumber(getPlayerdata("ptachivment", true, peer_id)) == 0 then
					local name = getPlayerdata("name", true, peer_id)
					sendannounce("[Playtime]", peer_id.." | "..name.." has reached 30 minutes of playtime")
					setPlayerdata("ptachivment", true, peer_id, 1)
				elseif playtime >= 3600000 and tonumber(getPlayerdata("ptachivment", true, peer_id)) == 1 then
					local name = getPlayerdata("name", true, peer_id)
					sendannounce("[Playtime]", peer_id.." | "..name.." has reached 1 hour of playtime")
					setPlayerdata("ptachivment", true, peer_id, 2)
				elseif playtime >= 7200000 and tonumber(getPlayerdata("ptachivment", true, peer_id)) == 2 then
					local name = getPlayerdata("name", true, peer_id)
					sendannounce("[Playtime]", peer_id.." | "..name.." has reached 2 hours of playtime")
					setPlayerdata("ptachivment", true, peer_id, 3)
				elseif playtime >= 14400000 and tonumber(getPlayerdata("ptachivment", true, peer_id)) == 3 then
					local name = getPlayerdata("name", true, peer_id)
					sendannounce("[Playtime]", peer_id.." | "..name.." has reached 4 hours of playtime")
					setPlayerdata("ptachivment", true, peer_id, 4)
				elseif playtime >= 28800000 and tonumber(getPlayerdata("ptachivment", true, peer_id)) == 4 then
					local name = getPlayerdata("name", true, peer_id)
					sendannounce("[Playtime]", peer_id.." | "..name.." has reached 8 hours of playtime")
					setPlayerdata("ptachivment", true, peer_id, 5)
				elseif playtime >= 36000000 and tonumber(getPlayerdata("ptachivment", true, peer_id)) == 5 then
					local name = getPlayerdata("name", true, peer_id)
					sendannounce("[Playtime]", peer_id.." | "..name.." has reached 10 hours of playtime")
					setPlayerdata("ptachivment", true, peer_id, 6)
				end
			end
		end
	end
end

function updatePVPEffects() --Made by: Sedrowow
	-- Update PVP status effects (healing and revival)
	for _, playerdata in pairs(playerlist) do
		local is_pvp = getPlayerdata("pvp",true,playerdata.id)
		if not is_pvp then -- If PVP is disabled
			-- Get player's character ID
			local object_id, is_success = server.getPlayerCharacterID(playerdata.id)
			if is_success then
				-- Get character data
				local char_data = server.getObjectData(object_id)
				if char_data then
					-- Revive if dead or incapacitated
					if char_data.dead or char_data.incapacitated then
						server.reviveCharacter(object_id)
					end
					-- Heal if damaged
					if char_data.hp < 100 then
						server.setCharacterData(object_id, 100, true, false)
					end
				end
			end
		end
	end
end

-- despawn droped items
function onEquipmentDrop(character_object_id, equipment_object_id, EQUIPMENT_ID)
	if despawndropeditems then
		loop(despawndropeditemsdelay,
		function(id)
			server.despawnObject(equipment_object_id, true)
			removeLoop(id)
		end
		)
	end
end

-- function that handles the custom weather
function customweatherhandler(state)
	if tostring(state) == "true" then
		customweatherevents = true
		if debug_enabled then
			sendannounce("[Debug]", "Custom weather loop created")
		end
		loop(customweatherfrequency,
		function(id)
			if customweatherevents ~= true then
				if debug_enabled then
					sendannounce("[Debug]", "Custom weather loop destroyed")
				end
				server.setWeather(0, 0, 0)
				removeLoop(id)
				return
			end
			local sev = math.random(1, 3)
			local f = 0
			local r = 0
			local w = 0
			if sev == 1 then
				f = math.random(0, 20)
				r = math.random(0, 10)
				w = math.random(0, 20)
			elseif sev == 2 then
				f = math.random(0, 35)
				r = math.random(10, 50)
				w = math.random(30, 50)
			elseif sev == 3 then
				f = math.random(10, 45)
				r = math.random(60, 90)
				w = math.random(60, 100)
			end
			f=f/100
			r=r/100
			w=w/100
			if debug_enabled then
				sendannounce("[Debug]", "Serverity: "..sev.." Fog: "..string.format("%.0f",(f*100)).."% Rain: "..string.format("%.0f",(r*100)).."% Wind: "..string.format("%.0f",(w*100)).."%")
			end
			server.setWeather(f, r, w)
		end)
	elseif tostring(state) == "false" then
		if debug_enabled then
			sendannounce("[Debug]", "Custom weather disabled")
		end
		customweatherevents = false
	end
end

-- ui function. displays tps uptime and players as and pvp
function updateUI()
	if #playerlist >= 1 then
		if uitimer >= 60 then
			local ut = formatUptime(uptimeTicks, tickDuration)
			local TPS = string.format("%.0f",TPS)
			for _,X in pairs(playerlist) do
				local sid = X.steam_id
				if sid ~= 0 then
					local peer_id=X.id
					local pvp = tostring(getPlayerdata("pvp", true, X.id)) or "unknown"
					local pas = tostring(getPlayerdata("as", true, X.id)) or "unknown"

					-- get the players vehicles
					local vehicles = getPlayerdata("groups", true, X.id)
					local vehiclestring = ""
					local vspawned = 0
					if vehicles ~= nil then
						for _, GroupData in pairs(vehicles) do
							if vspawned ~= 2 then
								vspawned = vspawned + 1
								if vehiclestring == "" then
									vehiclestring = GroupData["group_id"]
								else
									vehiclestring = vehiclestring.."\n"..GroupData["group_id"]
								end
							end
						end
						if vspawned ~= 0 then
							for i=1, 2-vspawned do
								vehiclestring = vehiclestring.."\n"
							end
						else
							vehiclestring = vehiclestring.."\n"
						end
					end

					if enableplaytime then
						local pt = formattime(getPlayerdata("pt", true, X.id)) or "unknown"
						server.setPopupScreen(peer_id, 2, "ui", getPlayerdata("ui", true, X.id), "-=Uptime=-\n"..ut.."\n-=Playtime=-\n"..pt.."\n-=Vehicles=-\n"..vehiclestring.."\n-=Antisteal=-\n"..pas.."\n-=PVP=-\n"..pvp.."\n-=TPS=-\n"..TPS, -0.905, 0.7)
					else
						server.setPopupScreen(peer_id, 2, "ui", getPlayerdata("ui", true, X.id), "-=Uptime=-\n"..ut.."\n-=Antisteal=-\n"..pas.."\n-=PVP=-\n"..pvp.."\n-=TPS=-\n"..TPS, -0.905, 0.8)
					end
				end
			end
			uitimer = 0
		end
		uitimer = uitimer + 1
	end
end

--region Loop Manager
local loops = {}
function loop(time, func)
	local id = #loops + 1

	loops[id] = {
		callback = func,
		time = time,
		creationTime = server.getTimeMillisec(),
		id = id,
		paused = false
	}

	return {
		properties = loops[id],

		edit = function(self, newTime)
			self.properties.time = newTime
		end,

		call = function(self)
			self.properties.callback()
		end,

		remove = function(self)
			loops[id] = nil
			self = nil
		end,

		setPaused = function(self, state)
			self.paused = state
		end,

		id = id
	}
end

function removeLoop(id)
	loops[id] = nil
end

function loopManager()
	local timeNow = server.getTimeMillisec()
	for _, v in pairs(loops) do
		if timeNow >= v.creationTime + (v.time * 1000) and not v.paused then
			v.callback(v.id)
			v.creationTime = timeNow
		end
	end
end
--endregion

-- on world load / scripts reloaded
function onCreate(is_world_create)
	for i = 1, maxMessages do
		table.insert(chatMessages, {full_message="",name=" "})
	end
	sendannounce("[AusCode]", "AusCode reloaded")
	if unlockislands then
		server.setGameSetting("unlock_all_islands", true)
	end
	if customweatherevents then
		server.setWeather(0, 0, 0)
		customweatherhandler(customweatherevents)
	end
	server.setGameSetting("vehicle_damage", true)
	server.setGameSetting("clear_fow", true)
	server.setGameSetting("override_weather", true)
	for _,playerdata in pairs(server.getPlayers()) do
		playerint(playerdata["steam_id"], playerdata["id"])
	end
	if despawnonreload then
		sendannounce("[Server]", "Vehicles despawned for script reload. Once scripts have reloaded you may respawn your vehicles")
		for group_id, GroupData in pairs(g_savedata["usercreations"]) do
			server.despawnVehicleGroup(group_id, true)
		end
	end
	if is_world_create then
		-- g_savedata table that persists between game sessions
		g_savedata = {
			playerdata={},
			usercreations={}
		}
	end
	if customchat then
		sendChat = true
	end
	if enableplaytime then
		loop(playtimeupdatefrequency,
		function(id)
			updatePlaytime()
		end)
	end
	playerlist = {}
	for _, player in pairs(server.getPlayers()) do
		if player.steam_id ~= 0 then
			table.insert(playerlist, {id=player.id, steam_id=player.steam_id, name=player.name})
		end
	end
	if enablebackend then
		loop(playtimetodbfrequency,
		function(id)
			for _, player in pairs(playerlist) do
				sendPlaytime(player.steam_id)
			end
		end)
		loop(heartbeatfrequency,
		function()
			heartbeat()
		end)
	end
end
--endregion