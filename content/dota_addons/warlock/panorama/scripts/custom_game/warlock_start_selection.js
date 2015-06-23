var g_PlayerPanels = [];
var g_PlayerIds = [];
var g_PlayerCount = 0;

var g_TeamModes = [ "Teams", "FFA", "Shuffle" ];
var g_Modes = [ "Rounds" ];
var g_WinConditions = [ "Score", "Rounds" ];

function isHost() {
    var player = Game.GetLocalPlayerInfo();
    
    if(!player)
    {
        return false;
    }

	$.Msg("isHost: ", player.player_has_host_privileges);
	
    return player.player_has_host_privileges;
}

function addNewPlayers() {
	var playerListRoot = $("#PlayerList");
	
	var playerIds = Game.GetAllPlayerIDs();

	for(var playerId of playerIds) {
		if(g_PlayerIds.indexOf(playerId) == -1) {
			$.Msg("New player with id ", playerId);
			var playerNode = $.CreatePanel("Panel", playerListRoot, "");
			playerNode.AddClass("Player");
			playerNode.SetAttributeInt("player_id", playerId);
			playerNode.SetAttributeInt("player_team", g_PlayerCount+1); //Assign the next team to the player
			playerNode.BLoadLayout("file://{resources}/layout/custom_game/warlock_player.xml", false, false);

			g_PlayerPanels.push(playerNode);
			g_PlayerIds.push(playerId);
			g_PlayerCount++;
		}
	}
}

function updatePlayers() {
	
}

function playerSelectLoop() {
	addNewPlayers();
	updatePlayers();
	$.Schedule(0.5, playerSelectLoop);
}

//Enables or disables (grays out) the team selection on the players
function enableTeamSelection(enable) {
	if(isHost()) {
		for(var i = 0; i < g_PlayerCount; i++) {
			var root = g_PlayerPanels[i];
			var teamDropDown = root.FindChildTraverse("#TeamDropDown");
			teamDropDown.enabled = enable;
		}
	}
}

function setupSelection() {
    Game.SetAutoLaunchEnabled(false);
    Game.SetRemainingSetupTime(40);
    Game.SetTeamSelectionLocked(true);
}

setupSelection();
playerSelectLoop();

function sendSetGameOption(index, value) {
	GameEvents.SendCustomGameEventToServer("set_game_option", { "index": index, "value": value });
}

/* -------------

     Events

---------------*/

function onTeamModeChanged() {
	if(isHost()) {
		var dropDown = $("#TeamModeDropDown");
		var newTeamMode = dropDown.GetSelected().text;

		sendSetGameOption(1, g_TeamModes.indexOf(newTeamMode)+1);
		
		var teamSelectionEnabled = newTeamMode == "Teams";
		enableTeamSelection(teamSelectionEnabled);
	}
}

function onModeChanged() {
	if(isHost()) {
		var dropDown = $("#ModeDropDown");
		var newMode = dropDown.GetSelected().text;
		
		sendSetGameOption(2, g_Modes.indexOf(newMode)+1);
	}
}

function onWinConditionChanged() {
	if(isHost()) {
		var dropDown = $("#WinConditionDropDown");
		var newWinCondition = dropDown.GetSelected().text;
		
		sendSetGameOption(3, g_WinConditions.indexOf(newWinCondition)+1);
	}
}

function onWinCondMaxChanged() {
	if(isHost()) {
		var winCondMaxText = $("#WinCondMaxText");

		var n = ~~winCondMaxText.text;
		
		if(String(n) === winCondMaxText.text && n >= 0) {
			sendSetGameOption(4, n);
		} else {
			$.Msg("Win Cond Max was not a positive integer", winCondMaxText.team);
		}
	}
}

function onStartGame() {
    if(isHost()) {
		onWinCondMaxChanged(); //Update it manually before starting since it only updates on submits
        Game.SetRemainingSetupTime(0);
    }
}
