--- Obstacle objects
-- @author Krzysztof Lis (Adynathos)

Obstacle = class(Actor)
Obstacle.mass 			= 10000
Obstacle.z				= 72
Obstacle.owner = {
	team = DOTA_TEAM_NEUTRALS,
	userid = -1
}
setmetatable(Obstacle.owner, Player)

-- List of list with definitions
Obstacle.variations = 
{
	{
		{ model = "models/props_stone/stone_ruins001a.vmdl", elasticity = 0.5, radius = 70 },
		{ model = "models/props_stone/stone_ruins002a.vmdl", elasticity = 0.5, radius = 70 },
		{ model = "models/props_stone/stone_ruins003a.vmdl", elasticity = 0.5, radius = 70 },
		{ model = "models/props_stone/stone_ruins004a.vmdl", elasticity = 0.5, radius = 70 },
		{ model = "models/props_stone/stone_ruins005a.vmdl", elasticity = 0.5, radius = 70 }
	},
	{
		{ model = "models/props_rock/badside_rocks001.vmdl", elasticity = 0.5, radius = 80 },
		{ model = "models/props_rock/badside_rocks002.vmdl", elasticity = 0.5, radius = 55 },
		{ model = "models/props_rock/badside_rocks003.vmdl", elasticity = 0.5, radius = 70 },
		{ model = "models/props_rock/badside_rocks004.vmdl", elasticity = 0.5, radius = 50 }
	},
	{
		{ model = "models/props_debris/barrel001.vmdl", elasticity = 0.5, radius = 60 },
		{ model = "models/props_debris/barrel002.vmdl", elasticity = 0.5, radius = 60 },
		{ model = "models/props_debris/wooden_pole_01.vmdl", elasticity = 0.5, radius = 45 },
		{ model = "models/props_debris/wooden_pole_02.vmdl", elasticity = 0.5, radius = 45 },
		{ model = "models/props_debris/merchant_debris_chest001.vmdl", elasticity = 0.5, radius = 60 }
	}
}

Obstacle.variation_count = #Obstacle.variations
Obstacle.variation = 1 -- The current variation set

--- Params
-- Actor params (location)
--- Optional
-- obstacle_def { model, radius, elasticity }

function Obstacle:init(def)
	-- defaults for obstacles
	def.static 	= true
	def.owner 	= def.owner or Obstacle.owner
	def.mass	= def.mass or Obstacle.mass
	def.location.z = Config.GAME_Z
	
	local obstacle_def = def.obstacle_def or Obstacle.getRandomDefinition()

	-- construct actor
	Obstacle.super.init(self, def)

	-- collision component
	self:addCollisionComponent{
		id 					= 'main',
		channel 			= CollisionComponent.CHANNEL_OBSTACLE,
		coll_mat = CollisionComponent.createCollMatSimple(
			{Player.ALLIANCE_ENEMY, Player.ALLIANCE_ALLY},
			{CollisionComponent.CHANNEL_PLAYER , CollisionComponent.CHANNEL_PROJECTILE}),
		ellastic 			= true,
		radius 				= obstacle_def.radius,
		ellasticity 		= obstacle_def.elasticity
	}

	-- effect
	self.prop = Entities:CreateByClassname("prop_dynamic")
	self.prop:SetModel(obstacle_def.model)

	self:_updateLocation()
end

function Obstacle.getRandomDefinition()
	local def_count = #Obstacle.variations[Obstacle.variation]
	return Obstacle.variations[Obstacle.variation][math.random(1, def_count)]
end

function Obstacle:_updateLocation()
	if self.prop ~= nil then
		self.prop:SetAbsOrigin(Vector(self.location.x, self.location.y, Obstacle.z))
	end
end

function Obstacle:receiveDamage(dmg_info)
	-- Hahaha, your primitive weapons are useless against me!
end

function Obstacle:onDestroy()
	if self.prop then
		self.prop:Destroy()
	end

	Obstacle.super.onDestroy(self)
end

function Game:addObstacle(loc)
	self.obstacles:add(Obstacle:new{location=loc})
end

function Game:addRandomObstacles(count)
	for x = 1, count do
		local loc = Vector(math.random(-Config.OBSTACLE_MAX_COORD, Config.OBSTACLE_MAX_COORD), math.random(-Config.OBSTACLE_MAX_COORD, Config.OBSTACLE_MAX_COORD), 0)
		self:addObstacle(loc)
	end
end

function Game:clearObstacles()
	for obst, _ in pairs(self.obstacles) do
		obst:destroy()
	end
end

function Game:setRandomObstacleVariation()
	Obstacle.variation = math.random(1, Obstacle.variation_count)
end
