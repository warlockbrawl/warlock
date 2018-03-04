var g_PlayerPanels = [];
var g_PlayerIds = [];
var g_PlayerCount = 0;

var g_ScoreBoard;

function addNewPlayers() {
	var playerListRoot = $("#ScorePlayerList");
	
	var playerIds = Game.GetAllPlayerIDs();

	for(var playerId of playerIds) {
		if(g_PlayerIds.indexOf(playerId) == -1) {
			var playerNode = $.CreatePanel("Panel", playerListRoot, "");
			playerNode.AddClass("ScorePlayer");
			playerNode.SetAttributeInt("player_id", playerId);
			playerNode.BLoadLayout("file://{resources}/layout/custom_game/warlock_scoreboard_player.xml", false, false);

			g_PlayerPanels.push(playerNode);
			g_PlayerIds.push(playerId);
			g_PlayerCount++;
		}
	}
}

function playerSelectLoop() {
	addNewPlayers();
	$.Schedule(1.0, playerSelectLoop);
}

function toggleScoreboard() {
	g_ScoreBoard.visible = !g_ScoreBoard.visible;
}

g_ScoreBoard = $("#ScorePlayerList");
g_ScoreBoard.visible = false;
playerSelectLoop();
