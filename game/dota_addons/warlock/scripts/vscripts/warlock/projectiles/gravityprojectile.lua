GravityProjectile = class(Projectile)

function GravityProjectile:init(def)
	-- extract data
	self.instigator = def.instigator
	self.strength = def.strength
	self.damage = def.damage

	if self.instigator then
		def.owner = self.instigator.owner
	end

	if (not def.location) and self.instigator then
		def.location = self.instigator.location
	end

	-- actor constructor
	Projectile.super.init(self, def)

	-- effect
	if def.projectile_effect then
		self.effect = Effect:create(def.projectile_effect, {location=self.location})
	end
	
	self:addCollisionComponent{
		id 					= 'gravity',
		channel 			= def.coll_channel or CollisionComponent.CHANNEL_PROJECTILE,
		coll_mat = CollisionComponent.createCollMatSimple(
			{Player.ALLIANCE_ENEMY, Player.ALLIANCE_SELF, Player.ALLIANCE_ALLY},
			{CollisionComponent.CHANNEL_OBSTACLE}),
		radius 				= (def.coll_radius or 1)
	}
	
	-- Add the damage task
	self.task = GAME:addTask {
		period = 0.2,
		func = function()
			self:damageTick(0.2)
		end
	}
end

function GravityProjectile:onDestroy()
	GravityProjectile.super.onDestroy(self)
	self.task:cancel()
end

function GravityProjectile:onCollision(coll_info, cc)
	if self:isMovingTowards(coll_info.hit_normal) then
		self:reflectVelocity(coll_info.hit_normal)
	end
end

-- Applies damage to close enemy pawns
function GravityProjectile:damageTick(dt)
	for pawn, _ in pairs(GAME.pawns) do
		if pawn.owner:getAlliance(self.instigator.owner) == Player.ALLIANCE_ENEMY then
			local delta = self.location - pawn.location
			if delta:Dot(delta) <= 62500 then -- 250*250
				pawn:receiveDamage {
					source = self.instigator or self,
					amount = self.damage * dt
				}
			end
		end
	end
end

function GravityProjectile:onPreTick(dt)
	-- Iterate over all actors
	for actor, _ in pairs(GAME.actors) do
		-- Only influence pawns and projectiles (hardcoded not to influence some projectiles atm)
		local is_pawn = actor:instanceof(Pawn)
		local is_proj = actor:instanceof(Projectile) 
			and not actor:instanceof(MeteorProjectile)
			and not actor:instanceof(GravityProjectile)
		
		if(is_pawn or is_proj) then
			local dir = self.location - actor.location
			local dist = dir:Length()

			if(is_pawn and self.instigator.owner.team ~= actor.owner.team) then
				-- Apply velocity for pawns that are close
				if(dist <= 450) then
					dir = dir:Normalized()
					actor.velocity = actor.velocity + self.strength * (1 - dist * dist / 202500) * dir * dt
				end
			elseif(is_proj) then
				-- Apply velocity for projectiles that are close
				if(dist <= 600) then
					dir = dir:Normalized()
					actor.velocity = actor.velocity + 1650 * (1.5 - dist * dist / 360000) * dir * dt
				end
			end
		end
	end
end
