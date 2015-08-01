function Shop(root) {
	this.root = root;
	this.data = new ShopData();
	this.masteries = new ShopMasteries(this);
	this.spells = new ShopSpells(this);
	this.items = new ShopItems(this);
}

function ShopElement(shop) {
	this.shop = shop;
}