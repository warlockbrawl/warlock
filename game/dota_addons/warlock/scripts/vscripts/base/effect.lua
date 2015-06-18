--- Graphic effects
-- @author Krzysztof Lis (Adynathos)

-------------------------------------------------------------------------------
--- Base for all effects
-------------------------------------------------------------------------------
Effect = class()
Effect.effect_definitions = {}

--[[ def:
	* location
	* parent_actor
	* destruction_sound
	* angles
	* scale
]]
function Effect:init(def)
	if def.parent_actor then
		self.parent_actor = def.parent_actor
		self.location = self.parent_actor.location
		self.angles = self.parent_actor.angles
	end

	if def.location then
		self.location = def.location
	end
	
	if def.angles then
		self:setAngles(angles)
	else
		self.angles = Vector(0, 0, 0)
	end
	
	if def.scale then
		self:setScale(def.scale)
	end

	self.destruction_sound = def.destruction_sound
	self.destruction_effect = def.destruction_effect
end

--- velocity_size is optional but useful for 'projectile effect'
function Effect:setLocation(new_location, velocity_size)
	self.location = new_location

	-- by defautl move the locust to the new location
	if self.locust then
		self.locust:SetAbsOrigin(new_location)
	end
end

--- sets the pitch, yaw, roll angles of the effect
function Effect:setAngles(pitch, yaw, roll)
	if self.locust then
		self.locust:SetAngles(pitch, yaw, roll)
		
		-- Get the angles from the locust unit, otherwise we have to write own code
		-- to clamp the angles between 0 and 360 degrees to prevent overflows
		self.angles = self.locust:GetAngles()
	else
		self.angles = Vector(pitch, yaw, roll)
	end
end

--- Change the effects scale
function Effect:setScale(scale)
	if self.locust then
		self.locust:SetModelScale(scale)
	end
end

--- set b_no_death_effect to true to avoid the explosion
function Effect:destroy()
	if self.destruction_sound and self.locust then
		self.locust:EmitSound(self.destruction_sound)
	end
	
	if self.destruction_effect then
		Effect:create(self.destruction_effect, {
			location = self.location
		})
	end

	if self.particleId then
		ParticleManager:ReleaseParticleIndex(self.particleId)
		self.particleId = nil
	end

	self:removeLocust()
end

--- Spawn a default locust unit for this effect
-- location needs to be initialized
function Effect:spawnLocustProp()
	log("Warning: spawnLocustProp called (deprecated")

	self:removeLocust()

	self.locust = Entities:CreateByClassname("prop_dynamic")
	self.locust:SetAbsOrigin(self.location)
end

--- Spawn a default locust unit for this effect
-- location needs to be initialized
function Effect:spawnLocustUnit()
	self:removeLocust()

	self.locust = CreateUnitByName(Config.LOCUST_UNIT, self.location, true, nil, nil, DOTA_TEAM_NOTEAM)
	self.locust:SetAbsOrigin(self.location)
end

function Effect:removeLocust()
	if self.locust then
		self.locust:Destroy()
		self.locust = nil
	end
end

--- Store effect definition under this name
function Effect:register(id, def)
	Effect.effect_definitions[id] = def
end

--- Spawn an effect using stored definition
-- @param additional_def Overrides the standard def and provides
-- 			additional info like location
function Effect:create(id, additional_def)
	local def = Effect.effect_definitions[id]

	if def ~= nil then
		-- apply the additional def
		if additional_def then
			for k, v in pairs(additional_def) do
				def[k] = v
			end
		end

		local effect_class = def.class
		if effect_class ~= nil then
			return effect_class:new(def)
		else
			err("Missing class in definition of effect "..id)
		end
	else
		err("Unknown effect "..id)
	end

end

-------------------------------------------------------------------------------
--- Particle emitter effect
-------------------------------------------------------------------------------
ParticleEffect = class(Effect)

--[[ def:
	* effect_name
]]
function ParticleEffect:init(def)
	self.effect_name = def.effect_name

	ParticleEffect.super.init(self, def)

	-- a unit is needed to initially attach the effect
	-- self:spawnLocustProp() -- Calling :Destroy on props causes the game to crash while they collide something
    self:spawnLocustUnit()

	if def.effect_name then
		self.particleId = ParticleManager:CreateParticle(self.effect_name, PATTACH_ABSORIGIN_FOLLOW , self.locust)
	end

	self:setLocation(self.location, 0)
end

function ParticleEffect:setControlPoint(cp, value)
	ParticleManager:SetParticleControl(self.particleId, cp, value)
end

-------------------------------------------------------------------------------
--- For 'projectile' particle emitters which do not want to follow their owners
-------------------------------------------------------------------------------
ProjectileParticleEffect = class(ParticleEffect)

function ProjectileParticleEffect:setLocation(new_location, velocity_size)
	self.location = new_location
	-- no need to move the locust now

	if self.particleId then
		-- target
		ParticleManager:SetParticleControl( self.particleId, 1, self.location)

		-- velocity
		ParticleManager:SetParticleControl( self.particleId, 2, Vector(velocity_size,0,0))
	end
end

function ProjectileParticleEffect:destroy()
    if self.locust then
        -- move because we may be playing a death sound
	    self.locust:SetAbsOrigin(self.location)
    end

	ProjectileParticleEffect.super.destroy(self)
end

-------------------------------------------------------------------------------
--- Effect displaying a model
-------------------------------------------------------------------------------

ModelEffect = class(Effect)

function ModelEffect:init(def)
	ModelEffect.super.init(self, def)

	self:spawnLocustUnit()

	-- Need to do this again because the super ctr is called before the
	-- locust was spawned
	
	if def.scale then
		self:setScale(def.scale)
	end

	if def.model_name then
		self.locust:SetModel(def.model_name)
	end
end

-------------------------------------------------------------------------------
--- Beam particle effect
-- def:
-- * start_location
-- * end_location
-------------------------------------------------------------------------------
LightningEffect = class(ParticleEffect)

function LightningEffect:init(def)
	def.location = def.start_location

	LightningEffect.super.init(self, def)

	if self.particleId then
		ParticleManager:SetParticleControl( self.particleId, 0, def.end_location)
		ParticleManager:SetParticleControl( self.particleId, 1, def.end_location)
		ParticleManager:SetParticleControl( self.particleId, 2, def.end_location)
	end

	if def.sound and self.locust then
		self.locust:EmitSound(def.sound)
	end

	if def.lifetime then
		GAME:addTask({
			id='destroy lightning effect',
			time=def.lifetime,
			func = function()
				self:destroy()
			end
		})
	end
end
