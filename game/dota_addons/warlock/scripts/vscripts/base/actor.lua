--- Actor is the unit in mod's terms
-- @author Krzysztof Lis (Adynathos)

-------------------------------------------------------------------------------
-- Actor = physics object, unit
-------------------------------------------------------------------------------
Actor = class()

function Actor:init(def)
	self.name 		= def.name or 'actor'
	self.unit		= def.unit
	self.owner 		= def.owner
	self.location 	= def.location or Vector(0, 0, Config.GAME_Z)
	self.velocity 	= def.velocity or Vector(0, 0, 0)
	self.mass 		= def.mass or 1
	self.static		= def.static or false -- static means its vel will allways be zero
	self.time_scale	= def.time_scale or 1
	self.collision_components = {}

	if def.lifetime and def.lifetime > 0 then
		self:setLifetime(def.lifetime)
	end

	if self.unit then
		GAME.entityActor[self.unit] = self
	end

	self.exists = true

	self:enable()
end

function Actor:enable()
	self.enabled = true
	GAME:_addActor(self)
end

function Actor:disable()
	self.enabled = false
	GAME:_removeActor(self)
end

function Actor:addCollisionComponent(cc_def)
	local cc_class = cc_def.class or CollisionComponentSphere

	cc_def.actor = self

	local cc = cc_class:new(cc_def)

	self.collision_components[cc.id] = cc

	if self.enabled then
		GAME:_addCC(cc)
	end
end

function Actor:removeCollisionComponent(cc_id)
	local cc = self.collision_components[cc_id]

	self.collision_components[cc_id] = nil
	GAME.phys_active_ccs:remove(cc)
end

function Actor:_updateLocation()
end

function Actor:_arenaBoundsCheck()
	-- check if inside bounds
	if self.location:Dot(self.location) >= Config.GAME_ARENA_RADIUS_SQ then

		-- if outside, move to the border
		local radial = self.location:Normalized()
		radial.z = 0

		self.location = radial*Config.GAME_ARENA_RADIUS
		self.location.z = Config.GAME_Z

		-- bounce the velocity
		self.velocity = self.velocity - self.velocity:Dot(radial) * radial

		self:onArenaBoundCollision()
	end
end

function Actor:applyMomentum(mom)
	if not self.static then
		self.velocity = self.velocity + mom / self.mass
	end
end

function Actor:isMovingTowards(normal)
	return normal:Dot(self.velocity) > 0
end

function Actor:reflectVelocity(normal)
	self.velocity = self.velocity - 2 * normal:Dot(self.velocity) * normal
end

function Actor:destroy()
	if not self.exists then
		return
	end

	self.exists = false

	self:onDestroy()
	GAME:_removeActor(self)
end

function Actor:setLifetime(lifetime)	
	self.time_to_live = lifetime
end

function Actor:receiveDamage(dmg_info)
	-- dmg_info
	--	amount = damage amount (scalar)
	--	source = actor which deals the dmg
	--	hit_normal = direction in which the dmg is dealt

	-- the default implementation does nothing
end

function Actor:onDestroy()
end

function Actor:onPreTick(dt)
end

function Actor:onPostTick(dt)
	-- Lifetime handling
	if self.time_to_live then
		self.time_to_live = self.time_to_live - dt * self.time_scale
		if self.time_to_live <= 0 then
			self:destroy()
		end
	end
end

function Actor:onCollision(coll_info, cc)
	-- Notify game about collision for modifiers
	GAME:modOnCollision(coll_info, cc)
end

function Actor:onArenaBoundCollision()
end

-------------------------------------------------------------------------------
-- Game: actor interface
-------------------------------------------------------------------------------
function Game:_addActor(actor)
	self.actors:add(actor)

	for id, cc in pairs(actor.collision_components) do
		self.phys_active_ccs:add(cc)
	end
end

function Game:_addCC(cc)
	self.phys_active_ccs:add(cc)
end

function Game:_removeActor(actor)
	self.actors:remove(actor)

	for id, cc in pairs(actor.collision_components) do
		self.phys_active_ccs:remove(cc)
	end
end

function Game:filterActors(filter)
	local actors = {}

	if(not filter) then
		log("Warning: filter in filterActors was nil, returning empty list")
		return actors
	end

	for actor, _ in pairs(GAME.actors) do
		if(filter(actor)) then
			table.insert(actors, actor)
		end
	end

	return actors
end

function Game:actorsOfType(type)
	return self:filterActors(function(actor)
		return actor:instanceof(type)
	end)
end
