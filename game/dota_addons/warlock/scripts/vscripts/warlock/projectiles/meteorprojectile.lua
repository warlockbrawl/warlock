MeteorProjectile = class(Projectile)

--- Params
-- instigator
-- radius
-- damage_min
-- damage_max
-- target
-- hover_time
-- fall_time
--- Optional
-- height = 700
-- offset = 400

function MeteorProjectile:init(def)
	-- extract data
	self.explode_effect = def.explode_effect
	self.instigator = def.instigator
	self.radius = def.radius
	self.damage_min = def.damage_min
	self.damage_max = def.damage_max
	self.target = def.target
	self.hover_time = def.hover_time
	self.fall_time = def.fall_time
	
	self.height = def.height or 700
	local offset = def.offset or 400
	
	-- For visual hovering we need the time
	self.creation_time = GAME:time()

	self.falling = false

	if self.instigator then
		def.owner = self.instigator.owner
	end

	local caster_loc = self.instigator.location
	
	-- Calculate direction and distance
	local dir = self.target - caster_loc
	dir.z = 0
	local dist = dir:Length()
	dir = dir:Normalized()
	
	-- Restrict the range
	if(dist > def.range) then
		dist = def.range
		self.target = caster_loc + dir * dist
	end
	
	-- Set the initial location of the meteor
	def.location = caster_loc + dir * dist - offset * dir
	def.location.z = self.height

	-- actor constructor
	Projectile.super.init(self, def)

	-- effect
	if def.projectile_effect then
		self.effect = Effect:create(def.projectile_effect, { location = self.location, duration = -1})
	end

	-- Start a timer for the meteor to fall
	self.task = GAME:addTask {
		time = self.hover_time,
		func = function()
			self:fall()
		end
	}
end

function MeteorProjectile:onDestroy()
	MeteorProjectile.super.onDestroy(self)
	
	-- Cancel tasks if any
	if(self.task) then
		self.task:cancel()
	end
end

function MeteorProjectile:fall()
	self.falling = true
	self.velocity = (self.target - self.location) / self.fall_time
	
	-- Start a timer for the meteor to explode
	self.task = GAME:addTask {
		time = self.fall_time,
		func = function()
			self:explode()
		end
	}
end

-- Called when the meteor ends its lifetime (ie. hits the ground)
function MeteorProjectile:explode()
	self.task = nil
	self.instigator:damageArea(self.target, self.radius, { 
			amount_min = self.damage_min, 
			amount_max = self.damage_max,
			knockback_factor = 0.66
	})

	local effect = Effect:create(self.explode_effect, { location=self.target })

	self:destroy()
end

function MeteorProjectile:onPreTick(dt)
	if(self.falling) then
		-- Spin (disabled because it doesnt work correctly with scale not 1
		--self.effect:setAngles(self.effect.angles.x + 150 * dt, self.effect.angles.y + 180 * dt, self.effect.angles.z + 210 * dt)
	else
		-- Hover
		self.location.z = self.height + 50 * math.sin(math.pi / self.hover_time * (GAME:time() - self.creation_time))
	end
	
	self.effect.location = self.location
end
