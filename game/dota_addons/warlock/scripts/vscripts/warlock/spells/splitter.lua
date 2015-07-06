--- Spell warlock_splitter
Splitter = Spell:new{id='warlock_splitter'}

Splitter.cast_sound = "Splitter.Cast"

-- Main projectile params
Splitter.projectile_class = SplitterProjectile
Splitter.projectile_effect = 'splitter_projectile'
Splitter.radius = 50
Splitter.lifetime = 1.0 -- Time to live
Splitter.speed = 700

-- Spawner params
Splitter.spawner_speed = 250
Splitter.spawner_lifetime = 0.48
Splitter.spawner_count = 4
Splitter.spawner_projectile_effect = 'splitter_spawner_projectile'

-- Child params
Splitter.child_radius = 21
Splitter.child_speed = 600
Splitter.child_lifetime = 1.2
Splitter.child_projectile_effect = 'splitter_child_projectile'
Splitter.child_hit_sound = "Splitter.ChildHit"

function Splitter:onCast(cast_info)
    local actor = cast_info.caster_actor
    local range_mastery_factor = actor.owner.mastery_factor[Player.MASTERY_RANGE]

    local cast_sound = cast_info:attribute('cast_sound')

    -- Main projectile params
    local projectile_class = cast_info:attribute('projectile_class')
	local radius = cast_info:attribute('radius')
	local projectile_effect = cast_info:attribute('projectile_effect')
	local lifetime = cast_info:attribute('lifetime') * range_mastery_factor
	local speed = cast_info:attribute('speed')

    -- Spawner params
    local spawner_speed = cast_info:attribute('spawner_speed')
    local spawner_lifetime = cast_info:attribute('spawner_lifetime')
    local spawner_count = cast_info:attribute('spawner_count')
    local spawner_projectile_effect = cast_info:attribute('spawner_projectile_effect')

    -- Child params
    local child_damage = cast_info:attribute('damage')
    local child_radius = cast_info:attribute('child_radius')
    local child_speed = cast_info:attribute('child_speed')
    local child_lifetime = cast_info:attribute('child_lifetime') * range_mastery_factor
    local child_projectile_effect = cast_info:attribute('child_projectile_effect')
    local child_hit_sound = cast_info:attribute('child_hit_sound')

	-- Direction to target
	local start = actor.location
    local delta = cast_info.target - start
    delta.z = 0

    -- Explode earlier if the target is closer than the max lifetime
    lifetime = math.min(lifetime, delta:Length() / speed)

	local dir = delta:Normalized()

	projectile_class:new {
		instigator = actor,
        lifetime = lifetime,
		coll_radius = radius,
		projectile_effect = projectile_effect,
		location = start,
		velocity = speed * dir,
        
        -- Spawner parameters
        spawner_speed = spawner_speed,
        spawner_lifetime = spawner_lifetime,
        spawner_count = spawner_count,
        spawner_projectile_effect = spawner_projectile_effect,

        -- Child paramters
        child_damage = child_damage,
        child_radius = child_radius,
        child_speed = child_speed,
        child_projectile_effect = child_projectile_effect,
        child_lifetime = child_lifetime,
        child_hit_sound = child_hit_sound
	}

    -- Play the cast sound
    if actor.unit and cast_sound then
        actor.unit:EmitSound(cast_sound)
    end
end

-- effects
Effect:register('splitter_projectile', {
	class = ProjectileParticleEffect,
	effect_name = "particles/units/heroes/hero_skywrath_mage/skywrath_mage_arcane_bolt.vpcf",
	destruction_sound = "Splitter.Split"
})

Effect:register('splitter_spawner_projectile', {
	class = ProjectileParticleEffect,
	effect_name = "particles/units/heroes/hero_skywrath_mage/skywrath_mage_concussive_shot.vpcf"
})

Effect:register('splitter_child_projectile', {
	class = ProjectileParticleEffect,
	effect_name = "particles/units/heroes/hero_skywrath_mage/skywrath_mage_base_attack.vpcf"
})