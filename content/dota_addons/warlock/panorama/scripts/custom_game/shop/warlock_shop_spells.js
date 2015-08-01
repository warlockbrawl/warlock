function ShopSpells(shop) {
	ShopElement.call(this, shop);
	
	this.spellColumnPanels = [];
	this.spellColumnLevelPanels = [];
	this.spellCostLabels = [];
	this.root = $("#ShopSpells");
	
	this.createUI();
	
	var self = this;
	
	var spellColumnInfoFunc = function() {
		return function(eventData) {
			self.onSpellColumnInfo(eventData);
		}
	}();
	
	GameEvents.Subscribe("shop_spell_column_info", spellColumnInfoFunc);
	
	this.sendSpellInfoRequest();
}

ShopSpells.inherit(ShopElement);

ShopSpells.prototype.onSpellColumnInfo = function(eventData) {
	$.Msg("onSpellColumnInfo received: ", eventData);
	
	if(!eventData.spell_name || !eventData.level) {
		$.Msg("Doing nothing");
		//Column is empty, keep everything as is (no reseting implemented yet)
	} else {
		$.Msg("with spell name and level");
		
		//Column has spell
		if(!this.spellColumnLevelPanels[eventData.column-1]) {
			this.spellColumnChoose(eventData.column, eventData.spell_name);
		}
		
		this.setColumnUILevel(eventData.column, eventData.level);
		
		var spell = this.shop.data.getSpellData(eventData.spell_name);
		
		//Set the upgrade cost text
		if(eventData.level - 1 < spell.upgradeCost.length) {
			this.spellCostLabels[eventData.column-1].text = spell.upgradeCost[eventData.level-1];
		} else {
			this.spellCostLabels[eventData.column-1].text = "";
		}
	}
};

//Sets the level indicator of a mastery to a specified level
ShopSpells.prototype.setColumnUILevel = function(column, level) {
	setLevelPanelsLevel(this.spellColumnLevelPanels[column-1], level);
};

ShopSpells.prototype.sendBuySpell = function sendBuySpell(spellName) {
	$.Msg("Sent buy spell ", spellName);
	GameEvents.SendCustomGameEventToServer("shop_buy_spell", { "name": spellName });
};

ShopSpells.prototype.sendUpgradeSpell = function(column) {
	$.Msg("Sent upgrade spell for column ", column);
	GameEvents.SendCustomGameEventToServer("shop_upgrade_spell", { "column": column });
};

//Sends a request to receive mastery information (levels)
ShopSpells.prototype.sendSpellInfoRequest = function() {
	$.Msg("Sending spell info request");
	GameEvents.SendCustomGameEventToServer("shop_spell_info_request", { });
};

ShopSpells.prototype.createUI = function() {
	this.root.RemoveAndDeleteChildren();
	
	for(var i = 0; i < 6; i++) {
		var column = i + 1; //The column indexing starts at 1
		
		var columnContainer = $.CreatePanel("Panel", this.root, "");
		columnContainer.AddClass("ShopSpellColumn");
		
		this.spellColumnPanels[i] = columnContainer;
		
		var columnSpells = this.shop.data.getColumnSpellData(column);
		
		/*
		Creating XML hierarchy
		
		- Parent
		-- Buy Spell Container
		--- Spell Column Header Label
		--- For each Spell: Buy Spell Button (ID: #Buy<SpellName>Button)
		---- Buy Spell Label
		---- Buy Spell Image
		*/
		
		var columnHeader = $.CreatePanel("Label", columnContainer, "");
		columnHeader.text = column.toString();
		columnHeader.AddClass("ShopSpellColumnHeader");
		
		$.Msg("Found ", columnSpells.length, " spells in column " , column);
		
		for(var j = 0; j < columnSpells.length; j++) {
			var spell = columnSpells[j];
			
			var self = this;
			
			var buySpellFunc = function(spellName) {
				return function() {
					self.sendBuySpell(spellName);
				}
			}(spell.name);
			
			var showTooltipFunc = makeTooltipFunction(spell.name, spell.description);
			
			var spellContainer = $.CreatePanel("Panel", columnContainer, "");
			spellContainer.AddClass("ShopBuySpellContainer");
			
			var spellButton = $.CreatePanel("Panel", spellContainer, "Buy" + spell.name + "Button");
			spellButton.AddClass("ShopBuySpellButton");
			spellButton.SetPanelEvent("onactivate", buySpellFunc);
			spellButton.SetPanelEvent("onmouseover", showTooltipFunc);
			
			var spellLabel = $.CreatePanel("Label", spellButton, "");
			spellLabel.AddClass("ShopBuySpellLabel");
			spellLabel.text = spell.buyCost;
			
			var spellImage = $.CreatePanel("Image", spellButton, "");
			spellImage.AddClass("ShopBuySpellImage");
			spellImage.SetImage(spell.iconPath);
		}
	}
};

ShopSpells.prototype.spellColumnChoose = function(column, spellName) {
	var parent = this.spellColumnPanels[column-1];
	
	parent.RemoveAndDeleteChildren();
	
	var spell = this.shop.data.getSpellData(spellName);
	
	/*
	Creating XML hierarchy
	
	- Parent
	-- Upgrade Spell Container
	--- Upgrade Spell Icon
	--- 7 Spell Levels
	--- Upgrade Spell Button
	---- Upgrade Spell Label
	---- Upgrade Spell Cost Label
	*/
	
	var upgradeSpellFunc = function(col) {
		return function() {
			self.sendUpgradeSpell(col);
		}
	}(column);
	
	var showTooltipFunc = makeTooltipFunction(spell.name, spell.description);
	
	var spellContainer = $.CreatePanel("Panel", parent, "");
	spellContainer.AddClass("ShopUpgradeSpellContainer");
	spellContainer.SetPanelEvent("onmouseover", showTooltipFunc);
	
	var spellIcon = $.CreatePanel("Image", spellContainer, "");
	spellIcon.AddClass("ShopUpgradeSpellIcon");
	spellIcon.SetImage(spell.iconPath);
	
	this.spellColumnLevelPanels[column-1] = addLevelPanels(spellContainer, 7);
	
	var self = this;

	var spellButton = $.CreatePanel("Button", spellContainer, "");
	spellButton.AddClass("ShopUpgradeSpellButton");
	spellButton.SetPanelEvent("onactivate", upgradeSpellFunc);
	
	var spellLabel = $.CreatePanel("Label", spellButton, "");
	spellLabel.AddClass("ShopUpgradeSpellLabel");
	spellLabel.text = "+";
	
	var spellCostLabel = $.CreatePanel("Label", spellButton, "");
	spellCostLabel.AddClass("ShopUpgradeSpellCostLabel");
	spellCostLabel.text = spell.upgradeCost[0];
	
	this.spellCostLabels[column-1] = spellCostLabel;
};
