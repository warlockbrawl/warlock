from shutil import copyfile

class WarlockSpell:
	def __init__(self, name, description, cast_anim):
		self.name = name
		self.description = description
		self.cast_anim = cast_anim
		
class WarlockItem:
	def __init__(self, name, description, levels, stats):
		self.name = name
		self.levels = levels
		self.stats = stats
		self.description = description
		
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

spells = []
items = []

spells.append(WarlockSpell("lightning", "Cast a lightning that instantly strikes the first obstacle on its path", 3))
spells.append(WarlockSpell("teleport", "Instantly alter your location", 1))
spells.append(WarlockSpell("drain", "Cast a projectile that can change direction, grant a slow debuff and steal life of its target", 2))
spells.append(WarlockSpell("meteor", "Summons a meteor to strike from the skies", 4))
spells.append(WarlockSpell("rush", "Enter a focused state where half damage taken is absorbed and converted into movement speed", 1))
spells.append(WarlockSpell("boomerang", "Cast a magically enhanced shuriken which will return to its caster", 2))
spells.append(WarlockSpell("thrust", "Charge toward target point and deal damage to enemies on impact", 2))
spells.append(WarlockSpell("cluster", "Cast four lesser fireballs simultaneously", 2))
spells.append(WarlockSpell("windwalk", "Fade and gain high movement speed, enabling a charge attack for a short duration", 1))
spells.append(WarlockSpell("shield", "Activates a shield that will deflect projectile spells", 1))
spells.append(WarlockSpell("grip", "Cast a missile that immobilizes its target", 2))
spells.append(WarlockSpell("homing", "Cast a bolt of energy which will homes in on its target", 2))
spells.append(WarlockSpell("swap", "Cast missile that swaps location with its target", 1))
spells.append(WarlockSpell("bouncer", "Cast missile which will bounce between nearby Warlocks", 2))
spells.append(WarlockSpell("gravity", "Cast an enchanted orb that will pull enemies with gravitational forces", 2))
spells.append(WarlockSpell("warpzone", "Create a time sphere that slows time in an area for any missiles", 2))
spells.append(WarlockSpell("magnetize", "Creates a missile that magnetizes its target repelling or attracting enemy projectiles", 2))
spells.append(WarlockSpell("rockpillar", "Spawn a rock pillar at the target location that blocks players and projectiles", 2))
spells.append(WarlockSpell("alteration", "Alters the position with the next enemy projectile coming close to hitting you", 1))
spells.append(WarlockSpell("link", "Shoot a magical link which can latch on enemies or allies and pull them to you", 2))
spells.append(WarlockSpell("splitter", "Cast a projectile which splits into minor missiles", 2))
spells.append(WarlockSpell("snowball", "Spawns a snowball which will drag other players with it and explode", 2))
spells.append(WarlockSpell("recharge", "Casts a projectile that refreshes the spells cooldown if it hits", 2))

# Items		
items.append(WarlockItem("ring_of_health", "Increases maximum HP", 5, { "hp_bonus": "100 190 270 340 400" }))
items.append(WarlockItem("cursed_ring", "Increases maximum HP and reduces knockback taken from spells, but suffer longer from debuffs", 2, { "hp_bonus": "100 200", "kb_reduction": "0.15 0.15", "debuff_factor": "0.25 0.30" }))
items.append(WarlockItem("cape", "Increases HP regeneration", 3, { "hp_regen": "1.5 2.5 3.5" }))
items.append(WarlockItem("armor", "Reduces knockback taken from spells'", 3, { "kb_reduction": "0.12 0.18 0.22" }))
items.append(WarlockItem("boots", "Increases movement speed", 3, { "speed_bonus_abs": "18 29 40" }))
items.append(WarlockItem("pocket_watch", "Reduces debuff duration significantly", 2, { "debuff_factor": "-0.35 -0.45" }))

base_npc_items_custom = ""
		
template_spell = ""
template_item_level = ""
template_addon_english = ""
template_addon_english_panorama = ""
	
with open("base_npc_items_custom.txt", "r") as f:
	base_npc_items_custom = f.read()
	
with open("template_item_level.txt", "r") as f:
	template_item_level = f.read()

with open("template_addon_english.txt", "r") as f:
	template_addon_english = f.read()
	
with open("template_addon_english_panorama.txt", "r") as f:
	template_addon_english_panorama = f.read()
	
# Create items file
	
with open("../game/dota_addons/warlock/scripts/npc/npc_items_custom.txt", "w") as f:
	f.write(base_npc_items_custom + "\n")
			
	id = 1900
			
	for item in items:		
		for level in range(1, item.levels+1):
			f.write(template_item_level % {
				"item_name": item.name,
				"level": level,
				"id": id,
				"levels": item.levels,
				"stats": item.get_stats_string(1)
			})
			
			id += 1
	
	f.write("}\n")

# Create localization file

with open("../game/dota_addons/warlock/resource/addon_english.txt", "w", encoding = 'utf-16-le') as f:
	strings = ""
	
	for spell in spells:
		prefix = '		"DOTA_Tooltip_ability_warlock_' + spell.name
		strings += prefix + '" "' + spell.name.capitalize() + '"\n'
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
		strings += prefix + '_coll_radius" "Collision radius:"\n'
		
	for item in items:
		prefix = '		"DOTA_Tooltip_ability_item_warlock_' + item.name
		strings += prefix + '" "' + item.name.replace("_", " ").capitalize() + '"\n'
		strings += prefix + '_Description" "' + item.description + '"\n'
		
		for level in range(1, item.levels+1):
			prefix = '		"DOTA_Tooltip_ability_item_warlock_' + item.name + str(level)
			strings += prefix + '" "' + item.name.replace("_", " ").capitalize() + '"\n'
			strings += prefix + '_Description" "' + item.description + '"\n'
			for stat_key, stat_val in item.stats.items():
				strings += prefix + '_' + stat_key + '" "' + stat_key.replace("_", " ").capitalize() + ':"\n'
	
	f.write('\ufeff')
	f.write(template_addon_english % { "strings": strings })
	
with open("../game/dota_addons/warlock/panorama/localization/addon_english.txt", "w", encoding = 'utf-8') as f:
	strings = ""
	
	for spell in spells:
		prefix = '	"WL_shop_ability_' + spell.name
		strings += prefix + '" "' + spell.name.capitalize() + '"\n'
		strings += prefix + '_description" "' + spell.description + '"\n'
		
	for item in items:
		prefix = '	"WL_shop_item_' + item.name
		strings += prefix + '" "' + item.name.replace("_", " ").capitalize() + '"\n'
		strings += prefix + '_description" "' + item.description + '"\n'

	f.write(template_addon_english_panorama % { "strings": strings })
	
# Create Lua abilities
template_lua_ability = ""

with open("template_lua_ability.lua", "r") as f:
	template_lua_ability = f.read()

for spell in spells:
	spell_name = "warlock_" + spell.name
	with open("../game/dota_addons/warlock/scripts/vscripts/luaabils/" + spell_name + ".lua", "w+") as f:
		f.write(template_lua_ability % { "spell_name": spell_name, "cast_anim": spell.cast_anim })
