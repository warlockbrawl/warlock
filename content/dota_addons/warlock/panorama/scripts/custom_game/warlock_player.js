var g_PlayerId;
var g_PlayerInfo;

//Unassigned, GoodGuys, BadGuys, Custom1 - Custom8 (# = 13)
var g_DotaTeamList = [ 5, 2, 3, 6, 7, 8, 9, 10, 11, 12, 13 ];

function getUITeam() {
	var root = $.GetContextPanel();
	var dropDown = root.FindChildTraverse("#TeamDropDown");
	var selectedText = dropDown.GetSelected().id;
	return g_DotaTeamList[parseInt(selectedText.substring(4))];
}

function sendSetTeam(playerId, newTeam) {
	GameEvents.SendCustomGameEventToServer("set_team", { "player_id": playerId, "new_team_id": newTeam });
	$.Msg("Sent set team for", playerId, "to", newTeam);
}

function onPlayerTeamChanged() {
	var uiTeam = getUITeam();
	sendSetTeam(g_PlayerId, uiTeam);
}

(function() {
	var rootPanel = $.GetContextPanel();
	
	g_PlayerId = rootPanel.GetAttributeInt("player_id", -1);
	g_PlayerInfo = Game.GetPlayerInfo(g_PlayerId);
	if(!g_PlayerInfo) {
		$.Msg("PlayerInfo was null");
		return;
	}
		
	$("#PlayerAvatar").steamid = g_PlayerInfo.player_steamid;
	$("#PlayerName").steamid = g_PlayerInfo.player_steamid;
})();