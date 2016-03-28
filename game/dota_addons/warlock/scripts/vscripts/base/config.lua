--- Configs
-- @author Krzysztof Lis (Adynathos)


Config = {}

--[[

    Unmodifiable constants

--]]

Config.GAME_START_TIME				= 10

Config.GAME_TICK_RATE 				= 0.035
Config.GAME_Z 						= 120
Config.GAME_ARENA_RADIUS 			= 5910
Config.GAME_ARENA_RADIUS_SQ 		= Config.GAME_ARENA_RADIUS*Config.GAME_ARENA_RADIUS

Config.PAWN_MAX_LIFE 				= 1000
Config.PAWN_MOVE_SPEED				= 210
Config.PAWN_HEALTH_REG				= 5.0

Config.HERO_SETTINGS				= {
	npc_dota_hero_warlock = {
		CAST_ANIMS = {
			ACT_DOTA_DISABLED, -- None
			ACT_DOTA_CAST_ABILITY_4, -- Generic cast
			ACT_DOTA_CAST_ABILITY_2, -- Lightning
			ACT_DOTA_FATAL_BONDS, -- Meteor
		},
		SCALE = 0.65
	},
	npc_dota_hero_invoker = {
		CAST_ANIMS = {
			ACT_DOTA_DISABLED, -- None
			ACT_DOTA_ATTACK, -- Generic cast
			ACT_DOTA_CAST_SUN_STRIKE, -- Lightning
			ACT_DOTA_CAST_SUN_STRIKE, -- Meteor
		},
		SCALE = 0.55
	},
	npc_dota_hero_rubick = {
		CAST_ANIMS = {
			ACT_DOTA_DISABLED, -- None
			ACT_DOTA_CAST_ABILITY_5, -- Generic cast
			ACT_DOTA_CAST_ABILITY_5 , -- Lightning
			ACT_DOTA_CAST_ABILITY_5 , -- Meteor
		},
		SCALE = 0.50
	},
}

Config.KB_DMG_TO_VELOCITY 			= 10.0

Config.LOCUST_UNIT 					= "npc_dummy_unit"

Config.DEVELOPMENT 					= false
Config.MAX_LEVEL					= 100

Config.OBSTACLE_MAX_COORD			= 1000

Config.FRICTION = 0.96

Config.BOT_BUY_DELAY                = 120 -- How many seconds an AI should wait before buying items on a disconnected player

Config.ARENA_RADIUS_PER_LAYER       = 100
Config.ARENA_BASE_LAYER             = 13
Config.ARENA_LAYER_PER_PLAYER       = 1
Config.ARENA_SPAWN_INSET            = 600

-- Web API constants
Config.WEB_API_MOD_ID               = "warlockbrawl"
Config.WEB_API_MOD_VERSION          = 5
Config.WEB_API_BASE_URL             = "http://api.warlockbrawl.com/mod"

--[[

    Non-constants

--]]

Config.bot_on_dc = true -- Whether to replace leavers with bots until they reconnect
Config.bot_count = 0 -- How many bots to add in Game:start()

Config.dmg_multiplier = 1
Config.kb_multiplier = 1
