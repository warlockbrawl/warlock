MagnetizeProjectile = class(Projectile)

--- Params
-- hit_sound
-- end_sound
-- duration
-- native_mod

function MagnetizeProjectile:init(def)
	MagnetizeProjectile.super.init(self, def)

	-- Extract
	self.hit_sound = def.hit_sound
	self.end_sound = def.end_sound
	self.duration = def.duration
    self.native_mod = def.native_mod
    self.bounced = false

    -- Enable collision with allies and obstacles
    local cc = self.collision_components["projectile"]
	cc.coll_mat[Player.ALLIANCE_ALLY][CollisionComponent.CHANNEL_PLAYER] = true
    cc.coll_mat[Player.ALLIANCE_SELF][CollisionComponent.CHANNEL_PLAYER] = true
    cc.coll_mat[Player.ALLIANCE_ENEMY][CollisionComponent.CHANNEL_OBSTACLE] = true
    cc.coll_initiative = -1
end

function MagnetizeProjectile:onCollision(coll_info, cc)
    MagnetizeProjectile.super.onCollision(self, coll_info, cc)

	local actor = coll_info.actor

	if actor:instanceof(Pawn) then
        local alliance = actor.owner:getAlliance(self.instigator.owner)

        -- Only self-hit after a bounce
        if alliance == Player.ALLIANCE_SELF and not self.bounced then
            return
        end

		-- Play a hit sound
		if self.hit_sound then
			actor.unit:EmitSound(self.hit_sound)
		end

        local time = 0
        local sign = 0 -- Repel or attract

        if alliance == Player.ALLIANCE_ENEMY then
            sign = 1
            time = actor:getDebuffDuration(self.duration, self.instigator)
        else
            sign = -1
            time = actor:getBuffDuration(self.duration, self.instigator)
        end

		-- Add the grip modifier
		GAME:addModifier(MagnetizeModifier:new {
			pawn = actor,
			time = time,
			sign = sign,
			end_sound = self.end_sound,
            native_mod = self.native_mod,
		})

        -- destroy
	    self:setLifetime(0)
    elseif(actor:instanceof(Obstacle)) then
		if self:isMovingTowards(coll_info.hit_normal) then
			self:reflectVelocity(coll_info.hit_normal)
            self.bounced = true
		end
	else
        -- destroy
	    self:setLifetime(0)
    end
end
