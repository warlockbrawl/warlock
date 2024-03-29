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
		self:setAngles(def.angles[1], def.angles[2], def.angles[3])
	else
		self.angles = Vector(0, 0, 0)
	end
	
	if def.scale then
		self:setScale(def.scale)
	end

	self.destruction_sound = def.destruction_sound
	self.destruction_effect = def.destruction_effect

    local duration = def.duration or 5 -- Default duration five seconds

    -- duration -1 means permanent
    if duration ~= -1 then
	    GAME:addTask {
		    time = duration,
		    func = function()
			    self:destroy()
		    end
	    }
    end
end

--- velocity_size is optional but useful for 'projectile effect'
function Effect:setLocation(new_location, velocity_size)
	self.location = new_location

	-- by default move the locust to the new location
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
        ParticleManager:DestroyParticle(self.particleId, false)
		self.particleId = nil
	end

	self:removeLocust()
end

--- Spawn a default locust unit for this effect
-- location needs to be initialized
function Effect:spawnLocustProp()
	warning("spawnLocustProp called (deprecated)")

	self:removeLocust()

	self.locust = Entities:CreateByClassname("prop_dynamic")
	self.locust:SetAbsOrigin(self.location)
end

--- Spawn a default locust unit for this effect
-- location needs to be initialized
function Effect:spawnLocustUnit()
	self:removeLocust()

	self.locust = CreateUnitByName(Config.LOCUST_UNIT, self.location, true, nil, nil, DOTA_TEAM_NOTEAM)

    local locust_abil = self.locust:FindAbilityByName("warlock_tech_locust")
    locust_abil:SetLevel(1)

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
    -- Get the effect definition
	local def = Effect.effect_definitions[id]

	if def ~= nil then
		-- If there's any additional def, copy the original one and extend it
        -- If we don't copy it then the original def will be modified!
		if additional_def then
			def = copy_extend(def, additional_def)
		end

		local effect_class = def.class
		if effect_class ~= nil then
			return effect_class:new(def)
		else
			err("Missing class in definition of effect " .. tostring(id))
		end
	else
		err("Unknown effect " .. tostring(id))
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
        -- Create particle effect differently when attached to an entity
        if not def.ent then
		    self.particleId = ParticleManager:CreateParticle(self.effect_name, PATTACH_ABSORIGIN_FOLLOW , self.locust)
        else
            self.particleId = ParticleManager:CreateParticle(self.effect_name, PATTACH_CUSTOMORIGIN , nil)
        end
	end

	self:setLocation(self.location, 0)

    if def.angles then
        self:setAngles(def.angles[1], def.angles[2], def.angles[3])
    end

    -- Attach cp0 (location) to an entity if specified
    if self.particleId and def.ent then
        self:setEntity(def.ent, def.attach_point)
    end
end

--- sets the pitch, yaw, roll angles of the effect
function ParticleEffect:setAngles(pitch, yaw, roll)
	ParticleEffect.super.setAngles(self, pitch, yaw, roll)

    if self.particleId then
        ParticleManager:SetParticleControlForward(self.particleId, 0, Vector(pitch, yaw, roll))
    end
end

function ParticleEffect:setControlPoint(cp, value)
	ParticleManager:SetParticleControl(self.particleId, cp, value)
end

function ParticleEffect:setEntity(ent, attach_point)
    if attach_point then
        ParticleManager:SetParticleControlEnt(self.particleId, 0, ent, PATTACH_POINT_FOLLOW, attach_point, Vector(0, 0, 0), true)
    else
        ParticleManager:SetParticleControlEnt(self.particleId, 0, ent, PATTACH_ABSORIGIN_FOLLOW, nil, Vector(0, 0, 0), true)
    end
end

-------------------------------------------------------------------------------
--- For 'projectile' particle emitters which do not want to follow their owners
-------------------------------------------------------------------------------
ProjectileParticleEffect = class(ParticleEffect)

function ProjectileParticleEffect:setLocation(new_location, velocity_size)
	self.location = new_location
	-- no need to move the locust now

    -- Still moving the locust to prevent some bugs and allow follow particles
    if self.locust then
        self.locust:SetAbsOrigin(self.location)
    end

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

	if def.model_name then
		self.locust:SetModel(def.model_name)
        self.locust:SetOriginalModel(def.model_name)
	end

    -- Need to do this again because the super ctr is called before the
	-- locust was spawned
    if def.scale then
		self:setScale(def.scale)
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
		ParticleManager:SetParticleControl( self.particleId, 1, def.end_location)
	end

	if def.sound and self.locust then
		self.locust:EmitSound(def.sound)
	end
end

-------------------------------------------------------------------------------
--- Beam particle effect that follows a start and end entity
-- def:
-- * end_ent
-- * end_ent_attach_point
-------------------------------------------------------------------------------
FollowLightningEffect = class(ParticleEffect)

function FollowLightningEffect:init(def)
	def.location = def.start_location

	self.effect_name = def.effect_name

	ParticleEffect.super.init(self, def)

	if def.effect_name then
		self.particleId = ParticleManager:CreateParticle(self.effect_name, PATTACH_CUSTOMORIGIN , nil)
	end

	self:setLocation(self.location, 0)

	if self.particleId then
        self:setEntity(def.ent, def.ent_attach_point)
        self:setEndEntity(def.end_ent, def.end_ent_attach_point)
	end
end

function FollowLightningEffect:setEndEntity(ent, attach_point)
    if attach_point then
        ParticleManager:SetParticleControlEnt(self.particleId, 1, ent, PATTACH_POINT_FOLLOW, attach_point, Vector(0, 0, 0), true)
    else
        ParticleManager:SetParticleControlEnt(self.particleId, 1, ent, PATTACH_ABSORIGIN_FOLLOW, nil, Vector(0, 0, 0), true)
    end
end

function FollowLightningEffect:setStartLocation(loc)
    ParticleManager:SetParticleControl(self.particleId, 0, loc)
end

function FollowLightningEffect:setEndLocation(loc)
    ParticleManager:SetParticleControl(self.particleId, 1, loc)
end