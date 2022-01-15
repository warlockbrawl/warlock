--- Obstacle objects
-- @author Krzysztof Lis (Adynathos)

Obstacle = class(Actor)
Obstacle.z = Config.GAME_Z
Obstacle.dummy_unit = "npc_obstacle"
Obstacle.mass 			= 10000
Obstacle.owner = {
	team = DOTA_TEAM_NEUTRALS,
	userid = -1
}
Obstacle.max_health		= 400
Obstacle.explode_effect = 'obstacle_explode'
Obstacle.explode_radius = 300
Obstacle.explode_dmg_min = 5
Obstacle.explode_dmg_gain = 5
setmetatable(Obstacle.owner, Player)

-- List of list with definitions
Obstacle.variations = 
{
	{
		{ model = "models/props_stone/stone_ruins001a.vmdl", elasticity = 0.5, radius = 60 },
		{ model = "models/props_stone/stone_ruins002a.vmdl", elasticity = 0.5, radius = 60 },
		{ model = "models/props_stone/stone_ruins003a.vmdl", elasticity = 0.5, radius = 60 },
		{ model = "models/props_stone/stone_ruins004a.vmdl", elasticity = 0.5, radius = 60 },
		{ model = "models/props_stone/stone_ruins005a.vmdl", elasticity = 0.5, radius = 60 }
	},
	{
		{ model = "models/props_rock/badside_rocks001.vmdl", elasticity = 0.5, radius = 70 },
		{ model = "models/props_rock/badside_rocks002.vmdl", elasticity = 0.5, radius = 45 },
		{ model = "models/props_rock/badside_rocks003.vmdl", elasticity = 0.5, radius = 60 },
		{ model = "models/props_rock/badside_rocks004.vmdl", elasticity = 0.5, radius = 40 }
	},
	{
		{ model = "models/props_debris/barrel001.vmdl", elasticity = 0.5, radius = 50 },
		{ model = "models/props_debris/barrel002.vmdl", elasticity = 0.5, radius = 50 },
		{ model = "models/props_debris/wooden_pole_01.vmdl", elasticity = 0.5, radius = 35 },
		{ model = "models/props_debris/wooden_pole_02.vmdl", elasticity = 0.5, radius = 35 },
		{ model = "models/props_debris/merchant_debris_chest001.vmdl", elasticity = 0.5, radius = 50 }
	}
}

Obstacle.variation_count = #Obstacle.variations
Obstacle.variation = 1 -- The current variation set

Effect:register('obstacle_explode', {
	class = ParticleEffect,
	effect_name = 'particles/units/heroes/hero_jakiro/jakiro_liquid_fire_explosion.vpcf'
})

--- Params
-- Actor params (location)
--- Optional
-- obstacle_def { model, radius, elasticity }

function Obstacle:init(def)
	-- defaults for obstacles
	def.static 	= true
	def.owner 	= def.owner or Obstacle.owner
	def.mass	= def.mass or Obstacle.mass
	def.location.z = Obstacle.z
    def.name = "Obstacle"
	
	local obstacle_def = def.obstacle_def or Obstacle.getRandomDefinition()

	self.obstacle_def = obstacle_def

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
	self.model_unit = CreateUnitByName(Obstacle.dummy_unit, self.location, false, nil, nil, DOTA_TEAM_NOTEAM)

    local locust_abil = self.model_unit:FindAbilityByName("warlock_tech_obstacle")
    locust_abil:SetLevel(1)

	self.model_unit:SetModel(obstacle_def.model)
	self.model_unit:SetOriginalModel(obstacle_def.model)

	self.health = def.max_health or Obstacle.max_health
	
	-- Set the dummy's health
	self.model_unit:SetMaxHealth(Obstacle.max_health)
	self.model_unit:SetHealth(self.health)
end

function Obstacle.getRandomDefinition()
	local def_count = #Obstacle.variations[Obstacle.variation]
	return Obstacle.variations[Obstacle.variation][math.random(1, def_count)]
end

function Obstacle:_updateLocation()
	if self.model_unit ~= nil then
		self.model_unit:SetAbsOrigin(Vector(self.location.x, self.location.y, Obstacle.z))
	end
end

function Obstacle:receiveDamage(dmg_info)
	if not GAME.combat or not self.exists then
		return
	end

	-- Take damage
	self.health = self.health - dmg_info.amount
	if(self.health < 0) then
		self.health = 0
	end
	
	-- Set the dummy's health
	if self.model_unit then
		self.model_unit:SetMaxHealth(Obstacle.max_health)
		self.model_unit:SetHealth(self.health)
	end
	
	-- Explode the pillar if its health is too low
	if(self.health <= 0) then
		self:explode(dmg_info)
	end
end

function Obstacle:explode(destroyer_dmg_info)
	local destroyer = nil
	
	print("Obstacle exploded")
	
	-- Set the damage source if any
	if destroyer_dmg_info.source then
		destroyer = destroyer_dmg_info.source.owner
	end
	
	-- The damage info used to deal the damage
	local dmg_info = { }
	
	for pawn, _ in pairs(GAME.pawns) do
		if pawn.enabled then
			local diff = pawn.location - self.location
			diff.z = 0

			local dst = diff:Length()

			-- Only hit targets in the explode radius
			if dst < Obstacle.explode_radius then
				dmg_info.hit_normal = diff:Normalized()

				-- Deal damage depending on the distance
				dmg_info.amount = Obstacle.explode_dmg_min + Obstacle.explode_dmg_gain * (1 - dst / Obstacle.explode_radius)

				-- No KB points for allies
				if destroyer and pawn.owner:getAlliance(destroyer) == Player.ALLIANCE_ALLY then
					dmg_info.knockback_vulnerability_factor = 0
				else
					dmg_info.knockback_vulnerability_factor = 1
				end
				
				pawn:receiveDamage(dmg_info)
			end
		end
	end
	
	Effect:create(self.explode_effect, { location = self.location })
	self:destroy()
end

function Obstacle:onDestroy()
	if self.model_unit then
		self.model_unit:RemoveSelf()
		self.model_unit = nil
	end

	Obstacle.super.onDestroy(self)
end

function Game:addObstacle(loc)
    local obstacle = Obstacle:new{ location=loc }
	self.obstacles:add(obstacle)
    return obstacle
end

function Game:addObstacleByDef(def)
    local obstacle = Obstacle:new(def)
    self.obstacles:add(obstacle)
    return obstacle
end

function Game:removeObstacle(obstacle)
    self.obstacles:remove(obstacle)
    obstacle:destroy()
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

    self.obstacles = Set:new()
end

function Game:setRandomObstacleVariation()
	Obstacle.variation = math.random(1, Obstacle.variation_count)
end
