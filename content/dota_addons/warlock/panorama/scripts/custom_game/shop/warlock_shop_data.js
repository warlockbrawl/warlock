function ShopData() {
	this.masteryData = [
		{ name: "Duration", iconPath: "file://{images}/spellicons/pugna_nether_blast_png.vtex", description: "#DOTA_Tooltip_ability_item_warlock_duration_mastery_Description" },
		{ name: "Lifesteal", iconPath: "file://{images}/spellicons/pugna_life_drain_png.vtex", description: "#DOTA_Tooltip_ability_item_warlock_life_steal_mastery_Description" },
		{ name: "Range", iconPath: "file://{images}/spellicons/pugna_nether_ward_png.vtex", description: "#DOTA_Tooltip_ability_item_warlock_range_mastery_Description" },
	];
	
	this.spellData = [
		// D 1
		{ name: "Boomerang", column: 1, buyCost: 11, upgradeCost: [ 7, 8, 9, 10, 11, 12 ], iconPath: "file://{images}/spellicons/bounty_hunter_shuriken_toss_png.vtex", description: "#DOTA_Tooltip_ability_warlock_boomerang_Description" },
		{ name: "Lightning", column: 1, buyCost: 11, upgradeCost: [ 8, 9, 10, 11, 12, 13 ], iconPath: "file://{images}/spellicons/lina_laguna_blade_png.vtex", description: "#DOTA_Tooltip_ability_warlock_lightning_Description" },
		{ name: "Homing", column: 1, buyCost: 11, upgradeCost: [ 8, 9, 10, 11, 12, 13 ], iconPath: "file://{images}/spellicons/puck_illusory_orb_png.vtex", description: "#DOTA_Tooltip_ability_warlock_homing_Description" },
		
		// R 2
		{ name: "Teleport", column: 2, buyCost: 12, upgradeCost: [ 6, 7, 8, 9, 10, 11 ], iconPath: "file://{images}/spellicons/rubick_telekinesis_png.vtex", description: "#DOTA_Tooltip_ability_warlock_teleport_Description" },
		{ name: "Thrust", column: 2, buyCost: 11, upgradeCost: [ 6, 7, 8, 9, 10, 11 ], iconPath: "file://{images}/spellicons/disruptor_glimpse_png.vtex", description: "#DOTA_Tooltip_ability_warlock_thrust_Description" },
		{ name: "Swap", column: 2, buyCost: 11, upgradeCost: [ 6, 7, 8, 9, 10, 11 ], iconPath: "file://{images}/spellicons/vengefulspirit_nether_swap_png.vtex", description: "#DOTA_Tooltip_ability_warlock_swap_Description" },
		
		// T 3
		{ name: "Cluster", column: 3, buyCost: 14, upgradeCost: [ 6, 7, 8, 9, 10, 11 ], iconPath: "file://{images}/spellicons/ember_spirit_searing_chains_png.vtex", description: "#DOTA_Tooltip_ability_warlock_cluster_Description" },
		{ name: "Drain", column: 3, buyCost: 14, upgradeCost: [ 6, 7, 8, 9, 10, 11 ], iconPath: "file://{images}/spellicons/necrolyte_death_pulse_png.vtex", description: "#DOTA_Tooltip_ability_warlock_drain_Description" },
		{ name: "Bouncer", column: 3, buyCost: 14, upgradeCost: [ 6, 7, 8, 9, 10, 11 ], iconPath: "file://{images}/spellicons/viper_poison_attack_png.vtex", description: "#DOTA_Tooltip_ability_warlock_bouncer_Description" },
		
		// E 4
		{ name: "Windwalk", column: 4, buyCost: 14, upgradeCost: [ 6, 7, 8, 9, 10, 11 ], iconPath: "file://{images}/spellicons/elder_titan_echo_stomp_spirit_png.vtex", description: "#DOTA_Tooltip_ability_warlock_windwalk_Description" },
		{ name: "Meteor", column: 4, buyCost: 14, upgradeCost: [ 6, 7, 8, 9, 10, 11 ], iconPath: "file://{images}/spellicons/invoker_chaos_meteor_png.vtex", description: "#DOTA_Tooltip_ability_warlock_meteor_Description" },
		{ name: "Splitter", column: 4, buyCost: 15, upgradeCost: [ 7, 8, 9, 10, 11, 12 ], iconPath: "file://{images}/spellicons/skywrath_mage_arcane_bolt_png.vtex", description: "#DOTA_Tooltip_ability_warlock_splitter_Description" },
		
		// C 5
		{ name: "Shield", column: 5, buyCost: 12, upgradeCost: [ 6, 7, 8, 9, 10, 11 ], iconPath: "file://{images}/spellicons/faceless_void_chronosphere_png.vtex", description: "#DOTA_Tooltip_ability_warlock_shield_Description" },
		{ name: "Rush", column: 5, buyCost: 12, upgradeCost: [ 6, 7, 8, 9, 10, 11 ], iconPath: "file://{images}/spellicons/ogre_magi_bloodlust_png.vtex", description: "#DOTA_Tooltip_ability_warlock_rush_Description" },
		{ name: "Alteration", column: 5, buyCost: 11, upgradeCost: [ 5, 6, 7, 8, 9, 10 ], iconPath: "file://none.vtex", description: "#DOTA_Tooltip_ability_warlock_alteration_Description" },
		
		// Y 6
		{ name: "Gravity", column: 6, buyCost: 12, upgradeCost: [ 7, 8, 9, 10, 11, 12 ], iconPath: "file://{images}/spellicons/enigma_black_hole_png.vtex", description: "#DOTA_Tooltip_ability_warlock_gravity_Description" },
		{ name: "Grip", column: 6, buyCost: 12, upgradeCost: [ 6, 7, 8, 9, 10, 11 ], iconPath: "file://{images}/spellicons/nevermore_shadowraze3_png.vtex", description: "#DOTA_Tooltip_ability_warlock_grip_Description" },
		{ name: "Warpzone", column: 6, buyCost: 12, upgradeCost: [ 6, 7, 8, 9, 10, 11 ], iconPath: "file://{images}/spellicons/antimage_spell_shield_png.vtex", description: "#DOTA_Tooltip_ability_warlock_warpzone_Description" },
		{ name: "Magnetize", column: 6, buyCost: 14, upgradeCost: [ 5, 6, 7, 8, 9, 10 ], iconPath: "file://{images}/spellicons/earth_spirit_magnetize_png.vtex", description: "#DOTA_Tooltip_ability_warlock_magnetize_Description" },
		{ name: "Rockpillar", column: 6, buyCost: 13, upgradeCost: [ 5, 6, 7, 8, 9, 10 ], iconPath: "file://{images}/spellicons/earth_spirit_rolling_boulder_png.vtex", description: "#DOTA_Tooltip_ability_warlock_rockpillar_Description" },
		{ name: "Link", column: 6, buyCost: 12, upgradeCost: [ 6, 7, 8, 9, 10, 11 ], iconPath: "file://{images}/spellicons/wisp_tether_png.vtex", description: "#DOTA_Tooltip_ability_warlock_link_Description" },
	];
	
	this.itemData =  [
		{ name: "Scourge", itemName: "item_warlock_scourge", buyCost: 7, maxLevel: 3, modDefs: [ {}, {}, {} ], iconPath: "file://{images}/spellicons/abaddon_borrowed_time_png.vtex", description: "#DOTA_Tooltip_ability_item_warlock_scourge_Description" },
		{ name: "Ring of Health", itemName: "item_warlock_ring_of_health", buyCost: 4, maxLevel: 5, modDefs: [ { hpBonus: 100 }, { hpBonus: 190 }, { hpBonus: 270 }, { hpBonus: 340 }, { hpBonus: 400 } ], iconPath: "file://{images}/items/ring_of_health_png.vtex", description: "#DOTA_Tooltip_ability_item_warlock_ring_of_health_Description" },
		{ name: "Cursed Ring", itemName: "item_warlock_cursed_ring", buyCost: 4, maxLevel: 2, modDefs: [ { hpBonus: 100, kbReduction: 0.15, debuffFactor: 0.25 }, { hpBonus: 200, kbReduction: 0.15, debuffFactor: 0.30 } ], iconPath: "file://{images}/items/ring_of_regen_png.vtex", description: "#DOTA_Tooltip_ability_item_warlock_cursed_ring_Description" },
		{ name: "Cape", itemName: "item_warlock_cape", buyCost: 3, maxLevel: 3, modDefs: [ { hp_regen: 2 }, { hp_regen: 3.5 }, { hp_regen: 4.5 } ], iconPath: "file://{images}/items/cloak_png.vtex", description: "#DOTA_Tooltip_ability_item_warlock_cape_Description" },
		{ name: "Armor", itemName: "item_warlock_armor", buyCost: 6, maxLevel: 3, modDefs: [ { kbReduction: 0.12 }, { kbReduction: 0.18 }, { kbReduction: 0.22 } ], iconPath: "file://{images}/items/assault_png.vtex", description: "#DOTA_Tooltip_ability_item_warlock_armor_Description" },
		{ name: "Boots", itemName: "item_warlock_boots", buyCost: 5, maxLevel: 3, modDefs: [ { speedBonusAbs: 18 }, { speedBonusAbs: 29 }, { speedBonusAbs: 40 } ], iconPath: "file://{images}/items/boots_png.vtex", description: "#DOTA_Tooltip_ability_item_warlock_boots_Description" },
		{ name: "Pocket Watch", itemName: "item_warlock_pocket_watch", buyCost: 2, modDefs: [ { debuffFactor: -0.35 }, { debuffFactor: -0.45 } ], iconPath: "file://{images}/items/talisman_of_evasion_png.vtex", description: "#DOTA_Tooltip_ability_item_warlock_pocket_watch_Description" },
	];
}

//Gets the spell data of all spells in a specified column
ShopData.prototype.getColumnSpellData = function(column) {
	var spells = [];
	
	for(var i = 0; i < this.spellData.length; i++) {
		if(this.spellData[i].column == column) {
			spells.push(this.spellData[i]);
		}
	}
	
	return spells;
};

ShopData.prototype.getSpellData = function(spellName) {
	for(var i = 0; i < this.spellData.length; i++) {
		if(this.spellData[i].name == spellName) {
			return this.spellData[i];
		}
	}
	
	$.Msg("Warning: Could not find spell data for spell with name ", spellName);
	
	return null;
};

ShopData.prototype.getItemData = function(itemName) {
	for(var i = 0; i < this.itemData.length; i++) {
		if(this.itemData[i].name == itemName) {
			return this.itemData[i];
		}
	}
	
	$.Msg("Warning: Could not find item data for item with name ", itemName);
	
	return null;
};
