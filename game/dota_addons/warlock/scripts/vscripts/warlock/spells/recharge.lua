--- Spell warlock_grip
Recharge = Spell:new{id='warlock_recharge'}

Recharge.projectile_effect = 'recharge_projectile'
Recharge.radius = 35
Recharge.speed = 900
Recharge.lifetime = 1
Recharge.damage_per_consecutive = 10
Recharge.cast_sound = "Recharge.Cast"
Recharge.hit_sound = "Recharge.Hit" -- Sound played when projectile hits
Recharge.hit_effect = "recharge_hit"
Recharge.refresh_hit_sound = "Recharge.Refresh" -- Sound played when projectile hits
Recharge.refresh_projectile_effect = "recharge_refresh_projectile"
Recharge.consecutive_count = {} -- How many hits in a row an actor has

function Recharge:onCast(cast_info)
	local start = cast_info.caster_actor.location
	local target = cast_info.target

	-- Direction to target
	local dir = target - start
	dir.z = 0
	dir = dir:Normalized()

	cast_info.caster_actor.unit:EmitSound(cast_info:attribute("cast_sound"))

	local dmg = cast_info:attribute("damage") + cast_info:attribute("damage_per_consecutive") * Recharge.getConsecutiveCount(cast_info.caster_actor)

	local proj = RechargeProjectile:new{
		instigator	= 			cast_info.caster_actor,
		damage =				dmg,
		coll_radius = 			cast_info:attribute("radius"),
		projectile_effect = 	cast_info:attribute("projectile_effect"),
		location = 				start,
		velocity = 				dir * cast_info:attribute("speed"),
		lifetime = 				cast_info:attribute("lifetime"),
		hit_sound = 			cast_info:attribute("hit_sound"),
		hit_effect = 			cast_info:attribute("hit_effect"),
		refresh_hit_sound =		cast_info:attribute("refresh_hit_sound"),
		refresh_projectile_effect = cast_info:attribute("refresh_projectile_effect")
	}
end

function Recharge.incrementConsecutiveCount(actor)
	if not Recharge.consecutive_count[actor] then
		Recharge.consecutive_count[actor] = 0
	end

	Recharge.consecutive_count[actor] = Recharge.consecutive_count[actor] + 1
end

function Recharge.resetConsecutiveCount(actor)
	Recharge.consecutive_count[actor] = 0
end

function Recharge.getConsecutiveCount(actor)
	if not Recharge.consecutive_count[actor] then
		Recharge.consecutive_count[actor] = 0
	end

	return Recharge.consecutive_count[actor]
end

-- effects
Effect:register('recharge_projectile', {
	class 				= ProjectileParticleEffect,
	effect_name 		= 'particles/econ/items/templar_assassin/templar_assassin_butterfly/templar_assassin_meld_attack_butterfly.vpcf',
	destruction_sound	= "Recharge.Destroy",
})

Effect:register('recharge_hit', {
	class				= ParticleEffect,
	effect_name			= 'particles/econ/items/templar_assassin/templar_assassin_butterfly/templar_assassin_trap_explosion_shock_butterfly.vpcf'
})

Effect:register('recharge_refresh_projectile', {
	class 				= ProjectileParticleEffect,
	effect_name 		= 'particles/units/heroes/hero_puck/puck_base_attack.vpcf',
})
