SnowballProjectile = class(Projectile)
SnowballProjectile.damage_period = 0.5

function SnowballProjectile:init(def)
    SnowballProjectile.super.init(self, def)

    self.damage = def.damage
    self.damage_min = def.damage_min
    self.damage_max = def.damage_max
    self.knockback_factor = def.knockback_factor
    self.radius = def.radius

    self.explode_effect = def.explode_effect

    self.dps_effect = def.dps_effect

    self.pitch = 0
    self.roll = 0
end

function SnowballProjectile:onDestroy()
    SnowballProjectile.super.onDestroy(self)
    self.effect = Effect:create(self.explode_effect, { location = self.location })

    self.instigator:damageArea(self.location, self.radius, { 
		amount_min = self.damage_min,
        amount_max = self.damage_max,
		knockback_factor = self.knockback_factor,
        radius = self.radius
	})
end

function SnowballProjectile:receiveDamage(dmg_info)
	-- Ignore incoming damage
end

function SnowballProjectile:onCollision(coll_info, cc)
    SnowballProjectile.super.onCollision(self, coll_info, cc)

    -- On pillar hit
    if coll_info.actor:instanceof(Pawn) then
        -- Drag hit target with it, compensating for its velocity too
        local direction = self.velocity:Normalized()
        local c = 425 - direction:Dot(coll_info.actor.velocity)
        if c > 0 then
            coll_info.actor.velocity = coll_info.actor.velocity + c * direction
        end

        -- Add buff that slows and deals damage after expiring
        if not coll_info.actor:hasModifierOfType(SnowballModifier) then
            GAME:addModifier(SnowballModifier:new {
			    pawn = coll_info.actor,
                instigator = self.instigator,
			    speed_bonus_abs = -100,
			    time = SnowballProjectile.damage_period,
			    end_damage = self.damage * SnowballProjectile.damage_period,
                end_sound = self.dps_sound,
                effect = self.dps_effect
		    })
        end

    elseif coll_info.actor:instanceof(Obstacle) then
        self:destroy()

        coll_info.actor:receiveDamage {
		    source	= self.instigator or self,
		    amount	= self.damage_max
	    }
    end
end

function SnowballProjectile:onPostTick(dt)
    SnowballProjectile.super.onPostTick(self, dt)

    -- Rotate the snowball in the direction it is rolling
    local dir = self.velocity:Normalized()
    self.pitch = self.pitch + 1000 * dt * dir.y
    self.roll = self.roll + 1000 * dt * dir.x
    self.effect:setAngles(self.pitch, 0, self.roll)
end
