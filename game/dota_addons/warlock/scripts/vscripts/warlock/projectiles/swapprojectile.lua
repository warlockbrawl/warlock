SwapProjectile = class(Projectile)

function SwapProjectile:init(def)
	SwapProjectile.super.init(self, def)

	self.end_time = def.end_time
	self.swap_sound = def.swap_sound
	self.swap_effect = def.swap_effect

	-- Set the correct coll matrix
	local coll_mat = { }
	coll_mat[Player.ALLIANCE_SELF] = {}
	coll_mat[Player.ALLIANCE_ALLY] = {}
	coll_mat[Player.ALLIANCE_ENEMY] = {}

	coll_mat[Player.ALLIANCE_ALLY][CollisionComponent.CHANNEL_PLAYER] = true
	coll_mat[Player.ALLIANCE_ENEMY][CollisionComponent.CHANNEL_PLAYER] = true
	
	-- Only enable swapping pillars in the actual game, not in shoptime
	if GAME.combat then
		coll_mat[Player.ALLIANCE_ENEMY][CollisionComponent.CHANNEL_OBSTACLE] = true
	end

	self.collision_components["projectile"].coll_mat = coll_mat

	self.swapped = false
end

function SwapProjectile:onCollision(coll_info, cc)
    SwapProjectile.super.onCollision(self, coll_info, cc)

	-- Swap the locations
	local self_loc = self.instigator.location
	self.instigator.location = coll_info.actor.location
	self.instigator:_updateLocation()

	coll_info.actor.location = self_loc
	coll_info.actor:_updateLocation()

	self.swapped = true

	Effect:create(self.swap_effect, { location=self_loc })
	Effect:create(self.swap_effect, { location=self.instigator.location })

    -- Stop movement
	self.instigator.unit:Stop()

	self:setLifetime(0)
end

function SwapProjectile:onDestroy()
	SwapProjectile.super.onDestroy(self)

	-- Play a sound
	if self.swap_sound then
		self.instigator.unit:EmitSound(self.swap_sound)
	end

	if not self.swapped then
		Effect:create(self.swap_effect, { location=self.instigator.location })

		-- Set location of pawn at correct time
		self.instigator.location = self.location + self.death_timer.time_left * self.velocity

        -- Stop movement
	    self.instigator.unit:Stop()

		Effect:create(self.swap_effect, { location=self.instigator.location })
	end
end
