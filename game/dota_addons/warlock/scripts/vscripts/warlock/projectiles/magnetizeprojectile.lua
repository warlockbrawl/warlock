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

    -- Enable collision with allies and obstacles
    local cc = self.collision_components["projectile"]
	cc.coll_mat[Player.ALLIANCE_ALLY][CollisionComponent.CHANNEL_PLAYER] = true
end

function MagnetizeProjectile:onCollision(coll_info, cc)
	local actor = coll_info.actor

    log("Coll")

	if actor:instanceof(Pawn) then
		-- Play a hit sound
		if self.hit_sound then
			actor.unit:EmitSound(self.hit_sound)
		end

        local sign = 1
        if actor.owner:getAlliance(self.instigator.owner) == Player.ALLIANCE_ALLY then
            sign = -1
        end

		-- Add the grip modifier
		GAME:addModifier(MagnetizeModifier:new {
			pawn = actor,
			time = actor:getDebuffDuration(self.duration, self.instigator),
			sign = sign,
			end_sound = self.end_sound,
            native_mod = self.native_mod,
		})

        log("Added")
	end

	-- destroy
	self:setLifetime(0)
end
