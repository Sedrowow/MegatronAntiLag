local commands = {	
	"===Vote Commands (pg 4/4)===",
	"?vote yes/no  for a apporval or disapporoval of the vote",
	"?vote kick user_id - vote kick someone out",
	"?vote disaster - vote for a random disatser",
	"?vote text (full vote message) - do a custom vote, just put in your vote after 'text ' and youre good to go!"
}


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
	server.notify(-1,"[VOTE]","Vote was successful",8)
	if voteID == 1 then
		server.kickPlayer(votetarget)
	end	
	if voteID == 2 then
		pickRandomDisaster(votetarget)
	end
	if voteID == 3 then
		server.cleanVehicles()
		server.announce("[VOTE]", "Server has been cleaned up by vote! Sorry for any inconvenience caused.")
	end
	if voteID == 4 then
	    server.announce("[VOTE]", "succesful Vote: "..votetext)
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
		if getRatio() >= 1 then
			voteSuccessfull()
			voteEnd()
		end
		
		tick = tick+game_ticks
		if tick >= votetime then
			tick = 0
			if getRatio() < minrequirement then
				server.notify(-1,"[VOTE]","Vote was unsuccessful",8)
			else
				voteSuccessfull()
			end
			voteEnd()
		end
	end
end

function cNameStr(id)
	return id..": "..server.getPlayerName(id)
end

function onCustomCommand(full_message, user_peer_id, is_admin, is_auth, command, arg1, arg2)
	if command=="?delobjs" and is_admin then
		count=0
		for i=1,99999 do
			is_success = server.despawnObject(i, true)
			if is_success then count=count+1 end
		end
		server.notify(user_id, "server-command", "removed "..tostring(count).." items/objects", 7)
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
				server.announce("[VOTE]","Started kick vote against: "..arg2.." : "..server.getPlayerName(arg2)..". '?vote yes' to agree, or '?vote no' to disagree!")
				server.notify(-1,"[VOTE]", cNameStr(user_peer_id).." Started a votekick againts "..arg2.." : "..server.getPlayerName(arg2),8)
				votetarget = arg2
			else
				VoteInProgress(user_peer_id)
			end
		end
		
		if arg1 == "disaster" then
			if not isVoteInProgress() then
				voteStart(minVoteDistasterRequirement,2)
				server.announce("[VOTE]","Started disaster vote, '?vote yes' to agree, or '?vote no' to disagree!")
				server.notify(-1,"[VOTE]", cNameStr(user_peer_id).." Started a vote for a random distaster",8)
				votetarget = user_peer_id
			else
				VoteInProgress(user_peer_id)
			end
		end
		if arg1 == "cleanup" then
			if not isVoteInProgress() then
				voteStart(0.6,3)
				server.announce("[VOTE]","Started cleanup vote, '?vote yes' to agree, or '?vote no' to disagree!")
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
		        	server.announce("[VOTE]","Started text Vote, '?vote yes' to agree, or '?vote no' to disagree!")
				server.notify(-1,"[VOTE]", cNameStr(user_peer_id).." Started vote: \n"..full_message,8)
				votetext = full_message
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
	        	local commands = createList(
        		commands, 
        		function(commands) return true end, 
        		function(commands) return help end
        		)
			server.announce("[VOTE]",help, user_peer_id)
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
