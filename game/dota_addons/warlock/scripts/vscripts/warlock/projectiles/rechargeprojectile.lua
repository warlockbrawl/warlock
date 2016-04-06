RechargeProjectile = class(Projectile)

--- Params
-- speed
-- damage
-- ttl (time to live)

function RechargeProjectile:init(def)
	RechargeProjectile.super.init(self, def)

	-- Extract
	self.original_instigator = def.instigator
	self.hit_sound = def.hit_sound
	self.hit_effect = def.hit_effect
	self.refresh_projectile_effect = def.refresh_projectile_effect
	self.refresh_hit_sound = def.refresh_hit_sound
	self.collided_pawn = false
	self.damage = def.damage
end

function RechargeProjectile:onDestroy()
	RechargeProjectile.super.onDestroy(self)

	-- Increment consecutive hits if a pawn was hit and the projectile was 
	-- not reflected (ie. owner / instigator changed)
	if self.collided_pawn and self.instigator == self.original_instigator then
		Recharge.incrementConsecutiveCount(self.original_instigator)

		-- Display consecutive count text
		GAME:showFloatingNum {
			num = Recharge.getConsecutiveCount(self.original_instigator),
			location = self.original_instigator.location,
			duration = 1,
			color = Vector(150, 30, 240)
		}
	else
		-- Reset consecutive hit count when no pawn was hit
		-- This is also executed when destroyed on new rounds etc.
		Recharge.resetConsecutiveCount(self.original_instigator)
	end
end

function RechargeProjectile:onCollision(coll_info, cc)
    RechargeProjectile.super.onCollision(self, coll_info, cc)

	if self.hit_sound and self.effect and self.effect.locust then
		self.effect.locust:EmitSound(self.hit_sound)
	end

	if coll_info.actor:instanceof(Pawn) then
		coll_info.actor:receiveDamage {
			source		= self.instigator or self,
			hit_normal	= coll_info.hit_normal,
			amount		= self.damage or 0,
		}

		if self.hit_effect then
			Effect:create(self.hit_effect, { location = self.location })
		end

		self.collided_pawn = true

		self:spawnRefreshProjectile()

		self:destroy()
	elseif coll_info.actor:instanceof(Obstacle) then
		if self:isMovingTowards(coll_info.hit_normal) then
			self:reflectVelocity(coll_info.hit_normal)
		end
	else
		self:destroy()
	end
end

function RechargeProjectile:spawnRefreshProjectile()
	-- Spawn heal projectile homing towards instigator
	RechargeRefreshProjectile:new {
		instigator = self.instigator,
		location = self.location,
		coll_radius = coll_radius,
		target = self.instigator,
		projectile_effect = self.refresh_projectile_effect,
		hit_sound = self.refresh_hit_sound,
	}
end
