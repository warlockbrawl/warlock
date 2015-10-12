Team = class()

Team.TEAM_COLOR = {
	Vector(0xFF, 0xFF, 0xFF), -- 01 Unused
	Vector(0xFF, 0xFF, 0xFF), -- 02 Unused
	Vector(0xFF, 0x03, 0x03), -- 03 DOTA_TEAM_GOODGUYS (Used)
	Vector(0x00, 0x42, 0xFF), -- 04 DOTA_TEAM_BADGUYS (Used)
	Vector(0xFF, 0xFF, 0xFF), -- 05 DOTA_TEAM_NEUTRALS
	Vector(0xFF, 0xFF, 0xFF), -- 06 DOTA_TEAM_NOTEAM
	Vector(0x00, 0xFF, 0xFF), -- 07 DOTA_TEAM_CUSTOM_1 (Used)
	Vector(0x54, 0x00, 0x81), -- 08 DOTA_TEAM_CUSTOM_2 (Used)
	Vector(0xFF, 0xFC, 0x01), -- 09 DOTA_TEAM_CUSTOM_3 (Used)
	Vector(0xFF, 0x88, 0x03), -- 10 DOTA_TEAM_CUSTOM_4 (Used)
	Vector(0x20, 0xC0, 0x00), -- 11 DOTA_TEAM_CUSTOM_5 (Used)
	Vector(0xE5, 0x5B, 0xB0), -- 12 DOTA_TEAM_CUSTOM_6 (Used)
	Vector(0x95, 0x96, 0x97), -- 13 DOTA_TEAM_CUSTOM_7 (Used)
	Vector(0x7E, 0xBF, 0xF1)  -- 14 DOTA_TEAM_CUSTOM_8 (Used)
	-- Vector(0x10, 0x62, 0x46), -- 15 Unused
	-- Vector(0x4E, 0x2A, 0x04)  -- 16 Unused
	-- Vector(0x70, 0x70, 0x70)  -- 17 Unused
}

Team.TEAM_COLOR_NAME = {
    "Unused",     -- 01
    "Unused",     -- 02
    "Red",        -- 03
    "Blue",       -- 04
    "Unused",     -- 05
    "Unused",     -- 06
    "Teal",       -- 07
    "Purple",     -- 08
    "Yellow",     -- 09
    "Orange",     -- 10
    "Green",      -- 11
    "Pink",       -- 12
    "Gray",       -- 13
    "Light Blue"  -- 14
    -- "Dark Green", -- 15
    -- "Brown"       -- 16
}

Team.TEAM_IDS = { 2, 3, 6, 7, 8, 9, 10, 11, 12, 13 }

function Team:init(def)
	self.id = def.id
	self.size = 0
	self.players = {}
	self.name = def.name or Team.TEAM_COLOR_NAME[def.id + 1] -- "Team " .. tostring(def.id + 1)
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
	for i = 0, DOTA_MAX_TEAM_PLAYERS - 1 do
		if not self.players[i] then
			player.team_player_index = i
			self.players[i] = player
			break
		end
	end
	
	-- Add team to active teams if it wasnt active
	if not self.active_team_id then
		for i = 0, DOTA_TEAM_COUNT - 1 do
			if not GAME.active_teams[i] then
				self.active_team_id = i
				GAME.active_teams[i] = self
				break
			end
		end

		GAME.active_team_count = GAME.active_team_count + 1
	end
	
	player.team = self

    -- Set the player's color
    local color = Team.TEAM_COLOR[self.id+1]
    PlayerResource:SetCustomPlayerColor(player.id, color[1], color[2], color[3])
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
		local a = self.active_team_id
        
        GAME.active_teams[self.active_team_id] = nil
		self.active_team_id = nil
		GAME.active_team_count = GAME.active_team_count - 1

        -- Move up teams after this one
        for i = a+1, DOTA_TEAM_COUNT - 1 do
            if GAME.active_teams[i] then
                GAME.active_teams[i-1] = GAME.active_teams[i]
                GAME.active_teams[i].active_team_id = i-1
                GAME.active_teams[i] = nil
            end
        end
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

        -- Update web api score
        if player.steam_id and player.steam_id ~= 0 then
            GAME.web_api:setMatchPlayerProperty(player.steam_id, "score", player.score)
        end
	end
end

-------------------------------------------------
-- Game Interface
-------------------------------------------------

function Game:initTeams()	
	GAME.teams = {}
	
	-- Active teams are teams with atleast one player
	GAME.active_teams = {}
	GAME.active_team_count = 0

	-- Create the teams
	for i = 0, DOTA_TEAM_COUNT - 1 do
		GameRules:SetCustomGameTeamMaxPlayers(i, DOTA_MAX_TEAM_PLAYERS)
		SetTeamCustomHealthbarColor(i, Team.TEAM_COLOR[i+1][1], Team.TEAM_COLOR[i+1][2], Team.TEAM_COLOR[i+1][3])
		
		local team = Team:new {
			id = i
		}
		
		GAME.teams[team.id] = team
	end
	
	log("Initialized Teams")
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
