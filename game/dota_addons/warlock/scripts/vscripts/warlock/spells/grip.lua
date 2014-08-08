--- Spell warlock_grip
Grip = Spell:new{id='warlock_grip'}

Grip.projectile_class = GripProjectile
Grip.projectile_effect = 'grip_projectile'
Grip.radius = 39
Grip.speed = 1000
Grip.lifetime = 1.1
Grip.hit_sound = "Grip.Hit" -- Sound played when projectile hits
Grip.grip_mod = "modifier_ember_spirit_searing_chains" -- Modifier attached to hit unit
Grip.end_sound = "Grip.End" -- Sound played when effect ends

function Grip:onCast(cast_info)
	local start = cast_info.caster_actor.location
	local target = cast_info.target

	-- Direction to target
	local dir = target - start
	dir.z = 0
	dir = dir:Normalized()

	local proj = GripProjectile:new{
		instigator	= 			cast_info.caster_actor,
		coll_radius = 			cast_info:attribute("radius"),
		projectile_effect = 	cast_info:attribute("projectile_effect"),
		location = 				start,
		velocity = 				dir * cast_info:attribute("speed"),
		lifetime = 				cast_info:attribute("lifetime"),
		hit_sound = 			cast_info:attribute("hit_sound"),
		grip_mod = 				cast_info:attribute("grip_mod"),
		end_sound = 			cast_info:attribute("end_sound"),
		duration = 				cast_info:attribute("duration"),
		dp_gain = 				cast_info:attribute("dp_gain")
	}
end

-- effects
Effect:register('grip_projectile', {
	class 				= ProjectileParticleEffect,
	effect_name 		= 'particles/units/heroes/hero_nevermore/nevermore_base_attack.vpcf',
	destruction_sound 	= "Grip.ProjectileDestroyed"
})
