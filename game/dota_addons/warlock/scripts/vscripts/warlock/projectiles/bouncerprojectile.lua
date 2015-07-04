BouncerProjectile = class(Projectile)

--- Params
-- speed
-- damage
-- ttl (time to live)

function BouncerProjectile:init(def)
	self.speed = def.speed
	self.damage = def.damage
	self.ttl = def.ttl
	self.hit_sound = def.hit_sound

	BouncerProjectile.super.init(self, def)

	-- Set the correct coll matrix
	local coll_mat = { }
	coll_mat[Player.ALLIANCE_SELF] = {}
	coll_mat[Player.ALLIANCE_ALLY] = {}
	coll_mat[Player.ALLIANCE_ENEMY] = {}

	coll_mat[Player.ALLIANCE_SELF][CollisionComponent.CHANNEL_PLAYER] = true
	coll_mat[Player.ALLIANCE_ALLY][CollisionComponent.CHANNEL_PLAYER] = true
	coll_mat[Player.ALLIANCE_ENEMY][CollisionComponent.CHANNEL_PLAYER] = true
	coll_mat[Player.ALLIANCE_ENEMY][CollisionComponent.CHANNEL_PROJECTILE] = true
	coll_mat[Player.ALLIANCE_ENEMY][CollisionComponent.CHANNEL_OBSTACLE] = true

	self.collision_components["projectile"].coll_mat = coll_mat
	self.collision_components["projectile"].coll_initiative = -1

	-- Dont collide with instigator on spawn
	self.prev_hit = self.instigator

	self:setLifetime(self.ttl)
end

function BouncerProjectile:onCollision(coll_info, cc)
    BouncerProjectile.super.onCollision(self, coll_info, cc)

	if(coll_info.actor:instanceof(Pawn)) then
		-- Prevent hitting the previous target again
		if(coll_info.actor ~= self.prev_hit) then
			-- Play a sound
			-- TODO: maybe not use the effects locust
			if self.hit_sound and self.effect and self.effect.locust then
				self.effect.locust:EmitSound(self.hit_sound)
			end

			-- Damage enemies only
			if(self.instigator.owner:getAlliance(coll_info.actor.owner) == Player.ALLIANCE_ENEMY) then
				-- Deal damage to the hit object
				coll_info.actor:receiveDamage {
					source = self.instigator or self,
					hit_normal = coll_info.hit_normal,
					amount = self.damage or 0,
					knockback_factor = 1.2
				}

				-- Reduce the damage
				self.damage = self.damage * 0.7
			end

			-- Destroy if the damage is too low, otherwise extend
			if(self.damage >= 10) then
				self:nextTarget(coll_info.actor)
				self:setLifetime(self.ttl)
			else
				self:destroy()
			end

			self.prev_hit = coll_info.actor
		end
	elseif(coll_info.actor:instanceof(Obstacle)) then
		if self:isMovingTowards(coll_info.hit_normal) then
			self:reflectVelocity(coll_info.hit_normal)
		end
	else
		self:destroy()
	end
end

-- Returns the direction needed to hit target
function BouncerProjectile:getPredictedDir(target)
	local delta = self.location - target.location
	local a = delta:Dot(target.velocity)
	local b = target.velocity:Length()
	b = b * b - self.speed * self.speed
	local c = delta:Length()
	c = c * c

	local d = a * a - b * c

	-- No solution, return direct path
	if(d < 0) then
		return (-delta):Normalized()
	end

	d = math.sqrt(d)

	local t_a = (a + d) / b
	local t_b = (a - d) / b
	local t = 0

	if(t_a < 0 and t_b < 0) then
		-- No solution, return direct path
		return (-delta):Normalized()
	elseif(t_a >= 0) then
		t = t_a
	else
		t = t_b
	end

	return (target.velocity * t - delta) / (self.speed * t)
end

-- Acquires the next closest target which is not hit_target
function BouncerProjectile:nextTarget(hit_target)
	local min_dist = 9999999999
	local target = nil

	-- Search new closest enemy target
	for pawn, _ in pairs(GAME.pawns) do
		if(pawn ~= hit_target) then
			dist = (pawn.location - self.location):Length()
			if(dist < min_dist) then
				min_dist = dist
				target = pawn
			end
		end
	end

	if(target) then
		self.velocity = self.speed * self:getPredictedDir(target)
	end
end
