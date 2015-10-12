var g_IsHost = false;

var g_PlayerPanels = [];
var g_PlayerIds = [];
var g_PlayerCount = 0;

var g_SelectedTab = 0;
var g_TabContainers = [];

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
var GAME_OPT_BOT_COUNT  = 11;
var GAME_OPT_BOT_ON_DC  = 12;
var GAME_OPT_LAVA_DPS	= 13;
var GAME_OPT_KB_MULT	= 14;
var GAME_OPT_DMG_MULT	= 15;
var GAME_OPT_PHYS_FRICT	= 16;

var g_TextBoxIntIds = {
	4: "#WinCondMaxText",
	7: "#RoundGoldText",
	8: "#StartGoldText",
	9: "#KillGoldText",
	10: "#WinGoldText",
	11: "#BotCountText"
};

var g_TextBoxFloatIds = {
	13: "#LavaDPSText",
	14: "#KnockbackMultiplierText",
	15: "#DamageMultiplierText",
	16: "#PhysicsFrictionText"
};

var g_DropDownIntIds = {
	1: { id: "#TeamModeDropDown", values: [ "Shuffle", "FFA", "Teams" ], valueIdPrefix: "TeamMode" },
	2: { id: "#ModeDropDown", values: ["Rounds", "Deathmatch" ], valueIdPrefix: "Mode" },
	3: { id: "#WinConditionDropDown", values: [ "Rounds", "Score" ], valueIdPrefix: "WinCondition" }
};

var g_ToggleButtonIntIds = {
	12: "#BotOnDC"
};

//Enables or disables all controls
function enableAll(enable) {
	for(var index in g_TextBoxIntIds) {
		$(g_TextBoxIntIds[index]).enabled = enable;
	}
	
	for(var index in g_DropDownIntIds) {
		$(g_DropDownIntIds[index].id).enabled = enable;
	}
	
	for(var index in g_ToggleButtonIntIds) {
		$(g_ToggleButtonIntIds[index]).enabled = enable;
		
		//TEMP: checked gets set to false when disabling
		if(enable) {
			$(g_ToggleButtonIntIds[index]).checked = true;
		}
	}
	
	$("#StartButton").enabled = enable;
}

//Checks whether we are past game setup or not
function isGameSetup() {
	return Game.GameStateIsBefore(DOTA_GameState.DOTA_GAMERULES_STATE_HERO_SELECTION);
}

//Adds all new players to the player list and creates a panel for them
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

//Finds the new players periodically
function playerSelectLoop() {
	addNewPlayers();
	if(isGameSetup()) {
		$.Schedule(0.5, playerSelectLoop);
	}
}

//Sends a set game option event
function sendSetGameOption(index, value) {
	GameEvents.SendCustomGameEventToServer("set_game_option", { "index": index, "value": value });
}

/* -------------
      
   Send Functions
   
----------------- */

//Sends the value of a text box
function sendTextBoxIntValue(index, textBoxId) {
	index = parseInt(index);
	var textBox = $(textBoxId);

	//Floor
	var n = ~~textBox.text;
	
	if(String(n) === textBox.text && n >= 0) {
		sendSetGameOption(index, n);
	} else {
		$.Msg("in sendTextBoxIntValue: was not a positive integer for index ", index, " and box id ", textBoxId);
	}
}

function sendTextBoxFloatValue(index, textBoxId) {
	index = parseInt(index);
	var textBox = $(textBoxId);

	var n = parseFloat(textBox.text);

	sendSetGameOption(index, n);
}

//Sends the value of a drop down
function sendDropDownIntValue(index, dropDownId) {
	index = parseInt(index);
	var dropDown = $(dropDownId);
	var newValue = dropDown.GetSelected().text;
	var valueList = g_DropDownIntIds[index].values;
	
	sendSetGameOption(index, valueList.indexOf(newValue)+1);
}

//Sends the values of all drop downs
function sendDropDownValues() {
	for(var index in g_DropDownIntIds) {
		sendDropDownIntValue(index, g_DropDownIntIds[index].id);
	}
}

//Send the text box values every few seconds
function sendTextBoxValues() {
	for(var index in g_TextBoxIntIds) {
		sendTextBoxIntValue(index, g_TextBoxIntIds[index]);
	}

	for(var index in g_TextBoxFloatIds) {
		sendTextBoxFloatValue(index, g_TextBoxFloatIds[index]);
	}
	
	//Call again even if not the host, because the host can be changed later
	if(isGameSetup()) {
		$.Schedule(1.0, sendTextBoxValues);
	}
}

function sendToggleButtonValue(index, toggleButtonId) {
	var toggleButton = $(toggleButtonId);
		
	var value = toggleButton.checked ? 1 : 0;
	
	$.Msg("Toggle Value:", value);
	
	sendSetGameOption(index, value);
}

//Sends the values of all toggle buttons
function sendToggleButtonValues() {
	for(var index in g_ToggleButtonIntIds) {
		sendToggleButtonValue(index, g_ToggleButtonIntIds[index])
	}
}

/* -------------

     Events

---------------*/

//Called when the host was detected in the loop
function onHostDetected() {
	enableAll(true);
	
	$("#HostLabel").text = $.Localize("#WL_setup_you_are_host") + "\n\n" + $.Localize("#WL_setup_choose_settings");
	
	if(isGameSetup()) {
		sendTextBoxValues();
		sendDropDownValues();
		sendToggleButtonValues();
	}
}

//Called when a drop down value changes
function onDropDownValueChanged() {
	//Send the values of all dropdowns to the server when it changes
	if(g_IsHost) {
		sendDropDownValues();
	}
}

//Called when a toggle button value changes
function onToggleButtonValueChanged() {
	if (g_IsHost) {
		sendToggleButtonValues();
	}
}

//Called when the score net table changes
function onNetTableChanged(tableName, key, data) {
	if(tableName != "wl_game_options") {
		$.Msg("Selection UI received non game options net table update");
		return;
	}
	
	//Only update clients' values
	if(g_IsHost) {
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
		dropDown.SetSelected(selectedId);
	}
	
	//Set the toggle button value
	if(index in g_ToggleButtonIntIds) {
		var toggleButtonId = g_ToggleButtonIntIds[index];
		var toggleButton = $(toggleButtonId);
		toggleButton.checked = value != 0 ? true : false;
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

//Called when the start game button was pressed
function onStartGame() {
    if(g_IsHost) {
		sendTextBoxValues(); //Send the text box's values before the game started
        Game.SetRemainingSetupTime(0);
    }
}

//Check if we are the host every second
function hostCheckLoop() {
	if(!isGameSetup()) {
		return;
	}
	
	if(!g_IsHost) {
		var player = Game.GetLocalPlayerInfo();

		if(player) {
			if(player.player_has_host_privileges) {
				g_IsHost = true;
				$.Msg("Host detected!");
				onHostDetected();
				return;
			}
		}
	}
	
	$.Schedule(1.0, hostCheckLoop);
}

//Sets one specified tab to be visible
function selectTab(tabNum) {
	g_SelectedTab = tabNum;
	for(var num in g_TabContainers) {
		g_TabContainers[num].visible = num == tabNum;
	}
}

function setupSelection() {
	//GameEvents.Subscribe("dota_team_player_list_changed", onTeamChanged);
	CustomNetTables.SubscribeNetTableListener("wl_game_options", onNetTableChanged);
    Game.SetAutoLaunchEnabled(false);
    Game.SetRemainingSetupTime(60);
    Game.SetTeamSelectionLocked(true);
	
	enableAll(false);
	
	//Setup the tabs
	g_TabContainers.push($("#TabContainer1"));
	g_TabContainers.push($("#TabContainer2"));
	selectTab(0);

	hostCheckLoop();
	playerSelectLoop();
}

setupSelection();