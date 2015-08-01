function ShopItems(shop) {
	ShopElement.call(this, shop);
	this.root = $("#ShopItems");
	this.createUI();
}

ShopItems.inherit(ShopElement);

//Sends a request to upgrade a specified mastery
ShopItems.prototype.sendBuyItem = function(itemName) {
	$.Msg("Sending buy item ", itemName);
	GameEvents.SendCustomGameEventToServer("shop_buy_item", { "name": itemName });
};

//Initially create the UI
ShopItems.prototype.createUI = function() {
	this.root.RemoveAndDeleteChildren();
	
	/*
	Creating XML hierarchy
	
	- Parent
	-- For each item: Buy Item Button
	--- Buy Item Label
	--- Buy Item Image
	*/
	
	for(var i = 0; i < this.shop.data.itemData.length; i++) {
		var item = this.shop.data.itemData[i];
		
		var self = this;
		
		//Create a function for upgrading the mastery
		var buyItemFunc = function(itemName) {
			return function() {
				self.sendBuyItem(itemName);
			}
		}(item.name);

		var showTooltipFunc = makeTooltipFunction(item.name, item.description);
		
		var itemButton = $.CreatePanel("Button", this.root, "");
		itemButton.AddClass("ShopBuyItemButton");
		itemButton.SetPanelEvent("onactivate", buyItemFunc);
		itemButton.SetPanelEvent("onmouseover", showTooltipFunc);
		
		var itemLabel = $.CreatePanel("Label", itemButton, "");
		itemLabel.AddClass("ShopBuyItemLabel");
		itemLabel.text = item.buyCost;
		
		var itemImage = $.CreatePanel("Image", itemButton, "");
		itemImage.AddClass("ShopBuyItemImage");
		itemImage.SetImage(item.iconPath);
	}
};