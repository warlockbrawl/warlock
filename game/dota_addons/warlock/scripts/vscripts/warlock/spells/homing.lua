--- Spell warlock_homing
Homing = Spell:new{id='warlock_homing'}

Homing.projectile_class 	= HomingProjectile
Homing.projectile_speed		= 1000
Homing.projectile_effect 	= 'homing_projectile'
Homing.radius 				= 30
Homing.explode_effect		= 'homing_explode'
Homing.explode_radius		= 200 * 1.46
Homing.burnout_effect		= 'homing_burnout'

function Homing:onCast(cast_info)
	local start = cast_info.caster_actor.location
	local target = cast_info.target

	-- Direction to target
	local dir = target - start
	dir.z = 0
	dir = dir:Normalized()
	
	local offset = 64 * dir --pawnsize + homingsize + 4

	local projectile_speed = cast_info:attribute('projectile_speed')
	local damage = cast_info:attribute('damage')
	local range = cast_info:attribute('range')
	local radius = cast_info:attribute('radius')
	local projectile_effect = cast_info:attribute('projectile_effect')
	
	-- Velocity along cast dir
	local part_vel = cast_info.caster_actor.velocity:Dot(dir)

	local proj = HomingProjectile:new {
		instigator		= cast_info.caster_actor,
		location		= start + offset,
		velocity		= dir * (800 + part_vel),
		coll_radius		= radius,
		lifetime		= range / projectile_speed,
		projectile_effect = projectile_effect,
		target			= target,
		damage 			= damage,
		speed			= projectile_speed,
		explode_effect	= cast_info:attribute('explode_effect'),
		explode_radius	= cast_info:attribute('explode_radius'),
		burnout_effect	= cast_info:attribute('burnout_effect')
	}
end

-- effects
Effect:register('homing_projectile', {
	class 				= ProjectileParticleEffect,
	effect_name 		= 'particles/homing/wisp_base_attack.vpcf',
	destruction_sound 	= "Homing.Destroy",
	destruction_effect	= "homing_destroy"
})

Effect:register('homing_destroy', {
	class		= ParticleEffect,
	effect_name	= "particles/units/heroes/hero_wisp/wisp_base_attack_explosion.vpcf"
})

Effect:register('homing_explode', {
	class		= ParticleEffect,
	effect_name	= "particles/units/heroes/hero_wisp/wisp_guardian_explosion.vpcf"
})

Effect:register('homing_burnout', {
	class		= ParticleEffect,
	effect_name	= 'particles/units/heroes/hero_doom_bringer/doom_bringer_lvl_death.vpcf'
})
