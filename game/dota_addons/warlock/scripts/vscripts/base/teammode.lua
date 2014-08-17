TeamMode = class()

--------------------------------------
-- Default (teams like in lobby)
--------------------------------------

function TeamMode:init(def)
	-- Native team stuff
	self.native_team_size = {}
	self.native_team_size[DOTA_TEAM_GOODGUYS] = 0
	self.native_team_size[DOTA_TEAM_BADGUYS] = 0
end

function TeamMode:getTeamForNewPlayer(player)
	if GAME.teams[0].size <= GAME.teams[1].size then
		return GAME.teams[0]
	else
		return GAME.teams[1]
	end
end

function TeamMode:getNativeTeamForNewPlayer(player)
	-- Native teams have to be evenly assigned else it will bug
	if self.native_team_size[DOTA_TEAM_GOODGUYS] <= self.native_team_size[DOTA_TEAM_BADGUYS] then
		return DOTA_TEAM_GOODGUYS
	else
		return DOTA_TEAM_BADGUYS
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

function TeamModeFFA:getTeamForNewPlayer(player)
	self.ffa_next_team = self.ffa_next_team + 1
	return GAME.teams[self.ffa_next_team - 1]
end

--------------------------------------
-- Shuffle
--------------------------------------

TeamModeShuffle = class(TeamMode)

function TeamModeShuffle:onNewRound()
	local players = {}
	
	-- Copy players table
	for _, player in pairs(GAME.players) do
		table.insert(players, player)
	end
	
	local player_count = #players
	
	local team_sizes = {}
	
	-- Find all factors
	for i = 1, math.ceil(player_count / 2) do
		if player_count % i == 0 then
			table.insert(team_sizes, i)
		end
	end
	
	-- Get random team size
	local team_size = team_sizes[math.random(1, #team_sizes)]
	
	-- Calculate team count
	local team_count = player_count / team_size
	
	display("Team size: " .. tostring(team_size) .. " / Team Count: " .. tostring(team_count))
	
	-- Shuffle the players array
	for i = 1, player_count do
		local j = math.random(player_count)
		local k = math.random(player_count)
		players[j] = players[k]
		players[k] = players[j]
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
end
