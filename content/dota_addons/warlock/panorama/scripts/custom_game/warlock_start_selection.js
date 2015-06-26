var g_PlayerPanels = [];
var g_PlayerIds = [];
var g_PlayerCount = 0;

var GAME_OPT_TEAM		= 1;
var GAME_OPT_GAME		= 2;
var GAME_OPT_WINC		= 3;
var GAME_OPT_WINC_MAX	= 4;
var GAME_OPT_NODRAWS	= 5;
var GAME_OPT_TEAMSCORE	= 6;
var GAME_OPT_CASH_ROUND = 7;
var GAME_OPT_CASH_START = 8;
var GAME_OPT_CASH_KILL  = 9;
var GAME_OPT_CASH_WIN   = 10;

var g_TextBoxIntIds = {
	4: "#WinCondMaxText",
	7: "#RoundGoldText",
	8: "#StartGoldText",
	9: "#KillGoldText",
	10: "#WinGoldText"
};

var g_DropDownIntIds = {
	1: { id: "#TeamModeDropDown", values: [ "Shuffle", "FFA", "Teams" ], valueIdPrefix: "TeamMode" },
	2: { id: "#ModeDropDown", values: ["Rounds" ], valueIdPrefix: "Mode" },
	3: { id: "#WinConditionDropDown", values: [ "Rounds", "Score" ], valueIdPrefix: "WinCondition" }
};

function isHost() {
    var player = Game.GetLocalPlayerInfo();
    
    if(!player)
    {
        return false;
    }

    return player.player_has_host_privileges;
}

function isGameSetup() {
	return Game.GameStateIsBefore(DOTA_GameState.DOTA_GAMERULES_STATE_HERO_SELECTION);
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

function playerSelectLoop() {
	addNewPlayers();
	if(isGameSetup()) {
		$.Schedule(0.5, playerSelectLoop);
	}
}

function enableAll(enable) {
	for(var index in g_TextBoxIntIds) {
		$(g_TextBoxIntIds[index]).enabled = enable;
	}
	
	for(var index in g_DropDownIntIds) {
		$(g_DropDownIntIds[index].id).enabled = enable;
	}
	
	$("#StartButton").enabled = enable;
}

function sendSetGameOption(index, value) {
	GameEvents.SendCustomGameEventToServer("set_game_option", { "index": index, "value": value });
}

/* -------------
      
   Send Functions
   
----------------- */

function sendTextBoxIntValue(index, textBoxId) {
	if(isHost()) {
		index = parseInt(index);
		var textBox = $(textBoxId);

		var n = ~~textBox.text;
		
		if(String(n) === textBox.text && n >= 0) {
			sendSetGameOption(index, n);
		} else {
			$.Msg("in sendTextBoxIntValue: was not a positive integer for index ", index, " and box id ", textBoxId);
		}
	}
}

function sendDropDownIntValue(index, dropDownId) {
	if(isHost()) {
		index = parseInt(index);
		var dropDown = $(dropDownId);
		var newValue = dropDown.GetSelected().text;
		var valueList = g_DropDownIntIds[index].values;
		
		sendSetGameOption(index, valueList.indexOf(newValue)+1);
	}
}

function sendDropDownValues() {
	for(var index in g_DropDownIntIds) {
		$.Msg("Index:", index);
		sendDropDownIntValue(index, g_DropDownIntIds[index].id);
	}
}

function sendTextBoxValues() {
	for(var index in g_TextBoxIntIds) {
		sendTextBoxIntValue(index, g_TextBoxIntIds[index]);
	}
}

/* -------------

     Events

---------------*/

//Send the text box values every few seconds
function onSendTextBoxValues() {
	if(isHost()) {
		$.Msg("Updating text box values");
		sendTextBoxValues();
		if(isGameSetup()) {
			$.Schedule(1.0, onSendTextBoxValues);
		}
	}
}

function onDropDownValueChanged() {
	//Send the values of all dropdowns to the server when it changes
	if(isHost()) {
		sendDropDownValues();
	}
}

function onNetTableChanged(tableName, key, data) {
	if(tableName != "wl_game_options") {
		$.Msg("Selection UI received non game options net table update");
		return;
	}
	
	//Only update clients' values
	if(isHost()) {
		return;
	}

	var index = parseInt(key);
	var value = data.value;
	
	//Set the text box text
	if(index in g_TextBoxIntIds) {
		var textBoxId = g_TextBoxIntIds[index];
		var textBox = $(textBoxId);
		textBox.text = value.toString();
	}
	
	//Set the selected dropdown item
	if(index in g_DropDownIntIds) {
		var dropDownId = g_DropDownIntIds[index].id;
		var dropDown = $(dropDownId);
		var prefix = g_DropDownIntIds[index].valueIdPrefix;
		var selectedId = prefix + g_DropDownIntIds[index].values[value-1];
		$.Msg("Selected ID: ", selectedId);
		dropDown.SetSelected(selectedId);
	}
}

//Called when a team of any player changes
/*function onTeamChanged() {
	if(isHost()) {
		return;
	}
	
	//Update all selected dropdown items of the teams
	for(var i = 0; i < g_PlayerCount; i++) {
		var playerId = g_PlayerIds[i];
		var panel = g_PlayerPanels[i];
		var teamId = Game.GetPlayerInfo(playerId).team;
		
		panel.FindChildTraverse("#TeamDropDown").SetSelected("team" + teamId.toString());
	}
}*/

function onStartGame() {
    if(isHost()) {
		sendTextBoxValues(); //Send the text box's values before the game started
        Game.SetRemainingSetupTime(0);
    }
}

function setupSelection() {
	//GameEvents.Subscribe("dota_team_player_list_changed", onTeamChanged);
	CustomNetTables.SubscribeNetTableListener("wl_game_options", onNetTableChanged);
    Game.SetAutoLaunchEnabled(false);
    Game.SetRemainingSetupTime(60);
    Game.SetTeamSelectionLocked(true);
	
	var host = isHost();
	$.Msg("Start host: ", host);
	if(host) {
		$("#HostLabel").text = "You are the host!\n\nChoose the settings and start the game within one minute.";
		
		onSendTextBoxValues();
	} else {
		enableAll(false);
	}
	
	playerSelectLoop();
}

(function() {
	$.Msg("Start host: started");
	$.Schedule(1.0, setupSelection);
})();