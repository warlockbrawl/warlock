function ShopData() {
	this.masteryData = [
		{ name: "Duration", iconPath: "file://{images}/spellicons/pugna_nether_blast_png.vtex", displayName: "#WL_shop_mastery_duration", description: "#WL_shop_mastery_duration_description" },
		{ name: "Range", iconPath: "file://{images}/spellicons/pugna_nether_ward_png.vtex", displayName: "#WL_shop_mastery_range", description: "#WL_shop_mastery_range_description" },
		{ name: "Lifesteal", iconPath: "file://{images}/spellicons/pugna_life_drain_png.vtex", displayName: "#WL_shop_mastery_life_steal", description: "#WL_shop_mastery_life_steal_description" },
	];
	
	this.spellData = [
		// D 1
		{ name: "Boomerang", column: 1, buyCost: 11, upgradeCost: [ 7, 8, 9, 10, 11, 12 ], iconPath: "file://{images}/spellicons/bounty_hunter_shuriken_toss_png.vtex", displayName: "#WL_shop_ability_boomerang", description: "#WL_shop_ability_boomerang_description" },
		{ name: "Lightning", column: 1, buyCost: 11, upgradeCost: [ 8, 9, 10, 11, 12, 13 ], iconPath: "file://{images}/spellicons/lina_laguna_blade_png.vtex", displayName: "#WL_shop_ability_lightning", description: "#WL_shop_ability_lightning_description" },
		{ name: "Homing", column: 1, buyCost: 11, upgradeCost: [ 8, 9, 10, 11, 12, 13 ], iconPath: "file://{images}/spellicons/puck_illusory_orb_png.vtex", displayName: "#WL_shop_ability_homing", description: "#WL_shop_ability_homing_description" },
		
		// R 2
		{ name: "Teleport", column: 2, buyCost: 12, upgradeCost: [ 6, 7, 8, 9, 10, 11 ], iconPath: "file://{images}/spellicons/rubick_telekinesis_png.vtex", displayName: "#WL_shop_ability_teleport", description: "#WL_shop_ability_teleport_description" },
		{ name: "Thrust", column: 2, buyCost: 11, upgradeCost: [ 6, 7, 8, 9, 10, 11 ], iconPath: "file://{images}/spellicons/disruptor_glimpse_png.vtex", displayName: "#WL_shop_ability_thrust", description: "#WL_shop_ability_thrust_description" },
		{ name: "Swap", column: 2, buyCost: 11, upgradeCost: [ 6, 7, 8, 9, 10, 11 ], iconPath: "file://{images}/spellicons/vengefulspirit_nether_swap_png.vtex", displayName: "#WL_shop_ability_swap", description: "#WL_shop_ability_swap_description" },
		
		// T 3
		{ name: "Cluster", column: 3, buyCost: 14, upgradeCost: [ 6, 7, 8, 9, 10, 11 ], iconPath: "file://{images}/spellicons/ember_spirit_searing_chains_png.vtex", displayName: "#WL_shop_ability_cluster", description: "#WL_shop_ability_cluster_description" },
		{ name: "Drain", column: 3, buyCost: 14, upgradeCost: [ 6, 7, 8, 9, 10, 11 ], iconPath: "file://{images}/spellicons/necrolyte_death_pulse_png.vtex", displayName: "#WL_shop_ability_drain", description: "#WL_shop_ability_drain_description" },
		{ name: "Bouncer", column: 3, buyCost: 14, upgradeCost: [ 6, 7, 8, 9, 10, 11 ], iconPath: "file://{images}/spellicons/viper_poison_attack_png.vtex", displayName: "#WL_shop_ability_bouncer", description: "#WL_shop_ability_bouncer_description" },
		{ name: "Recharge", column: 3, buyCost: 13, upgradeCost: [ 6, 7, 8, 9, 10, 11 ], iconPath: "file://{images}/spellicons/vengefulspirit_wave_of_terror_png.vtex", displayName: "#WL_shop_ability_recharge", description: "#WL_shop_ability_recharge_description" },

		// E 4
		{ name: "Windwalk", column: 4, buyCost: 14, upgradeCost: [ 6, 7, 8, 9, 10, 11 ], iconPath: "file://{images}/spellicons/elder_titan_echo_stomp_spirit_png.vtex", displayName: "#WL_shop_ability_windwalk", description: "#WL_shop_ability_windwalk_description" },
		{ name: "Meteor", column: 4, buyCost: 14, upgradeCost: [ 6, 7, 8, 9, 10, 11 ], iconPath: "file://{images}/spellicons/invoker_chaos_meteor_png.vtex", displayName: "#WL_shop_ability_meteor", description: "#WL_shop_ability_meteor_description" },
		{ name: "Splitter", column: 4, buyCost: 15, upgradeCost: [ 7, 8, 9, 10, 11, 12 ], iconPath: "file://{images}/spellicons/skywrath_mage_concussive_shot_png.vtex", displayName: "#WL_shop_ability_splitter", description: "#WL_shop_ability_splitter_description" },
		{ name: "Snowball", column: 4, buyCost: 14, upgradeCost: [ 6, 7, 8, 9, 10, 11 ], iconPath: "file://{images}/spellicons/tusk_snowball_png.vtex", displayName: "#WL_shop_ability_snowball", description: "#WL_shop_ability_snowball_description" },

		// C 5
		{ name: "Shield", column: 5, buyCost: 12, upgradeCost: [ 6, 7, 8, 9, 10, 11 ], iconPath: "file://{images}/spellicons/faceless_void_chronosphere_png.vtex", displayName: "#WL_shop_ability_shield", description: "#WL_shop_ability_shield_description" },
		{ name: "Rush", column: 5, buyCost: 12, upgradeCost: [ 6, 7, 8, 9, 10, 11 ], iconPath: "file://{images}/spellicons/ogre_magi_bloodlust_png.vtex", displayName: "#WL_shop_ability_rush", description: "#WL_shop_ability_rush_description" },
		{ name: "Alteration", column: 5, buyCost: 11, upgradeCost: [ 5, 6, 7, 8, 9, 10 ], iconPath: "file://{images}/spellicons/treant/fungal_protector_icons/treant_overgrowth_png.vtex", displayName: "#WL_shop_ability_alteration", description: "#WL_shop_ability_alteration_description" },
		
		// Y 6
		{ name: "Gravity", column: 6, buyCost: 12, upgradeCost: [ 7, 8, 9, 10, 11, 12 ], iconPath: "file://{images}/spellicons/enigma_black_hole_png.vtex", displayName: "#WL_shop_ability_gravity", description: "#WL_shop_ability_gravity_description" },
		{ name: "Grip", column: 6, buyCost: 12, upgradeCost: [ 6, 7, 8, 9, 10, 11 ], iconPath: "file://{images}/spellicons/nevermore_shadowraze3_png.vtex", displayName: "#WL_shop_ability_grip", description: "#WL_shop_ability_grip_description" },
		{ name: "Warpzone", column: 6, buyCost: 12, upgradeCost: [ 6, 7, 8, 9, 10, 11 ], iconPath: "file://{images}/spellicons/antimage_spell_shield_png.vtex", displayName: "#WL_shop_ability_warpzone", description: "#WL_shop_ability_warpzone_description" },
		{ name: "Magnetize", column: 6, buyCost: 14, upgradeCost: [ 5, 6, 7, 8, 9, 10 ], iconPath: "file://{images}/spellicons/earth_spirit_magnetize_png.vtex", displayName: "#WL_shop_ability_magnetize", description: "#WL_shop_ability_magnetize_description" },
		{ name: "Rockpillar", column: 6, buyCost: 13, upgradeCost: [ 5, 6, 7, 8, 9, 10 ], iconPath: "file://{images}/spellicons/earth_spirit_rolling_boulder_png.vtex", displayName: "#WL_shop_ability_rockpillar", description: "#WL_shop_ability_rockpillar_description" },
		{ name: "Link", column: 6, buyCost: 12, upgradeCost: [ 6, 7, 8, 9, 10, 11 ], iconPath: "file://{images}/spellicons/wisp_tether_png.vtex", displayName: "#WL_shop_ability_link", description: "#WL_shop_ability_link_description" },
	];
	
	this.itemData =  [
		{ name: "Scourge", itemName: "item_warlock_scourge", buyCost: 7, maxLevel: 3, modDefs: [ {}, {}, {} ], iconPath: "file://{images}/spellicons/abaddon_borrowed_time_alliance_png.vtex", displayName: "#WL_shop_item_scourge_incarnation", description: "#WL_shop_item_scourge_incarnation_description" },
		{ name: "Fireball", itemName: "item_warlock_fireball", buyCost: 7, maxLevel: 7, modDefs: [{}, {}, {}, {}, {}, {}, {} ], iconPath: "file://{images}/spellicons/ogre_magi_ignite_png.vtex", displayName: "#WL_shop_item_fireball", description: "#WL_shop_item_fireball_description" },
		{ name: "Ring of Health", itemName: "item_warlock_ring_of_health", buyCost: 4, maxLevel: 5, modDefs: [ { hpBonus: 100 }, { hpBonus: 190 }, { hpBonus: 270 }, { hpBonus: 340 }, { hpBonus: 400 } ], iconPath: "file://{images}/items/ring_of_health_png.vtex", displayName: "#WL_shop_item_ring_of_health", description: "#WL_shop_item_ring_of_health_description" },
		{ name: "Cursed Ring", itemName: "item_warlock_cursed_ring", buyCost: 4, maxLevel: 2, modDefs: [ { hpBonus: 100, kbReduction: 0.15, debuffFactor: 0.25 }, { hpBonus: 200, kbReduction: 0.15, debuffFactor: 0.30 } ], iconPath: "file://{images}/items/ring_of_regen_png.vtex", displayName: "#WL_shop_item_cursed_ring", description: "#WL_shop_item_cursed_ring_description" },
		{ name: "Cape", itemName: "item_warlock_cape", buyCost: 3, maxLevel: 3, modDefs: [ { hp_regen: 2 }, { hp_regen: 3.5 }, { hp_regen: 4.5 } ], iconPath: "file://{images}/items/cloak_png.vtex", displayName: "#WL_shop_item_cape", description: "#WL_shop_item_cape_description" },
		{ name: "Armor", itemName: "item_warlock_armor", buyCost: 6, maxLevel: 3, modDefs: [ { kbReduction: 0.12 }, { kbReduction: 0.18 }, { kbReduction: 0.22 } ], iconPath: "file://{images}/items/assault_png.vtex", displayName: "#WL_shop_item_armor", description: "#WL_shop_item_armor_description" },
		{ name: "Boots", itemName: "item_warlock_boots", buyCost: 5, maxLevel: 3, modDefs: [ { speedBonusAbs: 18 }, { speedBonusAbs: 29 }, { speedBonusAbs: 40 } ], iconPath: "file://{images}/items/boots_png.vtex", displayName: "#WL_shop_item_boots", description: "#WL_shop_item_boots_description" },
		{ name: "Pocket Watch", itemName: "item_warlock_pocket_watch", maxLevel: 2, buyCost: 2, modDefs: [ { debuffFactor: -0.35 }, { debuffFactor: -0.45 } ], iconPath: "file://{images}/items/talisman_of_evasion_png.vtex", displayName: "#WL_shop_item_pocket_watch", description: "#WL_shop_item_pocket_watch_description" },
		{ name: "Redirector", itemName: "item_warlock_redirector", maxLevel: 1, buyCost: 8, modDefs: [ {} ], iconPath: "file://{images}/spellicons/disruptor_kinetic_field_png.vtex", displayName: "#WL_shop_item_redirector", description: "#WL_shop_item_redirector_description" },
		{ name: "Pact", itemName: "item_warlock_pact", maxLevel: 1, buyCost: 10, modDefs: [ {} ], iconPath: "file://{images}/spellicons/abaddon/mistral_fiend_icons/abaddon_death_coil_png.vtex", displayName: "#WL_shop_item_pact", description: "#WL_shop_item_pact_description" },
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
