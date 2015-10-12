-- Game Setup class, handles initial game setup with UI

GameSetup = class()

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
GAME_OPT_BOT_COUNT  = 11
GAME_OPT_BOT_ON_DC  = 12
GAME_OPT_LAVA_DPS	= 13
GAME_OPT_KB_MULT	= 14
GAME_OPT_DMG_MULT	= 15
GAME_OPT_PHYS_FRICT	= 16

GAME_OPT_TEAM_SHUFFLE	= 1
GAME_OPT_TEAM_FFA		= 2
GAME_OPT_TEAM_DEFAULT	= 3

GAME_OPT_GAME_ROUNDS	    = 1
GAME_OPT_GAME_DEATHMATCH    = 2

GAME_OPT_WINC_ROUNDS	= 1	
GAME_OPT_WINC_SCORE		= 2

GAME_OPT_TEAM_MODES = {
    TeamModeShuffle,
    TeamModeFFA,
	TeamMode,
}

GAME_OPT_GAME_MODES = {
	ModeLTS,
    ModeDeathmatch
}

GAME_OPT_WIN_CONDS = {
    RoundWinCondition,
	ScoreWinCondition
}

function GameSetup:init()
	-- Setup the default options
	self:setGameOption(GAME_OPT_TEAM, GAME_OPT_TEAM_SHUFFLE)
	self:setGameOption(GAME_OPT_GAME, GAME_OPT_GAME_ROUNDS)
	self:setGameOption(GAME_OPT_WINC, GAME_OPT_WINC_ROUNDS)
	self:setGameOption(GAME_OPT_WINC_MAX, 11)
	self:setGameOption(GAME_OPT_NODRAWS, 0)
	self:setGameOption(GAME_OPT_TEAMSCORE, 0)
    self:setGameOption(GAME_OPT_CASH_ROUND, 10)
    self:setGameOption(GAME_OPT_CASH_START, 30)
    self:setGameOption(GAME_OPT_CASH_KILL, 0)
    self:setGameOption(GAME_OPT_CASH_WIN, 0)
    self:setGameOption(GAME_OPT_BOT_COUNT, 0)
    self:setGameOption(GAME_OPT_BOT_ON_DC, 1)
    self:setGameOption(GAME_OPT_LAVA_DPS, 100)
    self:setGameOption(GAME_OPT_KB_MULT, 1)
    self:setGameOption(GAME_OPT_DMG_MULT, 1)
	self:setGameOption(GAME_OPT_PHYS_FRICT, 0.96)

	CustomGameEventManager:RegisterListener("set_team", Dynamic_Wrap(self, "onSetTeam"))
	CustomGameEventManager:RegisterListener("set_game_option", Dynamic_Wrap(self, "onSetGameOption"))

	print("Game Setup initialized")
end

function GameSetup:onSetTeam(args)
	print("onSetTeam called")
	DeepPrintTable(args)
	
    local player_id = args.PlayerID
    local player = PlayerResource:GetPlayer(player_id)

    if not player or not GameRules:PlayerHasCustomGameHostPrivileges(player) then
        log("Non-host tried to set teams")
        return
    end

	local source_player_id = args.PlayerID;
	local player_id = args.player_id
	local new_team_id = args.new_team_id
	PlayerResource:SetCustomTeamAssignment(player_id, new_team_id)
end

function GameSetup:onSetGameOption(args)
    --print("onSetGameOption called")
	--DeepPrintTable(args)

    local player_id = args.PlayerID
    local player = PlayerResource:GetPlayer(player_id)

    if not player or not GameRules:PlayerHasCustomGameHostPrivileges(player) then
        log("Non-host tried to set game option")
        return
    end

	local index = args.index
	local value = args.value

    GAME.game_setup:setGameOption(index, value)
end

function GameSetup:setGameOption(index, value)
    CustomNetTables:SetTableValue("wl_game_options", tostring(index), { value = value })
end

function GameSetup:getGameOption(index)
    print("NetTable", index, CustomNetTables:GetTableValue("wl_game_options", tostring(index)))
    return CustomNetTables:GetTableValue("wl_game_options", tostring(index)).value
end

------------------------
-- Game Interface
------------------------

function Game:initGameSetup()
	self.game_setup = GameSetup:new()
end

-- Select the modes
function Game:selectModes()
	local gs = self.game_setup
	
    Config.bot_on_dc = gs:getGameOption(GAME_OPT_BOT_ON_DC) ~= 0
    Config.bot_count = gs:getGameOption(GAME_OPT_BOT_COUNT)

	self.team_mode = GAME_OPT_TEAM_MODES[gs:getGameOption(GAME_OPT_TEAM)]:new {
		
	}
	
	local win_cond = GAME_OPT_WIN_CONDS[gs:getGameOption(GAME_OPT_WINC)]:new {
		detect_early_end = false,
		no_draws = gs:getGameOption(GAME_OPT_TEAM) ~= GAME_OPT_TEAM_DEFAULT, --gs:getGameOption(GAME_OPT_NODRAWS) ~= 0,
		use_team_score = gs:getGameOption(GAME_OPT_TEAMSCORE) ~= 0,
		max_score = gs:getGameOption(GAME_OPT_WINC_MAX),
		round_count = gs:getGameOption(GAME_OPT_WINC_MAX)
	}
	
	self.mode = GAME_OPT_GAME_MODES[gs:getGameOption(GAME_OPT_GAME)]:new {
		win_condition = win_cond,
        cash_every_round = gs:getGameOption(GAME_OPT_CASH_ROUND),
        cash_on_start = gs:getGameOption(GAME_OPT_CASH_START),
        cash_per_kill = gs:getGameOption(GAME_OPT_CASH_KILL),
        cash_per_win = gs:getGameOption(GAME_OPT_CASH_WIN)
	}

    -- Constants
    Arena.DAMAGE_PER_SECOND = gs:getGameOption(GAME_OPT_LAVA_DPS)
    Config.kb_multiplier = gs:getGameOption(GAME_OPT_KB_MULT)
    Config.dmg_multiplier = gs:getGameOption(GAME_OPT_DMG_MULT)
    Config.FRICTION = gs:getGameOption(GAME_OPT_PHYS_FRICT)

    -- Send setup info to web api
    self.web_api:setMatchProperty("bot_on_dc", tostring(Config.bot_on_dc))
    self.web_api:setMatchProperty("bot_count", tostring(Config.bot_count))
    self.web_api:setMatchProperty("mode", tostring(gs:getGameOption(GAME_OPT_GAME)))
    self.web_api:setMatchProperty("team_mode", tostring(gs:getGameOption(GAME_OPT_TEAM)))
    self.web_api:setMatchProperty("winc", tostring(gs:getGameOption(GAME_OPT_WINC)))
    self.web_api:setMatchProperty("winc_max", tostring(gs:getGameOption(GAME_OPT_WINC_MAX)))
    self.web_api:setMatchProperty("cash_every_round", tostring(gs:getGameOption(GAME_OPT_CASH_ROUND)))
    self.web_api:setMatchProperty("cash_on_start", tostring(gs:getGameOption(GAME_OPT_CASH_START)))
    self.web_api:setMatchProperty("cash_per_kill", tostring(gs:getGameOption(GAME_OPT_CASH_KILL)))
    self.web_api:setMatchProperty("cash_per_win", tostring(gs:getGameOption(GAME_OPT_CASH_WIN)))
    self.web_api:setMatchProperty("lava_dps", tostring(gs:getGameOption(GAME_OPT_LAVA_DPS)))
    self.web_api:setMatchProperty("kb_mult", tostring(gs:getGameOption(GAME_OPT_KB_MULT)))
    self.web_api:setMatchProperty("dmg_mult", tostring(gs:getGameOption(GAME_OPT_DMG_MULT)))
    self.web_api:setMatchProperty("phys_frict", tostring(gs:getGameOption(GAME_OPT_PHYS_FRICT)))

	display("-- Modes have been selected")
	display("Mode: " .. self.mode:getDescription())
	display("Team Mode: " .. self.team_mode:getDescription())
	display("Win Condition: " .. self.mode.win_condition:getDescription())
	display("No draws: " .. tostring(win_cond.no_draws))
	
	self:addTask {
		time = 3.0,
		func = function()
			self:start()
		end
	}
end
