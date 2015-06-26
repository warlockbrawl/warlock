var g_PlayerId;
var g_PlayerInfo;
var g_PanelKills;
var g_PanelDeaths;
var g_PanelScore;
var g_PanelDamage;

var g_Score = 0;
var g_Damage = 0;

function update() {
	//Get the kills and deaths via js
	var kills = Players.GetKills(g_PlayerId);
	var deaths = Players.GetDeaths(g_PlayerId);
	
	//Set the text of the panels
	g_PanelKills.text = kills.toString();
	g_PanelDeaths.text = deaths.toString();
	
	//Set the data received via net tables
	g_PanelScore.text = g_Score.toString();
	g_PanelDamage.text = g_Damage.toString();
	
	$.Schedule(1.0, update);
}

function onScoreTableChanged(tableName, key, data) {
	if(tableName != "wl_scoreboard") {
		$.Msg("Scoreboard UI received non scoreboard net table update");
		return;
	}
	
	//Check if the net table has a change for this player
	//Update the score and damage if it does
	if(g_PlayerId in data) {
		if(key == "Score") {
			g_Score = data[g_PlayerId];
		} else if(key == "Damage") {
			g_Damage = data[g_PlayerId];
		}
	}
}

(function() {
	var rootPanel = $.GetContextPanel();
	
	//Get the player id and its player info
	g_PlayerId = rootPanel.GetAttributeInt("player_id", -1);
	g_PlayerInfo = Game.GetPlayerInfo(g_PlayerId);

	if(!g_PlayerInfo) {
		$.Msg("PlayerInfo was null in scoreboard");
		return;
	}
	
	//Setup the steam avatar and name
	$("#ScoreAvatar").steamid = g_PlayerInfo.player_steamid;
	$("#ScoreName").steamid = g_PlayerInfo.player_steamid;
	
	//Grab some panels
	g_PanelKills = $("#ScoreKills");
	g_PanelDeaths = $("#ScoreDeaths");
	g_PanelScore = $("#ScoreScore");
	g_PanelDamage = $("#ScoreDamage");
	
	//Subscribe to the net table change event
	CustomNetTables.SubscribeNetTableListener("wl_scoreboard", onScoreTableChanged);
	
	update();
})();