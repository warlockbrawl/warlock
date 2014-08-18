WinCondition = class()

function WinCondition:init(def)
	self.detect_early_end = def.detect_early_end or false
	self.no_draws = def.no_draws or false
	self.use_team_score = def.use_team_score or false
	
	if self.detect_early_end then
		warning("WinCondition detect_early_end not yet implemented")
	end
end

function WinCondition:getDescription()
	return "Default"
end

function WinCondition:isGameOver()
	return false
end

function WinCondition:getWinners()
	return {}
end

-- Returns true if the game is tied, otherwise false
function WinCondition:isGameDrawn()
	local highest_score = -1
	local highest_score_count = 0
	
	if self.use_team_score then
		for i, team in pairs(GAME.teams) do
			if team.score > highest_score then
				highest_score = team.score
				highest_score_count = 0
			end
			
			if team.score == highest_score then
				highest_score_count = highest_score_count + 1
			end
		end
	else
		for i, player in pairs(GAME.players) do
			if player.score > highest_score then
				highest_score = player.score
				highest_score_count = 0
			end
			
			if player.score == highest_score then
				highest_score_count = highest_score_count + 1
			end
		end
	end
	
	return highest_score_count > 1
end

----------------------------------
-- Max Round Win Condition
----------------------------------

RoundWinCondition = class(WinCondition)

function RoundWinCondition:init(def)
	RoundWinCondition.super.init(self, def)
	
	self.round_count = def.round_count or 11
end

function RoundWinCondition:getDescription()
	return "Up to " .. tostring(self.round_count) .. " rounds"
end

-- Game is over when max round count is reached
function RoundWinCondition:isGameOver()
	local game_over = GAME.mode.round >= self.round_count
	
	-- Dont allow draws if no_draws is set
	if game_over and self.no_draws and self:isGameDrawn() then
		display("Game is tied! Continuing until a winner is found.")
		game_over = false
	end
	
	return game_over
end

-- Get players with the highest score
function RoundWinCondition:getWinners()
	local highest_score = -1
	local players = {}
	
	if self.use_team_score then
		for i, team in pairs(GAME.teams) do
			if team.score > highest_score then
				highest_score = team.score
				players = {}
			end
			
			if team.score == highest_score then
				-- Add all players of the team to the winner array
				for _, player in pairs(team.players) do
					table.insert(players, player)
				end
			end
		end
	else
		for i, player in pairs(GAME.players) do
			if player.score > highest_score then
				highest_score = player.score
			end

			if player.score == highest_score then
				table.insert(players, player)
			end
		end
	end
	
	return players
end

----------------------------------
-- Max Player Score Win Condition
----------------------------------

ScoreWinCondition = class(WinCondition)

function ScoreWinCondition:init(def)
	ScoreWinCondition.super.init(self, def)
	
	self.max_score = def.max_score or 11
end

function ScoreWinCondition:getDescription()
	return "Up to " .. tostring(self.max_score) .. " score"
end

-- Game is over when max round count is reached
function ScoreWinCondition:isGameOver()
	local winners = self:getWinners()	
	local game_over = #winners > 0
	
	-- Dont allow draws if no_draws is set
	if game_over and self.no_draws and self:isGameDrawn() then
		display("Game is tied! Continuing until a winner is found.")
		game_over = false
	end
	
	return game_over
end

-- Get players with the highest score and atleast max_score
function ScoreWinCondition:getWinners()
	local highest_score = -1
	local players = {}
	
	if self.use_team_score then
		for i, team in pairs(GAME.teams) do
			-- Atleast max_score
			if team.score >= self.max_score then
				if team.score > highest_score then
					highest_score = team.score
					players = {}
				end
				
				if team.score == highest_score then
					-- Add all players of the team to the winner array
					for _, player in pairs(team.players) do
						table.insert(players, player)
					end
				end
			end
		end
	else
		for i, player in pairs(GAME.players) do
			-- Atleast max_score
			if player.score >= self.max_score then
				if player.score > highest_score then
					highest_score = player.score
				end

				if player.score == highest_score then
					table.insert(players, player)
				end
			end
		end
	end
	
	return players
end
