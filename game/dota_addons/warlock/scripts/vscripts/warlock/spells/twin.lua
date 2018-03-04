--- Spell warlock_fireball
Twin = Spell:new{id='warlock_twin'}

Twin.projectile_class = TwinProjectile
Twin.projectile_effect = 'twin_projectile'
Twin.hit_sound = "Twin.Hit"
Twin.radius = 35
Twin.hit_effect = "twin_hit"
Twin.ellipse_area = 450 * 450
Twin.projectile_speed = 1000
Twin.cast_sound = "Twin.Cast"

function Twin:onCast(cast_info)
	local start = cast_info.caster_actor.location
	local area = cast_info:attribute("ellipse_area")

	local target = cast_info.target

	-- Direction to target
	local dir = target - start
	dir.z = 0
	local dist = dir:Length()
	dir = dir:Normalized()

	local damage = cast_info:attribute('damage')
	local radius = cast_info:attribute('radius')
	local projectile_effect = cast_info:attribute('projectile_effect')

	-- Calculate max range including range mastery
	local range = cast_info:attribute('range') * cast_info.caster_actor.owner.mastery_factor[Player.MASTERY_RANGE]

	-- Set min distance so the horizontal range is also at most "range"
	local min_dist = max(10, 2 * area / (math.pi * range))
    if dist < min_dist then
        dist = min_dist
    end

	local actual_target = start + math.min(dist, range) * dir

	cast_info:attribute('projectile_class'):new{
		instigator	= cast_info.caster_actor,
		coll_radius = radius,
		projectile_effect = projectile_effect,
		damage 		= damage,
		location = start,
		target = actual_target,
		hit_sound = cast_info:attribute("hit_sound"),
		hit_effect = cast_info:attribute("hit_effect"),
		ellipse_area = area,
		speed = cast_info:attribute("projectile_speed"),
		ellipse_sign = 1
	}

	cast_info:attribute('projectile_class'):new{
		instigator	= cast_info.caster_actor,
		coll_radius = radius,
		projectile_effect = projectile_effect,
		damage 		= damage,
		location = start,
		target = actual_target,
		hit_sound = cast_info:attribute("hit_sound"),
		hit_effect = cast_info:attribute("hit_effect"),
		ellipse_area = cast_info:attribute("ellipse_area"),
		speed = cast_info:attribute("projectile_speed"),
		ellipse_sign = -1
	}

	-- Play the cast sound
	local cast_sound = cast_info:attribute("cast_sound")
	if cast_info.caster_actor.unit and cast_sound then
		cast_info.caster_actor.unit:EmitSound(cast_sound)
	end
end

-- effects
Effect:register('twin_projectile', {
	class = ProjectileParticleEffect,
	effect_name = "particles/units/heroes/hero_dark_willow/dark_willow_base_attack.vpcf",
	scale = 1.2,
})

Effect:register('twin_hit', {
	class		= ParticleEffect,
	effect_name	= "particles/units/heroes/hero_dark_willow/dark_willow_wisp_aoe_cast_glow.vpcf",
	scale = 1.2,
})