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
	'base/teammode', 'base/team', 'base/gamesetup', 'base/scoreboard',

	'warlock/projectiles/boomerangprojectile', 'warlock/projectiles/gravityprojectile',
	'warlock/projectiles/meteorprojectile', 'warlock/projectiles/bouncerprojectile',
	'warlock/projectiles/swapprojectile', 'warlock/projectiles/gripprojectile',
	'warlock/projectiles/fireballprojectile', 'warlock/projectiles/drainprojectile',
	'warlock/projectiles/drainhealprojectile', 'warlock/projectiles/homingprojectile',
    'warlock/projectiles/magnetizeprojectile',

	'warlock/spells/fireball', 'warlock/spells/scourge',
	'warlock/spells/boomerang', 'warlock/spells/lightning',
	'warlock/spells/cluster', 'warlock/spells/windwalk',
	'warlock/spells/gravity', 'warlock/spells/teleport',
	'warlock/spells/meteor', 'warlock/spells/bouncer',
	'warlock/spells/shield', 'warlock/spells/swap',
	'warlock/spells/rush', 'warlock/spells/grip',
	'warlock/spells/drain', 'warlock/spells/homing',
	'warlock/spells/thrust', 'warlock/spells/warpzone',
    'warlock/spells/magnetize', 'warlock/spells/rockpillar',
    'warlock/spells/alteration',

	'warlock/modifiers/windwalkmodifier', 'warlock/modifiers/shieldmodifier',
	'warlock/modifiers/rushmodifier', 'warlock/modifiers/gripmodifier',
	'warlock/modifiers/thrustmodifier', 'warlock/modifiers/magnetizemodifier',
    'warlock/modifiers/alterationmodifier',

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
	PrecacheResource("particle", "particles/msg_fx/msg_evade.vpcf", context)
	PrecacheResource("model", "models/development/invisiblebox.vmdl", context)
	
	
	-- Hero
	PrecacheResource("particle_folder", "particles/units/heroes/hero_warlock", context)
	PrecacheUnitByNameAsync("npc_dota_hero_warlock", context)
	
	-- Arena
	PrecacheResource("model", "models/tile01.vmdl", context)
	PrecacheResource("model", "models/tile02.vmdl", context)
	PrecacheResource("model", "models/tile03.vmdl", context)
	PrecacheResource("particle", "particles/units/heroes/hero_phoenix/phoenix_icarus_dive_burn_debuff.vpcf", context)

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
    PrecacheResource("model", "models/props_rock/riveredge_rock006a.vmdl", context) -- Used for rock pillar
	
	-- Spells
	PrecacheResource("particle_folder", "particles/units/heroes/hero_omniknight", context)
	PrecacheResource("particle", "particles/econ/generic/generic_aoe_explosion_sphere_1/generic_aoe_explosion_sphere_1.vpcf", context)
	PrecacheResource("model", "models/particle/meteor.vmdl", context)
	PrecacheResource("particle", "particles/units/heroes/hero_nevermore/nevermore_base_attack.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_nevermore/nevermore_shadowraze.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_stormspirit/stormspirit_overload_discharge.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_vengeful/vengeful_nether_swap.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_vengeful/vengeful_nether_swap_blue.vpcf", context)
    PrecacheResource("particle", "particles/units/heroes/hero_vengeful/vengeful_base_attack.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_lina/lina_spell_laguna_blade.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_venomancer/venomancer_base_attack.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_dark_seer/dark_seer_ion_shell.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_weaver/weaver_shukuchi_damage.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_chen/chen_teleport.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_doom_bringer/doom_bringer_lvl_death.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_silencer/silencer_glaives_of_wisdom.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_chaos_knight/chaos_knight_chaos_bolt.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_visage/visage_soul_assumption_bolt.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_bristleback/bristleback_viscous_nasal_goo_debuff.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_ember_spirit/ember_spirit_searing_chains_debuff.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_ember_spirit/ember_spirit_flameguard.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_dazzle/dazzle_poison_touch.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_wisp/wisp_base_attack_explosion.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_wisp/wisp_guardian_explosion.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_sniper/sniper_assassinate_impact_blood.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_phoenix/phoenix_base_attack.vpcf", context)
    PrecacheResource("particle", "particles/units/heroes/hero_earth_spirit/espirit_magnetize.vpcf", context)
    PrecacheResource("particle", "particles/units/heroes/hero_earth_spirit/espirit_magnetize_pulse.vpcf", context)
    PrecacheResource("particle", "particles/units/heroes/hero_earth_spirit/espirit_magnetize_target.vpcf", context)
    PrecacheResource("particle", "particles/units/heroes/hero_earth_spirit/espirit_magnetize_target_ripple_b.vpcf", context)
    PrecacheResource("particle", "particles/units/heroes/hero_earth_spirit/espirit_magnetize_target_ripple_da.vpcf", context)
    PrecacheResource("particle", "particles/units/heroes/hero_earth_spirit/espirit_magnetize_target_ripple_db.vpcf", context)
    PrecacheResource("particle", "particles/units/heroes/hero_earth_spirit/espirit_magnetize_target_ripple_dust.vpcf", context)
    PrecacheResource("particle", "particles/units/heroes/hero_earth_spirit/espirit_magnetize_target_rocks.vpcf", context)
    PrecacheResource("particle", "particles/units/heroes/hero_earth_spirit/espirit_magnetized_ring.vpcf", context)
    PrecacheResource("particle", "particles/units/heroes/hero_earth_spirit/espirit_stoneismagnetized_xpld.vpcf", context)
    PrecacheResource("particle", "particles/econ/items/undying/undying_manyone/undying_pale_tower_destruction_dust_hit.vpcf", context)
    PrecacheResource("particle", "particles/econ/items/tinker/boots_of_travel/teleport_start_bots_dust.vpcf", context)
    PrecacheResource("particle", "particles/prototype_fx/item_linkens_buff_explosion.vpcf", context)
    PrecacheResource("particle", "particles/units/heroes/hero_treant/treant_livingarmor.vpcf", context)
   
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
