--- Player class
-- @author Krzysztof Lis (Adynathos)

Player = class()

Player.ALLIANCE_SELF		= 0
Player.ALLIANCE_ALLY		= 1
Player.ALLIANCE_ENEMY		= 2

--- Create a player using the information
-- from PreConnect event
-- @param info Table received from PreConnect event.
function Player:init()
	self.cash = 0
	self.reconnect = false --will be set to true when leaving for the first time
	
	-- stats
	self.damage = 0
end

function oppositeTeam(team)
	if team == DOTA_TEAM_GOODGUYS then
		return DOTA_TEAM_BADGUYS
	else
		return DOTA_TEAM_GOODGUYS
	end
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

		self.id = self.playerEntity:GetPlayerID()
		self.steamId = PlayerResource:GetSteamAccountID(self.id)

		self.userid = info.userid
		self.index = info.index
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

		-- increase the size of the team we are joining and add the player to the team players list
		GAME.team_size[self.team] = (GAME.team_size[self.team] or 0) + 1
		for i = 0, 10 do
			if GAME.team_players[self.team][i] == nil then
				self.team_player_index = i
				GAME.team_players[self.team][self.team_player_index] = self
				break
			end
		end
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

-- function Player:EventReconnected(info)
-- end

function Game:GetTeamForNewPlayer()
	if (self.team_size[DOTA_TEAM_GOODGUYS] or 0) <= (self.team_size[DOTA_TEAM_BADGUYS] or 0) then
		return DOTA_TEAM_GOODGUYS
	else
		return DOTA_TEAM_BADGUYS
	end
end

-- Native dota teams cannot be reassigned
function Player:initTeam()
	-- check for previous team
	self.team = self.playerEntity:GetTeam()

	print("TEAM ", self.team)

	-- if team is not assigned yet, assign a new one
	if self.team == -1 or self.team == 0 then
		self.team = GAME:GetTeamForNewPlayer()
		self.playerEntity:SetTeam(self.team)
	end
end

function Player:getTeam()
	return self.team
end

function Player:getAlliance(other_player)
	if self.userid == other_player.userid then
		return self.ALLIANCE_SELF
	end

	if self:getTeam() == other_player:getTeam() then
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
