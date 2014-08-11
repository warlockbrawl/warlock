DrainProjectile = class(Projectile)

--- Params
-- damage
-- hit_sound
-- ally_mod
-- heal_hit_sound
-- enemy_mod
-- changed_speed
-- buff_duration
-- heal_projectile_effect

function DrainProjectile:init(def)
	self.damage = def.damage or 0
	self.hit_sound = def.hit_sound
	self.heal_hit_sound = def.heal_hit_sound
	self.ally_mod = def.ally_mod
	self.enemy_mod = def.enemy_mod
	self.changed_speed = def.changed_speed
	self.buff_duration = def.buff_duration
	self.heal_projectile_effect = def.heal_projectile_effect

	DrainProjectile.super.init(self, def)

	-- Enable collision with allies
	local cc = self.collision_components["projectile"]
	cc.coll_mat[Player.ALLIANCE_ALLY][CollisionComponent.CHANNEL_PLAYER] = true

	-- Start the timer for changing acceleration
	self.timer = self:addTimer {
		time = def.lifetime - def.extra_time,
		func = function()
			self:changeDirection()
		end
	}
end

function DrainProjectile:changeDirection()
	local min_dist_sq = 99999999
	local min_dir
	local min_pawn
	
	-- Get closest enemy or allied pawn
	for pawn, _ in pairs(GAME.pawns) do
		if pawn.owner:getAlliance(self.instigator.owner) ~= Player.ALLIANCE_SELF then
			local dir = pawn.location - self.location
			local dist_sq = dir:Dot(dir)
			if dist_sq < min_dist_sq then
				min_dist_sq = dist_sq
				min_dir = dir
				min_pawn = pawn
			end
		end
	end
	
	-- Change the velocity to go towards the found pawn
	if min_pawn ~= nil then
		self.velocity = min_dir:Normalized()
	else
		self.velocity = self.velocity:Normalized()
	end

	self.velocity = self.velocity * self.changed_speed
end

function DrainProjectile:onCollision(coll_info, cc)
	self.task = nil
	
	local actor = coll_info.actor
	local alliance = actor.owner:getAlliance(self.instigator.owner)

	if actor:instanceof(Pawn) then
		if alliance == Player.ALLIANCE_ALLY then
			-- Heal and speedbuff allies
			actor:heal {
				source = self.instigator,
				amount = self.damage
			}

			-- Add speed buff, affected by duration mastery
			GAME:addModifier(Modifier:new {
				pawn = actor,
				speed_bonus_abs = 50,
				time = actor:getBuffDuration(self.buff_duration, self.instigator),
				native_mod = self.ally_mod
			})

			-- Play a sound
			-- TODO: maybe not use the effects locust
			if self.heal_hit_sound and self.effect and self.effect.locust then
				self.effect.locust:EmitSound(self.heal_hit_sound)
			end
		else
			-- Deal damage to enemies
			actor:receiveDamage {
				source = self.instigator or self,
				hit_normal = coll_info.hit_normal,
				amount 	= self.damage,
				knockback_factor = 0.2
			}

			-- Slow enemies, affected by duration mastery
			GAME:addModifier(Modifier:new {
				pawn = actor,
				speed_bonus_abs = -50,
				time = actor:getDebuffDuration(7.5, self.instigator),
				native_mod = self.enemy_mod
			})
		
			-- Spawn heal projectile homing towards instigator
			DrainHealProjectile:new {
				instigator = self.instigator,
				location = self.location,
				coll_radius = coll_radius,
				target = self.instigator,
				heal_amount = self.damage,
				projectile_effect = self.heal_projectile_effect,
				hit_sound = self.heal_hit_sound,
				hit_effect = self.heal_hit_effect
			}
			
			-- Play a sound
			-- TODO: maybe not use the effects locust
			if self.hit_sound and self.effect and self.effect.locust then
				self.effect.locust:EmitSound(self.hit_sound)
			end
		end
		
		-- destroy
		if not self.scheduled_destruction then
			self.scheduled_destruction = true
			self:setLifetime(0)
		end
	elseif actor:instanceof(Obstacle) then
		if self:isMovingTowards(coll_info.hit_normal) then
			self:reflectVelocity(coll_info.hit_normal)
		end
	end
end

function DrainProjectile:onDestroy()
	DrainProjectile.super.onDestroy(self)
	
	if self.timer then
		self:removeTimer(self.timer)
	end
end
