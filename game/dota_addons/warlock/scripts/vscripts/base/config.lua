--- Configs
-- @author Krzysztof Lis (Adynathos)


Config = {}

--[[

    Unmodifiable constants

--]]

Config.GAME_START_TIME				= 10

Config.GAME_TICK_RATE 				= 0.035
Config.GAME_CAMERA_DISTANCE 		= 1100
Config.GAME_Z 						= 120
Config.GAME_ARENA_RADIUS 			= 5910
Config.GAME_ARENA_RADIUS_SQ 		= Config.GAME_ARENA_RADIUS*Config.GAME_ARENA_RADIUS

Config.PAWN_HERO 					= 'npc_dota_hero_warlock' --'npc_dota_hero_invoker'
Config.PAWN_MAX_LIFE 				= 1000
Config.PAWN_MOVE_SPEED				= 210
Config.PAWN_HEALTH_REG				= 5.0
Config.PAWN_MODEL_SCALE				= 0.75
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


--[[

    Non-constants

--]]

Config.bot_on_dc = true -- Whether to replace leavers with bots until they reconnect
Config.bot_count = 0 -- How many bots to add in Game:start()