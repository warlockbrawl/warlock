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
		
		self.active = true
		GAME.active_players[self] = true
		
		log("Player " .. self.name .. " reconnected fully.")
	else
		self.index = info.index
		self.userid = info.userid
		
		-- add to the permanent player table
		GAME.playersByUserid[self.userid] = self
		GAME.playersByIndex[self.index] = self
		
		-- Assign the ids
		local id = self.playerEntity:GetPlayerID()
		if id ~= -1 then
			log("Assigned ID in connect")
			self.id = id
			self.steamId = PlayerResource:GetSteamAccountID(self.id)

			GAME.players[self.id] = self
		end
	end
end

function Player:EventJoinedTeam(info)
	self.userid = info.userid
	
	-- add to the permanent player table
	GAME.playersByUserid[self.userid] = self
	
	self.name = info.name
	self.is_bot = info.is_bot
	
	-- Assign the ids
	if self.playerEntity then
		local id = self.playerEntity:GetPlayerID()
		if id ~= -1 then
			log("Assigned ID in joined team: " .. tostring(id))
			self.id = id
			self.steamId = PlayerResource:GetSteamAccountID(self.id)

			GAME.players[self.id] = self
		else
			err("playerEntity was not nil in EventJoinedTeam but id was -1")
		end
	else
		err("playerEntity was nil in EventJoinedTeam")
	end
end

function Player:HeroSpawned(hero)	
	if self.pawn then
		log("HeroSpawned called but pawn already created (normal on respawn).")
		return
	end
	
	------- Player init ----------
	log("Hero spawned, initializing player...")
	
	-- Assign a non-native team
	self:initTeam()
	
	display(self.name .. ' has joined the game as player ' .. self.id)

	self:updateCash()
	
	self.active = true
	GAME.active_players[self] = true
	
	log("Player initialized")
	
	------------------------------
	
	-- Set mana to zero
	hero:SetMana(0)
	
	self.heroEntity = hero
	
	-- Create pawn
	self.pawn = Pawn:new {
		unit = hero,
		owner = self
	}
	
	GAME.picked_count = (GAME.picked_count or 0) + 1
	GAME.player_count = GAME.player_count + 1
	
	-- Kill pawn if not in combat
	if GAME.combat then
		self.pawn:die{}
	end
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
	GAME.active_players[self] = nil
end

-- Native dota teams cannot be reassigned
function Player:initTeam()
	log("initTeam")
	
	print("Player ID:", self.playerEntity:GetPlayerID())
	print("Native Team:", self.playerEntity:GetTeam())
	
	local team_id = PlayerResource:GetCustomTeamAssignment(self.id)
	print("Assigning new team in initTeam", team_id, "for player with id", self.id)
	self:setTeam(GAME.teams[team_id])
end

function Player:setTeam(new_team)
	log("setTeam " .. tostring(new_team.id))
	
    -- Assign native custom team if it's changed
	local native_team = PlayerResource:GetCustomTeamAssignment(self.id)
	if native_team ~= new_team.id then
		log("Reassigning native custom team")
		PlayerResource:SetCustomTeamAssignment(self.id, new_team.id)
	end

	-- Remove from old team
	if self.team then
		self.team:playerLeft(self)
	end
	
	if self.heroEntity then
		self.heroEntity:SetTeam(new_team.id)
	end

	new_team:playerJoined(self)
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
	PlayerResource:SetGold(self.id, self.cash, true)
	PlayerResource:SetGold(self.id, 0, false)
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

-- Called on connect and on team join
function Game:getOrCreatePlayer(userid)
	local p = GAME.playersByUserid[userid]
	
	if not p then
		log("New player created")
		p = Player:new()
	end
	
	return p
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
		p = self:getOrCreatePlayer(event.userid)
	end
	
	p:EventConnect(event)
end

function Game:EventPlayerJoinedTeam(event)
	log("EventPlayerJoinedTeam")
	PrintTable(event)
	
	local p = self:getOrCreatePlayer(event.userid)

	p:EventJoinedTeam(event)
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
