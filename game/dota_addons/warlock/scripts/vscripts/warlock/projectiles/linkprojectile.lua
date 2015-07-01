LinkProjectile = class(Projectile)

--- Params
-- speed
-- damage
-- retract_time

function LinkProjectile:init(def)
	self.speed = def.speed
	self.damage = def.damage
	self.retract_time = def.retract_time
	self.hit_sound = def.hit_sound

	LinkProjectile.super.init(self, def)

	-- Set the correct coll matrix
	local coll_mat = { }
	coll_mat[Player.ALLIANCE_SELF] = {}
	coll_mat[Player.ALLIANCE_ALLY] = {}
	coll_mat[Player.ALLIANCE_ENEMY] = {}

	coll_mat[Player.ALLIANCE_ALLY][CollisionComponent.CHANNEL_PLAYER] = true
	coll_mat[Player.ALLIANCE_ENEMY][CollisionComponent.CHANNEL_PLAYER] = true
	coll_mat[Player.ALLIANCE_ENEMY][CollisionComponent.CHANNEL_OBSTACLE] = true

	self.collision_components["projectile"].coll_mat = coll_mat
	self.collision_components["projectile"].coll_initiative = -1

	self:addTimer
	{
		time = def.retract_time,
		func = function()
			self:retract()
		end
	}
end

function LinkProjectile:onCollision(coll_info, cc)
	local actor = coll_info.actor

	if(actor:instanceof(Pawn)) then
		-- Add the link modifier that pushes the pawn towards the target
		GAME:addModifier(LinkModifier:new {
			pawn = actor,
			target = self.instigator,
			damage = self.damage
		})
	elseif(coll_info.actor:instanceof(Obstacle)) then
		-- Add the link modifier that pushes the pawn towards the target
		GAME:addModifier(LinkModifier:new {
			pawn = self.instigator,
			target = actor
		})
	end
	
	-- Destroy the projectile, the target is now linked
	self:destroy()
end

function LinkProjectile:retract()
	self.retract = true
end

function LinkProjectile:onPreTick(dt)
	if self.retract then
		local delta = self.instigator.location - self.location
		local dstSq = delta:LengthSquared()
		
		if dstSq < 75*75 then
			self:destroy()
		else
			local dir = delta:Normalized()
			self.velocity = self.speed * dir
		end
	end
end
