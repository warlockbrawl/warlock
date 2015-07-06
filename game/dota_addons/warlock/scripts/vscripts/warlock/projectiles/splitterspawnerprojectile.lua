SplitterSpawnerProjectile = class(Projectile)

--- Params

--[[        
count = self.spawner_count,

-- Child parameters
child_damage = self.child_damage,
child_radius = self.child_radius,
child_speed = self.child_speed,
child_projectile_effect = self.child_projectile_effect,
child_lifetime = child_lifetime
 --]]

function SplitterSpawnerProjectile:init(def)
    SplitterSpawnerProjectile.super.init(self, def)

    self.lifetime = def.lifetime

    -- Set the correct coll matrix, do not collide with anything
	local coll_mat = { }
	coll_mat[Player.ALLIANCE_SELF] = {}
	coll_mat[Player.ALLIANCE_ALLY] = {}
	coll_mat[Player.ALLIANCE_ENEMY] = {}

	self.collision_components["projectile"].coll_mat = coll_mat
	self.collision_components["projectile"].coll_initiative = -1

    self.count = def.count -- Count of projectiles to be spawned

    -- Grab child parameters
    self.child_damage = def.child_damage
    self.child_radius = def.child_radius
    self.child_speed = def.child_speed
    self.child_projectile_effect = def.child_projectile_effect
    self.child_lifetime = def.child_lifetime
    self.child_hit_sound = def.child_hit_sound

    self.spawned_count = 0 -- How many waves have already been spawned

    -- Set up a task for spawning the projectiles
    self:addTimer {
        time = self.lifetime / self.count,
        periodic = true,
        func = function()
            self:spawnChildren()

            -- Destroy the spawner once enough waves have been spawned
            if self.spawned_count == self.count then
                self:destroy()
            end
        end
    }
end

function SplitterSpawnerProjectile:spawnChildren()
    local dir = self.velocity:Normalized()

    -- Create two symmetric moving child projectiles
    for sign = -1, 1, 2 do
        -- Some factor
        local alpha = self.lifetime * (1 - self.spawned_count / self.count)

        -- Magic? :(
        local dx = (dir.x - sign * dir.y * alpha) / (1 + alpha)
        local dy = (dir.y + sign * dir.x * alpha) / (1 + alpha)
        local child_dir = Vector(dx, dy, 0)

        SplitterChildProjectile:new {
            instigator = self.instigator,
            location = self.location,
            velocity = child_dir * self.child_speed,
            damage = self.child_damage,
            coll_radius = self.child_radius,
            projectile_effect = self.child_projectile_effect,
            lifetime = self.child_lifetime,
            hit_sound = self.child_hit_sound
        }
    end

    -- Increment spawned count
    self.spawned_count = self.spawned_count + 1
end