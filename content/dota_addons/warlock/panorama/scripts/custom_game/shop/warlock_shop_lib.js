/* ---------------------
    
	     Utility
	
--------------------- */

function showTooltip(title, text) {
	$("#ShopTooltipTitle").text = title;
	if(text.startsWith("#")) {
		$("#ShopTooltipText").text = $.Localize(text);
	} else {
		$("#ShopTooltipText").text = text;
	}
}

function makeTooltipFunction(name, text) {
	return function() {
		showTooltip(name, text);
	}
}

function addLevelPanels(parent, count) {
	var levelPanels = []
	
	var container = $.CreatePanel("Panel", parent, "");
	container.AddClass("ShopLevelContainer");
	
	for(var i = 0; i < count; i++) {
		levelPanels[i] = $.CreatePanel("Panel", container, "");
		levelPanels[i].AddClass("ShopLevel");
	}
	
	return levelPanels;
}

function setLevelPanelsLevel(levelPanels, level) {
	for(var i = 0; i < levelPanels.length; i++) {
		levelPanels[i].SetHasClass("Active", i < level);
	}
}
