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
	
	-- Precache unit
	--PrecacheUnitByName('npc_precache_everything')

	-- Game data structures
	self.lastTickTime = 0
	self.players = {}
	self.player_count = 0
	self.playersByUserid = {} -- contains also leavers waiting for reconnect
	self.playersByIndex = {}
	self.team_size = {}
	self.team_alive_count = {}
	self.team_score = {}
	self.team_name = {}
	self.team_players = {}
	self.team_players[DOTA_TEAM_GOODGUYS] = {}
	self.team_players[DOTA_TEAM_BADGUYS] = {}
	self.team_name[DOTA_TEAM_GOODGUYS] = 'Radiant'
	self.team_name[DOTA_TEAM_BADGUYS] = 'Dire'
	self.entityActor = {} --map enity to actor
	self.obstacles = Set:new()

	self.combat = false

	-- Initialize subsystems
	self:initTaskManager()
	self:initPhysics()
	self:initGameRules()
	self:initEvents()
	self:initCommands()
	self:initScriptedCashRefresh()
	self:initArena()
	self:initUserInterface()

	-- self.task_start = self:addTask{
	-- 	id='game start',
	-- 	time=Config.GAME_START_TIME,
	-- 	func=function()
	-- 		self:start()
	-- 	end
	-- }

	-- Initialize mode
	self.mode = ModeLTS:new()

	-- Wait for the game to start
	self.in_progress = false

	self.task_start = self:addTask{
		id='game start check',
		period=1,
		func=function()
			if self.in_progrss then
				self.task_start:cancel()
				return
			end

			-- Check if the phase is proper
			if GameRules:State_Get() >= DOTA_GAMERULES_STATE_PRE_GAME then
				-- Check if we have any players
				if self.player_count > 0 then
					self.in_progress = true
					self.task_start:cancel()
					self.task_start = nil
					self:start()
				else
					log("Waiting for at least 1 player")
				end
			else
				log("Waiting for DOTA_GAMERULES_STATE_PRE_GAME")
			end
		end
	}
end

function Game:start()
	self.in_progress = true

	display("Welcome to Warlock")

	self.mode:onStart()
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

	self:async(function()
		-- GetGameModeEntity returns nil during addon_game_mode.lua
		-- Needs to be executed on the event loop

		self.nativeMode = GameRules:GetGameModeEntity()

		-- Disables recommended items...though I don't think it works
		self.nativeMode:SetRecommendedItemsDisabled( true )

		-- Set the cam distance
		self.nativeMode:SetCameraDistanceOverride( Config.GAME_CAMERA_DISTANCE )

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
	end)
end

--- Connect to events (including the tick loop)
function Game:initEvents()
	-- Tick loop
	Entities:FindAllByClassname('dota_base_game_mode')[1]:SetThink('_Tick', '', Config.GAME_TICK_RATE, self)

	-- Events
	ListenToGameEvent('player_connect_full', Dynamic_Wrap(self, 'EventPlayerConnected'), self)
	ListenToGameEvent('player_disconnect', Dynamic_Wrap(self, 'EventPlayerDisconnected'), self)
	ListenToGameEvent('player_say', Dynamic_Wrap(self, 'EventPlayerChat'), self)

	ListenToGameEvent('dota_item_purchased', Dynamic_Wrap(self, 'EventShop'), self)
	ListenToGameEvent('dota_player_learned_ability', Dynamic_Wrap(self, 'EventUpgrade'), self)

	ListenToGameEvent('dota_player_used_ability', Dynamic_Wrap(self, 'EventAbilityUsed'), self)
	ListenToGameEvent('entity_killed', Dynamic_Wrap(self, 'EventEntityKilled'), self)

	ListenToGameEvent('player_reconnected', Dynamic_Wrap(self, 'EventPlayerReconnected'), self)
	ListenToGameEvent('npc_spawned', Dynamic_Wrap(self, 'EventNPCSpawned'), self)
end

--- Function executed periodically every GAME_TICK_RATE
function Game:_Tick()
	local current_time = self:time()
	local dt = current_time - self.lastTickTime
	self.lastTickTime = current_time

	if GameRules:State_Get() >= DOTA_GAMERULES_STATE_POST_GAME then
		self.in_progress = false
		return
	end

	-- Tasks
	self:tickTaskManager()

	if self.in_progress then
		-- Physics
		self:tickPhysics(dt)

		-- Subclasses
		self:EventTick(dt)
	end

	return Config.GAME_TICK_RATE
end


function Game:EventTick(dt)
end

function Game:EventAbilityUsed(event)
	--print('EventAbilityUsed ')
	--PrintTable(event)
end

function Game:EventEntityKilled(event)
	--print('EventEntityKilled ')
	--PrintTable(event)
end

-- Custom events
-- event:
--	* victim
--	* killer (optional)
function Game:PawnKilled(event)
	-- recalc teams
	self.team_alive_count = {}

	for id, player in pairs(self.players) do
		if player:isAlive() then
			self.team_alive_count[player.team] = (self.team_alive_count[player.team] or 0) + 1
		end
	end

	self.mode:onKill(event)

	-- Modifier Stuff
	Game:modOnDeath(event)
end


function Game:setCombat(b_combat)
	self.combat = b_combat
end

function Game:setShop(b_shop)
end

function Game:getRespawnLocation(pawn)
	return self.mode:getRespawnLocation(pawn)
end

function Game:getTeamScore(team)
	return (self.team_score[team] or 0)
end

function Game:setTeamScore(team, score)
	self.team_score[team] = score
	self.nativeMode:SetTopBarTeamValue(team, self.team_score[team])
end

function Game:addTeamScore(team, difference)
	self:setTeamScore(team, difference + self:getTeamScore(team))
end

function Game:teamName(team)
	return self.team_name[team] or tostring(team)
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
