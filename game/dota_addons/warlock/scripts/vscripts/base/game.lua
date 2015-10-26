--- Base Game class
-- @author Krzysztof Lis (Adynathos)

Game = class()

--- Game constructor, called from addon_game_mode.lua
function Game:init()
	log('Game:init')
	GAME = self

	if Config.DEVELOPMENT then
		display("DEVELOPMENT MODE")
	end

	-- Seed RNG randomly
	local time_txt = string.gsub(string.gsub(GetSystemTime(), ':', ''), '0','')
	log("RNG Seed:" .. time_txt)
	math.randomseed(tonumber(time_txt))

	-- Game data structures
    self.tick = 0 -- The tick at the start of a frame
	self.lastTickTime = 0
	self.players = {}
	self.player_count = 0
	self.active_players = {}

	self.entityActor = {} --map enity to actor
	self.obstacles = Set:new()

	self.combat = false
	
	-- Temporary actors, destroyed on each round
	self.temp_actors = {}

	-- Initialize subsystems
	self:initTaskManager()
	self:initPhysics()
	self:initGameRules()
	self:initEvents()
	self:initCommands()
    self:initShop()
	self:initScriptedCashRefresh()
	self:initTeams()
	self:initArena()
	self:initGameSetup()
    self:initScoreboard()

	-- Wait for the game to start
	self.in_progress = false
    self.is_over = false

    -- AI Controllers
    self.ai_controllers = { }
end

-- Ends the game and sets winners
function Game:winGame(winners)
	local winner_str = ""

	if #winners > 0 then
		-- Create winner string
		for _, player in pairs(winners) do
			winner_str = winner_str .. player.name .. ", "
		end
		
		-- Remove comma and whitespace
		winner_str = string.sub(winner_str, 1, -3)

		winner_str = winner_str .. " won the game!"
		
		-- Display winner text
		display(winner_str)
	else		
		display("The game ended in a draw!")
	end
	
	display("If you have found any bugs or have feedback please visit us at warlockbrawl.com")
	
    self.web_api:finishMatch()

	GameRules:SetGameWinner(DOTA_TEAM_GOODGUYS)
end

function Game:EventStateChanged(event)
	new_state = GameRules:State_Get()
	
    -- Start a timer for game start
	if not self.in_progress and not self.is_over and not self.game_start_task and new_state >= DOTA_GAMERULES_STATE_PRE_GAME then
		self:selectModes()
	end

    -- Need to init web api here because http requests dont work before
    if new_state == DOTA_GAMERULES_STATE_CUSTOM_GAME_SETUP then
        self:initWebAPI()
    end

	log("GameState changed to " .. tostring(new_state))
end

function Game:start()
    if self.game_start_task or self.in_progress then
        warning("Game:start called more than once")
        return
    end

    self.game_start_task = self:addTask {
        period = 1,
        func = function()
            if self.player_count < 1 then
                log("Waiting for at least 1 player to pick")
                return
            end

            self.game_start_task:cancel()
            self.game_start_task = nil
            
            self.in_progress = true

            log("Game:start called")

	        display("Welcome to Warlock")
	        display("Created by Toraxxx, Adynathos, Zymoran")

	        -- Assign teams
	        for _, player in pairs(GAME.players) do
		        player:initTeam()
	        end

	        self.mode:onStart()

            -- Add bots
            log("Adding " .. tostring(Config.bot_count) .. " bots")
            for i = 1, Config.bot_count do
                self:addBot(0.2)
            end
        end
    }
end

--- @return Current game time
function Game:time()
	return GameRules:GetGameTime()
end

--- @return Current real time
function Game:realTime()
	return Time()
end

--- Send settings through the native API
function Game:initGameRules()
	GameRules:SetHeroRespawnEnabled(false)
	GameRules:SetUseUniversalShopMode(true)
	GameRules:SetSameHeroSelectionEnabled(true)
	GameRules:SetHeroSelectionTime(1.0)
	GameRules:SetPreGameTime(Config.GAME_START_TIME)
	GameRules:SetPostGameTime(10.0)
	GameRules:SetTreeRegrowTime(60.0)
	GameRules:SetUseCustomHeroXPValues (true)
	GameRules:SetGoldPerTick(0)

	-- Heroes will use the basic NPC functionality for determining their bounty, rather than DOTA specific formulas.
	GameRules:SetUseBaseGoldBountyOnHeroes(true)

	-- Disable first blood event (and its cash reward)
	GameRules:SetFirstBloodActive(false)

	self.nativeMode = GameRules:GetGameModeEntity()
    
    -- Disable recommended items
    self.nativeMode:SetHUDVisible(DOTA_HUD_VISIBILITY_SHOP_SUGGESTEDITEMS, false)

	--
	self.nativeMode:SetCustomBuybackCostEnabled( true )
	self.nativeMode:SetCustomBuybackCooldownEnabled( true )
	self.nativeMode:SetBuybackEnabled( false )
	-- Override the top bar values to show your own settings instead of total deaths
	self.nativeMode:SetTopBarTeamValuesOverride ( true )
	-- Use custom hero level maximum and your own XP per level
	self.nativeMode:SetUseCustomHeroLevels ( true )
	self.nativeMode:SetCustomHeroMaxLevel ( Config.MAX_LEVEL )
	self.nativeMode:SetFogOfWarDisabled( true )

	--self.nativeMode:SetCustomXPRequiredToReachNextLevel( 1 )
end

--- Connect to events (including the tick loop)
function Game:initEvents()
	-- Tick loop
	self.nativeMode:SetThink("_Tick", self, "_Tick", Config.GAME_TICK_RATE)
	
	-- Player init events
	ListenToGameEvent('player_team', Dynamic_Wrap(self, 'EventPlayerJoinedTeam'), self)
    ListenToGameEvent('npc_spawned', Dynamic_Wrap(self, 'EventNPCSpawned'), self)

    -- Player killed event
	ListenToGameEvent('entity_killed', Dynamic_Wrap(self, 'EventEntityKilled'), self)

    -- Misc events
	ListenToGameEvent('game_rules_state_change', Dynamic_Wrap(self, 'EventStateChanged'), self)

    self:startReconnectTask()
end

--- Function executed periodically every GAME_TICK_RATE
function Game:_Tick()
	local current_time = self:time()
	local dt = current_time - self.lastTickTime
	self.lastTickTime = current_time

	if GameRules:State_Get() >= DOTA_GAMERULES_STATE_POST_GAME then
		self.in_progress = false
        self.is_over = true
		return
	end

	-- New way to check if a game is paused instead of dt == 0 does not work yet
	--if GameRules:IsGamePaused() then
	
	-- dt = 0 means the game is paused
	-- Do nothing when game was paused
	if dt == 0 then
		return Config.GAME_TICK_RATE
	end

	-- Tasks
	self:tickTaskManager()

	if self.in_progress then
		-- Physics
		self:tickPhysics(dt)

		-- Subclasses
		self:EventTick(dt)
	end

    self.tick = self.tick + 1

	return Config.GAME_TICK_RATE
end


function Game:EventTick(dt)
end

function Game:EventEntityKilled(event)

end

-- Custom events
-- event:
--	* victim
--	* killer (optional)
function Game:PawnKilled(event)
	self.mode:onKill(event)

	-- Modifier Stuff
	Game:modOnDeath(event.victim)

    -- Update kills and deaths for Web API
    if event.killer and event.killer.owner and event.killer.owner.steam_id ~= 0 then
        local kills = tostring(PlayerResource:GetKills(event.killer.owner.id))
        self.web_api:setMatchPlayerProperty(event.killer.owner.steam_id, "kills", kills)
    end

    if event.victim.owner and event.victim.owner.steam_id ~= 0 then
        local deaths = tostring(PlayerResource:GetDeaths(event.victim.owner.id))
        self.web_api:setMatchPlayerProperty(event.victim.owner.steam_id, "deaths", deaths)
    end
end


function Game:setCombat(b_combat)
	self.combat = b_combat
end

function Game:setShop(b_shop)
end

function Game:getRespawnLocation(pawn)
	if not self.mode then
		return Vector(0, 0, Config.GAME_Z)
	end
	
	return self.mode:getRespawnLocation(pawn)
end

function Game:showMessage(text, duration)
	local msg = {
		message = text,
		duration = duration
	}

	FireGameEvent("show_center_message", msg)
end

function Game:showFloatingNum(def)
	if not def.num or not def.location or def.num < 1 then
		return
	end
	
	local duration = def.duration or 1
	local color = def.color or Vector(255, 255, 255)
	
	-- Round number and display only needed digits
	local strnum = string.format("%.0f", def.num)
	local digits = strnum:len()
	
	-- Create the particle system that displays the text
	local pid = ParticleManager:CreateParticle("particles/msg_fx/msg_evade.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(pid, 0, def.location)
	ParticleManager:SetParticleControl(pid, 1, Vector(1, tonumber(strnum), 0))
	ParticleManager:SetParticleControl(pid, 2, Vector(duration, digits, digits))
	ParticleManager:SetParticleControl(pid, 3, color)
	
	
	-- Release the particle system
	self:addTask {
		time = duration,
		func = function()
			ParticleManager:ReleaseParticleIndex(pid)
		end
	}
end

function Game:addTempActor(actor)
	self.temp_actors[actor] = true
end

function Game:removeTempActor(actor)
	self.temp_actors[actor] = nil
end

function Game:destroyTempActors()
	for actor, _ in pairs(self.temp_actors) do
		actor:destroy()
	end
	
	self.temp_actors = {}
end
