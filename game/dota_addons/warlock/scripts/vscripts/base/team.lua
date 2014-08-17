Team = class()

function Team:init(def)
	self.id = def.id
	self.size = 0
	self.players = {}
	self.name = def.name or "Team " .. tostring(def.id + 1)
	self.score = 0
	self.alive_count = 0
end

function Team:playerJoined(player)
	if player.team_player_index and self.players[player.team_player_index] == player then
		log("Player tried to join team but was already in it.")
		return
	end
	
	if player.team then
		warning("playerJoined but player.team already set")
	end
	
	self.size = self.size + 1
	
	-- Add player to team at lowest possible index
	for i = 0, 10 do
		if not self.players[i] then
			player.team_player_index = i
			self.players[i] = player
			break
		end
	end
	
	-- Add team to active teams if it wasnt active
	if not self.active_team_id then
		for i = 0, 11 do
			if not GAME.active_teams[i] then
				self.active_team_id = i
				GAME.active_teams[i] = self
				break
			end
		end

		GAME.active_team_count = GAME.active_team_count + 1
	end
	
	player.team = self
end

function Team:playerLeft(player)
	if self.players[player.team_player_index] ~= player then
		log("Player tried to leave team but wasnt in it.")
		return
	end
	
	self.players[player.team_player_index] = nil
	player.team_player_index = nil
	self.size = self.size - 1
	
	-- Remove team from active teams if its empty
	if self.size == 0 then
		GAME.active_teams[self.active_team_id] = nil
		self.active_team_id = nil
		GAME.active_team_count = GAME.active_team_count - 1
	end
	
	player.team = nil
end

function Team:updateAliveCount()
	local start_alive_count = self.alive_count
	self.alive_count = 0
	
	for _, player in pairs(self.players) do
		if player:isAlive() then
			self.alive_count = self.alive_count + 1
		end
	end
end

function Team:addScore(score)
	self.score = self.score + score
	
	-- Increase individual player score
	for _, player in pairs(self.players) do
		player.score = player.score + 1
	end
end

-------------------------------------------------
-- Game Interface
-------------------------------------------------

function Game:initTeams()
	self.team_mode = TeamModeShuffle:new {
		max = true 
	}
	
	GAME.teams = {}
	
	-- Active teams are teams with atleast one player
	GAME.active_teams = {}
	GAME.active_team_count = 0

	-- Create the teams
	for i = 0, 11 do
		local team = Team:new {
			id = i,
			name = "Team " .. Player.COLOR_NAMES[i+1]
		}
		
		GAME.teams[team.id] = team
	end
end

function Game:getAliveTeams()
	local alive_teams = {}
	for _, team in pairs(GAME.active_teams) do
		if team.alive_count > 0 then
			table.insert(alive_teams, team)
		end
	end
	
	return alive_teams
end

function Game:getWinnerTeams()
	local best_score = -1
	local best_teams = {}
	
	for team, _ in pairs(GAME.active_teams) do
		if team.score > best_score then
			best_teams = {}
			best_score = team.score
		end
		
		if team.score == best_score then
			table.insert(best_teams, team)
		end
	end
	
	return best_teams
end
