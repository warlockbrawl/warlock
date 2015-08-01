var g_Shop;
var g_ShopRoot;
var g_ShopElements;
var g_ShopLabel;
var g_ShopTooltip;

function onUpgradeAllMasteriesClicked() {
	g_Shop.masteries.sendUpgradeAllMasteries();
}

function toggleShop() {
	g_ShopElements.visible = !g_ShopElements.visible;
	g_ShopTooltip.visible = g_ShopElements.visible;
	if(g_ShopElements.visible) {
		g_ShopLabel.text = $.Localize("#WL_shop_close");
	} else {
		g_ShopLabel.text = $.Localize("#WL_shop_open");
	}
}

function shopInitialize() {
	g_ShopRoot = $.GetContextPanel();
	g_Shop = new Shop(g_ShopRoot);
	g_ShopElements = $("#ShopElements");
	g_ShopTooltip = $("#ShopTooltip");
	g_ShopLabel = $("#ShopLabel");
}

(function() {
	shopInitialize();
})();
