-- UI class, handles updating the UI

UserInterface = class()

GAME_OPT_TEAM		= 1
GAME_OPT_GAME		= 2
GAME_OPT_WINC		= 3
GAME_OPT_WINC_MAX	= 4
GAME_OPT_NODRAWS	= 5
GAME_OPT_TEAMSCORE	= 6

GAME_OPT_TEAM_DEFAULT	= 1
GAME_OPT_TEAM_FFA		= 2
GAME_OPT_TEAM_SHUFFLE	= 3

GAME_OPT_GAME_ROUNDS	= 1
	
GAME_OPT_WINC_SCORE		= 1
GAME_OPT_WINC_ROUNDS	= 2

GAME_OPT_TEAM_MODES = {
	TeamMode,
	TeamModeFFA,
	TeamModeShuffle
}

GAME_OPT_GAME_MODES = {
	ModeLTS
}

GAME_OPT_WIN_CONDS = {
	ScoreWinCondition,
	RoundWinCondition
}

function UserInterface:init()
	-- Holds all the mode selection data
	self.game_options = {}
	self.game_options[GAME_OPT_TEAM] = GAME_OPT_TEAM_SHUFFLE
	self.game_options[GAME_OPT_GAME] = GAME_OPT_GAME_ROUNDS
	self.game_options[GAME_OPT_WINC] = GAME_OPT_WINC_ROUNDS
	self.game_options[GAME_OPT_WINC_MAX] = 11
	self.game_options[GAME_OPT_NODRAWS] = true
	self.game_options[GAME_OPT_TEAMSCORE] = false
	
	CustomGameEventManager:RegisterListener("set_team", Dynamic_Wrap(self, "onSetTeam"))
	CustomGameEventManager:RegisterListener("set_game_option", Dynamic_Wrap(self, "onSetGameOption"))
	CustomGameEventManager:RegisterListener("start_game", Dynamic_Wrap(self, "onStartGame"))

	print("UI initialized")
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

function UserInterface:onStartGame(args)
	print("onStartGame called")
	DeepPrintTable(args)
	
	Game:selectModes()
end

function UserInterface:onSetGameOption(args)
	print("onSetGameOption called")
	DeepPrintTable(args)
	
	local index = args.index
	local value = args.value
	GAME.user_interface.game_options[index] = value
end

------------------------
-- Game Interface
------------------------

function Game:initUserInterface()
	self.user_interface = UserInterface:new()
	print("Game:initUserInterface")
	print(self.user_interface)
end

-- Select the modes
function Game:selectModes()
	local ui = self.user_interface
	
	self.team_mode = GAME_OPT_TEAM_MODES[ui.game_options[GAME_OPT_TEAM]]:new {
		
	}
	
	local win_cond = GAME_OPT_WIN_CONDS[ui.game_options[GAME_OPT_WINC]]:new {
		detect_early_end = false,
		no_draws = ui.game_options[GAME_OPT_NODRAWS],
		use_team_score = ui.game_options[GAME_OPT_TEAMSCORE],
		max_score = ui.game_options[GAME_OPT_WINC_MAX],
		round_count = ui.game_options[GAME_OPT_WINC_MAX]
	}
	
	self.mode = GAME_OPT_GAME_MODES[ui.game_options[GAME_OPT_GAME]]:new {
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
