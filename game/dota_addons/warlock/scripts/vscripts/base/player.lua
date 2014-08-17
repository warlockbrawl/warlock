--- Player class
-- @author Krzysztof Lis (Adynathos)

Player = class()

Player.ALLIANCE_SELF		= 0
Player.ALLIANCE_ALLY		= 1
Player.ALLIANCE_ENEMY		= 2

Player.MASTERY_DURATION		= 0
Player.MASTERY_RANGE		= 1
Player.MASTERY_LIFESTEAL	= 2
Player.MASTERY_MAX_INDEX	= 2

Player.STATS_DAMAGE			= 0
Player.STATS_HEALING		= 1
Player.STATS_MAX_INDEX		= 1

Player.TEAM_COLOR = {
	Vector(0xFF, 0x03, 0x03) / 256,
	Vector(0x00, 0x42, 0xFF) / 256,
	Vector(0x00, 0xFF, 0xFF) / 256,
	Vector(0x54, 0x00, 0x81) / 256,
	Vector(0xFF, 0xFC, 0x01) / 256,
	Vector(0xFF, 0x88, 0x03) / 256,
	Vector(0x20, 0xC0, 0x00) / 256,
	Vector(0xE5, 0x5B, 0xB0) / 256,
	Vector(0x95, 0x96, 0x97) / 256,
	Vector(0x7E, 0xBF, 0xF1) / 256,
	Vector(0x10, 0x62, 0x46) / 256,
	Vector(0x4E, 0x2A, 0x04) / 256,
	Vector(0x70, 0x70, 0x70) / 256 -- Observer
}

Player.COLOR_NAMES = {
	"Red",
	"Blue",
	"Teal",
	"Purple",
	"Yellow",
	"Orange",
	"Green",
	"Pink",
	"Gray",
	"Light Blue",
	"Dark Green",
	"Brown",
	"Observer"
}

--- Create a player using the information
-- from PreConnect event
-- @param info Table received from PreConnect event.
function Player:init()
	self.cash = 0
	self.reconnect = false --will be set to true when leaving for the first time
	
	-- stats
	self.stats = {}
	for i = 0, Player.STATS_MAX_INDEX do
		self.stats[i] = 0
	end

	-- Masteries
	self.mastery_factor = {}
	self.mastery_factor[Player.MASTERY_DURATION] = 1.0
	self.mastery_factor[Player.MASTERY_RANGE] = 1.0
	self.mastery_factor[Player.MASTERY_LIFESTEAL] = 0.0
	
	-- Owned actors, get destroyed on round restart etc
	self.temp_actors = {}
	
	self.score = 0
end

function Player:resetStats()
	for stat, val in pairs(self.stats) do
		self.stats[stat] = 0
	end
end

function Player:changeStat(stat, num)
	self.stats[stat] = self.stats[stat] + num
end

-- player joins
function Player:EventConnect(info)
	self.playerEntity = EntIndexToHScript(info.index+1)

	if not IsValidEntity(self.playerEntity) then
		err("Invalid player entity")
		return
	end
	
	-- Reconnect, set in EventReconnect
	if self.reconnect then
		self.reconnect = false
		
		if not GAME.combat then
			self.pawn:respawn()
		end
		
		log("Player " .. self.name .. " reconnected fully.")
	else
		-- It is required to assign him to a team
		self:initTeam()
		
		-- Assign the ids
		self.id = self.playerEntity:GetPlayerID()
		self.steamId = PlayerResource:GetSteamAccountID(self.id)
		self.userid = info.userid
		self.index = info.index
		
		-- Get the players name
		self.name = PlayerResource:GetPlayerName(self.id)

		-- add to the permanent player table
		GAME.playersByUserid[self.userid] = self
		GAME.playersByIndex[self.index] = self
		
		-- remove all unreliable gold
		-- no cash before mode starts
		PlayerResource:SetGold(self.id, 0, true)
		PlayerResource:SetGold(self.id, 0, false)

		display(self.name .. ' has joined the game as player '..self.id)
		
		GAME.players[self.id] = self
		GAME.player_count = (GAME.player_count or 0) + 1
	end

	self.active = true
	self:updateCash()
end

function Player:HeroSpawned(hero)	
	if self.pawn then
		log("HeroSpawned called but pawn already created (normal on respawn).")
		return
	end
	
	-- Set mana to zero
	hero:SetMana(0)
	
	self.heroEntity = hero
	
	-- Create pawn
	self.pawn = Pawn:new {
		unit = hero,
		owner = self
	}
	
	GAME.picked_count = (GAME.picked_count or 0) + 1
	--self.pawn:disable()
end

function Player:HeroRemoved()
	if self.pawn then
		self.pawn:disable()
		self.pawn = nil
	end
end

function Player:EventReconnect(info)
	self.reconnect = true
end

function Player:EventDisconnect(info)
	log(self.name .. ' has left the game.')

	-- Kill the pawn
	if self.pawn.enabled then
		self.pawn.last_hitter = nil
		self.pawn:die({})
	end

	-- Disable pawn
	self.pawn:disable()
	
	-- Make sure the hero is dead
	if self.heroEntity and self.heroEntity:IsAlive() then
		self.heroEntity:ForceKill(false)
	end

	-- the entity will be removed from c++ anyway
	self.playerEntity = nil
	self.active = false
end

-- Native dota teams cannot be reassigned
function Player:initTeam()
	-- check for previous team
	self.playerEntity:SetTeam(DOTA_TEAM_GOODGUYS)
	
	log("initTeam")

	-- if team is not assigned yet, assign a new one
	if not self.team then
		log("Assigning new team")
		self:setTeam(GAME:GetTeamForNewPlayer(self))
	end
end

function Player:setTeam(new_team)
	log("setTeam " .. tostring(new_team))
	
	-- Remove from old team
	if self.team then
		self.team:playerLeft(self)
	end

	new_team:playerJoined(self)

	if self.pawn and self.pawn.unit then
		self.pawn:updateTeamColor()
	end
	
	-- The player will only have an id if this is not the first assignment
	if self.id then
		self:updateCash()
	end
end

function Player:getAlliance(other_player)
	if self.userid == other_player.userid then
		return self.ALLIANCE_SELF
	end

	if self.team == other_player.team then
		return self.ALLIANCE_ALLY
	end

	return self.ALLIANCE_ENEMY
end

function Player:isAllied(other_player)
	local al = self:getAlliance(other_player)

	return al == ALLIANCE_SELF or al == ALLIANCE_ALLY
end

function Player:isAlive()
	return self.pawn and self.pawn.enabled
end

function Player:getCash(reliable)
	return self.cash
end

--- Set the displayed cash to match the script value
function Player:updateCash()
	--print(self.name, " - update cash: ", self.cash)
	PlayerResource:SetGold(self.id, self.cash, true)
end

function Player:setCash(amount)
	self.cash = amount
	self:updateCash()
end

function Player:addCash(amount)
	self.cash = self.cash + amount
	self:updateCash()
end

function Game:findPlayerByEvent(event)
	if event.userid and self.playersByUserid[event.userid] then
		return self.playersByUserid[event.userid]
	end

	if event.index and self.playersByIndex[event.index] then
		return self.playersByIndex[event.index]
	end

	return nil
end

function Game:EventPlayerConnected(event)
	log('EventPlayerConnected')
	PrintTable(event)
	
	local p = GAME.playersByIndex[event.index]
	
	if p then
		log("Existing player")
		if not p.reconnect then
			warning("Existing player connected and is not reconnecting")
		end
	else
		log("New player created")
		p = Player:new()
	end
	
	p:EventConnect(event)
end

function Game:EventPlayerReconnected(event)
	log("EventPlayerReconnected")
	PrintTable(event)
	
	local p = GAME.players[event.PlayerID]
	
	if not p then
		log("Unknown player reconnected")
		return
	end
	
	p:EventReconnect(event)
end

function Game:EventNPCSpawned(event)
	log("EventNPCSpawned")
	PrintTable(event)
	
	local spawned_unit = EntIndexToHScript(event.entindex)
	
	-- Ignore non-hero units
	if not spawned_unit:IsHero() then
		return
	end
	
	local p = GAME.players[spawned_unit:GetPlayerID()]
	
	if not p then
		err("NPC spawned but player owner not found.")
		return
	end
	
	p:HeroSpawned(spawned_unit)
end

function Game:EventPlayerDisconnected(event)
	print('EventPlayerDisconnected ')
	PrintTable(event)

	local p = self:findPlayerByEvent(event)

	if p then
		if self.players[p.id] then
			p:EventDisconnect(event)
		else
			warning('Player leaves before fully connecting')
		end
	else
		err('Unknown player leaving')
		PrintTable(event)
	end
end

--- Periodically sets players' cash to match the scripted value
function Game:initScriptedCashRefresh()
	self:addTask{
		id="scripted cash refresh",
		period=5,
		func = function()
			for id, player in pairs(self.players) do
				player:updateCash()
			end
		end
	}
end

function Game:getHighestScorePlayers()
	local best_score = -1
	local highest_count = 0
	local players = {}
	
	for _, player in pairs(self.players) do
		if player.score > best_score then
			players = {}
			best_score = player.score
			highest_count = 0
		end
		
		if player.score == best_score then
			table.insert(players, player)
			highest_count = highest_count + 1
		end
	end
	
	return players, highest_count
end
