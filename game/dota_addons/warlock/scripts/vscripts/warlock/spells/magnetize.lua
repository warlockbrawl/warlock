--- Spell warlock_grip
Magnetize = Spell:new{id='warlock_magnetize'}

Magnetize.projectile_class = MagnetizeProjectile
Magnetize.projectile_effect = 'magnetize_projectile'
Magnetize.radius = 39
Magnetize.speed = 1000
Magnetize.lifetime = 1.1
Magnetize.hit_sound = "Grip.Hit" -- Sound played when projectile hits
Magnetize.end_sound = "Grip.End" -- Sound played when effect ends

function Magnetize:onCast(cast_info)
	local start = cast_info.caster_actor.location
	local target = cast_info.target

	-- Direction to target
	local dir = target - start
	dir.z = 0
	dir = dir:Normalized()

	local proj = MagnetizeProjectile:new{
		instigator	= 			cast_info.caster_actor,
		coll_radius = 			cast_info:attribute("radius"),
		projectile_effect = 	cast_info:attribute("projectile_effect"),
		location = 				start,
		velocity = 				dir * cast_info:attribute("speed"),
		lifetime = 				cast_info:attribute("lifetime"),
		hit_sound = 			cast_info:attribute("hit_sound"),
		end_sound = 			cast_info:attribute("end_sound"),
		duration = 				cast_info:attribute("duration")
	}
end

-- effects
Effect:register('magnetize_projectile', {
	class 				= ProjectileParticleEffect,
	effect_name 		= 'particles/units/heroes/hero_nevermore/nevermore_base_attack.vpcf',
	destruction_sound 	= "Grip.ProjectileDestroyed"
})
