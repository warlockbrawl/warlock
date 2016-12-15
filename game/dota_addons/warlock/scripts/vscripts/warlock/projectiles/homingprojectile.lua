HomingProjectile = class(Projectile)

function HomingProjectile:init(def)
	self.damage = def.damage or 0
	self.speed = def.speed
	self.explode_effect = def.explode_effect
	self.explode_radius = def.explode_radius
	self.burnout_effect = def.burnout_effect

	HomingProjectile.super.init(self, def)

	local cc = self.collision_components["projectile"]
	cc.coll_mat[Player.ALLIANCE_SELF][CollisionComponent.CHANNEL_PLAYER] = true
	cc.coll_initiative = -1
	
	self:acquireTarget(def.target)
end

function HomingProjectile:onCollision(coll_info, cc)
    HomingProjectile.super.onCollision(self, coll_info, cc)

	local actor = coll_info.actor

	if actor:instanceof(Pawn) then
		local alliance = actor.owner:getAlliance(self.instigator.owner)
		if alliance == Player.ALLIANCE_ENEMY then
			-- Damage enemies
			actor:receiveDamage {
				source		= self.instigator,
				hit_normal	= coll_info.hit_normal,
				amount		= self.damage
			}
		else
			-- Spawn an effect
			if self.explode_effect then
				Effect:create(self.explode_effect, { location=actor.location })
			end
			
			local bonus_speed = 50
			local explode_radius = self.explode_radius
			
			-- Thrust/Homing combo (burnout), increased bonus ms and radius
			if actor:hasModifierOfType(ThrustModifier) then
				if self.burnout_effect then
					Effect:create(self.burnout_effect, { location=actor.location })
				end
				
				bonus_speed = 120
				explode_radius = explode_radius * 1.05
			end
			
			-- AOE Damage
			self.instigator:damageArea(self.location, self.explode_radius, { 
				amount_min = 0, 
				amount_max = self.damage,
				knockback_factor = 0.9
			})
		
			-- Add speed buff
			GAME:addModifier(Modifier:new {
				pawn = actor,
				speed_bonus_abs = bonus_speed,
				time = actor:getBuffDuration(4, self.instigator),
				native_mod = "modifier_chen_test_of_faith_teleport"
			})
		end
	end
	
	-- destroy
	self:setLifetime(0)
end

-- Tries to find a new target closest to loc
function HomingProjectile:acquireTarget(loc)
	local min_dst_sq = 999999999
	local min_pawn
	
	for pawn, _ in pairs(GAME.pawns) do
		local alliance = pawn.owner:getAlliance(self.instigator.owner)
		if alliance == Player.ALLIANCE_ENEMY then
			local delta = loc - pawn.location
			local dst_sq = delta:Dot(delta)
			if dst_sq < min_dst_sq then
				min_dst_sq = dst_sq
				min_pawn = pawn
			end
		end
	end
	
	-- Set target, can be nil
	self.target = min_pawn
end

function HomingProjectile:onPreTick(dt)
	local acquire_new_target = (self.target == nil) or
		(self.target ~= nil and 
		self.instigator.owner:getAlliance(self.target.owner) ~= Player.ALLIANCE_ENEMY)
		or (not self.target.enabled)
	
	if acquire_new_target then
		self:acquireTarget(self.location)
	end
	
	if self.target then
		local v = self.speed * (self.target.location - self.location):Normalized()
		self.velocity = Homing.home_alpha * self.velocity + (1 - Homing.home_alpha) * v
	end
end
