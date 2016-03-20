--- Spell warlock_shield

WarpZone = Spell:new{id='warlock_warpzone'}

--- Params
-- duration
-- time_scale

function WarpZone:onCast(cast_info)
	-- Dir, dist
	local target = cast_info.target
	local dir = target - cast_info.caster_actor.location
	dir.z = 0
	local dist = dir:Length()
	dir = dir:Normalized()
	
	local range = cast_info:attribute("range")
	local radius = cast_info:attribute("radius")
	local duration = cast_info:attribute("duration")
	local time_scale = cast_info:attribute("time_scale")
	local owner = cast_info.caster_actor.owner
	
	-- Set max range
	if dist > range then
		target = cast_info.caster_actor.location + range * dir
	end

	-- Create the warp zone actor
	local actor = WarpZoneActor:new {
		location = target,
		owner = owner,
		lifetime = duration * owner.mastery_factor[Player.MASTERY_DURATION],
		radius = radius,
		static = true,
		time_scale_change = time_scale
	}
end

----- Actor -----
--- Params
-- time_scale_change

WarpZoneActor = class(Actor)

function WarpZoneActor:init(def)
	WarpZoneActor.super.init(self, def)
	
	-- Add to temp actors so it gets removed on new round etc.
	GAME:addTempActor(self)
	
	self.time_scale_change = def.time_scale_change
	self.scaled_actors = {}
	self.radius_sq = def.radius * def.radius
	
	-- Add a CC to the actor
	self:addCollisionComponent {
		id = 'warpzone',
		channel 	= CollisionComponent.CHANNEL_PROJECTILE,
		coll_mat 	= CollisionComponent.createCollMatSimple(
			{Player.ALLIANCE_ENEMY},
			{CollisionComponent.CHANNEL_PROJECTILE}),
		radius 		= def.radius,
		ellastic 	= false,
		class 		= WarpZoneCollisionComponent,
		coll_initiative = -5,
		accept_damage = false,
		warp_zone_actor = self
	}
	
	self.task = GAME:addTask {
		period = 0.1,
		func = function()
			self:checkActors()
		end
	}
	
	-- Add an effect
	self.locust = CreateUnitByName(Config.LOCUST_UNIT, self.location, true, nil, nil, DOTA_TEAM_NOTEAM)
    local locust_abil = self.locust:FindAbilityByName("warlock_tech_locust")
    locust_abil:SetLevel(1)
	
	self.effect = ParticleManager:CreateParticle("particles/warpzone.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.locust)
	ParticleManager:SetParticleControl(self.effect, 1, Vector(def.radius, 1, 1))
end

function WarpZoneActor:onDestroy()
	WarpZoneActor.super.onDestroy(self)

	for actor, _ in pairs(self.scaled_actors) do
		self:unscaleActor(actor)
	end
	
	self.task:cancel()
	
	-- Remove the effect
	ParticleManager:DestroyParticle(self.effect, false)
	self.effect = nil
	self.locust:Destroy()
	
	GAME:removeTempActor(self)
end

function WarpZoneActor:scaleActor(actor)
	self.scaled_actors[actor] = true
	actor.time_scale = actor.time_scale * self.time_scale_change
end

function WarpZoneActor:unscaleActor(actor)
	actor.time_scale = actor.time_scale / self.time_scale_change
end

function WarpZoneActor:checkActors()
	local to_remove = {}
	
	for actor, _ in pairs(self.scaled_actors) do
		local delta = actor.location - self.location
		
		if delta:Dot(delta) > self.radius_sq then
			self:unscaleActor(actor)
			table.insert(to_remove, actor)
		end
	end
	
	for i, actor in pairs(to_remove) do
		self.scaled_actors[actor] = nil
	end
end

------ Collision Component -------
WarpZoneCollisionComponent = class(CollisionComponentSphere)

function WarpZoneCollisionComponent:init(def)
	WarpZoneCollisionComponent.super.init(self, def)
	
	self.warp_zone_actor = def.warp_zone_actor
end

function WarpZoneCollisionComponent:onCollision(coll_info)
	WarpZoneCollisionComponent.super.onCollision(self, coll_info)
	
	local actor = coll_info.actor
	
	-- Scale colliding projectiles, hardcoded exceptions
	if not self.warp_zone_actor.scaled_actors[actor] and 
		not actor:instanceof(WarpZoneActor) and 
		not actor:instanceof(MeteorProjectile) then
			
		self.warp_zone_actor:scaleActor(actor)
	end
end

function WarpZoneCollisionComponent:collisionFilter(other_cc)
	-- returns notify_self, notify_other, ellastic
	local alliance = self.actor.owner:getAlliance(other_cc.actor.owner)

	if(self.coll_mat[alliance][other_cc.channel]) then
		return true, false, self.ellastic
	end

	return false, false, false
end
