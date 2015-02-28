from shutil import copyfile

class WarlockSpell:
	def __init__(self, name, description, cost, column):
		self.name = name
		self.description = description
		self.cost = cost
		self.column = column
		
class WarlockItem:
	def __init__(self, name, description, cost, levels, stats, category):
		self.name = name
		self.cost = cost
		self.levels = levels
		self.stats = stats
		self.description = description
		self.category = category
		self.is_mastery = False
		
	def get_stats_string(self, start_index):
		stats_str = ""
		i = start_index
		
		for stat_key, stat_val in self.stats.items():
			if i >= 10:
				print("Warning: 10 or more stats")
			
			stats_str += '			"0' + str(i) + '"\n'
			stats_str += '			{\n'
			stats_str += '				"var_type" "FIELD_FLOAT"\n'
			stats_str += '				"' + stat_key + '" "' + stat_val + '"\n'
			stats_str += '			}\n'
			i += 1
			
		return stats_str
		
		
class WarlockMastery(WarlockItem):
	def __init__(self, name, description, cost, levels, stats, category, index):
		super().__init__(name, description, cost, levels, stats, category)
		self.is_mastery = True
		self.index = index
		
	def get_stats_string(self, start_index):
		stats_str = '			"0' + str(start_index) + '"\n'
		stats_str += '			{\n'
		stats_str += '				"var_type" "FIELD_INTEGER"\n'
		stats_str += '				"index" "' + str(self.index) + '"\n'
		stats_str += '			}\n'
	
		stats_str += super().get_stats_string(start_index + 1)
		
		return stats_str

spells = []
items = []

spells.append(WarlockSpell("lightning", "Cast a lightning that instantly strikes the first obstacle on its path", 11, 0))
spells.append(WarlockSpell("teleport", "Instantly alter your location", 11, 1))
spells.append(WarlockSpell("drain", "Cast a projectile that can change direction, grant a slow debuff and steal life of its target", 14, 2))
spells.append(WarlockSpell("meteor", "Summons a meteor to strike from the skies", 14, 3))
spells.append(WarlockSpell("rush", "Enter a focused state where half damage taken is absorbed and converted into movement speed", 12, 4))
spells.append(WarlockSpell("boomerang", "Cast a magically enhanced shuriken which will return to its caster", 11, 0))
spells.append(WarlockSpell("thrust", "Charge toward target point and deal damage to enemies on impact", 11, 1))
spells.append(WarlockSpell("cluster", "Cast four lesser fireballs simultaneously", 14, 2))
spells.append(WarlockSpell("windwalk", "Fade and gain high movement speed, enabling a charge attack for a short duration", 14, 3))
spells.append(WarlockSpell("shield", "Activates a shield that will deflect projectile spells", 12, 4))
spells.append(WarlockSpell("grip", "Cast a missile that immobilizes its target", 12, 5))
spells.append(WarlockSpell("homing", "Cast a bolt of energy which will homes in on its target", 11, 0))
spells.append(WarlockSpell("swap", "Cast missile that swaps location with its target", 11, 1))
spells.append(WarlockSpell("bouncer", "Cast missile which will bounce between nearby Warlocks", 14, 2))
spells.append(WarlockSpell("gravity", "Cast an enchanted orb that will pull enemies with gravitational forces", 12, 5))
spells.append(WarlockSpell("warpzone", "Create a time sphere that slows time in an area for any missiles", 12, 5))
spells.append(WarlockSpell("magnetize", "Creates a missile that magnetizes its target repelling or attracting enemy projectiles", 14, 5))
spells.append(WarlockSpell("rockpillar", "Spawn a rock pillar at the target location that blocks players and projectiles", 13, 5))
spells.append(WarlockSpell("alteration", "Alters the position with the next enemy projectile coming close to hitting you", 11, 4))

# Items		
items.append(WarlockItem("scourge_incarnation", "", 7, 2, { "damage": "110 120" }, "consumables"))
items.append(WarlockItem("ring_of_health", "Increases maximum HP", 4, 5, { "hp_bonus": "100 190 270 340 400" }, "attributes"))
items.append(WarlockItem("cursed_ring", "Increases maximum HP and reduces knockback taken from spells, but suffer longer from debuffs", 6, 2, { "hp_bonus": "100 200", "kb_reduction": "0.15 0.15", "debuff_factor": "0.25 0.30" }, "attributes"))
items.append(WarlockItem("cape", "Increases HP regeneration", 3, 3, { "hp_regen": "2.0 3.5 4.5" }, "attributes"))
items.append(WarlockItem("armor", "Reduces knockback taken from spells'", 6, 3, { "kb_reduction": "0.12 0.18 0.22" }, "attributes"))
items.append(WarlockItem("boots", "Increases movement speed", 5, 3, { "speed_bonus_abs": "18 29 40" }, "attributes"))
items.append(WarlockItem("pocket_watch", "Reduces debuff duration significantly", 4, 2, { "debuff_factor": "-0.35 -0.45" }, "attributes"))

# Masteries
items.append(WarlockMastery("duration_mastery", "Passively grants 10/18/25/31/36/40 percent additional duration to all duration spells", 5, 6, { "stats": "10 8 7 6 5 4" }, "misc", 0))
items.append(WarlockMastery("range_mastery", "Passively grants 12/22/31/39/46/52 percent additional range to all missile spells", 5, 6, { "stats": "12 10 9 8 7 6" }, "misc", 1))
items.append(WarlockMastery("life_steal_mastery", "Passively grants 9/17/24/30/35/39 percent life steal (half the life stolen goes to DP reduction)", 5, 6, { "stats": "9 8 7 6 5 4" }, "misc", 2))
items.append(WarlockMastery("jack_of_all_trades", "Increases the level of all masteries at 2 gold discount", 13, 18, { "stats": "10 8 7 6 5 4 12 10 9 8 7 6 9 8 7 6 5 4" }, "misc", 3))

base_npc_items_custom = ""
		
template_spell = ""
template_spell_item = ""
template_item = ""
template_item_level = ""
template_addon_english = ""
	
with open("base_npc_items_custom.txt", "r") as f:
	base_npc_items_custom = f.read()
	
with open("template_spell_item.txt", "r") as f:
    template_spell_item = f.read()
	
with open("template_item.txt", "r") as f:
	template_item = f.read()
	
with open("template_item_level.txt", "r") as f:
	template_item_level = f.read()

with open("template_addon_english.txt", "r") as f:
	template_addon_english = f.read()
	
# Create items file
	
with open("../game/dota_addons/warlock/scripts/npc/npc_items_custom.txt", "w") as f:
	f.write(base_npc_items_custom + "\n")
	
	id = 1900
	for spell in spells:
		# TODO: Write Icons to warlock_name
		f.write(template_spell_item % { 
			"spell_name": spell.name, 
			"id": id, 
			"icon_name": "warlock_" + spell.name, 
			"cost": spell.cost, 
			"column": spell.column 
		})
		
		id += 1
			
	for item in items:
		f.write(template_item % {
			"item_name": item.name,
			"id": id,
			"cost": item.cost,
			"levels": item.levels,
			"type": "2" if item.is_mastery else "0",
			"stats": item.get_stats_string(3)
		})
		
		id += 1
		
		if not item.is_mastery:
			for level in range(1, item.levels+1):
				f.write(template_item_level % {
					"item_name": item.name,
					"level": level,
					"id": id,
					"cost": item.cost,
					"levels": item.levels,
					"stats": item.get_stats_string(1)
				})
				
				id += 1
	
	f.write("}\n")
	

# Create shops file	

item_categories = [ "misc", "consumables", "attributes" ]
spell_categories = [ "basics", "support", "magics", "weapons", "defense", "artifacts" ]
unused_categories = [ "weapons_armor", "sideshop1", "sideshop2", "secretshop1" ]
	
with open("../game/dota_addons/warlock/scripts/shops/warlock_shops.txt", "w") as f:
	f.write('"dota_shops"\n')
	f.write('{\n')
	
	for category in item_categories:
		f.write('	"' + category + '"\n')
		f.write('	{\n')
		for item in items:
			if item.category == category:
				f.write('		"item" "item_warlock_' + item.name + '"\n')
		f.write('	}\n')
	
	for col, category in enumerate(spell_categories):
		f.write('	"' + category + '"\n')
		f.write('	{\n')
		for spell in spells:
			if spell.column == col:
				f.write('		"item" "item_warlock_' + spell.name + '"\n')
		f.write('	}\n')
	
	for category in unused_categories:
		f.write('	"' + category + '"\n')
		f.write('	{\n')
		f.write('	}\n')
	
	f.write('}\n')


# Create localization file

with open("../game/dota_addons/warlock/resource/addon_english.txt", "w", encoding = 'utf-16-le') as f:
	strings = ""
	
	for spell in spells:
		prefix = '		"DOTA_Tooltip_ability_warlock_' + spell.name
		strings += '		"DOTA_Tooltip_ability_item_warlock_' + spell.name + '" "Learn ' + spell.name + '"\n'
		strings += '		"DOTA_Tooltip_ability_item_warlock_' + spell.name + '_Description" "' + spell.description + '"\n'
		strings += prefix + '" "' + spell.name + '"\n'
		strings += prefix + '_Description" "' + spell.description + '"\n'
		strings += prefix + '_Note0" ""\n'
		strings += prefix + '_damage" "Damage:"\n'
		strings += prefix + '_damage_max" "Max damage:"\n'
		strings += prefix + '_radius" "AoE:"\n'
		strings += prefix + '_time_scale" "Time scale:"\n'
		strings += prefix + '_duration" "Duration:"\n'
		strings += prefix + '_strength" "Force:"\n'
		strings += prefix + '_cooldown2" "Cooldown:"\n'
		strings += prefix + '_upgrade_cost" "Upgrade cost:"\n'
		strings += prefix + '_range" "Range:"\n'
		strings += prefix + '_absorb_max" "Max absorb:"\n'
		
	for item in items:
		prefix = '		"DOTA_Tooltip_ability_item_warlock_' + item.name
		strings += prefix + '" "' + item.name + '"\n'
		strings += prefix + '_Description" "' + item.description + '"\n'
		
		for level in range(1, item.levels+1):
			prefix = '		"DOTA_Tooltip_ability_item_warlock_' + item.name + str(level)
			strings += prefix + '" "' + item.name + '"\n'
			strings += prefix + '_Description" "' + item.description + '"\n'
			for stat_key, stat_val in item.stats.items():
				strings += prefix + '_' + stat_key + '" "' + stat_key.replace("_", " ").capitalize() + ':"\n'
	
	f.write('\ufeff')
	f.write(template_addon_english % { "strings": strings })
	