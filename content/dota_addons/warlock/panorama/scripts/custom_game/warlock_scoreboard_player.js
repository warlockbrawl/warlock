var g_PlayerId;
var g_PlayerInfo;
var g_PanelKills;
var g_PanelDeaths;
var g_PanelScore;
var g_PanelDamage;

function update() {
	var kills = Players.GetKills(g_PlayerId);
	var deaths = Players.GetDeaths(g_PlayerId);
	var score = 0; //TODO: Get from nettable
	var damage = 0;
	
	g_PanelKills.text = kills.toString();
	g_PanelDeaths.text = deaths.toString();
	g_PanelScore.text = score.toString();
	g_PanelDamage.text = damage.toString();
	
	$.Schedule(1.0, update);
}

(function() {
	var rootPanel = $.GetContextPanel();
	
	g_PlayerId = rootPanel.GetAttributeInt("player_id", -1);
	g_PlayerInfo = Game.GetPlayerInfo(g_PlayerId);

	if(!g_PlayerInfo) {
		$.Msg("PlayerInfo was null in scoreboard");
		return;
	}
		
	$("#PlayerAvatar").steamid = g_PlayerInfo.player_steamid;
	$("#PlayerName").steamid = g_PlayerInfo.player_steamid;
	
	g_PanelKills = $("#ScoreKills");
	g_PanelDeaths = $("#ScoreDeaths");
	g_PanelScore = $("#ScoreScore");
	g_PanelDamage = $("#ScoreDamage");
	
	update();
})();