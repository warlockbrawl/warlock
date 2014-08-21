---
--	Copyright (c) 2014 Krzysztof Lis (Adynathos), Zymoran, Toraxxx
--  All rights reserved.
---

--- module_loader
-- @author Krzysztof Lis (Adynathos)

print("## Script start load ##")

BASE_MODULES		= {
	'util/print', 'util/print_table', 'util/class', 'util/set',
	'base/config', 'base/game', 'base/tasks', 'base/player', 'base/commands', 'base/effect', 'base/actor',
	'base/physics', 'base/projectile', 'base/pawn', 'base/spell', 'base/arena', 'base/obstacles',
	'base/mode', 'base/shop', 'base/modifier', 'base/item', 'base/wincondition',
	'base/teammode', 'base/team', 'base/userinterface',

	'warlock/projectiles/boomerangprojectile', 'warlock/projectiles/gravityprojectile',
	'warlock/projectiles/meteorprojectile', 'warlock/projectiles/bouncerprojectile',
	'warlock/projectiles/swapprojectile', 'warlock/projectiles/gripprojectile',
	'warlock/projectiles/fireballprojectile', 'warlock/projectiles/drainprojectile',
	'warlock/projectiles/drainhealprojectile', 'warlock/projectiles/homingprojectile',

	'warlock/spells/fireball', 'warlock/spells/scourge',
	'warlock/spells/boomerang', 'warlock/spells/lightning',
	'warlock/spells/cluster', 'warlock/spells/windwalk',
	'warlock/spells/gravity', 'warlock/spells/teleport',
	'warlock/spells/meteor', 'warlock/spells/bouncer',
	'warlock/spells/shield', 'warlock/spells/swap',
	'warlock/spells/rush', 'warlock/spells/grip',
	'warlock/spells/drain', 'warlock/spells/homing',
	'warlock/spells/thrust', 'warlock/spells/warpzone',

	'warlock/modifiers/windwalkmodifier', 'warlock/modifiers/shieldmodifier',
	'warlock/modifiers/rushmodifier', 'warlock/modifiers/gripmodifier',
	'warlock/modifiers/thrustmodifier',

	'triggers'
}

local function load_module(mod_name)
	-- load the module in a monitored environment
	local status, err_msg = pcall(function()
		require(mod_name)
	end)

	if status then
		log(' module ' .. mod_name .. ' OK')
	else
		err(' module ' .. mod_name .. ' FAILED: '..err_msg)
	end
end

-- Heap must be included specially
require('heap')

-- Load all modules
for i, mod_name in pairs(BASE_MODULES) do
	load_module(mod_name)
end

function Precache(context)
	print("## Precache ##")
	
	-- Sounds
	PrecacheResource("soundfile", "soundevents/game_sounds_custom.vsndevts", context)
	
	-- Misc
	PrecacheResource("particle_folder", "particles/msg_fx", context)
	PrecacheResource("model", "models/development/invisiblebox.vmdl", context)
	PrecacheResource("particle", "particles/team_indicator.vpcf", context)
	
	-- Hero
	PrecacheResource("particle_folder", "particles/units/heroes/hero_warlock", context)
	PrecacheUnitByNameAsync("npc_dota_hero_warlock", context)
	
	-- Arena
	PrecacheResource("model", "models/tile01.vmdl", context)
	PrecacheResource("model", "models/tile02.vmdl", context)
	PrecacheResource("model", "models/tile03.vmdl", context)
	PrecacheResource("sound", "scripts/game_sounds_heroes/game_sounds_jakiro.txt", context)
	PrecacheResource("particle_folder", "particles/units/heroes/hero_jakiro", context)
	
	-- Obstacles
	PrecacheResource("model", "models/props_stone/stone_ruins001a.vmdl", context)
	PrecacheResource("model", "models/props_stone/stone_ruins002a.vmdl", context)
	PrecacheResource("model", "models/props_stone/stone_ruins003a.vmdl", context)
	PrecacheResource("model", "models/props_stone/stone_ruins004a.vmdl", context)
	PrecacheResource("model", "models/props_stone/stone_ruins005a.vmdl", context)
	PrecacheResource("model", "models/props_rock/badside_rocks001.vmdl", context)
	PrecacheResource("model", "models/props_rock/badside_rocks002.vmdl", context)
	PrecacheResource("model", "models/props_rock/badside_rocks003.vmdl", context)
	PrecacheResource("model", "models/props_rock/badside_rocks004.vmdl", context)
	PrecacheResource("model", "models/props_debris/barrel001.vmdl", context)
	PrecacheResource("model", "models/props_debris/barrel002.vmdl", context)
	PrecacheResource("model", "models/props_debris/wooden_pole_01.vmdl", context)
	PrecacheResource("model", "models/props_debris/wooden_pole_02.vmdl", context)
	PrecacheResource("model", "models/props_debris/merchant_debris_chest001.vmdl", context)
	
	-- Items
	PrecacheItemByNameSync("item_warlock_scourge_incarnation", context)
	PrecacheItemByNameSync("item_warlock_ring_of_health", context)
	PrecacheItemByNameSync("item_warlock_cape", context)
	PrecacheItemByNameSync("item_warlock_armor", context)
	PrecacheItemByNameSync("item_warlock_boots", context)
	PrecacheItemByNameSync("item_warlock_lightning", context)
	PrecacheItemByNameSync("item_warlock_boomerang", context)
	PrecacheItemByNameSync("item_warlock_homing", context)
	PrecacheItemByNameSync("item_warlock_drain", context)
	PrecacheItemByNameSync("item_warlock_cluster", context)
	PrecacheItemByNameSync("item_warlock_bouncer", context)
	PrecacheItemByNameSync("item_warlock_meteor", context)
	PrecacheItemByNameSync("item_warlock_windwalk", context)
	PrecacheItemByNameSync("item_warlock_rush", context)
	PrecacheItemByNameSync("item_warlock_shield", context)
	PrecacheItemByNameSync("item_warlock_grip", context)
	PrecacheItemByNameSync("item_warlock_gravity", context)
	PrecacheItemByNameSync("item_warlock_warpzone", context)
	
	-- Spells
	PrecacheResource("model", "models/particle/meteor.vmdl", context)
	PrecacheResource("particle_folder", "particles/msg_fx", context)
	PrecacheResource("particle_folder", "particles/base_attacks", context)
	PrecacheResource("particle_folder", "particles/econ/generic/generic_aoe_explosion_sphere_1", context)
	PrecacheResource("particle_folder", "particles/units/heroes/hero_bane", context)
	PrecacheResource("particle_folder", "particles/units/heroes/hero_nevermore", context)
	PrecacheResource("particle_folder", "particles/units/heroes/hero_stormspirit", context)
	PrecacheResource("particle_folder", "particles/units/heroes/hero_vengeful", context)
	PrecacheResource("particle_folder", "particles/units/heroes/hero_zuus", context)
	PrecacheResource("particle_folder", "particles/units/heroes/hero_lina", context)
	PrecacheResource("particle_folder", "particles/units/heroes/hero_venomancer", context)
	PrecacheResource("particle_folder", "particles/units/heroes/hero_viper", context)
	PrecacheResource("particle_folder", "particles/units/heroes/hero_dark_seer", context)
	PrecacheResource("particle_folder", "particles/units/heroes/hero_omniknight", context)
	PrecacheResource("particle_folder", "particles/units/heroes/hero_weaver", context)
	PrecacheResource("particle_folder", "particles/units/heroes/hero_chen", context)
	PrecacheResource("particle_folder", "particles/units/heroes/hero_doom_bringer", context)
	PrecacheResource("particle_folder", "particles/units/heroes/hero_invoker", context)
	PrecacheResource("particle_folder", "particles/units/heroes/hero_silencer", context)
	PrecacheResource("particle_folder", "particles/units/heroes/hero_chaos_knight", context)
	PrecacheResource("particle_folder", "particles/units/heroes/hero_ogre_magi", context)
	PrecacheResource("particle_folder", "particles/units/heroes/hero_visage", context)
	PrecacheResource("particle_folder", "particles/units/heroes/hero_bristleback", context)
	PrecacheResource("particle_folder", "particles/units/heroes/hero_abaddon", context)
	PrecacheResource("particle_folder", "particles/units/heroes/hero_ember_spirit", context)
	PrecacheResource("particle_folder", "particles/units/heroes/hero_phoenix", context)
	PrecacheResource("particle_folder", "particles/units/heroes/hero_dazzle", context)
	PrecacheResource("particle_folder", "particles/units/heroes/hero_wisp", context)
	PrecacheResource("particle", "particles/units/heroes/hero_sniper/sniper_assassinate_impact_blood.vpcf", context)

	-- custom effects
	PrecacheResource("particle_folder", "particles/fireball", context)
	PrecacheResource("particle_folder", "particles/homing", context)
	PrecacheResource("particle_folder", "particles/gravity", context)
	PrecacheResource("particle", "particles/warpzone.vpcf", context)
end

function Activate()
	print("## Activate ##")
	GAME = Game:new()
end
