--- Spell warlock_fireball
Gravity = Spell:new{id='warlock_gravity'}

Gravity.projectile_class 	= GravityProjectile
Gravity.projectile_effect 	= 'gravity_projectile'
Gravity.projectile_speed = 400.0
Gravity.cast_sound = "Gravity.Cast"

function Gravity:onCast(cast_info)
	cast_info.caster_actor.unit:EmitSound(cast_info:attribute("cast_sound"))
	
	local start = cast_info.caster_actor.location

	target = cast_info.target

	-- Direction to target
	local dir = target - start
	dir.z = 0
	dir = dir:Normalized()

	local projectile_speed = cast_info:attribute('projectile_speed')
	local damage = cast_info:attribute('damage')
	local range = cast_info:attribute('range')
	local projectile_effect = cast_info:attribute('projectile_effect')
	local strength = cast_info:attribute('strength')

	GravityProjectile:new{
		instigator = cast_info.caster_actor,
		coll_radius = 25,
		velocity = dir * projectile_speed,
		lifetime = range / projectile_speed,
		projectile_effect = projectile_effect,
		damage = damage,
		strength = strength
	}
end

-- effects
Effect:register('gravity_projectile', {
	class 				= ProjectileParticleEffect,
	effect_name 		= 'particles/units/heroes/hero_lich/lich_base_attack.vpcf',
	destruction_sound 	= "Gravity.Destroyed"
	})
	--'lich_chain_frost',
