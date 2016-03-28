RechargeProjectile = class(SimpleProjectile)

--- Params
-- speed
-- damage
-- ttl (time to live)

function RechargeProjectile:init(def)
	RechargeProjectile.super.init(self, def)

	-- Extract
	self.hit_sound = def.hit_sound
	self.hit_effect = def.hit_effect
	self.refresh_projectile_effect = def.refresh_projectile_effect
	self.refresh_hit_sound = def.refresh_hit_sound
end

function RechargeProjectile:onCollision(coll_info, cc)
    RechargeProjectile.super.onCollision(self, coll_info, cc)

	if self.hit_sound and self.effect and self.effect.locust then
		self.effect.locust:EmitSound(self.hit_sound)
	end

	if coll_info.actor:instanceof(Pawn) then
		if self.hit_effect then
			Effect:create(self.hit_effect, { location = self.location })
		end

		self:spawnRefreshProjectile()
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
