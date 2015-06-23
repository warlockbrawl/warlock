-- UI class, handles updating the UI

UserInterface = class()
UserInterface.update_period = 2.0

function UserInterface:init()
	CustomGameEventManager:RegisterListener("set_team", Dynamic_Wrap(self, "onSetTeam"))
	CustomGameEventManager:RegisterListener("set_team_mode", Dynamic_Wrap(self, "onSetTeamMode"))
	CustomGameEventManager:RegisterListener("set_mode", Dynamic_Wrap(self, "onSetMode"))
	CustomGameEventManager:RegisterListener("start_game", Dynamic_Wrap(self, "onStartGame"))
	print("UI initialized")
	
	GAME:addTask {
		id		='ui update',
		period	= UserInterface.update_period,
		func	= function()
			self:update()
		end
	}
end

function UserInterface:onSetTeam(args)
	-- TODO: Check if source player is the host
	print("onSetTeam called")
	DeepPrintTable(args)
	local source_player_id = args.PlayerID;
	local player_id = args.player_id
	local new_team_id = args.new_team_id
	PlayerResource:SetCustomTeamAssignment(player_id, new_team_id)
end

function UserInterface:onSetTeamMode(args)
	print("onSetTeamMode called")
	DeepPrintTable(args)
end

function UserInterface:onSetMode(args)
	print("onSetMode called")
	DeepPrintTable(args)
end

function UserInterface:onStartGame(args)
	print("onStartGame called")
	DeepPrintTable(args)
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
	self.mode_sel_data[MODE_SEL_WINC] = MODE_SEL_WINC_ROUNDS
	self.mode_sel_data[MODE_SEL_MAXSCORE] = 11
	self.mode_sel_data[MODE_SEL_ROUNDCOUNT] = 11
	self.mode_sel_data[MODE_SEL_NODRAWS] = true
	self.mode_sel_data[MODE_SEL_TEAMSCORE] = false
end

function Game:setMode(index, value)
	log("setMode " .. tostring(index) .. " " .. tostring(value))
	self.mode_sel_data[index] = value
end

-- Shows the selection screen and starts the timer to select modes
function Game:startModeSelection()
	local player
	
	for _, p in pairs(GAME.players) do
		log("Player " .. p.name .. " id " .. tostring(p.id))
		
		if not player or player.id > p.id then
			player = p
		end
	end
	
	self.mode_selecting_player = player
	
	display("Waiting for " .. self.mode_selecting_player.name .. " to select modes for up to " .. tostring(Config.MODE_PICK_TIME) .. " seconds.")
	
	FireGameEvent("w_start_mode_selection", { id = self.mode_selecting_player.id })
	
	self.mode_task = self:addTask {
		time = Config.MODE_PICK_TIME,
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
	
	FireGameEvent("w_modes_selected", { id = self.mode_selecting_player.id })
	
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

	display("-- Modes have been selected")
	display("Mode: " .. self.mode:getDescription())
	display("Team Mode: " .. self.team_mode:getDescription())
	display("Win Condition: " .. self.mode.win_condition:getDescription())
	
	self:addTask {
		time = 3.0,
		func = function()
			self:start()
		end
	}
end
