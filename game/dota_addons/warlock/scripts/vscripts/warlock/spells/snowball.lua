--- Spell warlock_snowball
Snowball = Spell:new{id='warlock_snowball'}

Snowball.projectile_class 	= SnowballProjectile
Snowball.projectile_effect 	= 'snowball_projectile'
Snowball.projectile_speed = 400.0
Snowball.cast_sound = "Snowball.Cast"
Snowball.explode_effect = "snowball_explode"
Snowball.dps_effect = "snowball_dps"

function Snowball:onCast(cast_info)
	cast_info.caster_actor.unit:EmitSound(cast_info:attribute("cast_sound"))
	
	local start = cast_info.caster_actor.location

	local target = cast_info.target

	-- Direction to target
	local dir = target - start
	dir.z = 0
	dir = dir:Normalized()

	local projectile_speed = cast_info:attribute('projectile_speed')
	local damage = cast_info:attribute('damage')
    local damage_min = cast_info:attribute('damage_min')
    local damage_max = cast_info:attribute('damage_max')
	local range = cast_info:attribute('range')
	local projectile_effect = cast_info:attribute('projectile_effect')
    local coll_radius = cast_info:attribute('coll_radius')
    local explode_effect = cast_info:attribute('explode_effect')
    local radius = cast_info:attribute('radius')

	SnowballProjectile:new{
		instigator = cast_info.caster_actor,
		coll_radius = coll_radius,
		velocity = dir * projectile_speed,
		lifetime = range / projectile_speed,
		projectile_effect = projectile_effect,
        explode_effect = explode_effect,
		damage = damage,
        damage_min = damage_min,
        damage_max = damage_max,
        knockback_factor = 0.8,
        radius = radius,
        dps_effect = Snowball.dps_effect
	}
end

-- effects
Effect:register('snowball_projectile', {
	class 				= ModelEffect,
	model_name 		    = 'models/particle/snowball.vmdl',
    scale               = 0.4,
	destruction_sound 	= "Snowball.Explode"
})

Effect:register('snowball_explode', {
	class = ParticleEffect,
	effect_name = 'particles/econ/items/crystal_maiden/crystal_maiden_cowl_of_ice/maiden_crystal_nova_cowlofice.vpcf'
})

Effect:register('snowball_dps', {
    class = ParticleEffect,
    effect_name = 'particles/units/heroes/hero_crystalmaiden/maiden_crystal_nova.vpcf',
    destruction_sound = "Snowball.DPS"
})
