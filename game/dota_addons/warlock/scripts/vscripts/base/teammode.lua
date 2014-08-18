TeamMode = class()

--------------------------------------
-- Default (teams like in lobby)
--------------------------------------

function TeamMode:init(def)
end

function TeamMode:getDescription()
	return "Teams (selected in lobby)"
end

function TeamMode:getTeamForNewPlayer(player)
	if GAME.teams[0].size <= GAME.teams[1].size then
		return GAME.teams[0]
	else
		return GAME.teams[1]
	end
end

function TeamMode:onNewRound()
end

--------------------------------------
-- FFA
--------------------------------------

TeamModeFFA = class(TeamMode)

function TeamModeFFA:init(def)
	TeamModeFFA.super.init(self, def)
	
	self.ffa_next_team = 0
end

function TeamModeFFA:getDescription()
	return "Free for all"
end

function TeamModeFFA:getTeamForNewPlayer(player)
	self.ffa_next_team = self.ffa_next_team + 1
	return GAME.teams[self.ffa_next_team - 1]
end

--------------------------------------
-- Shuffle
--------------------------------------

TeamModeShuffle = class(TeamMode)

function TeamModeShuffle:init(def)
	TeamModeShuffle.super.init(self, def)
	
	self.max = def.max
end

function TeamModeShuffle:getDescription()
	return "Shuffle (random teams every round)"
end

function TeamModeShuffle:onNewRound()
	local players = {}
	
	-- Copy players table
	for _, player in pairs(GAME.players) do
		table.insert(players, player)
	end
	
	local player_count = #players
	local team_counts = {}
	
	if player_count == 1 then
		-- Special case for 1 player: only 1 team
		table.insert(team_counts, 1)
	else
		-- Find all factors, no single team case
		for i = 2, player_count do
			if player_count % i == 0 then
				table.insert(team_counts, i)
			end
		end
	end
	
	-- Biggest teams possible if max is set
	if self.max then
		local max_team = team_counts[1]
		team_counts = { max_team }
	end
	
	-- Get random team size
	local team_count = team_counts[math.random(1, #team_counts)]
	
	-- Calculate team count
	local team_size = player_count / team_count
	
	display("Team size: " .. tostring(team_size) .. " / Team count: " .. tostring(team_count))
	
	-- Shuffle the players array
	for i = 1, player_count do
		local j = math.random(player_count)
		local k = math.random(player_count)
		local p = players[j] 
		players[j] = players[k]
		players[k] = p
	end
	
	-- Assign teams
	local team = 0
	for _, player in pairs(players) do
		display(player.name .. " in team " .. tostring(team))
		
		player:setTeam(GAME.teams[team])
		
		team = team + 1
		if team >= team_count then
			team = 0
		end
	end
	
	-- Reset team scores
	for i = 0, team_count - 1 do
		GAME.teams[i].score = 0
	end
end
