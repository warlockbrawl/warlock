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

	self.ellipse_dir = delta:Normalized()

	self.virtual_location = self:getEllipseLocation() -- unrotated ellipse location
	self.prev_unrotated_velocity = Vector(0, 0, 0) -- previously applied unrotated velocity

	self.speed = def.speed
end

function TwinProjectile:onCollision(coll_info, cc)
    TwinProjectile.super.onCollision(self, coll_info, cc)

	-- Deal damage
	coll_info.actor:receiveDamage{
		source		= self.instigator or self,
		hit_normal	= coll_info.hit_normal,
		amount = self.damage or 0,
	}

	if coll_info.actor:instanceof(Pawn) then
		-- Spawn an effect
		local effect = Effect:create(self.hit_effect, { location=coll_info.actor.location })
		effect:setControlPoint(0, coll_info.actor.location)
		effect:setControlPoint(1, coll_info.actor.location)
		effect:setControlPoint(2, coll_info.actor.location)

		-- Play a sound
		-- TODO: maybe not use the effects locust
		if self.hit_sound and self.effect and self.effect.locust then
			self.effect.locust:EmitSound(self.hit_sound)
		end
	end

	self:setLifetime(0)
end

function TwinProjectile:getEllipseLocation()
	return Vector(self.ellipse_a * math.cos(self.ellipse_t),
                  self.ellipse_sign * self.ellipse_b * math.sin(self.ellipse_t),
                  0)
end

function TwinProjectile:getEllipseVelocity()
	return Vector(-self.ellipse_a * math.sin(self.ellipse_t),
	              self.ellipse_sign * self.ellipse_b * math.cos(self.ellipse_t),
                  0)
end

function TwinProjectile:rotateEllipseVector(vec)
	return Vector(self.ellipse_dir[1] * vec[1] - self.ellipse_dir[2] * vec[2],
				  self.ellipse_dir[2] * vec[1] + self.ellipse_dir[1] * vec[2],
				  0)
end

function TwinProjectile:onPreTick(dt)
	-- Calculate d Ellipse(t) / dt to determine timestep needed for constant velocity
	local ellipse_vel = self:getEllipseVelocity()

	local ellipse_dt = dt * self.speed / ellipse_vel:Length()
	ellipse_dt = max(0.001, ellipse_dt)

	-- Advance ellipse time by determined timestep
	self.ellipse_t = min(math.pi, self.ellipse_t + ellipse_dt)

	-- Calculate new location on ellipse at Ellipse(t)
	local ellipse_loc = self:getEllipseLocation()

	-- Calculate velocity required to move from old to new ellipse location
	-- Potential issue if dt is not fixed every frame
	local unrotated_velocity = (ellipse_loc - self.virtual_location) / dt
	self.virtual_location = ellipse_loc

	-- Rotate the velocity vectors
	local new_applied_velocity = self:rotateEllipseVector(unrotated_velocity)
	local old_applied_velocity = self:rotateEllipseVector(self.prev_unrotated_velocity)

	self.prev_unrotated_velocity = unrotated_velocity

	-- Subtract old applied velocity and add the new one
	self.velocity = self.velocity - old_applied_velocity + new_applied_velocity

	-- Destroy if end of ellipse was reached
	if self.ellipse_t >= math.pi then
		self:setLifetime(0)
	end
end

function TwinProjectile:reflectVelocity(normal)
	TwinProjectile.super.reflectVelocity(self, normal)

	-- Reflect the ellipse direction too
	self.ellipse_dir = self.ellipse_dir - 2 * normal:Dot(self.ellipse_dir) * normal
end
