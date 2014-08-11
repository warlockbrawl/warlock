--- Spell warlock_drain
Drain = Spell:new{id='warlock_drain'}

Drain.projectile_class 			= DrainProjectile
Drain.projectile_speed 			= 700
Drain.changed_speed				= 600
Drain.projectile_effect 		= 'drain_projectile'
Drain.heal_projectile_effect	= 'drain_heal_projectile'
Drain.radius 					= 24.5
Drain.range						= 850
Drain.extra_time				= 1.2 -- lifetime after direction change
Drain.ally_mod					= 'modifier_chen_test_of_faith_teleport'
Drain.enemy_mod					= 'modifier_bristleback_viscous_nasal_goo'
Drain.heal_hit_sound			= 'Drain.HealHit'
Drain.hit_sound					= 'Drain.Hit'

--- In txt
-- damage
-- buff_duration

function Drain:onCast(cast_info)
	local actor = cast_info.caster_actor
	local start = actor.location

	local target = cast_info.target

	-- Direction to target
	local dir = target - start
	dir.z = 0
	local dist = dir:Length()
	dir = dir:Normalized()


	local damage = cast_info:attribute('damage')
	local buff_duration = cast_info:attribute('buff_duration')
	local changed_speed = cast_info:attribute('changed_speed')
	local projectile_effect = cast_info:attribute('projectile_effect')
	local coll_radius = cast_info:attribute('coll_radius')
	
	-- Calculate range, lifetime etc.
	local projectile_speed = cast_info:attribute('projectile_speed')
	local range = math.min(dist, cast_info:attribute('range') * actor.owner.mastery_factor[Player.MASTERY_RANGE]) -- range to turn
	local extra_time = cast_info:attribute('extra_time') * actor.owner.mastery_factor[Player.MASTERY_RANGE] -- time after turn
	local change_time = range / projectile_speed -- time after which drain turns
	local lifetime = change_time + extra_time -- total lifetime

	DrainProjectile:new {
		instigator = cast_info.caster_actor,
		coll_radius = coll_radius,
		velocity = dir * projectile_speed,
		lifetime = lifetime,
		projectile_effect = projectile_effect,
		extra_time = extra_time,
		damage = damage,
		buff_duration = buff_duration,
		changed_speed = changed_speed,
		ally_mod = cast_info:attribute('ally_mod'),
		enemy_mod = cast_info:attribute('enemy_mod'),
		heal_hit_sound = cast_info:attribute('heal_hit_sound'),
		hit_sound = cast_info:attribute('hit_sound'),
		heal_projectile_effect = cast_info:attribute('heal_projectile_effect'),
		no_range_mastery = true -- Already calculated before
	}
end

-- effects
Effect:register('drain_projectile', {
	class 				= ProjectileParticleEffect,
	effect_name 		= 'particles/units/heroes/hero_dazzle/dazzle_poison_touch.vpcf'
})

Effect:register('drain_heal_projectile', {
	class 				= ProjectileParticleEffect,
	effect_name 		= 'particles/units/heroes/hero_venomancer/venomancer_base_attack.vpcf'
})
