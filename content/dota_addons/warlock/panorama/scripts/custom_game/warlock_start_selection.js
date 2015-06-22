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
	
	$.Msg(playerIds);

	for(var playerId of playerIds) {
		$.Msg("Player", playerId);
		
		if(g_PlayerIds.indexOf(playerId) == -1) {
			$.Msg("New player");
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
    Game.SetRemainingSetupTime(40);
    Game.SetTeamSelectionLocked(true);
}

setupSelection();
playerSelectLoop();

/* -------------

     Events

---------------*/

function onTeamModeChanged() {
    var dropDown = $("#TeamModeDropDown");
    var teamSelectionEnabled = dropDown.GetSelected().text == "Teams";
    enableTeamSelection(teamSelectionEnabled);
}

function onStartGame() {
    if(isHost()) {
        Game.SetRemainingSetupTime(0);
    }
}