var g_PlayerPanels = [];
var g_PlayerIds = [];
var g_PlayerCount = 0;

function isHost() {
    var player = Game.GetLocalPlayerInfo();
    
    if(!player)
    {
        return false;
    }

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
    for(var i = 0; i < g_PlayerCount; i++) {
        var root = g_PlayerPanels[i];
        var teamDropDown = root.FindChildTraverse("#TeamDropDown");
        teamDropDown.enabled = enable;
    }
}

function setupSelection() {
    Game.SetAutoLaunchEnabled(false);
    Game.SetRemainingSetupTime(100000);
    Game.SetTeamSelectionLocked(true);
}

setupSelection();
playerSelectLoop();

function sendSetTeamMode(newTeamMode) {
	//TODO: convert team mode string to int
	GameEvents.SendCustomGameEventToServer("set_team_mode", { "new_team_mode": newTeamMode });
}

/* -------------

     Events

---------------*/

function onTeamModeChanged() {
    var dropDown = $("#TeamModeDropDown");
	var newTeamMode = dropDown.GetSelected().text
    var teamSelectionEnabled = newTeamMode == "Teams";
    enableTeamSelection(teamSelectionEnabled);
	
	sendSetTeamMode(newTeamMode);
}

function onModeChanged() {

}

function onStartGame() {
    if(isHost()) {
        Game.SetRemainingSetupTime(0);
    }
}
