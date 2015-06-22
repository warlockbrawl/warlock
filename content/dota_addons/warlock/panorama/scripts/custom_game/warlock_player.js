(function() {
	var rootPanel = $.GetContextPanel();
	
	var playerId = rootPanel.GetAttributeInt("player_id", -1);
	var playerInfo = Game.GetPlayerInfo(playerId);
	if(!playerInfo) {
		$.Msg("PlayerInfo was null");
		return;
	}
		
	$("#PlayerAvatar").steamid = playerInfo.player_steamid;
	$("#PlayerName").steamid = playerInfo.player_steamid;
})();