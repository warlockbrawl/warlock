function ShopMasteries(shop) {
	ShopElement.call(this, shop);
	
	this.masteryLevelPanels = [];
	this.root = $("#ShopMasteries");
	this.createUI();
	
	var self = this;
	
	var masteryInfoFunc = function() {
		return function(eventData) {
			self.onMasteryInfo(eventData);
		}
	}();
	
	GameEvents.Subscribe("shop_mastery_info", masteryInfoFunc);
	
	this.sendMasteryInfoRequest();
}

ShopMasteries.inherit(ShopElement);

//Called when a mastery info was received, updates the UI levels
ShopMasteries.prototype.onMasteryInfo = function(eventData) {
	$.Msg("On mastery info received");
	for(var i = 1; i < 4; i++) {
		this.setUILevel(i-1, eventData.levels[i]);
	}
};

//Sends a request to upgrade a specified mastery
ShopMasteries.prototype.sendUpgradeMastery = function(masteryName) {
	$.Msg("Sending upgrade mastery ", masteryName);
	GameEvents.SendCustomGameEventToServer("shop_upgrade_mastery", { "name": masteryName });
};

//Sends a request to upgrade all masteries
ShopMasteries.prototype.sendUpgradeAllMasteries = function() {
	$.Msg("Sending upgrade all masteries");
	GameEvents.SendCustomGameEventToServer("shop_upgrade_all_masteries", { });
};

//Sends a request to receive mastery information (levels)
ShopMasteries.prototype.sendMasteryInfoRequest = function() {
	$.Msg("Sending mastery info request");
	GameEvents.SendCustomGameEventToServer("shop_mastery_info_request", { });
};

//Sets the level indicator of a mastery to a specified level
ShopMasteries.prototype.setUILevel = function(masteryIndex, level) {
	setLevelPanelsLevel(this.masteryLevelPanels[masteryIndex], level);
};

//Initially create the UI
ShopMasteries.prototype.createUI = function() {
	this.root.RemoveAndDeleteChildren();
	
	for(var i = 0; i < 3; i++) {
		var mastery = this.shop.data.masteryData[i];
		
		var self = this;
		
		//Create a function for upgrading the mastery
		var upgradeFunc = function(masteryName) {
			return function() {
				self.sendUpgradeMastery(masteryName);
			}
		}(mastery.name);
		
		var showTooltipFunc = makeTooltipFunction(mastery.name, mastery.description);
		
		/*
		Creating XML hierarchy
		
		- Parent
		-- For each mastery: Upgrade Mastery Container
		--- Upgrade Mastery Icon
		--- 7 Mastery Levels
		--- Upgrade Mastery Button
		---- Upgrade Mastery Label
		*/
		
		var masteryContainer = $.CreatePanel("Panel", this.root, "");
		masteryContainer.AddClass("ShopUpgradeMasteryContainer");
		masteryContainer.SetPanelEvent("onmouseover", showTooltipFunc);
		
		var masteryIcon = $.CreatePanel("Image", masteryContainer, "");
		masteryIcon.AddClass("ShopUpgradeMasteryIcon");
		masteryIcon.SetImage(mastery.iconPath);
		
		this.masteryLevelPanels[i] = addLevelPanels(masteryContainer, 6);
		
		var masteryButton = $.CreatePanel("Button", masteryContainer, "");
		masteryButton.AddClass("ShopUpgradeMasteryButton");
		masteryButton.SetPanelEvent("onactivate", upgradeFunc);
		
		var masteryLabel = $.CreatePanel("Label", masteryButton, "");
		masteryLabel.AddClass("ShopUpgradeMasteryLabel");
		masteryLabel.text = "+";
	}
};