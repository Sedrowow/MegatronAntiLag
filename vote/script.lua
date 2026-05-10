local commands = {	
	"===Vote Commands (pg 4/4)===",
	"?vote yes/no  for a apporval or disapporoval of the vote",
	"?vote kick user_id - vote kick someone out",
	"?vote disaster - vote for a random disatser",
	"?vote text (full vote message) - do a custom vote, just put in your vote after 'text ' and youre good to go!",
	"?vote timelock - vote to toggle the time lock",
	"?vote weatherlock - vote to toggle the weather lock"
}

local systemName = "[VOTE]"

local function announce(message, peer_id)
	message = message:gsub("\n", "\n| ")
	if peer_id then
		server.announce(systemName, "| " .. message, peer_id)
	else
		server.announce(systemName, "| " .. message)
	end
end


function onCreate(is_world_create)
	votingdata = {}
	hasVoteddata  = {}
	
	voteinprogress = false
	playercount = 0
	minrequirement = 0
	
	tick = 0
	
	votetarget = nil
	voteID = 0
	votetext = nil
	time_lock_enabled = false
	weather_lock_enabled = false
	locked_weather = nil
end

minVoteKickRequirement = 0.75
minVoteDistasterRequirement = 0.5

votetime = 3000

function clamp(a,b,c)
	return math.min(math.max(a,b),c)
end

function noVote(P_ID)
	server.notify(P_ID,"[VOTE]","There is no vote in progress!",8)
end

function AlreadyVoted(P_ID)
	server.notify(P_ID,"[VOTE]","You already voted!",8)
end

function VoteInProgress(P_ID)
	server.notify(P_ID,"[VOTE]","There is already a vote in progress!",8)
end

function isVoteInProgress()
	if voteinprogress == true then
		return true 
	else
		return false
	end
end

function tableLength(tab)
	local length = 0
	for i in pairs(tab) do
		length = length + 1
	end
	return length
end

function pickRandomDisaster(id)
	local random = math.floor(math.random(0,5))
	local intensity = math.random(0,1)
	x1 = math.random(0,1000)-500
	y1 = math.random(0,1000)-500
	z1 = math.random(0,1000)-500
	transform_matrix, is_success = server.getPlayerPos(peer_id)
	x,y,z = matrix.position(transform_matrix)
	local matrix = matrix.translation(x1+x,y1+y,z1+z)
	if random == 0 then server.spawnTsunami(matrix,intensity) end
	if random == 1 then server.spawnWhirlpool(matrix,intensity) end
	if random == 2 then server.spawnTornado(matrix, 0.5) end
	if random == 3 then server.spawnMeteorShower(matrix,intensity,true) end
	if random == 4 then server.spawnMeteor(matrix,intensity) end
end

function voteSuccessfull()
	announce("Vote was successful")
	if voteID == 1 then
		server.kickPlayer(votetarget)
	end	
	if voteID == 2 then
		pickRandomDisaster(votetarget)
	end
	if voteID == 3 then
		server.cleanVehicles()
		announce("Server has been cleaned up by vote! Sorry for any inconvenience caused.")
	end
	if voteID == 4 then
	    announce("succesful Vote: "..votetext)
	end
	if voteID == 5 then
		time_lock_enabled = not time_lock_enabled
		server.setGameSetting("override_time", time_lock_enabled)
		announce("Time lock has been " .. (time_lock_enabled and "enabled" or "disabled") .. ".")
	end
	if voteID == 6 then
		weather_lock_enabled = not weather_lock_enabled
		server.setGameSetting("override_weather", weather_lock_enabled)
		if weather_lock_enabled then
			local weather = server.getWeather(matrix.translation(0, 0, 0))
			if weather then
				locked_weather = {
					fog = weather.fog or 0,
					rain = weather.rain or 0,
					wind = weather.wind or 0
				}
				server.setWeather(locked_weather.fog, locked_weather.rain, locked_weather.wind)
			end
		end
		announce("Weather lock has been " .. (weather_lock_enabled and "enabled" or "disabled") .. ".")
	end
end

function voteStart(minReq,votetype)
	voteinprogress = true
	minrequirement = minReq
	voteID = votetype
	playercount = tableLength(server.getPlayers())-1
end

function voteEnd()
	votingdata = {}
	hasVoteddata = {}
	voteinprogress = false
end

function getRatio()
	return #votingdata/playercount
end

function onTick(game_ticks)

	if isVoteInProgress() then
		-- Calculate yes/no votes
		local yes_count = #votingdata
		local total_voters = playercount
		local no_count = 0
		for peer_id, voted in pairs(hasVoteddata) do
			if voted == true then
				-- already counted as yes
			else
				no_count = no_count + 1
			end
		end
		-- Countdown
		local time_left = math.max(0, math.floor((votetime - tick) / 60))
		-- Vote content
		local vote_content = "Vote in progress"
		if voteID == 1 then
			vote_content = "Kick: " .. tostring(votetarget) .. " (" .. (server.getPlayerName and server.getPlayerName(votetarget) or "") .. ")"
		elseif voteID == 2 then
			vote_content = "Random Disaster"
		elseif voteID == 3 then
			vote_content = "Cleanup Server"
		elseif voteID == 4 then
			vote_content = "Custom: " .. (votetext or "")
		elseif voteID == 5 then
			vote_content = "Toggle Time Lock"
		elseif voteID == 6 then
			vote_content = "Toggle Weather Lock"
		end
		-- Popup text
		local popup_text = "[VOTE] " .. vote_content .. "\nYes: " .. yes_count .. "  No: " .. no_count .. "\nTime left: " .. time_left .. "s"
		-- Show popup to all players
		local players = server.getPlayers()
		for _, player in ipairs(players) do
			local peer_id = player.id or player.peer_id or player -- support both formats
			server.setPopupScreen(peer_id, 1001, "[VOTE]", true, popup_text, 0.7, 0.3)
		end

		if getRatio() >= 1 then
			voteSuccessfull()
			voteEnd()
			-- Remove popup
			for _, player in ipairs(players) do
				local peer_id = player.id or player.peer_id or player
				server.removePopup(peer_id, 1001)
			end
		else
			tick = tick+game_ticks
			if tick >= votetime then
				tick = 0
				if getRatio() < minrequirement then
					server.notify(-1,"[VOTE]","Vote was unsuccessful",8)
				else
					voteSuccessfull()
				end
				voteEnd()
				-- Remove popup
				for _, player in ipairs(players) do
					local peer_id = player.id or player.peer_id or player
					server.removePopup(peer_id, 1001)
				end
			end
		end
	end
end

-- Automatic periodic cleanup removed per user request. ?delobjs remains as an admin-invoked command only.

function cNameStr(id)
	return id..": "..server.getPlayerName(id)
end

function onCustomCommand(full_message, user_peer_id, is_admin, is_auth, command, arg1, arg2)
	if command=="?delobjs" and is_admin then
		-- Usage: ?delobjs [all]
		-- By default this will despawn most objects but will skip characters and creatures, fire and drill_rods.
		-- If the optional argument 'all' is provided, fires and drill_rods will also be removed.
		local include_fires_and_drill = false
		if arg1 and arg1:lower() == "all" then include_fires_and_drill = true end

		local protected_types = {
			-- object type ids for characters/creatures are handled by server.getObjectData (type field)
		}

		local count = 0
		-- We will iterate over a reasonable object id range and attempt to query each object
		for i = 1, 99999 do
			local data, ok = server.getObjectData(i)
			if ok and data then
				local obj_type = data.type -- integer type: 0 none, 1 character, 72 creature, etc per intellisense

				-- Protect characters and creatures always
				if obj_type == 1 or obj_type == 72 then
					goto continue_del
				end

				-- Protect fires and drill_rods by default, remove only if 'all' passed
				-- Fire type in object list may be represented differently; we'll also check server.getFireData
				if not include_fires_and_drill then
					-- Try to detect fire by checking if getFireData returns something
					local is_fire = false
					local okf, fdata = pcall(function() return server.getFireData(i) end)
					if okf and fdata ~= nil then
						is_fire = true
					end
					-- Detect drill rod by equipment/object id heuristics: object descriptors sometimes include name/type - fallback: skip objects with equipment field or tag 'drill_rod'
					local is_drill = false
					if data.tags_full and string.find(data.tags_full:lower(), "drill") then is_drill = true end

					if is_fire or is_drill then goto continue_del end
				end

				-- Special-case items that we usually want to keep unless excessive: flares, glowsticks, grenades, c4
				-- We'll count instances per sub-type and only despawn them automatically if there are more than 10 of that sub-type
				local keep_special = { ["flare"] = true, ["glowstick"] = true, ["grenade"] = true, ["c4"] = true }
				-- Attempt to examine tooltip or tags to classify special items
				local lowername = (data.display_name or ""):lower()
				local is_special = false
				local special_key = nil
				for k,_ in pairs(keep_special) do
					if string.find(lowername, k) then is_special = true; special_key = k; break end
				end

				if is_special then
					-- Count existing instances to decide
					-- We'll gather counts lazily into a cache located in this script's env
					_G._delobjs_counts = _G._delobjs_counts or {}
					_G._delobjs_counts[special_key] = (_G._delobjs_counts[special_key] or 0) + 1
					-- Don't despawn now; we'll run a second pass below after counting
					goto continue_del
				end

				-- If we reached here, attempt to despawn the object
				local okdes = server.despawnObject(i, true)
				if okdes then count = count + 1 end
			end
			::continue_del::
		end

		-- Handle special items: if any category exceeded 10, remove extras (despawn all of that type)
		if _G._delobjs_counts then
			for key, cnt in pairs(_G._delobjs_counts) do
				if cnt > 10 then
					-- second pass: despawn objects matching this special_key
					for i = 1, 99999 do
						local data, ok = server.getObjectData(i)
						if ok and data then
							local lowername = (data.display_name or ""):lower()
							if string.find(lowername, key) then
								local okdes = server.despawnObject(i, true)
								if okdes then count = count + 1 end
							end
						end
					end
				end
			end
			-- reset counts cache
			_G._delobjs_counts = nil
		end

		server.notify(user_peer_id, "server-command", "removed "..tostring(count).." items/objects", 7)
	end
	if command == "?vote" then
		
		local Voted = hasVoteddata[user_peer_id]
		if Voted == nil then Voted = false end
				
		if arg1 == "yes" then
			if isVoteInProgress() then
				if Voted == false then
					hasVoteddata[user_peer_id] = true
					votingdata[#votingdata+1] = true
					server.notify(-1,"[VOTE]", cNameStr(user_peer_id).." Voted yes "..#votingdata.."/"..playercount,8)
				else
					AlreadyVoted(user_peer_id)
				end
			else
				noVote(user_peer_id)
			end
		end
		
		if arg1 == "no" then
			if isVoteInProgress() then
				if Voted == false then
					hasVoteddata[user_peer_id] = true
					server.notify(-1,"[VOTE]", cNameStr(user_peer_id).." Voted no "..#votingdata.."/"..playercount,8)
				else
					AlreadyVoted(user_peer_id)
				end
			else
				noVote(user_peer_id)
			end
		end

		
		if arg1 == "kick" then
			if not isVoteInProgress() then
				voteStart(minVoteKickRequirement,1)
				announce("Started kick vote against: "..arg2.." : "..server.getPlayerName(arg2)..". '?vote yes' to agree, or '?vote no' to disagree!")
				server.notify(-1,"[VOTE]", cNameStr(user_peer_id).." Started a votekick againts "..arg2.." : "..server.getPlayerName(arg2),8)
				votetarget = arg2
			else
				VoteInProgress(user_peer_id)
			end
		end
		
		if arg1 == "disaster" then
			if not isVoteInProgress() then
				voteStart(minVoteDistasterRequirement,2)
				announce("Started disaster vote, '?vote yes' to agree, or '?vote no' to disagree!")
				server.notify(-1,"[VOTE]", cNameStr(user_peer_id).." Started a vote for a random distaster",8)
				votetarget = user_peer_id
			else
				VoteInProgress(user_peer_id)
			end
		end
		if arg1 == "cleanup" then
			if not isVoteInProgress() then
				voteStart(0.6,3)
				announce("Started cleanup vote, '?vote yes' to agree, or '?vote no' to disagree!")
				server.notify(-1,"[VOTE]", cNameStr(user_peer_id).." Started a vote for cleanup",8)
				votetarget = user_peer_id
			else
				VoteInProgress(user_peer_id)
			end
		end
		if arg1 == "text" then
			if not isVoteInProgress() then
		       		voteStart(0.5, 4)
		        	full_message = full_message:gsub("%^?vote text ","")
		        	full_message = full_message:gsub("%?","")
	        	announce("Started text Vote, '?vote yes' to agree, or '?vote no' to disagree!")
				server.notify(-1,"[VOTE]", cNameStr(user_peer_id).." Started vote: \n"..full_message,8)
				votetext = full_message
			else
		        VoteInProgress(user_peer_id)
			end
        	end
		if arg1 == "timelock" then
			if not isVoteInProgress() then
				voteStart(0.5, 5)
				announce("Started time lock vote, '?vote yes' to agree, or '?vote no' to disagree!")
				server.notify(-1, "[VOTE]", cNameStr(user_peer_id) .. " Started a vote to toggle time lock", 8)
				votetarget = user_peer_id
			else
				VoteInProgress(user_peer_id)
			end
		end
		if arg1 == "weatherlock" then
			if not isVoteInProgress() then
				voteStart(0.5, 6)
				announce("Started weather lock vote, '?vote yes' to agree, or '?vote no' to disagree!")
				server.notify(-1, "[VOTE]", cNameStr(user_peer_id) .. " Started a vote to toggle weather lock", 8)
				votetarget = user_peer_id
			else
				VoteInProgress(user_peer_id)
			end
		end
		if arg1 == "vevo" and is_admin then
			if isVoteInProgress() then
				voteEnd()
				server.notify(-1,"[VOTE]","Vote was halted!",8)
			else
				noVote(user_peer_id)
			end
		end
		
		if (arg1 == "help") then
	        	local commands_str = table.concat(commands, "\n")
	        	help = "Available commands:\n" .. commands_str

			announce(help, user_peer_id)
        end
	end
	if is_admin then	
		if command == "?min-kick-req" then
			val = clamp(arg1,0,1)
			minVoteKickRequirement = val 
			server.notify(user_peer_id,"[VOTE]","Minimum vote-kick requirement changed to "..(val *100).."%",8)
		end
			
		if command == "?min-disaster-req" then
			val = clamp(arg1,0,1)
			minVoteDistasterRequirement = val
			server.notify(user_peer_id,"[VOTE]","Minimum vote disaster requirement changed to "..(val*100).."%",8)
		end
		
		if command == "?timer-length" then
			val = math.max(arg1,0)
			votetime = val*60
			server.notify(-1,"[VOTE]","Vote timer set to "..val.." seconds",8)
		end
	end

end
