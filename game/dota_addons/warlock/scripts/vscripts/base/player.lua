--- Player class
-- @author Krzysztof Lis (Adynathos)

Player = class()

Player.ALLIANCE_SELF		= 0
Player.ALLIANCE_ALLY		= 1
Player.ALLIANCE_ENEMY		= 2

Player.MASTERY_DURATION		= 1
Player.MASTERY_RANGE		= 2
Player.MASTERY_LIFESTEAL	= 3
Player.MASTERY_MAX_INDEX	= 3

Player.STATS_DAMAGE			= 1
Player.STATS_HEALING		= 2
Player.STATS_MAX_INDEX		= 2

--- Create a player using the information
-- from PreConnect event
-- @param info Table received from PreConnect event.
function Player:init()
	self.cash = 0
	self.reconnect = false --will be set to true when leaving for the first time
	
	-- stats
	self.stats = {}
	for i = 1, Player.STATS_MAX_INDEX do
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

    self.name = "Unknown"
end

function Player:resetStats()
	for stat, val in pairs(self.stats) do
		self.stats[stat] = 0
	end
end

function Player:changeStat(stat, num)
	self.stats[stat] = self.stats[stat] + num
end

function Player:HeroSpawned(hero)	
	if self.pawn then
		warning("HeroSpawned called but pawn already created.")
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

    GAME.shop:giveItem(self, 2) -- Fireball
    GAME.shop:giveItem(self, 1) -- Scourge

	-- Kill pawn if not in combat
	if GAME.combat then
		self.pawn:die{}
	end

    -- Remove staff and lantern
    local child= hero:FirstMoveChild()
    while child ~= nil do
        if child:GetClassname() == "dota_item_wearable" then
            if string.match(child:GetModelName():lower(), "staff") or string.match(child:GetModelName():lower(), "lantern") then
                child:RemoveSelf()
            end
        end

        child = child:NextMovePeer()
    end

    -- Add all start and round gold
    -- The mode can be nil in the start of the game
    if GAME.mode then
        GAME.mode:addNewPlayerGold(self)
    end
end

function Player:HeroRemoved()
	if self.pawn then
		self.pawn:disable()
		self.pawn = nil
	end
end

function Player:EventReconnect()
	self.disconnected = false
	
    if Config.bot_on_dc then
        GAME:removePlayerAI(self)
    else
        if not GAME.combat then
		    self.pawn:respawn()
	    end
		
	    self.active = true
	    GAME.active_players[self] = true
    end

    -- Get the player entity, invalid after reconnecting
    self.playerEntity = PlayerResource:GetPlayer(self.id)

	log("Player " .. self.name .. " reconnected fully.")

    if GAME.mode then
        GAME.mode:playerReconnected(self)
    end
end

function Player:EventDisconnect()
	log(self.name .. ' has left the game.')

    -- Replace leavers with bots or kill the leaver until he rejoins
    if Config.bot_on_dc then
        display("Adding AI for disconnected player")
        GAME:addPlayerAI(self, { buy_delay = Config.BOT_BUY_DELAY })
    else
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

    -- Set disconencted flag for detecting reconnects
    self.disconnected = true
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
	if self == other_player then
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
	return self.pawn ~= nil and self.pawn.enabled
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

-- Called on connect and on team join
function Game:getOrCreatePlayer(player_id)
	local p = self.players[player_id]
	
	if not p then
		log("New player created")
		p = Player:new()
        p.id = player_id
        p.playerEntity = PlayerResource:GetPlayer(p.id)
        p.disconnected = false

        if not p.playerEntity then
            err("Player Entity nil in getOrCreatePlayer")
        end

        p.name = PlayerResource:GetPlayerName(p.id)

        self.players[p.id] = p

        -- Add new player to shop
        self.shop:addPlayer(p)

        GAME.player_count = GAME.player_count + 1
	end

	return p
end

function Game:startReconnectTask()
    self:addTask {
        id = "Reconnect detection",
        period = 1,
        func = function()
            -- Find reconnected players
            for id, player in pairs(self.players) do
                if player.disconnected and PlayerResource:GetConnectionState(id) == DOTA_CONNECTION_STATE_CONNECTED then
                    log("Detected reconnected player " .. tostring(id))
                    player:EventReconnect()
                end
            end
        end
    }
end

function Game:EventPlayerJoinedTeam(event)
	log("EventPlayerJoinedTeam")
	PrintTable(event)

    if event.disconnect == 1 then
        local dc_count = 0

        -- Find newly disconnected players
        for id, player in pairs(self.players) do
            if not player.disconnected and PlayerResource:GetConnectionState(id) ~= DOTA_CONNECTION_STATE_CONNECTED then
                log("Detected disconnected player " .. tostring(id))
                player:EventDisconnect()
                dc_count = dc_count + 1
            end
        end

        if dc_count > 1 then
            warning("More than one disconnected player detected at once")
        end
    end
end

function Game:EventNPCSpawned(event)
	local spawned_unit = EntIndexToHScript(event.entindex)

	-- Ignore non-hero units and respawns
	if not spawned_unit:IsHero() or spawned_unit.hero_spawned_called then
		return
	end

    print("EventNPCSpawned Hero Spawned")
    DeepPrintTable(event)

    local player_id = spawned_unit:GetPlayerID()

    print("Player ID:", player_id)

    if player_id == -1 then
        err("Player ID was -1 in EventNPCSpawned")
        return
    end

	local p = GAME:getOrCreatePlayer(player_id)

	p:HeroSpawned(spawned_unit)
    spawned_unit.hero_spawned_called = true

    -- Detect AI and add an AI controller
    if PlayerResource:IsFakeClient(player_id) then
        display("Added AI player")

        if not p.playerEntity.ai_def then
            warning("Fake player hero spawned but player's entity ai_def was nil")
        end

        self:addPlayerAI(p, p.playerEntity.ai_def)

        p.is_bot = true

        -- Move AI definition from player entity to player object
        p.ai_def = p.playerEntity.ai_def
        p.playerEntity.ai_def = nil
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
