TwinProjectile = class(Projectile)

function TwinProjectile:init(def)
	TwinProjectile.super.init(self, def)

	self.damage = def.damage or 0
	self.hit_sound = def.hit_sound
	self.hit_effect = def.hit_effect

	local delta = def.location - def.target

	self.ellipse_a = delta:Length() / 2
	self.ellipse_b = def.ellipse_area / (math.pi * self.ellipse_a)
	self.ellipse_t = 0

	self.ellipse_sign = def.ellipse_sign

	self.ellipse_angle = math.atan2(delta.y, delta.x)

	self.virtual_velocity = Vector(0, 0, 0)

	self.speed = def.speed
end

function TwinProjectile:onCollision(coll_info, cc)
    TwinProjectile.super.onCollision(self, coll_info, cc)

	if coll_info.actor:instanceof(Pawn) then
		-- Deal damage
		coll_info.actor:receiveDamage{
			source		= self.instigator or self,
			hit_normal	= coll_info.hit_normal,
			amount = self.damage or 0,
		}
		
		-- Spawn an effect
		local effect = Effect:create(self.hit_effect, { location=coll_info.actor.location })
		effect:setControlPoint(0, coll_info.actor.location)
		effect:setControlPoint(1, coll_info.actor.location)

		-- Play a sound
		-- TODO: maybe not use the effects locust
		if self.hit_sound and self.effect and self.effect.locust then
			self.effect.locust:EmitSound(self.hit_sound)
		end
	end

	self:setLifetime(0)
end

function TwinProjectile:onPreTick(dt)
	local vx = -self.ellipse_a * math.sin(self.ellipse_t)
	local vy = self.ellipse_sign * self.ellipse_b * math.cos(self.ellipse_t)

	local ellipse_dt = dt * self.speed / math.sqrt(vx*vx + vy*vy)
	ellipse_dt = max(0.001, ellipse_dt)

	self.ellipse_t = self.ellipse_t + ellipse_dt

	-- Rotate the ellipse
	local vx_rot = math.cos(self.ellipse_angle) * vx - math.sin(self.ellipse_angle) * vy
	local vy_rot = math.sin(self.ellipse_angle) * vx + math.cos(self.ellipse_angle) * vy

	local new_virtual_velocity = Vector(vx_rot, vy_rot, 0) * ellipse_dt / dt

	self.velocity = self.velocity - self.virtual_velocity + new_virtual_velocity

	self.virtual_velocity = new_virtual_velocity

	if self.ellipse_t >= 1.07 * math.pi then
		self:setLifetime(0)
	end
end

function TwinProjectile:negateAngle()
	self.ellipse_angle = -self.ellipse_angle
end
