--- Spell warlock_fireball
Boomerang = Spell:new{id='warlock_boomerang'}

Boomerang.projectile_class = BoomerangProjectile
Boomerang.projectile_effect = 'boomerang_projectile'
Boomerang.hit_sound = "Boomerang.Hit"
Boomerang.radius = 38
Boomerang.hit_effect = "boomerang_hit"

function Boomerang:onCast(cast_info)
	local start = cast_info.caster_actor.location

	local target = cast_info.target

	-- Direction to target
	local dir = target - start
	dir.z = 0
	local dist = dir:Length()
	dir = dir:Normalized()

    -- Prevent division by zero and incorrect directions
    if dist < 1 then
        dist = 1
        dir = Vector(1, 0, 0)
    end

	local damage = cast_info:attribute('damage')
	local radius = cast_info:attribute('radius')
	local projectile_effect = cast_info:attribute('projectile_effect')
	
	-- Calculate max range including range mastery
	local range = cast_info:attribute('range') * cast_info.caster_actor.owner.mastery_factor[Player.MASTERY_RANGE]

	BoomerangProjectile:new{
		instigator	= cast_info.caster_actor,
		coll_radius = radius,
		projectile_effect = projectile_effect,
		damage 		= damage,
		location = start,
		direction = dir,
		distance = math.min(dist, range),
		hit_sound = Boomerang.hit_sound,
		hit_effect = Boomerang.hit_effect
	}
end

-- effects
Effect:register('boomerang_projectile', {
	class 				= ProjectileParticleEffect,
	effect_name 		= "particles/units/heroes/hero_silencer/silencer_glaives_of_wisdom.vpcf"
})

Effect:register('boomerang_hit', {
	class = ParticleEffect,
	effect_name = "particles/units/heroes/hero_sniper/sniper_assassinate_impact_blood.vpcf"
})
