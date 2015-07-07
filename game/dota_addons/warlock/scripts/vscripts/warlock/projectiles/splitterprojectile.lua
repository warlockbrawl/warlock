SplitterProjectile = class(Projectile)

--- Params

--[[        
-- Spawner parameters
spawner_speed = spawned_speed,
spawner_lifetime = spawner_lifetime,
spawner_count = spawner_count,
spawner_projectile_effect = spawner_projectile_effect,

-- Child paramters
child_damage = child_damage,
child_radius = child_radius,
child_speed = child_speed,
child_projectile_effect = child_projectile_effect,
child_lifetime = child_lifetime
 --]]

function SplitterProjectile:init(def)
    SplitterProjectile.super.init(self, def)

    -- Grab spawner parameters
    self.spawner_speed = def.spawner_speed
    self.spawner_lifetime = def.spawner_lifetime
    self.spawner_count = def.spawner_count
    self.spawner_projectile_effect = def.spawner_projectile_effect

    -- Grab child parameters
    self.child_damage = def.child_damage
    self.child_radius = def.child_radius
    self.child_speed = def.child_speed
    self.child_projectile_effect = def.child_projectile_effect
    self.child_lifetime = def.child_lifetime
    self.child_hit_sound = def.child_hit_sound

    self.offset = Vector(0, 0, 0)
end

function SplitterProjectile:onDestroy()
    SplitterProjectile.super.onDestroy(self)

    -- Spawn the spawner

    SplitterSpawnerProjectile:new {
        instigator = self.instigator,
        location = self.location + self.offset, -- Spawn it offset so it doesnt instantly die to pillars
        velocity = self.velocity:Normalized() * self.spawner_speed,
        lifetime = self.spawner_lifetime,
        count = self.spawner_count,
        projectile_effect = self.spawner_projectile_effect,

        -- Child parameters
        child_damage = self.child_damage,
        child_radius = self.child_radius,
        child_speed = self.child_speed,
        child_projectile_effect = self.child_projectile_effect,
        child_lifetime = self.child_lifetime,
        child_hit_sound = self.child_hit_sound
    }
end

function SplitterProjectile:onCollision(coll_info, cc)
    SplitterProjectile.super.onCollision(self, coll_info, cc)

    -- On pillar hit
    if coll_info.actor:instanceof(Obstacle) then
        -- Revert the velocity so the spawn direction is reversed spawn
        self.velocity = -self.velocity

        -- Set the spawner offset so children dont instantly die when they collide
        self.offset = -coll_info.hit_normal * ((coll_info.other_cc.radius + cc.radius + 10) - coll_info.hit_distance)
    end

    self:destroy()
end
