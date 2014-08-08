--- Spell warlock_swap
Swap = Spell:new{id='warlock_swap'}

Swap.projectile_class = SwapProjectile
Swap.projectile_effect = 'swap_projectile'
Swap.radius = 40
Swap.speed = 1983
Swap.lifetime = 0.4706
Swap.swap_sound = "Swap.Swap"
Swap.swap_effect = "swap_effect"

function Swap:onCast(cast_info)
	local start = cast_info.caster_actor.location

	local target = cast_info.target

	-- Direction to target
	local dir = target - start
	dir.z = 0
	local dist = dir:Length()
	dir = dir:Normalized()

	local speed = cast_info:attribute("speed")
	local lifetime = math.min(dist / speed, cast_info:attribute("lifetime"))

	local proj = SwapProjectile:new{
		instigator	= cast_info.caster_actor,
		coll_radius = cast_info:attribute("radius"),
		projectile_effect = cast_info:attribute("projectile_effect"),
		location = start,
		velocity = dir * speed,
		lifetime = lifetime,
		end_time = GAME:time() + lifetime,
		swap_sound = cast_info:attribute("swap_sound"),
		swap_effect = cast_info:attribute("swap_effect")
	}
end

-- effects
Effect:register('swap_projectile', {
	class 				= ProjectileParticleEffect,
	effect_name 		= "particles/units/heroes/hero_chaos_knight/chaos_knight_chaos_bolt.vpcf"
})

Effect:register('swap_effect', {
	class 				= ProjectileParticleEffect,
	effect_name 		= "particles/units/heroes/hero_nevermore/nevermore_shadowraze.vpcf"
})