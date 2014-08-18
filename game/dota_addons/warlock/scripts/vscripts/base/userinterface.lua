-- UI class, handles updating the UI

UserInterface = class()
UserInterface.update_period = 2.0

function UserInterface:init()
	GAME:addTask {
		id		='ui update',
		period	= UserInterface.update_period,
		func	= function()
			self:update()
		end
	}
end

function UserInterface:update()
	for id, pl in pairs(GAME.players) do
		local score = pl.score
		
		-- Display team score instead of team score if use_team_score is set
		if GAME.mode and GAME.mode.win_condition and GAME.mode.win_condition.use_team_score then
			if pl.team then
				score = pl.team.score
			end
		end
		
		FireGameEvent("w_update_scoreboard", {
			id		= id,
			points	= score,
			dmg		= pl.stats[Player.STATS_DAMAGE]
		})
	end
end

------------------------
-- Game Interface
------------------------

MODE_SEL_TEAM		= 1
MODE_SEL_GAME		= 2
MODE_SEL_WINC		= 3
MODE_SEL_MAXSCORE	= 4
MODE_SEL_ROUNDCOUNT	= 5
MODE_SEL_NODRAWS	= 6
MODE_SEL_TEAMSCORE	= 7

MODE_SEL_TEAM_DEFAULT	= 1
MODE_SEL_TEAM_FFA		= 2
MODE_SEL_TEAM_SHUFFLE	= 3

MODE_SEL_GAME_ROUNDS	= 1
	
MODE_SEL_WINC_SCORE		= 1
MODE_SEL_WINC_ROUNDS	= 2

MODE_SEL_TEAM_MODES = {
	TeamMode,
	TeamModeFFA,
	TeamModeShuffle
}

MODE_SEL_GAME_MODES = {
	ModeLTS
}

MODE_SEL_WIN_CONDS = {
	ScoreWinCondition,
	RoundWinCondition
}

function Game:initUserInterface()
	self.user_interface = UserInterface:new()
	
	-- Holds all the mode selection data
	self.mode_sel_data = {}
	self.mode_sel_data[MODE_SEL_TEAM] = MODE_SEL_TEAM_SHUFFLE
	self.mode_sel_data[MODE_SEL_GAME] = MODE_SEL_GAME_ROUNDS
	self.mode_sel_data[MODE_SEL_WINC] = MODE_SEL_WINC_SCORE
	self.mode_sel_data[MODE_SEL_MAXSCORE] = 11
	self.mode_sel_data[MODE_SEL_ROUNDCOUNT] = 11
	self.mode_sel_data[MODE_SEL_NODRAWS] = true
	self.mode_sel_data[MODE_SEL_TEAMSCORE] = false
	
	FireGameEvent("w_start_mode_selection", {
			
	})
end

function Game:setMode(index, value)
	self.mode_sel_data[index] = value
end

-- Shows the selection screen and starts the timer to select modes
function Game:startModeSelection()
	display("Waiting for player 1 to select modes up to 20 seconds.")
	
	self.mode_task = self:addTask {
		time = 20.0,
		func = function()
			self.mode_task = nil
			self:selectModes()
		end
	}
end

-- Select the modes
function Game:selectModes()
	if self.mode_task then
		self.mode_task:cancel()
		self.mode_task = nil
	end
		
	PrintTable(self.mode_sel_data)
	print("-------")
	PrintTable(MODE_SEL_TEAM_MODES)
		
	self.team_mode = MODE_SEL_TEAM_MODES[self.mode_sel_data[MODE_SEL_TEAM]]:new {
		
	}
	
	local win_cond = MODE_SEL_WIN_CONDS[self.mode_sel_data[MODE_SEL_WINC]]:new {
		detect_early_end = false,
		no_draws = self.mode_sel_data[MODE_SEL_NODRAWS],
		use_team_score = self.mode_sel_data[MODE_SEL_TEAMSCORE],
		max_score = self.mode_sel_data[MODE_SEL_MAXSCORE],
		round_count = self.mode_sel_data[MODE_SEL_ROUNDCOUNT]
	}
	
	self.mode = MODE_SEL_GAME_MODES[self.mode_sel_data[MODE_SEL_GAME]]:new {
		win_condition = win_cond
	}
	
	FireGameEvent("w_modes_selected", {
		
	})

	display("Modes have been selected.")
	
	self:addTask {
		time = 3.0,
		func = function()
			self:start()
		end
	}
end
