--- Base mode
-- @author Krzysztof Lis (Adynathos)

Mode = class()
Mode.SHOP_TIME = 30
Mode.OBSTACLE_COUNT_MIN = 2
Mode.OBSTACLE_COUNT_MAX = 8

function Mode:roundName(round_to_print)
	return 'Round ' .. (round_to_print or self.round or 0)
end

function Mode:init(def)
	self.round = 0
	self.win_condition = def.win_condition or ScoreWinCondition:new {
		detect_early_end = true,
		no_draws = true,
		max_score = 5,
		use_team_score = false
	}

    -- Set cash constants
    self.cash_every_round = def.cash_every_round
    self.cash_on_start = def.cash_on_start
    self.cash_per_kill = def.cash_per_kill
    self.cash_per_win = def.cash_per_win
end

function Mode:getDescription()
	return "Default"
end

function Mode:onStart()
	for id, player in pairs(GAME.players) do
		player:setCash(self.cash_on_start)
	end
	
	self:prepareForRound()
end

function Mode:respawnPlayers(shop_time)
	-- Respawn players and make them un/able to upgrade spells
	for id, player in pairs(GAME.players) do
		if player.active and player.pawn then
			player.pawn:respawn()
			if shop_time then
				player.pawn.unit:SetAbilityPoints(1)
			else
				player.pawn.unit:SetAbilityPoints(0)
			end
		end
		
		-- Reset player stats (kills etc.)
		if not shop_time then
			player:resetStats()
		end
	end
end

function Mode:prepareForRound()
	GAME:setCombat(false)
	GAME:removeProjectiles()
	GAME:destroyTempActors()
	GAME:setShop(true)
	GAME.arena:setAutoShrink(false)
	
	-- obstacles
	GAME:clearObstacles()
	GAME:setRandomObstacleVariation()
	Arena:setPlatformType(Obstacle.variation) -- arena platform type matches obstacle variation
	GAME.arena:setLayer(0) -- delete the remaining tiles (to create new platform type)
	GAME.arena:setLayer(16) -- corresponding to 1 player
	GAME:addRandomObstacles(math.random(Mode.OBSTACLE_COUNT_MIN, Mode.OBSTACLE_COUNT_MAX))

	self:respawnPlayers(true)

	-- Start the round start timer
	GAME:addTask{
		id='round start',
		time=self.SHOP_TIME,
		func= function()
			self:onRoundStart()
		end
	}

 	-- Every 5 s print time till shoptime ends
	local shoptime_end = GAME:time() + self.SHOP_TIME

	local function print_shoptime_countdown()
		local time_to_round_start = math.ceil(shoptime_end - GAME:time())
		display(self:roundName(self.round+1) ..' in ' .. time_to_round_start .. 's')
	end

	for t = 0, self.SHOP_TIME-1, 5 do
		GAME:addTask{
			id='shoptime countdown',
			time=t,
			func=print_shoptime_countdown
		}
	end

	-- Print the last 3 seconds bigger
	local function print_shoptime_final_countdown()
		local time_to_round_start = math.ceil(shoptime_end - GAME:time())
		GAME:showMessage(tostring(time_to_round_start), 0.7)
	end

	for t = self.SHOP_TIME-3, self.SHOP_TIME-1 do
		GAME:addTask{
			id='shoptime final countdown',
			time=t,
			func=print_shoptime_final_countdown
		}
	end

	GAME:addTask{
		id="shoptime help",
		time = 1,
		func=function()
			display('Buy new spells in the shop')
			display('Assign ability points to buy spell upgrades (remember this costs money)')
		end
	}

	GAME:addTask {
		id ='shoptime fight',
		time = self.SHOP_TIME,
		func = function()
			GAME:showMessage("FIGHT!", 1.0)
		end
	}

	-- Show SHOPTIME message at the top
	GAME:showMessage("SHOPTIME", self.SHOP_TIME - 5)
end

-- Called when a round starts
function Mode:onRoundStart()
	self.round = self.round + 1
	display(self:roundName())

	GAME:setShop(false)
	GAME:removeProjectiles()
	GAME:destroyTempActors()
	GAME:setCombat(true)
	
	GAME.team_mode:onNewRound()

	self:respawnPlayers(false)
	
	-- initial invul
	for pawn, _ in pairs(GAME.pawns) do
		pawn.unit:Stop()
		pawn:addNativeModifier("modifier_omninight_guardian_angel")
		pawn.invulnerable = true
	end
	
	-- remove initial invul after some time
	GAME:addTask {
		time = 2,
		func = function()
			for pawn, _ in pairs(GAME.pawns) do
				pawn:removeNativeModifier("modifier_omninight_guardian_angel")
				pawn.invulnerable = false
			end
		end
	}
	
	GAME.arena:setLayer(15+GAME.player_count*1)
	GAME.arena:setAutoShrink(true)

	-- modifier event
	GAME:modOnReset()
end

-- Called when a round was won
function Mode:onRoundWon(winner_team)
	GAME:setCombat(false)

	-- Leave some time to end the round, end it later
	GAME:addTask {
		id = 'round end',
		time = 2,
		func = function()
			self:onRoundEnd()
		end
	}

	if winner_team then
		display(winner_team.name .. ' has won the round')
		
		-- Get player that dealt the highest damage
		local highest_dmg = -1
		local highest_dmg_player
		for id, player in pairs(GAME.players) do
			if player.stats[Player.STATS_DAMAGE] > highest_dmg then
				highest_dmg = player.stats[Player.STATS_DAMAGE]
				highest_dmg_player = player
			end
		end
		
		if highest_dmg_player and highest_dmg > 0 then
			local dmg_text = string.format("%.0f", highest_dmg)
			display(highest_dmg_player.name .. " has dealt the highest damage (" .. dmg_text .. ")")
		end
		
		winner_team:addScore(1)

		-- rewards for winning
		for _, player in pairs(winner_team.players) do
			player:addCash(self.cash_per_win)
		end
	else
		display('Draw')
	end
end

-- Called when a round ended
function Mode:onRoundEnd()
	display(self:roundName()..' has ended')

	-- Rewards for ending the round
	for id, player in pairs(GAME.players) do
		player:addCash(self.cash_every_round)
	end

	-- Check the win condition if the game is over
	if not self.win_condition:isGameOver() then
		self:prepareForRound()
	else
		GAME:winGame(self.win_condition:getWinners())
	end
end

-- Called when a player was killed
function Mode:onKill(event)
	-- give reward for kill
	if event.killer and event.killer.owner and event.killer ~= event.victim then
		local player_to_reward = event.killer.owner

		-- the player may get some naive rewards, so update his cash
		-- after that potentially happens
		GAME:addTask{
			time = 1,
			func = function()
				player_to_reward:addCash(self.cash_per_kill)
			end
		}
	end
end

-- Called when a pawn wants to respawn
function Mode:getRespawnLocation(pawn)
	local angle_per_team = 2 * math.pi / GAME.active_team_count
	
	local radius = 650 + 50 * GAME.player_count
	local angle = angle_per_team * pawn.owner.team.active_team_id
	
	-- Offset the individual players of a team
	local angle_offset = 0.2 * (pawn.owner.team_player_index - (pawn.owner.team.size - 1) / 2.0)
	angle = angle + angle_offset

	return Vector(radius * math.cos(angle), radius * math.sin(angle), Config.GAME_Z)
end

ModeLTS = class(Mode)

function ModeLTS:getDescription()
	return "Rounds"
end

-- check for victory conditions
function ModeLTS:onKill(event)
	ModeLTS.super.onKill(self, event)

	if GAME.combat then
		local alive_teams = GAME:getAliveTeams()
		local round_over = #alive_teams <= 1

		if round_over then
			-- alive_teams[1] can be nil = draw
			self:onRoundWon(alive_teams[1])
		end
	end
end
