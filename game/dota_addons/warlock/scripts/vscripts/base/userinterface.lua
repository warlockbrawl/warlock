-- UI class, handles updating the UI

UserInterface = class()

GAME_OPT_TEAM		= 1
GAME_OPT_GAME		= 2
GAME_OPT_WINC		= 3
GAME_OPT_WINC_MAX	= 4
GAME_OPT_NODRAWS	= 5
GAME_OPT_TEAMSCORE	= 6
GAME_OPT_CASH_ROUND = 7
GAME_OPT_CASH_START = 8
GAME_OPT_CASH_KILL  = 9
GAME_OPT_CASH_WIN   = 10

GAME_OPT_TEAM_SHUFFLE	= 1
GAME_OPT_TEAM_FFA		= 2
GAME_OPT_TEAM_DEFAULT	= 3

GAME_OPT_GAME_ROUNDS	= 1

GAME_OPT_WINC_ROUNDS	= 1	
GAME_OPT_WINC_SCORE		= 2

GAME_OPT_TEAM_MODES = {
    TeamModeShuffle,
    TeamModeFFA,
	TeamMode,
}

GAME_OPT_GAME_MODES = {
	ModeLTS
}

GAME_OPT_WIN_CONDS = {
    RoundWinCondition,
	ScoreWinCondition
}

function UserInterface:init()
	-- Setup the default options
	self:setGameOption(GAME_OPT_TEAM, GAME_OPT_TEAM_SHUFFLE)
	self:setGameOption(GAME_OPT_GAME, GAME_OPT_GAME_ROUNDS)
	self:setGameOption(GAME_OPT_WINC, GAME_OPT_WINC_ROUNDS)
	self:setGameOption(GAME_OPT_WINC_MAX, 11)
	self:setGameOption(GAME_OPT_NODRAWS, true)
	self:setGameOption(GAME_OPT_TEAMSCORE, false)
    self:setGameOption(GAME_OPT_CASH_ROUND, 10)
    self:setGameOption(GAME_OPT_CASH_START, 30)
    self:setGameOption(GAME_OPT_CASH_ROUND, 0)
    self:setGameOption(GAME_OPT_CASH_WIN, 0)
	
	CustomGameEventManager:RegisterListener("set_team", Dynamic_Wrap(self, "onSetTeam"))
	CustomGameEventManager:RegisterListener("set_game_option", Dynamic_Wrap(self, "onSetGameOption"))
	CustomGameEventManager:RegisterListener("start_game", Dynamic_Wrap(self, "onStartGame"))

	print("UI initialized")
end

function UserInterface:onSetTeam(args)
	print("onSetTeam called")
	DeepPrintTable(args)
	
    local player_id = args.PlayerID

    -- TODO: Verify host for dedicated server correctly
    if GetListenServerHost():GetPlayerID() ~= player_id then
        log("Non-host tried to set teams")
        return
    end

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

    local player_id = args.PlayerID

    -- TODO: Verify host for dedicated server correctly
    if GetListenServerHost():GetPlayerID() ~= player_id then
        log("Non-host tried to set game option")
        return
    end

	local index = args.index
	local value = args.value

    GAME.user_interface:setGameOption(index, value)
end

function UserInterface:setGameOption(index, value)
    CustomNetTables:SetTableValue("wl_game_options", tostring(index), { value = value })
end

function UserInterface:getGameOption(index)
    print("NetTable", index, CustomNetTables:GetTableValue("wl_game_options", tostring(index)))
    return CustomNetTables:GetTableValue("wl_game_options", tostring(index)).value
end

------------------------
-- Game Interface
------------------------

function Game:initUserInterface()
	self.user_interface = UserInterface:new()
end

-- Select the modes
function Game:selectModes()
	local ui = self.user_interface
	
	self.team_mode = GAME_OPT_TEAM_MODES[ui:getGameOption(GAME_OPT_TEAM)]:new {
		
	}
	
	local win_cond = GAME_OPT_WIN_CONDS[ui:getGameOption(GAME_OPT_WINC)]:new {
		detect_early_end = false,
		no_draws = ui:getGameOption(GAME_OPT_NODRAWS),
		use_team_score = ui:getGameOption(GAME_OPT_TEAMSCORE),
		max_score = ui:getGameOption(GAME_OPT_WINC_MAX),
		round_count = ui:getGameOption(GAME_OPT_WINC_MAX)
	}
	
	self.mode = GAME_OPT_GAME_MODES[ui:getGameOption(GAME_OPT_GAME)]:new {
		win_condition = win_cond,
        cash_every_round = ui:getGameOption(GAME_OPT_CASH_ROUND),
        cash_on_start = ui:getGameOption(GAME_OPT_CASH_START),
        cash_per_kill = ui:getGameOption(GAME_OPT_CASH_KILL),
        cash_per_win = ui:getGameOption(GAME_OPT_CASH_WIN)
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
